import { db } from "../config/firebase";
import { getPlan, PlanDefinition, PlanName } from "../config/plans";

/**
 * Non-throwing variant of requirePlanFeature, for use inside scheduled/batch
 * jobs (e.g. generateWeeklyReport) where we want to silently skip users
 * rather than throw an HttpsError.
 */
export async function requirePlanFeatureForUser(
  userId: string,
  feature: keyof PlanDefinition
): Promise<boolean> {
  const snap = await db.doc(`subscriptions/${userId}`).get();
  if (!snap.exists) return false;

  const data = snap.data() as { planName: PlanName; status: string };
  if (data.status !== "active" && data.status !== "trialing") return false;

  const plan = getPlan(data.planName);
  return plan[feature] === true;
}
