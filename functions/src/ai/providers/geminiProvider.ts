import axios from "axios";
import { env } from "../../config/env";
import { AiGenerationOptions, AiProvider } from "./aiProvider.interface";

/**
 * Google Gemini API adapter.
 * Docs: https://ai.google.dev/gemini-api/docs
 *
 * TODO: confirm final model name (e.g. "gemini-2.5-flash") against current
 * Gemini API docs before production deploy — model identifiers change over time.
 */
const GEMINI_MODEL = "gemini-2.5-flash";
const GEMINI_ENDPOINT = `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`;

export class GeminiProvider implements AiProvider {
  readonly name = "gemini" as const;

  async generateText(prompt: string, options?: AiGenerationOptions): Promise<string> {
    if (!env.ai.geminiApiKey) {
      throw new Error("GEMINI_API_KEY is not configured.");
    }

    const fullPrompt = options?.systemInstruction
      ? `${options.systemInstruction}\n\n${prompt}`
      : prompt;

    const response = await axios.post(
      `${GEMINI_ENDPOINT}?key=${env.ai.geminiApiKey}`,
      {
        contents: [{ parts: [{ text: fullPrompt }] }],
        generationConfig: {
          temperature: options?.temperature ?? 0.8,
          maxOutputTokens: options?.maxTokens ?? 2048,
        },
      },
      { headers: { "Content-Type": "application/json" }, timeout: 30000 }
    );

    const text = response.data?.candidates?.[0]?.content?.parts?.[0]?.text;
    if (!text) {
      throw new Error("Gemini API returned an empty response.");
    }
    return text;
  }
}
