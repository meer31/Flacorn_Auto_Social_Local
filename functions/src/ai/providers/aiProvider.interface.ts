/**
 * Common interface every AI provider adapter must implement.
 * This lets `ai/aiService.ts` call `provider.generateText(prompt)` without
 * caring whether the active provider is Gemini, Claude, or an
 * OpenAI-compatible endpoint. Swapping providers = swapping the adapter
 * bound in `ai/providers/index.ts`; no business logic changes needed.
 */
export interface AiGenerationOptions {
  /** Max output tokens, provider-specific ceiling applied internally. */
  maxTokens?: number;
  /** 0.0 - 1.0, higher = more creative. */
  temperature?: number;
  /** Optional system/style instruction prepended to the prompt. */
  systemInstruction?: string;
}

export interface AiProvider {
  readonly name: "gemini" | "claude" | "openai_compatible";

  /**
   * Sends a prompt and returns raw text output.
   * Callers are responsible for parsing JSON if they requested structured output.
   */
  generateText(prompt: string, options?: AiGenerationOptions): Promise<string>;
}
