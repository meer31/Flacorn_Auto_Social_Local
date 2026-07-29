import { onCall, HttpsError } from "firebase-functions/v2/https";
import { z } from "zod";
import { requireAuth } from "../middleware/authGuard";
import { db } from "../config/firebase";
import { decrementUsage } from "../subscriptions/incrementUsage";
import { withUpdateTimestamp } from "../utils/timestamps";
import { env } from "../config/env";

const InputSchema = z.object({
  scheduledPostId: z.string().min(1),
});

/**
 * cancelScheduledPost — HTTPS Callable (PDF Section 14).
 * Marks a pending/draft post as cancelled. Does not delete the document
 * (kept for history/analytics), and frees up one slot in the plan's
 * scheduledPostLimit usage counter.
 */
export const cancelScheduledPost = onCall(
  { region: env.functionsRegion, timeoutSeconds: 15 },
  async (request) => {
    const uid = requireAuth(request);
    const { scheduledPostId } = InputSchema.parse(request.data);

    const ref = db.doc(`users/${uid}/scheduledPosts/${scheduledPostId}`);
    const snap = await ref.get();
    if (!snap.exists) {
      throw new HttpsError("not-found", "Scheduled post not found.");
    }

    const current = snap.data();
    if (current?.status === "sent") {
      throw new HttpsError("failed-precondition", "Cannot cancel a post that was already published.");
    }

    await ref.update(withUpdateTimestamp({ status: "cancelled" }));

    if (current?.status === "pending" || current?.status === "draft") {
      await decrementUsage(uid, "scheduledPostsUsed");
    }

    return { success: true };
  }
);
