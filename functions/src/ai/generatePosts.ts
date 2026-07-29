import { onCall } from "firebase-functions/v2/https";
import { z } from "zod";
import { requireAuth } from "../middleware/authGuard";
import { requireWithinUsageLimit } from "../middleware/planGuard";
import { enforceRateLimit } from "../middleware/rateLimiter";
import { generateJson } from "./aiService";
import { buildGeneratePostsPrompt } from "./promptTemplates";
import { env } from "../config/env";
import { db, FieldValue } from "../config/firebase";

const InputSchema = z.object({
  niche: z.string().min(1),
  businessCategory: z.string().min(1),
  goal: z.string().min(1),
  tone: z.string().min(1),
  numberOfPosts: z.number().int().min(1).max(30),
  platform: z.string().min(1),
  offer: z.string().optional(),
  bookingLink: z.string().optional(),
  productOrService: z.string().optional(),
  targetAudience: z.string().optional(),
  location: z.string().optional(),
});

interface GeneratedPost {
  title: string;
  postIdea: string;
  captionText: string;
  hashtags: string[];
  cta: string;
  suggestedPlatform: string;
  suggestedDateTime: string;
  suggestedMediaType: string;
  contentScore: number;
  reelIdea: string | null;
  storyVersion: string | null;
}

/**
 * generatePosts — HTTPS Callable
 * Core AI Content Generator (PDF Section 11).
 * Enforces plan-based AI generation limits and per-minute rate limiting.
 */
export const generatePosts = onCall(
  { region: env.functionsRegion, timeoutSeconds: 60, memory: "512MiB" },
  async (request) => {
    const uid = requireAuth(request);
    const input = InputSchema.parse(request.data);

    await enforceRateLimit(uid, "ai-generation", env.rateLimits.aiPerMinute, 60);
    await requireWithinUsageLimit(uid, "aiGenerationLimit", "aiGenerationsUsed");

    // Pull saved brand voice, if any, to personalize output.
    const brandVoiceSnap = await db
      .collection(`users/${uid}/brandVoice`)
      .limit(1)
      .get();
    const brandVoice = brandVoiceSnap.empty ? undefined : brandVoiceSnap.docs[0].data();

    const prompt = buildGeneratePostsPrompt({ ...input, brandVoice });
    const posts = await generateJson<GeneratedPost[]>(prompt, { temperature: 0.85 });

    // Persist as post templates the user can review/edit/schedule.
    const batch = db.batch();
    const createdIds: string[] = [];
    for (const post of posts) {
      const ref = db.collection(`users/${uid}/postTemplates`).doc();
      createdIds.push(ref.id);
      batch.set(ref, {
        ...post,
        createdBy: "ai",
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
    batch.set(
      db.doc(`subscriptions/${uid}`),
      { aiGenerationsUsed: FieldValue.increment(1) },
      { merge: true }
    );
    await batch.commit();

    return { posts, createdTemplateIds: createdIds };
  }
);
