# Social Media OAuth Integration

## Supported Platforms (MVP)
Instagram Business & Facebook Pages (via Meta Graph API), X/Twitter (API
v2), LinkedIn.

## Flow (PDF Section 10)
1. Flutter calls `getOAuthUrl({ platform })`.
2. The function builds the platform's OAuth authorization URL, embedding
   a `state` parameter that encodes the Firebase `uid` + platform.
3. Flutter opens the URL externally; the user authorizes in their
   browser/the platform's own login flow.
4. The platform redirects to `oauthCallback?platform=...&code=...&state=...`.
5. `oauthCallback` decodes `state`, exchanges `code` for tokens (platform
   API call — currently a TODO stub per platform, see below), encrypts
   the tokens, and writes a new
   `users/{uid}/socialAccounts/{socialAccountId}` document.
6. The user is redirected back into the app.

## What's Implemented vs. TODO
The full OAuth *plumbing* is implemented and testable end-to-end in the
emulator: state encoding/decoding, Firestore writes, token encryption,
usage-counter increments, and audit logging.

**What requires real app credentials before going live** (each is a
clearly marked `TODO` in the corresponding file):
- `functions/src/social-oauth/oauthCallback.ts` → `exchangeCodeForToken()`
  — implement the actual token-exchange HTTP calls to:
  - Meta: `POST https://graph.facebook.com/v19.0/oauth/access_token`
  - X/Twitter: `POST https://api.twitter.com/2/oauth2/token` (PKCE)
  - LinkedIn: `POST https://www.linkedin.com/oauth/v2/accessToken`
- `functions/src/social-oauth/refreshTokenIfNeeded.ts` →
  `refreshWithPlatform()` — implement each platform's refresh-token grant.
- `functions/src/scheduling/publishers/*.ts` — implement the actual
  publish API calls per platform.
- `functions/src/analytics/collectors/*.ts` — implement the actual
  insights/metrics API calls per platform.

## Getting App Credentials
- **Meta**: create an app at developers.facebook.com, add the Instagram
  Graph API + Facebook Login products, and go through App Review for the
  `instagram_content_publish` / `pages_manage_posts` permissions before
  requesting real user data (this can take days-to-weeks — plan for it).
- **X/Twitter**: create a project + app at developer.twitter.com,
  enable OAuth 2.0 with PKCE, request "Read and write" access.
- **LinkedIn**: create an app at developer.linkedin.com, request the
  Share on LinkedIn / Community Management API products.

## Redirect URIs
Set each platform's redirect URI to the deployed `oauthCallback` function
URL with the correct `?platform=` — see `functions/.env.example` for the
exact format. These must be registered in each platform's developer
console exactly as configured, or the OAuth flow will be rejected.

## Token Refresh & Reconnection
`refreshTokenIfNeededInternal` is called automatically before every
scheduled publish attempt. If a refresh fails (or no refresh token
exists), the social account's `connectionStatus` is set to
`needs_reconnect`, and the Flutter Connected Accounts screen surfaces a
"Reconnect" button that re-runs the OAuth flow for that platform.
