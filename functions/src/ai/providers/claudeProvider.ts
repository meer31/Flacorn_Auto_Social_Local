import axios from "axios";
import { env } from "../../config/env";
import { AiGenerationOptions, AiProvider } from "./aiProvider.interface";

/**
 * Anthropic Claude API adapter.
 * Docs: https://docs.claude.com/en/api/messages
 *
 * TODO: confirm the desired model string (e.g. "claude-sonnet-4-6") against
 * current Claude API docs before production deploy.
 */
const CLAUDE_MODEL = "claude-sonnet-4-6";
const CLAUDE_ENDPOINT = "https://api.anthropic.com/v1/messages";

export class ClaudeProvider implements AiProvider {
  readonly name = "claude" as const;

  async generateText(prompt: string, options?: AiGenerationOptions): Promise<string> {
    if (!env.ai.claudeApiKey) {
      throw new Error("CLAUDE_API_KEY is not configured.");
    }

    const response = await axios.post(
      CLAUDE_ENDPOINT,
      {
        model: CLAUDE_MODEL,
        max_tokens: options?.maxTokens ?? 2048,
        system: options?.systemInstruction,
        messages: [{ role: "user", content: prompt }],
      },
      {
        headers: {
          "x-api-key": env.ai.claudeApiKey,
          "anthropic-version": "2023-06-01",
          "content-type": "application/json",
        },
        timeout: 30000,
      }
    );

    const text = response.data?.content
      ?.map((block: { type: string; text?: string }) => block.text ?? "")
      .join("\n");

    if (!text) {
      throw new Error("Claude API returned an empty response.");
    }
    return text;
  }
}
