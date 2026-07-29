import axios from "axios";
import { env } from "../../config/env";
import { AiGenerationOptions, AiProvider } from "./aiProvider.interface";

/**
 * Generic adapter for any OpenAI-compatible chat-completions endpoint
 * (OpenAI itself, Azure OpenAI, local/self-hosted models, etc).
 * Set OPENAI_COMPATIBLE_BASE_URL to override the default OpenAI endpoint.
 */
export class OpenAiCompatibleProvider implements AiProvider {
  readonly name = "openai_compatible" as const;

  async generateText(prompt: string, options?: AiGenerationOptions): Promise<string> {
    if (!env.ai.openAiApiKey) {
      throw new Error("OPENAI_API_KEY is not configured.");
    }

    const baseUrl = env.ai.openAiCompatibleBaseUrl || "https://api.openai.com/v1";

    const response = await axios.post(
      `${baseUrl}/chat/completions`,
      {
        model: "gpt-4o-mini", // TODO: confirm model choice for this provider
        temperature: options?.temperature ?? 0.8,
        max_tokens: options?.maxTokens ?? 2048,
        messages: [
          ...(options?.systemInstruction
            ? [{ role: "system", content: options.systemInstruction }]
            : []),
          { role: "user", content: prompt },
        ],
      },
      {
        headers: {
          Authorization: `Bearer ${env.ai.openAiApiKey}`,
          "Content-Type": "application/json",
        },
        timeout: 30000,
      }
    );

    const text = response.data?.choices?.[0]?.message?.content;
    if (!text) {
      throw new Error("OpenAI-compatible API returned an empty response.");
    }
    return text;
  }
}
