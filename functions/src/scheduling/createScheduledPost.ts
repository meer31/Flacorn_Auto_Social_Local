import { onCall } from "firebase-functions/v2/https";
import { z } from "zod";
import { requireAuth } from "../middleware/authGuard";
import { requireWithinUsageLimit } from "../middleware/planGuard";
import { enforceRateLimit } from "../middleware/rateLimiter";
import { incrementUsage } from "../subscriptions/incrementUsage";
import { db, FieldValue } from "../config/firebase";
import { env } from "../config/env";

const InputSchema = z.object({
  platform: z.enum(["instagram", "facebook", "twitter", "linkedin"]),
  socialAccountRef: z.string().min(1),
  captionText: z.string().min(1),
  hashtags: z.array(z.string()).default([]),
  mediaUrl: z.string().optional(),
  scheduledAt: z.string(), // ISO 8601
  timezone: z.string().default("UTC"),
});

/**
 * createScheduledPost — HTTPS Callable (PDF Section 14: Scheduling and Auto-Publishing).
 * Enforces the plan's scheduledPostLimit (unlimited for Pro/Agency).
 */
export const createScheduledPost = onCall(
  { region: env.functionsRegion, timeoutSeconds: 20 },
  async (request) => {
    const uid = requireAuth(request);
    const input = InputSchema.parse(request.data);

    await enforceRateLimit(uid, "scheduling", env.rateLimits.schedulingPerMinute, 60);
    await requireWithinUsageLimit(uid, "scheduledPostLimit", "scheduledPostsUsed");

    const ref = db.collection(`users/${uid}/scheduledPosts`).doc();
    await ref.set({
      ...input,
      status: "pending",
      externalPostId: null,
      errorMessage: null,
      retryCount: 0,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    await incrementUsage(uid, "scheduledPostsUsed");

    return { scheduledPostId: ref.id };
  }
);
