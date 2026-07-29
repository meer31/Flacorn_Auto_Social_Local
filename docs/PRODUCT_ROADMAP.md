# Product Roadmap

## Development Priority (PDF Section 33)

### Priority 1 — Core Platform ✅ Scaffolded
Authentication, onboarding, Stripe billing, Firestore structure, social
OAuth plumbing, AI content generation, basic scheduling, auto-publishing
worker.

### Priority 2 — Conversion Features ✅ Scaffolded
30-day content plan, campaign generator, AI brand voice, content score,
booking CTA generator, review-to-post generator, upgrade prompts.

### Priority 3 — Analytics ✅ Scaffolded
Basic analytics collector, dashboard charts, weekly AI report.

### Priority 4 — AR ✅ Scaffolded (MVP web preview) / 🔜 True AR (Phase 2)
See `AR_ROADMAP.md`.

### Priority 5 — Agency 🔜 Phase 2
Firestore structure (`agencies/{agencyId}/clients/{clientId}`) and
security rules exist; client management UI, approval workflow, and
white-label report export are not yet built.

## Phase 2 Features (PDF Section 32)
- TikTok integration
- YouTube Shorts scheduling
- Google Business Profile posting
- Auto-replies to comments and DMs
- AI inbox assistant
- Competitor inspiration tool
- Canva integration
- Advanced AR product showcase
- True mobile AR using ARKit and ARCore
- AI video/reel generation
- Client approval workflow (full build-out)
- Full agency white-label mode
- Template marketplace
- Lead capture pages
- Booking pages
- WhatsApp campaign integration
- Email marketing integration
- Advanced social listening
- Multi-language content generation

## Architectural Notes for Extending
- **New social platform** (e.g. TikTok): add a new
  `scheduling/publishers/tiktokPublisher.ts` implementing
  `SocialPublisher`, a matching `analytics/collectors/tiktokInsightCollector.ts`,
  OAuth config in `config/env.ts`, and a branch in `getOAuthUrl.ts` /
  `oauthCallback.ts`. No changes needed to `runScheduledPosts.ts` or
  `collectInsights.ts` — the factory pattern absorbs it.
- **New AI tool**: see `AI_ARCHITECTURE.md` → "Adding a New AI-Powered Tool".
- **New paid feature**: add a flag to `config/plans.ts` (and the Dart
  mirror in `frontend/lib/core/constants/plans.dart`), then gate it with
  `requirePlanFeature()` server-side and conditional UI client-side.
- **Lead capture / booking pages**: would be new public (unauthenticated)
  routes + Cloud Functions, likely reusing the AR QR Promo's "hosted
  micro-page" pattern.
