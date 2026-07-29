# AI Architecture

## Provider Abstraction
`functions/src/ai/providers/aiProvider.interface.ts` defines a single
`AiProvider.generateText(prompt, options)` contract. Three adapters
implement it:
- `geminiProvider.ts` — Google Gemini API
- `claudeProvider.ts` — Anthropic Claude API
- `openAiCompatibleProvider.ts` — OpenAI or any OpenAI-compatible endpoint

`ai/providers/index.ts` returns the active provider based on the
`AI_PROVIDER` env var (`gemini` | `claude` | `openai_compatible`).
**Switching providers requires changing exactly one environment variable
— no other code changes.**

## Prompt Templates
All prompt construction lives in `ai/promptTemplates.ts`, separated from
the Cloud Functions that call them. Each template asks the model to
return strict JSON matching a documented shape (e.g. the post-generation
schema used by `generatePosts`, `generateContentPlan`, and
`generateCampaign`).

## JSON Parsing Safety
`ai/aiService.ts`'s `generateJson<T>()` strips markdown code fences the
model might add despite instructions, then parses JSON, throwing a
descriptive error (including a truncated raw-output excerpt) if parsing
fails — this makes prompt debugging much faster than a bare
`JSON.parse` crash.

## Which Functions Use AI
| Function | Prompt Template | Notes |
|---|---|---|
| `generatePosts` | `buildGeneratePostsPrompt` | Core generator; incorporates saved Brand Voice automatically |
| `generateContentPlan` | `buildContentPlanPrompt` | 7 or 30-day calendar |
| `generateCampaign` | `buildCampaignPrompt` | Themed campaigns |
| `generateReviewPost` | `buildReviewToPostPrompt` | Review → social content |
| `generateContentScore` | `buildContentScorePrompt` | 0-100 score + recommendation |
| `generateWeeklyReport` | `buildWeeklyReportPrompt` | Weekly AI performance summary |
| `generateReelScript` | `buildReelScriptPrompt` | Short-form video scripts |

## Brand Voice Integration
`generatePosts` automatically loads the user's saved
`users/{uid}/brandVoice` document (if any) and includes it in the prompt,
so once a user fills out the Brand Voice Builder (PDF Section 21), every
subsequent generation call respects it without any extra frontend work.

## Cost & Quota Controls
- Every AI-calling function enforces `RATE_LIMIT_AI_PER_MINUTE` via
  `middleware/rateLimiter.ts`.
- Every AI-calling function enforces the plan's `aiGenerationLimit` via
  `middleware/planGuard.ts` before calling the provider (so a rejected
  request never costs API spend).
- `generateContentScore` is intentionally NOT counted against the AI
  quota — it's meant to be used freely while editing a caption.

## Model Selection
Model identifiers (`gemini-2.5-flash`, `claude-sonnet-4-6`,
`gpt-4o-mini`) are marked with `TODO` comments in each provider file —
verify against each vendor's current model catalog before production
deploy, since model names/availability change over time.

## Adding a New AI-Powered Tool
1. Add a prompt builder to `promptTemplates.ts`.
2. Create a new Cloud Function under `ai/` following the pattern in
   `generateReviewPost.ts` (auth → plan check → rate limit → usage limit
   → `generateJson` → persist result → increment usage).
3. Export it from `functions/src/index.ts`.
4. Add a typed wrapper to `frontend/lib/core/services/functions_service.dart`.
