# Flacron Social Auto

**Your AI Social Media Manager for daily posts, campaigns, AR content,
scheduling, analytics, and business growth.**

A scalable SaaS platform: Flutter (Web-first, mobile-ready) frontend +
Firebase (Auth, Firestore, Cloud Functions, Storage, Scheduler, Pub/Sub)
backend, Stripe billing, a provider-agnostic AI layer (Gemini / Claude /
OpenAI-compatible), and an AR-ready content preview system.

## Project Structure

```
flacron-social-auto/
├── docs/            Architecture, schema, security, deployment docs
├── frontend/         Flutter app (Web, Android, iOS)
│   └── lib/
│       ├── core/      theme, routing, constants, services, shared widgets
│       ├── features/  one folder per screen domain (auth, dashboard, ai_content, ...)
│       └── shared/    models, repositories, providers used across features
└── functions/        Firebase Cloud Functions backend (TypeScript)
    └── src/
        ├── config/        env, Firebase Admin SDK init, plan definitions
        ├── middleware/    auth/plan/rate-limit guards
        ├── utils/         encryption, audit logging, timestamps
        ├── user/ stripe/ subscriptions/ ai/ social-oauth/
        ├── scheduling/ analytics/ ar/ notifications/ admin/ audit/
        └── index.ts       exports every deployable function
```

See `docs/ARCHITECTURE.md` for the full data-flow diagram and
`docs/FIRESTORE_SCHEMA.md` for the complete database schema.

## Quick Start

```bash
# 1. Firebase project
firebase login
cp .firebaserc.example .firebaserc   # edit with your project ID(s)

# 2. Connect Flutter to Firebase
cd frontend && flutterfire configure && cd ..

# 3. Install dependencies
cd frontend && flutter pub get && cd ../functions && npm install && cd ..

# 4. Configure secrets
cp functions/.env.example functions/.env   # fill in real values

# 5. Run locally
firebase emulators:start &
cd frontend && flutter run -d chrome
```

Full deployment instructions: `docs/DEPLOYMENT.md`.

## What's Implemented

Every screen listed in the developer document is scaffolded and wired to
real Firestore streams and Cloud Functions: Auth (3 screens), Onboarding
(7 steps), Dashboard, Connected Accounts, AI Content Generator, 30-Day
Content Calendar, Campaigns, Scheduler, Templates, Analytics, Weekly
Reports, AR Campaigns, Billing, Settings, Media Library, Notifications,
Brand Kit, Agency Workspace, and Admin Panel.

Every Cloud Function in PDF Section 25 is implemented, including plan
gating, rate limiting, usage-limit enforcement, encrypted OAuth token
storage, Stripe webhook handling, the auto-publishing worker with retry
logic, and the daily analytics collector.

**What needs your real credentials before going live** (clearly marked
`TODO` in code): the literal HTTP calls to Meta/X/LinkedIn's publish and
insights APIs, and the AR image-compositing pipeline. See
`docs/ACCEPTANCE_CRITERIA.md` for the full breakdown and
`docs/SOCIAL_OAUTH.md` / `docs/AR_ROADMAP.md` for exactly what to
implement and where.

## Security

- No API keys, tokens, or secrets ever appear in `frontend/`.
- OAuth tokens are AES-256 encrypted at rest and only decrypted in-memory
  inside Cloud Functions.
- Firestore security rules enforce per-user data isolation and block
  client writes to sensitive fields (tokens, subscription status, audit
  logs) even on documents the user otherwise owns.
- Full breakdown: `docs/SECURITY_PLAN.md`.

## License
Proprietary — prepared for Flacron Enterprises.
