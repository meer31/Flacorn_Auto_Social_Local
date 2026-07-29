import { onCall } from "firebase-functions/v2/https";
import { z } from "zod";
import { requireAuth } from "../middleware/authGuard";
import { getActiveSubscription } from "../middleware/planGuard";
import { getPlan, PlanDefinition } from "../config/plans";
import { env } from "../config/env";

const InputSchema = z.object({
  feature: z.string().optional(),
});

/**
 * checkPlanAccess — HTTPS Callable
 * Lightweight endpoint the Flutter app can call to check whether the
 * current user's plan unlocks a given feature, and to fetch usage counters
 * for dashboard display (PDF Section 27: Usage Limits).
 */
export const checkPlanAccess = onCall(
  { region: env.functionsRegion, timeoutSeconds: 15 },
  async (request) => {
    const uid = requireAuth(request);
    const input = InputSchema.parse(request.data ?? {});
    const { doc, plan } = await getActiveSubscription(uid);

    const featureAllowed =
      input.feature !== undefined ? plan[input.feature as keyof PlanDefinition] === true : null;

    return {
      planName: plan.name,
      displayName: plan.displayName,
      featureAllowed,
      usage: {
        aiGenerations: {
          used: doc.aiGenerationsUsed ?? 0,
          limit: plan.aiGenerationLimit,
        },
        scheduledPosts: {
          used: doc.scheduledPostsUsed ?? 0,
          limit: plan.scheduledPostLimit,
        },
        socialAccounts: {
          used: doc.socialAccountsUsed ?? 0,
          limit: plan.socialAccountLimit,
        },
      },
      arAccess: plan.arAccess,
      agencyAccess: plan.agencyAccess,
    };
  }
);

// Re-export for convenience elsewhere in the backend.
export { getPlan };
