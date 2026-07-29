# Cloud Functions Reference

All functions are exported from `functions/src/index.ts`. Types:
**Callable** = invoked from Flutter via `cloud_functions` SDK.
**Request** = raw HTTP endpoint (webhooks, OAuth redirects).
**Scheduled** = Cloud Scheduler-triggered background job.

| Function | Type | File | Purpose |
|---|---|---|---|
| `onAuthUserCreate` / `onUserDocCreate` | Auth/Firestore trigger | `user/onUserCreate.ts` | Provisions `users/{uid}` + `subscriptions/{uid}` on signup |
| `updateUserProfile` | Callable | `user/updateUserProfile.ts` | Saves onboarding profile fields |
| `createCheckoutSession` | Callable | `stripe/createCheckoutSession.ts` | Starts a Stripe Checkout session for a plan |
| `getBillingPortalUrl` | Callable | `stripe/getBillingPortalUrl.ts` | Returns a Stripe Customer Portal URL |
| `stripeWebhook` | Request | `stripe/stripeWebhook.ts` | Handles Stripe subscription lifecycle events |
| `checkPlanAccess` | Callable | `subscriptions/checkPlanAccess.ts` | Returns plan/usage info for dashboard display |
| `resetMonthlyUsage` | Scheduled (`0 0 1 * *`) | `subscriptions/resetMonthlyUsage.ts` | Monthly usage-counter safety-net reset |
| `generatePosts` | Callable | `ai/generatePosts.ts` | Core AI Content Generator |
| `generateContentPlan` | Callable | `ai/generateContentPlan.ts` | 7/30-day content calendar |
| `generateCampaign` | Callable | `ai/generateCampaign.ts` | Themed campaign generator |
| `generateReviewPost` | Callable | `ai/generateReviewPost.ts` | Review-to-post generator |
| `generateContentScore` | Callable | `ai/generateContentScore.ts` | AI content score (0-100) |
| `generateWeeklyReport` | Scheduled (`0 8 * * 1`) | `ai/generateWeeklyReport.ts` | Weekly AI performance report |
| `generateReelScript` | Callable | `ai/generateReelScript.ts` | Video/reel script generator |
| `getOAuthUrl` | Callable | `social-oauth/getOAuthUrl.ts` | Builds platform OAuth authorization URL |
| `oauthCallback` | Request | `social-oauth/oauthCallback.ts` | OAuth redirect target; exchanges code for tokens |
| `disconnectSocialAccount` | Callable | `social-oauth/disconnectSocialAccount.ts` | Removes a connected account |
| `createScheduledPost` | Callable | `scheduling/createScheduledPost.ts` | Schedules a post |
| `updateScheduledPost` | Callable | `scheduling/updateScheduledPost.ts` | Edits a draft/pending post |
| `cancelScheduledPost` | Callable | `scheduling/cancelScheduledPost.ts` | Cancels a scheduled post |
| `runScheduledPosts` | Scheduled (`every 2 minutes`) | `scheduling/runScheduledPosts.ts` | Publishes due posts, handles retries |
| `collectInsights` | Scheduled (`0 6 * * *`) | `analytics/collectInsights.ts` | Daily insight collection per published post |
| `generateAnalyticsSummary` | Callable | `analytics/generateAnalyticsSummary.ts` | Aggregated analytics for the dashboard |
| `createArCampaign` | Callable | `ar/createArCampaign.ts` | Creates an AR campaign record |
| `generateArPreview` | Callable | `ar/generateArPreview.ts` | Generates the composited AR-style preview |
| `createQrPromo` | Callable | `ar/createQrPromo.ts` | Generates a QR code promo image |
| `saveArCampaign` | Callable | `ar/saveArCampaign.ts` | Updates AR campaign metadata |
| `markNotificationRead` | Callable | `notifications/markNotificationRead.ts` | Marks a notification as read |
| `createAuditLog` | Callable | `audit/createAuditLog.ts` | Client-observable sensitive-action logging |
| `listUsers` | Callable (admin) | `admin/listUsers.ts` | Admin panel user list |
| `updateUserPlan` | Callable (admin) | `admin/updateUserPlan.ts` | Manual plan override |
| `disableUser` | Callable (admin) | `admin/disableUser.ts` | Disables a user's Auth account |

## Internal-only helpers (not exported as Cloud Functions)
- `subscriptions/incrementUsage.ts` — `incrementUsage` / `decrementUsage`
- `subscriptions/planFeatureHelper.ts` — `requirePlanFeatureForUser`
- `social-oauth/refreshTokenIfNeeded.ts` — `refreshTokenIfNeededInternal`
- `notifications/createNotification.ts` — `createNotification`
- `utils/auditLog.ts`, `utils/encryption.ts`, `utils/timestamps.ts`

## Adding a new function
1. Create the file under the right domain folder in `functions/src/`.
2. Import shared guards from `middleware/` (auth, plan, rate limit) —
   never duplicate this logic inline.
3. Export it from `functions/src/index.ts`.
4. If it's plan-gated, add/confirm the feature flag in
   `functions/src/config/plans.ts` AND
   `frontend/lib/core/constants/plans.dart`.
