import { getAiProvider } from "./providers";
import { AiGenerationOptions } from "./providers/aiProvider.interface";

/**
 * Calls the active AI provider and parses the response as JSON.
 * Strips markdown code fences if the model ignores the "no fences" instruction
 * (this happens often enough in practice to be worth handling defensively).
 */
export async function generateJson<T>(
  prompt: string,
  options?: AiGenerationOptions
): Promise<T> {
  const provider = getAiProvider();
  const raw = await provider.generateText(prompt, options);
  const cleaned = raw
    .trim()
    .replace(/^```json\s*/i, "")
    .replace(/^```\s*/i, "")
    .replace(/```\s*$/i, "");

  try {
    return JSON.parse(cleaned) as T;
  } catch (err) {
    throw new Error(
      `AI provider (${provider.name}) returned invalid JSON. Raw output: ${cleaned.slice(0, 500)}`
    );
  }
}

/** Plain-text generation passthrough, for cases that don't need structured output. */
export async function generateText(
  prompt: string,
  options?: AiGenerationOptions
): Promise<string> {
  return getAiProvider().generateText(prompt, options);
}
