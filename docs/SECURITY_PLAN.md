# Security Plan

Implements PDF Section 29 (Security Requirements) point by point.

## 1. Firestore Security Rules
See `firestore.rules`. Key guarantees:
- A user can only read/write within `users/{their-own-uid}/**`.
- OAuth token fields (`accessTokenEncrypted`, `refreshTokenEncrypted`,
  `tokenExpiry`) can never be written by the client, even on documents the
  client otherwise owns — writes to those fields are rejected regardless
  of who sends them.
- `subscriptions/{userId}` is fully read-only to the client; only the
  Admin SDK (used inside Cloud Functions) can write it, after a verified
  Stripe webhook or admin action.
- `postInsights` and `weeklyReports` are backend-write-only.
- `auditLogs` is admin-read-only, never client-writable.
- A default-deny rule closes anything not explicitly matched.

## 2. Firebase Authentication Checks
Every callable Cloud Function that touches user data starts with
`requireAuth(request)` (`middleware/authGuard.ts`), which throws
`unauthenticated` if `request.auth` is missing. Admin-only functions use
`requireAdmin(request)`, which additionally checks the `admin: true`
custom claim.

## 3. Role-Based Access
- `users/{uid}.role` distinguishes `owner` vs future roles (agency staff,
  team members — Phase 2).
- Admin capabilities are gated by a Firebase Auth **custom claim**
  (`admin: true`), never a Firestore field the client could tamper with.
  Custom claims must be set via a secure, out-of-band process (Firebase
  Admin SDK from a trusted environment, e.g. a one-off script or the
  Admin Panel's future "promote to admin" flow — Phase 2).

## 4. Plan-Based Feature Access
`middleware/planGuard.ts` (`requirePlanFeature`, `requireWithinUsageLimit`)
is the single enforcement point for every plan-gated action: AI
generation, scheduling, social account limits, AR access, agency access,
advanced analytics, etc. The Flutter frontend also hides/greys out locked
features for UX, but the backend re-validates independently — the client
UI is never trusted as the source of truth.

## 5. Encrypted OAuth Tokens
`utils/encryption.ts` provides AES-256 encrypt/decrypt helpers using a
server-only `TOKEN_ENCRYPTION_KEY`. Tokens are encrypted before every
Firestore write and decrypted only in-memory, only inside Cloud Functions
that need to make an API call on the user's behalf
(`runScheduledPosts.ts`, `collectInsights.ts`,
`refreshTokenIfNeeded.ts`). They are never returned to the client.

## 6. No API Keys / Tokens in Flutter
- `functions/.env.example` documents every secret; the real `.env` (or
  Firebase Functions secrets) never leaves the `functions/` directory.
- `frontend/lib/core/services/firebase_options.dart` contains only
  Firebase's public web/app configuration values, which are not secrets
  (see the comment in that file for why).
- Code review checklist: grep the `frontend/` directory for `sk_`,
  `AIza` (raw, outside firebase_options), `whsec_`, etc. before every
  release.

## 7. Stripe Webhook Signature Verification
`stripe/stripeWebhook.ts` verifies every incoming event with
`stripe.webhooks.constructEvent(rawBody, signature, webhookSecret)`
before processing it, rejecting anything that fails verification with a
400 response.

## 8. Rate Limiting
`middleware/rateLimiter.ts` implements a Firestore-backed sliding-window
limiter, applied to:
- AI generation endpoints (`RATE_LIMIT_AI_PER_MINUTE`, default 10/min)
- Scheduling endpoints (`RATE_LIMIT_SCHEDULING_PER_MINUTE`, default 20/min)

## 9. Audit Logs
`utils/auditLog.ts` writes to `auditLogs/{logId}` for: subscription
activation/cancellation, social account connect/disconnect/refresh
failure, post publish/publish-failure, and every admin action (plan
override, disable user). Admins can review this collection via the
Admin Panel (Phase 2 UI; backend already supports it).

## 10. Workspace-Level Permissions (Agency)
`firestore.rules` scopes `agencies/{agencyId}/**` to verified members via
`isAgencyMember()`, checking membership at
`agencies/{agencyId}/members/{uid}`. Full invite/accept flow is Phase 2
(see `PRODUCT_ROADMAP.md`), but the security boundary is in place from
day one.
