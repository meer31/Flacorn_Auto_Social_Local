import { env } from "../../config/env";
import { AiProvider } from "./aiProvider.interface";
import { GeminiProvider } from "./geminiProvider";
import { ClaudeProvider } from "./claudeProvider";
import { OpenAiCompatibleProvider } from "./openAiCompatibleProvider";

let cachedProvider: AiProvider | null = null;

/**
 * Returns the active AI provider adapter based on AI_PROVIDER env var.
 * This is the ONLY place in the codebase that should decide which
 * provider to use — everything else calls the AiProvider interface.
 */
export function getAiProvider(): AiProvider {
  if (cachedProvider) return cachedProvider;

  switch (env.ai.provider) {
    case "claude":
      cachedProvider = new ClaudeProvider();
      break;
    case "openai_compatible":
      cachedProvider = new OpenAiCompatibleProvider();
      break;
    case "gemini":
    default:
      cachedProvider = new GeminiProvider();
      break;
  }
  return cachedProvider;
}
