import { HttpsError } from "firebase-functions/v2/https";
import { db } from "../config/firebase";
import { getPlan, PlanDefinition, PlanName } from "../config/plans";

export interface SubscriptionDoc {
  planName: PlanName;
  status: "active" | "trialing" | "past_due" | "canceled" | "incomplete";
  aiGenerationsUsed?: number;
  scheduledPostsUsed?: number;
  socialAccountLimit?: number | null;
  arAccess?: boolean;
  agencyAccess?: boolean;
  [key: string]: unknown;
}

/**
 * Loads the caller's subscription document. Throws if none exists or the
 * subscription is not currently active/trialing.
 */
export async function getActiveSubscription(userId: string): Promise<{
  doc: SubscriptionDoc;
  plan: PlanDefinition;
}> {
  const snap = await db.doc(`subscriptions/${userId}`).get();
  if (!snap.exists) {
    throw new HttpsError("failed-precondition", "No active subscription found for this account.");
  }
  const doc = snap.data() as SubscriptionDoc;
  if (doc.status !== "active" && doc.status !== "trialing") {
    throw new HttpsError(
      "failed-precondition",
      "Your subscription is not active. Please update your billing to continue."
    );
  }
  return { doc, plan: getPlan(doc.planName) };
}

/**
 * Generic feature-flag gate. Pass the plan feature key to check
 * (e.g. "arAccess", "agencyAccess", "campaignGenerator").
 *
 * Mirrors PDF Section 9: "The backend must check the user's plan before
 * allowing: AI generation, Scheduling, Connecting more social accounts,
 * Using AR features, Creating client workspaces, Exporting reports,
 * Accessing advanced analytics."
 */
export async function requirePlanFeature(
  userId: string,
  feature: keyof PlanDefinition
): Promise<PlanDefinition> {
  const { plan } = await getActiveSubscription(userId);
  if (plan[feature] !== true) {
    throw new HttpsError(
      "permission-denied",
      `This feature (${String(feature)}) is not included in your current plan (${plan.displayName}). Please upgrade to continue.`
    );
  }
  return plan;
}

/**
 * Checks a numeric usage limit (e.g. aiGenerationLimit vs aiGenerationsUsed)
 * and throws a friendly upgrade-prompt error if the limit is reached.
 * `null` limit = unlimited.
 */
export async function requireWithinUsageLimit(
  userId: string,
  limitField: "aiGenerationLimit" | "scheduledPostLimit" | "socialAccountLimit",
  usedField: "aiGenerationsUsed" | "scheduledPostsUsed" | "socialAccountsUsed"
): Promise<{ plan: PlanDefinition; used: number; limit: number | null }> {
  const { doc, plan } = await getActiveSubscription(userId);
  const limit = plan[limitField];
  const used = Number(doc[usedField] ?? 0);

  if (limit !== null && used >= limit) {
    throw new HttpsError(
      "resource-exhausted",
      `You reached your ${plan.displayName} plan limit for this feature. Upgrade your plan to unlock more.`
    );
  }
  return { plan, used, limit };
}
