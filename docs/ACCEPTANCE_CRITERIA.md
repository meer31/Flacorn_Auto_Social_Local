# Acceptance Criteria Tracking

Mirrors PDF Section 31. Status reflects what's scaffolded in this
repository vs. what needs real credentials/production hardening.

| Criterion | Status | Notes |
|---|---|---|
| User can register and log in | ✅ Implemented | `features/auth/*` |
| User can complete onboarding | ✅ Implemented | `features/onboarding/*`, 7-step flow |
| User can choose a Stripe plan | ✅ Implemented | Requires real Stripe Price IDs |
| Stripe subscription updates Firestore correctly | ✅ Implemented | `stripe/stripeWebhook.ts` |
| User can connect Instagram/Facebook/X/LinkedIn | 🟡 Plumbing done | Token exchange calls are TODO stubs — see `SOCIAL_OAUTH.md` |
| OAuth tokens are encrypted and stored securely | ✅ Implemented | `utils/encryption.ts`, enforced by Firestore rules |
| User can generate AI captions and hashtags | ✅ Implemented | `generatePosts`, provider-agnostic |
| User can generate a 30-day content plan | ✅ Implemented | `generateContentPlan` |
| User can generate campaigns | ✅ Implemented | `generateCampaign` |
| User can save templates | ✅ Implemented | Auto-saved on generation; editable |
| User can schedule posts | ✅ Implemented | `createScheduledPost`, Scheduler screen |
| Scheduled posts publish automatically | 🟡 Worker implemented | Actual platform publish calls are TODO stubs — see `SOCIAL_OAUTH.md` |
| Failed posts show error status | ✅ Implemented | `runScheduledPosts.ts` retry + failure handling |
| Daily analytics collector runs | 🟡 Scheduled job implemented | Actual platform insight calls are TODO stubs |
| Analytics page displays basic stats | ✅ Implemented | `generateAnalyticsSummary`, Analytics screen |
| User can create at least a basic AR promo preview | 🟡 Implemented as MVP placeholder | See `AR_ROADMAP.md` for production compositing |
| Pro and Agency features are locked by plan | ✅ Implemented | `middleware/planGuard.ts`, enforced server-side |
| Usage limits are enforced | ✅ Implemented | `middleware/planGuard.ts`, `subscriptions/incrementUsage.ts` |
| Firebase security rules are implemented | ✅ Implemented | `firestore.rules`, `storage.rules` |
| App works on Flutter Web | ✅ Implemented | `frontend/web/`, responsive shell |
| Mobile-ready structure is prepared | ✅ Implemented | Riverpod + go_router + responsive layout, no web-only APIs in core logic |
| Deployment instructions are delivered | ✅ Delivered | `docs/DEPLOYMENT.md` |
| Environment variables list is delivered | ✅ Delivered | `functions/.env.example` |
| Technical architecture diagram is delivered | ✅ Delivered | `docs/ARCHITECTURE.md` |

## Legend
- ✅ **Implemented** — functionally complete for MVP use (still needs your
  real API keys/credentials to go live).
- 🟡 **Plumbing/architecture done, external API calls stubbed** — the
  full request/response flow, error handling, Firestore writes, plan
  gating, and UI are all wired and testable; only the literal HTTP call
  to a third-party API is a `TODO` pending that platform's app
  review/credentials (this is expected — those approvals are outside
  what any codebase can pre-complete).
