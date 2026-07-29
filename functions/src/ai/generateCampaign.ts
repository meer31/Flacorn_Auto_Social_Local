import { onCall } from "firebase-functions/v2/https";
import { z } from "zod";
import { requireAuth } from "../middleware/authGuard";
import { requirePlanFeature, requireWithinUsageLimit } from "../middleware/planGuard";
import { enforceRateLimit } from "../middleware/rateLimiter";
import { generateJson } from "./aiService";
import { buildCampaignPrompt } from "./promptTemplates";
import { env } from "../config/env";
import { db, FieldValue } from "../config/firebase";

const CAMPAIGN_TYPES = [
  "Weekend promotion",
  "Grand opening",
  "New product launch",
  "Valentine's Day campaign",
  "Black Friday campaign",
  "Back-to-school campaign",
  "Real estate open house",
  "Church event",
  "Restaurant special",
  "Salon booking campaign",
] as const;

const InputSchema = z.object({
  campaignName: z.string().min(1),
  campaignType: z.string().min(1),
  businessCategory: z.string().min(1),
  goal: z.string().min(1),
  tone: z.string().min(1),
  postCount: z.number().int().min(5).max(15).default(10),
  offer: z.string().optional(),
  startDate: z.string(),
  endDate: z.string(),
  arEnabled: z.boolean().default(false),
});

/**
 * generateCampaign — HTTPS Callable (PDF Section 13).
 * Campaign generator is a Pro/Agency feature.
 */
export const generateCampaign = onCall(
  { region: env.functionsRegion, timeoutSeconds: 90, memory: "512MiB" },
  async (request) => {
    const uid = requireAuth(request);
    const input = InputSchema.parse(request.data);

    await requirePlanFeature(uid, "campaignGenerator");
    if (input.arEnabled) {
      await requirePlanFeature(uid, "arAccess");
    }
    await enforceRateLimit(uid, "ai-generation", env.rateLimits.aiPerMinute, 60);
    await requireWithinUsageLimit(uid, "aiGenerationLimit", "aiGenerationsUsed");

    const prompt = buildCampaignPrompt(input);
    const posts = await generateJson<unknown[]>(prompt, { temperature: 0.85, maxTokens: 3000 });

    const ref = db.collection(`users/${uid}/campaigns`).doc();
    await ref.set({
      campaignName: input.campaignName,
      campaignType: input.campaignType,
      goal: input.goal,
      startDate: input.startDate,
      endDate: input.endDate,
      posts,
      arEnabled: input.arEnabled,
      status: "draft",
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    await db
      .doc(`subscriptions/${uid}`)
      .set({ aiGenerationsUsed: FieldValue.increment(1) }, { merge: true });

    return { campaignId: ref.id, posts, availableCampaignTypes: CAMPAIGN_TYPES };
  }
);
