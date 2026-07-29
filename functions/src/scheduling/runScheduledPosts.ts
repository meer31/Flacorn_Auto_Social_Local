import { onSchedule } from "firebase-functions/v2/scheduler";
import { db, FieldValue, Timestamp } from "../config/firebase";
import { env } from "../config/env";
import { decryptToken } from "../utils/encryption";
import { refreshTokenIfNeededInternal } from "../social-oauth/refreshTokenIfNeeded";
import { getPublisher } from "./publishers";
import { requirePlanFeatureForUser } from "../subscriptions/planFeatureHelper";
import { writeAuditLog } from "../utils/auditLog";

const MAX_RETRIES = 3;

/**
 * runScheduledPosts — Scheduled Function (PDF Section 14: Backend Worker).
 *
 * Cloud Scheduler triggers this every 1-5 minutes (configured below at
 * every 2 minutes). Implements the worker logic exactly as specified:
 *   1. Find scheduled posts where scheduledAt <= now and status = pending
 *   2. Check subscription is active
 *   3. Check social account token is valid
 *   4. Refresh token if needed
 *   5. Publish to correct platform
 *   6. Save externalPostId
 *   7. Update status to sent
 *   8. If failure, update status to failed and save errorMessage
 *   9. Retry failed posts according to retry rules
 *
 * Uses a Firestore collectionGroup query across all users'
 * `scheduledPosts` subcollections.
 */
export const runScheduledPosts = onSchedule(
  {
    schedule: "every 2 minutes",
    region: env.functionsRegion,
    timeoutSeconds: 540,
    memory: "512MiB",
    retryCount: 0, // we handle our own per-post retries; don't re-run the whole batch on failure
  },
  async () => {
    const now = Timestamp.now();

    const duePosts = await db
      .collectionGroup("scheduledPosts")
      .where("status", "==", "pending")
      .where("scheduledAt", "<=", now.toDate().toISOString())
      .limit(200) // batch size guard per invocation
      .get();

    if (duePosts.empty) {
      return;
    }

    for (const postDoc of duePosts.docs) {
      const userId = postDoc.ref.parent.parent?.id;
      if (!userId) continue;

      const post = postDoc.data() as {
        platform: "instagram" | "facebook" | "twitter" | "linkedin";
        socialAccountRef: string;
        captionText: string;
        hashtags: string[];
        mediaUrl?: string;
        retryCount: number;
      };

      try {
        // 2. Subscription must be active (any plan gates general publishing).
        const subSnap = await db.doc(`subscriptions/${userId}`).get();
        const subStatus = subSnap.data()?.status;
        if (subStatus !== "active" && subStatus !== "trialing") {
          await postDoc.ref.update({
            status: "failed",
            errorMessage: "Subscription is not active. Publishing paused until billing is resolved.",
            updatedAt: FieldValue.serverTimestamp(),
          });
          continue;
        }

        // 3 & 4. Validate / refresh the social account token.
        const { needsReconnect } = await refreshTokenIfNeededInternal(userId, post.socialAccountRef);
        if (needsReconnect) {
          await postDoc.ref.update({
            status: "needs_reconnect",
            errorMessage: "Social account token expired and could not be refreshed. Please reconnect.",
            updatedAt: FieldValue.serverTimestamp(),
          });
          continue;
        }

        const accountSnap = await db
          .doc(`users/${userId}/socialAccounts/${post.socialAccountRef}`)
          .get();
        const accountData = accountSnap.data();
        if (!accountData || accountData.connectionStatus !== "connected") {
          await postDoc.ref.update({
            status: "needs_reconnect",
            errorMessage: "Social account is not connected.",
            updatedAt: FieldValue.serverTimestamp(),
          });
          continue;
        }

        // 5. Publish.
        const publisher = getPublisher(post.platform);
        const accessTokenPlain = decryptToken(accountData.accessTokenEncrypted);
        const result = await publisher.publish({
          accessTokenPlain,
          accountIdFromPlatform: accountData.accountIdFromPlatform,
          captionText: post.captionText,
          hashtags: post.hashtags ?? [],
          mediaUrl: post.mediaUrl,
        });

        // 6 & 7. Save externalPostId, mark sent.
        await postDoc.ref.update({
          status: "sent",
          externalPostId: result.externalPostId,
          errorMessage: null,
          updatedAt: FieldValue.serverTimestamp(),
        });

        await writeAuditLog({
          userId,
          action: "post.published",
          resourceType: "scheduledPost",
          resourceId: postDoc.id,
        });

        // Weekly report / AR upsell nudge could be triggered here (Phase 2).
        void requirePlanFeatureForUser; // referenced to avoid unused-import lint in minimal builds
      } catch (err) {
        // 8 & 9. Failure handling + retry policy.
        const retryCount = (post.retryCount ?? 0) + 1;
        const errorMessage = err instanceof Error ? err.message : "Unknown publishing error.";

        if (retryCount >= MAX_RETRIES) {
          await postDoc.ref.update({
            status: "failed",
            errorMessage,
            retryCount,
            updatedAt: FieldValue.serverTimestamp(),
          });
          await writeAuditLog({
            userId,
            action: "post.publish_failed",
            resourceType: "scheduledPost",
            resourceId: postDoc.id,
          });
        } else {
          // Leave status as "pending" so the next run retries it, but push
          // scheduledAt forward a few minutes to avoid a tight retry loop.
          const nextAttempt = new Date(Date.now() + retryCount * 5 * 60 * 1000);
          await postDoc.ref.update({
            errorMessage,
            retryCount,
            scheduledAt: nextAttempt.toISOString(),
            updatedAt: FieldValue.serverTimestamp(),
          });
        }
      }
    }
  }
);
