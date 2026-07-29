import { onCall } from "firebase-functions/v2/https";
import { z } from "zod";
import { requireAuth } from "../middleware/authGuard";
import { requirePlanFeature } from "../middleware/planGuard";
import { generateJson } from "./aiService";
import { buildContentScorePrompt } from "./promptTemplates";
import { env } from "../config/env";

const InputSchema = z.object({
  captionText: z.string().min(1),
  platform: z.string().min(1),
});

/**
 * generateContentScore — HTTPS Callable (PDF Section 20: AI Content Score).
 * Pro/Agency feature. Does not count against the AI generation quota since
 * it's a lightweight scoring call meant to be used freely while editing.
 */
export const generateContentScore = onCall(
  { region: env.functionsRegion, timeoutSeconds: 30 },
  async (request) => {
    const uid = requireAuth(request);
    const input = InputSchema.parse(request.data);

    await requirePlanFeature(uid, "contentScore");

    const prompt = buildContentScorePrompt(input.captionText, input.platform);
    const result = await generateJson<{ score: number; recommendation: string }>(prompt);
    return result;
  }
);
