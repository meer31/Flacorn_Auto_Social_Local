# Flacron Auto Social — Architecture Overview

## 1. High-Level Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                          Flutter Frontend                            │
│   (Web first, mobile-ready — Android/iOS)                            │
│                                                                        │
│   core/            → theme, routing, constants, services, widgets     │
│   features/         → one folder per screen domain                    │
│   shared/            → models, repositories, providers, widgets       │
│                                                                        │
│   Talks to Firebase ONLY via:                                         │
│     • firebase_auth (sign in/up/out)                                  │
│     • cloud_firestore (READ-mostly; direct writes limited by rules)   │
│     • cloud_functions (ALL sensitive/business-logic operations)       │
│     • firebase_storage (media uploads)                                │
└───────────────────────────────┬────────────────────────────────────-┘
                                 │ HTTPS (Firebase SDKs)
┌────────────────────────────────▼───────────────────────────────────┐
│                     Firebase Cloud Functions (Node.js/TS)            │
│                                                                       │
│  user/            stripe/          subscriptions/    ai/             │
│  social-oauth/    scheduling/      analytics/         ar/            │
│  notifications/   admin/            audit/                           │
│                                                                       │
│  middleware/  → authGuard, planGuard, rateLimiter                    │
│  config/      → env.ts (secrets), firebase.ts (Admin SDK), plans.ts  │
│  utils/       → encryption, auditLog, timestamps                     │
└───┬─────────────┬──────────────┬───────────────┬────────────────┬──┘
    │              │              │               │                │
    ▼              ▼              ▼               ▼                ▼
Firestore      Cloud Storage   Stripe API    AI Provider API   Social APIs
(data)         (media/reports) (billing)     (Gemini/Claude/   (Meta, X,
                                              OpenAI-compat)     LinkedIn)
```

## 2. Core Principle: Backend-Only Secrets

Every credential — Stripe keys, AI provider keys, social platform app
secrets, and encrypted OAuth tokens — lives exclusively inside
`functions/src/config/env.ts` and Firestore documents that client-side
security rules block from being read/written directly. The Flutter app
never imports, receives, or displays a raw secret. It only ever calls
named Cloud Functions (`FunctionsService` in
`frontend/lib/core/services/functions_service.dart`) and reads
already-sanitized Firestore documents.

## 3. Data Flow Examples

### AI Content Generation
1. User fills out the AI Content Generator form (Flutter).
2. Flutter calls the `generatePosts` Cloud Function with plain business
   inputs (niche, goal, tone, platform, etc.) — no keys involved.
3. `generatePosts` checks auth, rate limit, and plan usage limits, then
   calls the configured `AiProvider` adapter (`ai/providers/*`).
4. Output is parsed as JSON, saved to
   `users/{userId}/postTemplates/{templateId}`, and the usage counter is
   incremented.
5. Flutter listens to the Firestore `postTemplates` collection (read-only
   for the client) to display results in real time.

### Scheduled Auto-Publishing
1. User schedules a post via `createScheduledPost` (Cloud Function),
   which writes to `users/{userId}/scheduledPosts/{postId}` with
   `status: "pending"`.
2. Cloud Scheduler triggers `runScheduledPosts` every 2 minutes.
3. The worker refreshes tokens if needed, calls the right
   `SocialPublisher` adapter (`scheduling/publishers/*`), and updates the
   post's status to `sent` or `failed`.
4. Flutter's Scheduler screen reflects status changes live via a
   Firestore stream.

## 4. Why This Structure Scales (PDF: "must be built with scalability in
mind")

- **Provider adapters** (`ai/providers/*`, `scheduling/publishers/*`,
  `analytics/collectors/*`) mean adding TikTok, YouTube, or a new AI
  vendor is a new adapter file + one line in a factory — no changes to
  calling code.
- **Plan gating is centralized** in `config/plans.ts` and
  `middleware/planGuard.ts`, so adding a new paid feature is one flag in
  one file, enforced everywhere automatically.
- **Firestore structure mirrors the PDF's schema 1:1** (see
  `FIRESTORE_SCHEMA.md`), so agency/white-label/multi-tenant features can
  be layered on without a data migration.
- **The Flutter feature folders are self-contained** (`screens/`,
  `widgets/`, `providers/` per feature), so new screens (TikTok
  publishing UI, lead capture pages, etc.) drop in without touching
  unrelated code.
