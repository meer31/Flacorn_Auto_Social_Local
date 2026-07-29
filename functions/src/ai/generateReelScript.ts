import { onCall } from "firebase-functions/v2/https";
import { z } from "zod";
import { requireAuth } from "../middleware/authGuard";
import { requireWithinUsageLimit } from "../middleware/planGuard";
import { enforceRateLimit } from "../middleware/rateLimiter";
import { generateJson } from "./aiService";
import { buildReelScriptPrompt } from "./promptTemplates";
import { env } from "../config/env";
import { db, FieldValue } from "../config/firebase";

const InputSchema = z.object({
  topic: z.string().min(1),
  tone: z.string().min(1),
  durationSeconds: z.number().int().min(15).max(90).default(30),
});

/**
 * generateReelScript — HTTPS Callable.
 * Supports the "Video Script Generator" tool in the AI Content Generator suite.
 */
export const generateReelScript = onCall(
  { region: env.functionsRegion, timeoutSeconds: 45 },
  async (request) => {
    const uid = requireAuth(request);
    const input = InputSchema.parse(request.data);

    await enforceRateLimit(uid, "ai-generation", env.rateLimits.aiPerMinute, 60);
    await requireWithinUsageLimit(uid, "aiGenerationLimit", "aiGenerationsUsed");

    const prompt = buildReelScriptPrompt(input.topic, input.tone, input.durationSeconds);
    const result = await generateJson<{
      hook: string;
      scenes: Array<{ timestamp: string; visual: string; onScreenText: string; voiceover: string }>;
      cta: string;
    }>(prompt, { maxTokens: 1500 });

    await db
      .doc(`subscriptions/${uid}`)
      .set({ aiGenerationsUsed: FieldValue.increment(1) }, { merge: true });

    return result;
  }
);
