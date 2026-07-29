/**
 * FLACRON AUTO SOCIAL — CLOUD FUNCTIONS ENTRY POINT
 * ----------------------------------------------------------------------------
 * Every deployable Cloud Function must be re-exported from this file so the
 * Firebase CLI can discover it. Grouped by domain to mirror the folder
 * structure under src/ and the "Cloud Functions Required" list in the
 * developer document (Section 25).
 */

// ---- User ----
export { onAuthUserCreate, onUserDocCreate } from "./user/onUserCreate";
export { updateUserProfile } from "./user/updateUserProfile";

// ---- Stripe ----
export { createCheckoutSession } from "./stripe/createCheckoutSession";
export { getBillingPortalUrl } from "./stripe/getBillingPortalUrl";
export { stripeWebhook } from "./stripe/stripeWebhook";

// ---- Subscription / Limits ----
export { checkPlanAccess } from "./subscriptions/checkPlanAccess";
export { resetMonthlyUsage } from "./subscriptions/resetMonthlyUsage";
// NOTE: incrementUsage/decrementUsage are internal helpers, not callables —
// see subscriptions/incrementUsage.ts.

// ---- AI ----
export { generatePosts } from "./ai/generatePosts";
export { generateContentPlan } from "./ai/generateContentPlan";
export { generateCampaign } from "./ai/generateCampaign";
export { generateReviewPost } from "./ai/generateReviewPost";
export { generateContentScore } from "./ai/generateContentScore";
export { generateWeeklyReport } from "./ai/generateWeeklyReport";
export { generateReelScript } from "./ai/generateReelScript";

// ---- Social OAuth ----
export { getOAuthUrl } from "./social-oauth/getOAuthUrl";
export { oauthCallback } from "./social-oauth/oauthCallback";
export { disconnectSocialAccount } from "./social-oauth/disconnectSocialAccount";
// NOTE: refreshTokenIfNeeded is an internal helper invoked from
// runScheduledPosts and other server-side flows — see
// social-oauth/refreshTokenIfNeeded.ts (refreshTokenIfNeededInternal).

// ---- Scheduling ----
export { createScheduledPost } from "./scheduling/createScheduledPost";
export { updateScheduledPost } from "./scheduling/updateScheduledPost";
export { cancelScheduledPost } from "./scheduling/cancelScheduledPost";
export { runScheduledPosts } from "./scheduling/runScheduledPosts";

// ---- Analytics ----
export { collectInsights } from "./analytics/collectInsights";
export { generateAnalyticsSummary } from "./analytics/generateAnalyticsSummary";
// NOTE: calculateEngagementRate is a pure utility function, not a callable —
// see analytics/calculateEngagementRate.ts.

// ---- AR ----
export { createArCampaign } from "./ar/createArCampaign";
export { generateArPreview } from "./ar/generateArPreview";
export { createQrPromo } from "./ar/createQrPromo";
export { saveArCampaign } from "./ar/saveArCampaign";

// ---- Notifications ----
export { markNotificationRead } from "./notifications/markNotificationRead";
// NOTE: createNotification is an internal helper called from other
// functions — see notifications/createNotification.ts.

// ---- Audit ----
export { createAuditLog } from "./audit/createAuditLog";

// ---- Admin ----
export { listUsers } from "./admin/listUsers";
export { updateUserPlan } from "./admin/updateUserPlan";
export { disableUser } from "./admin/disableUser";

// ---- Search ----
// Keeps users/{userId}/searchIndex/** in sync for the Global Search screen.
// Client only ever reads this collection — see firestore.rules.
export {
  onScheduledPostIndexWrite,
  onCampaignIndexWrite,
  onMediaIndexWrite,
  onTemplateIndexWrite,
} from "./search/indexSearchableEntities";

// ---- Workspaces / Team (RBAC) ----
// See docs/TEAM_RBAC.md and functions/src/middleware/workspaceGuard.ts.
export { inviteMember } from "./workspaces/inviteMember";
export { acceptInvite } from "./workspaces/acceptInvite";
export { updateMemberRole } from "./workspaces/updateMemberRole";
export { removeMember } from "./workspaces/removeMember";
export { requestApproval } from "./workspaces/requestApproval";
export { decideApproval } from "./workspaces/decideApproval";
