import { onCall, HttpsError } from "firebase-functions/v2/https";
import { z } from "zod";
import { requireAuth } from "../middleware/authGuard";
import { db } from "../config/firebase";
import { withUpdateTimestamp } from "../utils/timestamps";
import { env } from "../config/env";

const InputSchema = z.object({
  scheduledPostId: z.string().min(1),
  captionText: z.string().optional(),
  hashtags: z.array(z.string()).optional(),
  mediaUrl: z.string().optional(),
  scheduledAt: z.string().optional(),
  timezone: z.string().optional(),
});

/**
 * updateScheduledPost — HTTPS Callable (PDF Section 14).
 * Only allowed while status is "draft" or "pending" — posts already
 * "sent" or "failed" should be edited via a new post, not mutated in place.
 */
export const updateScheduledPost = onCall(
  { region: env.functionsRegion, timeoutSeconds: 15 },
  async (request) => {
    const uid = requireAuth(request);
    const { scheduledPostId, ...updates } = InputSchema.parse(request.data);

    const ref = db.doc(`users/${uid}/scheduledPosts/${scheduledPostId}`);
    const snap = await ref.get();
    if (!snap.exists) {
      throw new HttpsError("not-found", "Scheduled post not found.");
    }

    const current = snap.data();
    if (current?.status !== "draft" && current?.status !== "pending") {
      throw new HttpsError(
        "failed-precondition",
        "Only draft or pending posts can be edited."
      );
    }

    await ref.update(withUpdateTimestamp(updates));
    return { success: true };
  }
);
