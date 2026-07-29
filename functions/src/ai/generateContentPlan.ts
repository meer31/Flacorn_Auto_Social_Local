import { onCall } from "firebase-functions/v2/https";
import { z } from "zod";
import { requireAuth } from "../middleware/authGuard";
import { requirePlanFeature, requireWithinUsageLimit } from "../middleware/planGuard";
import { enforceRateLimit } from "../middleware/rateLimiter";
import { generateJson } from "./aiService";
import { buildContentPlanPrompt } from "./promptTemplates";
import { env } from "../config/env";
import { db, FieldValue } from "../config/firebase";

const InputSchema = z.object({
  planName: z.string().min(1),
  niche: z.string().min(1),
  businessCategory: z.string().min(1),
  goal: z.string().min(1),
  tone: z.string().min(1),
  platform: z.string().min(1),
  days: z.union([z.literal(7), z.literal(30)]).default(30),
  offer: z.string().optional(),
  bookingLink: z.string().optional(),
  targetAudience: z.string().optional(),
  location: z.string().optional(),
});

/**
 * generateContentPlan — HTTPS Callable
 * "Generate My 30-Day Content Plan" (PDF Section 12).
 * 30-day plans require Pro/Agency (contentCalendar30Day feature flag);
 * 7-day sample plans (used during onboarding) are allowed on Starter.
 */
export const generateContentPlan = onCall(
  { region: env.functionsRegion, timeoutSeconds: 120, memory: "512MiB" },
  async (request) => {
    const uid = requireAuth(request);
    const input = InputSchema.parse(request.data);

    if (input.days === 30) {
      await requirePlanFeature(uid, "contentCalendar30Day");
    }
    await enforceRateLimit(uid, "ai-generation", env.rateLimits.aiPerMinute, 60);
    await requireWithinUsageLimit(uid, "aiGenerationLimit", "aiGenerationsUsed");

    const prompt = buildContentPlanPrompt({ ...input, numberOfPosts: input.days });
    const posts = await generateJson<unknown[]>(prompt, { temperature: 0.85, maxTokens: 4096 });

    const startDate = new Date();
    const endDate = new Date(startDate);
    endDate.setDate(endDate.getDate() + input.days);

    const planRef = db.collection(`users/${uid}/contentPlans`).doc();
    await planRef.set({
      planName: input.planName,
      businessCategory: input.businessCategory,
      goal: input.goal,
      startDate: startDate.toISOString(),
      endDate: endDate.toISOString(),
      posts,
      status: "draft",
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    await db
      .doc(`subscriptions/${uid}`)
      .set({ aiGenerationsUsed: FieldValue.increment(1) }, { merge: true });

    return { planId: planRef.id, posts };
  }
);
