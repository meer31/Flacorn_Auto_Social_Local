/**
 * Centralized prompt construction. Keeping prompts here (instead of inline
 * in each Cloud Function) makes it easy to iterate on prompt quality
 * without touching business logic, and keeps output-shape contracts
 * (the JSON schema we ask the model for) in one place.
 */

export interface BrandVoiceContext {
  tone?: string;
  audience?: string;
  style?: string;
  preferredCTA?: string;
  wordsToUse?: string[];
  wordsToAvoid?: string[];
}

export interface PostGenerationInput {
  niche: string;
  businessCategory: string;
  goal: string;
  tone: string;
  numberOfPosts: number;
  platform: string;
  offer?: string;
  bookingLink?: string;
  productOrService?: string;
  targetAudience?: string;
  location?: string;
  brandVoice?: BrandVoiceContext;
}

const POST_OUTPUT_SCHEMA = `
Return ONLY valid JSON (no markdown fences, no commentary) as an array of objects,
each shaped exactly like this:
{
  "title": string,
  "postIdea": string,
  "captionText": string,
  "hashtags": string[],
  "cta": string,
  "suggestedPlatform": string,
  "suggestedDateTime": string,   // ISO 8601
  "suggestedMediaType": "image" | "video" | "carousel" | "reel" | "story",
  "contentScore": number,        // 0-100
  "reelIdea": string | null,
  "storyVersion": string | null
}
`.trim();

export function buildGeneratePostsPrompt(input: PostGenerationInput): string {
  const brand = input.brandVoice;
  return `
You are an expert social media manager writing content for a ${input.businessCategory} business.

Business niche: ${input.niche}
Primary goal: ${input.goal}
Brand tone: ${input.tone}
Platform: ${input.platform}
Target audience: ${input.targetAudience ?? "general local audience"}
Location: ${input.location ?? "not specified"}
Current offer/promotion: ${input.offer ?? "none"}
Product or service focus: ${input.productOrService ?? "general services"}
Booking link to reference in CTA when relevant: ${input.bookingLink ?? "none provided"}
${
  brand
    ? `Brand voice profile — tone: ${brand.tone ?? "n/a"}, audience: ${brand.audience ?? "n/a"}, style: ${brand.style ?? "n/a"}, preferred CTA: ${brand.preferredCTA ?? "n/a"}, words to use: ${(brand.wordsToUse ?? []).join(", ") || "n/a"}, words to avoid: ${(brand.wordsToAvoid ?? []).join(", ") || "n/a"}.`
    : ""
}

Generate ${input.numberOfPosts} unique, ready-to-publish social media posts that help this business
achieve its goal. Make captions natural, specific to the business type, and free of generic filler.

${POST_OUTPUT_SCHEMA}
`.trim();
}

export function buildContentPlanPrompt(input: PostGenerationInput & { days: number }): string {
  return `
You are generating a ${input.days}-day social media content calendar for a ${input.businessCategory} business.
${buildGeneratePostsPrompt({ ...input, numberOfPosts: input.days })}

Distribute suggestedDateTime across the next ${input.days} days, spacing posts sensibly across
platforms and avoiding duplicate topics on consecutive days.
`.trim();
}

export function buildCampaignPrompt(params: {
  campaignType: string;
  businessCategory: string;
  goal: string;
  tone: string;
  postCount: number;
  offer?: string;
}): string {
  return `
You are creating a "${params.campaignType}" marketing campaign for a ${params.businessCategory} business.
Goal: ${params.goal}. Tone: ${params.tone}. Offer: ${params.offer ?? "none specified"}.

Generate ${params.postCount} posts for this campaign, including a mix of feed posts, story ideas,
and reel ideas, all consistent with the campaign theme.

${POST_OUTPUT_SCHEMA}
`.trim();
}

export function buildReviewToPostPrompt(params: {
  reviewText: string;
  businessType: string;
  platform: string;
  tone: string;
  cta?: string;
}): string {
  return `
Turn the following customer review into engaging social media content for a ${params.businessType} business.

Customer review: "${params.reviewText}"

Platform: ${params.platform}
Tone: ${params.tone}
Preferred CTA: ${params.cta ?? "encourage booking or visiting"}

Return ONLY valid JSON:
{
  "socialPostCaption": string,
  "testimonialPost": string,
  "storyCaption": string,
  "hashtags": string[],
  "bookingCta": string
}
`.trim();
}

export function buildContentScorePrompt(captionText: string, platform: string): string {
  return `
Score the following ${platform} caption from 0-100 based on hook strength, clarity, CTA quality,
hashtag quality, platform fit, conversion potential, and emotional appeal.

Caption: "${captionText}"

Return ONLY valid JSON:
{
  "score": number,
  "recommendation": string
}
`.trim();
}

export function buildWeeklyReportPrompt(params: {
  postsPublished: number;
  bestPost?: string;
  worstPost?: string;
  topPlatform?: string;
  businessCategory: string;
}): string {
  return `
Generate a concise weekly AI performance report for a ${params.businessCategory} business's social media.

Posts published this week: ${params.postsPublished}
Best performing post: ${params.bestPost ?? "not available"}
Worst performing post: ${params.worstPost ?? "not available"}
Most effective platform: ${params.topPlatform ?? "not available"}

Return ONLY valid JSON:
{
  "suggestedImprovements": string[],
  "recommendedNextWeekContent": string[],
  "bestCta": string,
  "bestContentType": string,
  "suggestedPostingFrequency": string
}
`.trim();
}

export function buildReelScriptPrompt(topic: string, tone: string, durationSeconds = 30): string {
  return `
Write a ${durationSeconds}-second vertical video/reel script about: "${topic}".
Tone: ${tone}. Include a hook in the first 2 seconds, 3-4 short scenes, on-screen text
suggestions, and a closing CTA.

Return ONLY valid JSON:
{
  "hook": string,
  "scenes": [{ "timestamp": string, "visual": string, "onScreenText": string, "voiceover": string }],
  "cta": string
}
`.trim();
}
