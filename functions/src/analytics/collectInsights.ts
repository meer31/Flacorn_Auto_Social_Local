import { onSchedule } from "firebase-functions/v2/scheduler";
import { db, FieldValue } from "../config/firebase";
import { env } from "../config/env";
import { decryptToken } from "../utils/encryption";
import { getInsightCollector } from "./collectors";
import { calculateEngagementRate } from "./calculateEngagementRate";

/**
 * collectInsights — Scheduled Function (PDF Section 15).
 * Runs daily and fetches insights for every "sent" scheduled post from the
 * last 30 days (platforms typically stop returning fresh insights after that
 * window anyway), writing normalized rows to postInsights/.
 */
export const collectInsights = onSchedule(
  { schedule: "0 6 * * *", timeZone: "UTC", region: env.functionsRegion, timeoutSeconds: 540 },
  async () => {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const sentPosts = await db
      .collectionGroup("scheduledPosts")
      .where("status", "==", "sent")
      .where("updatedAt", ">=", thirtyDaysAgo)
      .limit(500)
      .get();

    for (const postDoc of sentPosts.docs) {
      const userId = postDoc.ref.parent.parent?.id;
      if (!userId) continue;

      const post = postDoc.data() as {
        platform: "instagram" | "facebook" | "twitter" | "linkedin";
        socialAccountRef: string;
        externalPostId: string;
      };
      if (!post.externalPostId) continue;

      try {
        const accountSnap = await db
          .doc(`users/${userId}/socialAccounts/${post.socialAccountRef}`)
          .get();
        const accountData = accountSnap.data();
        if (!accountData || accountData.connectionStatus !== "connected") continue;

        const collector = getInsightCollector(post.platform);
        const accessTokenPlain = decryptToken(accountData.accessTokenEncrypted);
        const metrics = await collector.fetchInsights(accessTokenPlain, post.externalPostId);
        const engagementRate = calculateEngagementRate(metrics);

        await db.collection(`users/${userId}/postInsights`).add({
          platform: post.platform,
          socialAccountRef: post.socialAccountRef,
          scheduledPostRef: postDoc.id,
          externalPostId: post.externalPostId,
          ...metrics,
          engagementRate,
          fetchedAt: FieldValue.serverTimestamp(),
        });
      } catch (err) {
        // Log and continue — one platform failure shouldn't block the whole batch.
        console.error(`collectInsights: failed for post ${postDoc.id}`, err);
      }
    }
  }
);
