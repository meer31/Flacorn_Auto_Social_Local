/**
 * Centralized environment/config accessor.
 *
 * All Cloud Functions must read secrets/config through this module rather
 * than reaching into `process.env` directly. This keeps a single audit
 * point for every sensitive value used by the backend, and makes it easy
 * to swap `process.env` for `functions.config()` / Secret Manager without
 * touching business logic.
 *
 * SECURITY: Nothing in this file is ever imported by the Flutter frontend.
 * These values must never be returned in any HTTPS callable response.
 */

function required(name: string, fallback?: string): string {
  const value = process.env[name] ?? fallback;
  if (!value) {
    // Intentionally do not throw at module-load time in emulator/build
    // contexts; individual functions should validate before use.
    console.warn(`[env] Missing environment variable: ${name}`);
    return "";
  }
  return value;
}

export const env = {
  appEnv: required("APP_ENV", "development"),
  appBaseUrl: required("APP_BASE_URL", "http://localhost:5000"),
  functionsRegion: required("FUNCTIONS_REGION", "us-central1"),

  firebase: {
    projectId: required("FIREBASE_PROJECT_ID"),
    storageBucket: required("FIREBASE_STORAGE_BUCKET"),
  },

  tokenEncryptionKey: required("TOKEN_ENCRYPTION_KEY"),

  stripe: {
    secretKey: required("STRIPE_SECRET_KEY"),
    webhookSecret: required("STRIPE_WEBHOOK_SECRET"),
    priceIds: {
      starter: required("STRIPE_PRICE_ID_STARTER"),
      pro: required("STRIPE_PRICE_ID_PRO"),
      agency: required("STRIPE_PRICE_ID_AGENCY"),
    },
    portalReturnUrl: required("STRIPE_PORTAL_RETURN_URL"),
  },

  ai: {
    provider: required("AI_PROVIDER", "gemini") as "gemini" | "claude" | "openai_compatible",
    geminiApiKey: required("GEMINI_API_KEY"),
    claudeApiKey: required("CLAUDE_API_KEY"),
    openAiApiKey: required("OPENAI_API_KEY"),
    openAiCompatibleBaseUrl: required("OPENAI_COMPATIBLE_BASE_URL", ""),
  },

  social: {
    meta: {
      appId: required("META_APP_ID"),
      appSecret: required("META_APP_SECRET"),
      redirectUri: required("META_REDIRECT_URI"),
    },
    twitter: {
      clientId: required("TWITTER_CLIENT_ID"),
      clientSecret: required("TWITTER_CLIENT_SECRET"),
      redirectUri: required("TWITTER_REDIRECT_URI"),
    },
    linkedin: {
      clientId: required("LINKEDIN_CLIENT_ID"),
      clientSecret: required("LINKEDIN_CLIENT_SECRET"),
      redirectUri: required("LINKEDIN_REDIRECT_URI"),
    },
  },

  rateLimits: {
    aiPerMinute: Number(required("RATE_LIMIT_AI_PER_MINUTE", "10")),
    schedulingPerMinute: Number(required("RATE_LIMIT_SCHEDULING_PER_MINUTE", "20")),
  },

  email: {
    provider: required("EMAIL_PROVIDER", "sendgrid"),
    sendgridApiKey: required("SENDGRID_API_KEY"),
    fromAddress: required("EMAIL_FROM_ADDRESS", "noreply@flacronsocialauto.com"),
  },
};
