import { onCall } from "firebase-functions/v2/https";
import { z } from "zod";
import { requireAuth } from "../middleware/authGuard";
import { requirePlanFeature, requireWithinUsageLimit } from "../middleware/planGuard";
import { enforceRateLimit } from "../middleware/rateLimiter";
import { generateJson } from "./aiService";
import { buildReviewToPostPrompt } from "./promptTemplates";
import { env } from "../config/env";
import { db, FieldValue } from "../config/firebase";

const InputSchema = z.object({
  reviewText: z.string().min(5),
  businessType: z.string().min(1),
  platform: z.string().min(1),
  tone: z.string().min(1),
  cta: z.string().optional(),
});

/**
 * generateReviewPost — HTTPS Callable (PDF Section 18: Review-to-Post Generator).
 * Pro/Agency feature.
 */
export const generateReviewPost = onCall(
  { region: env.functionsRegion, timeoutSeconds: 45 },
  async (request) => {
    const uid = requireAuth(request);
    const input = InputSchema.parse(request.data);

    await requirePlanFeature(uid, "reviewToPostGenerator");
    await enforceRateLimit(uid, "ai-generation", env.rateLimits.aiPerMinute, 60);
    await requireWithinUsageLimit(uid, "aiGenerationLimit", "aiGenerationsUsed");

    const prompt = buildReviewToPostPrompt(input);
    const result = await generateJson<{
      socialPostCaption: string;
      testimonialPost: string;
      storyCaption: string;
      hashtags: string[];
      bookingCta: string;
    }>(prompt);

    await db
      .doc(`subscriptions/${uid}`)
      .set({ aiGenerationsUsed: FieldValue.increment(1) }, { merge: true });

    return result;
  }
);
