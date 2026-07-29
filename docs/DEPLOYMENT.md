# Deployment Guide

## Prerequisites
- Node.js 20+, npm
- Flutter SDK (stable channel, 3.27+ — required for the `Color.withValues()` API used throughout the theme)
- Firebase CLI: `npm install -g firebase-tools`
- A Firebase project (Blaze/pay-as-you-go plan — required for Cloud
  Functions with outbound network access, e.g. calling Stripe/AI/social APIs)
- FlutterFire CLI: `dart pub global activate flutterfire_cli`

## 1. Firebase Project Setup
```bash
firebase login
firebase projects:create flacron-auto-social-dev   # or use an existing project
cp .firebaserc.example .firebaserc                  # then edit with your real project IDs
```

## 2. Configure Flutter ↔ Firebase
```bash
cd frontend
flutterfire configure
```
This overwrites `lib/core/services/firebase_options.dart` with real
values for your project and registers web/Android/iOS apps as needed.

## 3. Install Dependencies
```bash
# Frontend
cd frontend
flutter pub get

# Backend
cd ../functions
npm install
```

## 4. Configure Environment Variables
```bash
cd functions
cp .env.example .env
# Fill in real values: Stripe keys, AI provider key(s), social app
# credentials, TOKEN_ENCRYPTION_KEY (generate with:
#   node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
# )
```
For deployed (non-emulator) environments, set the same values as Firebase
Functions secrets instead of relying on a committed `.env`:
```bash
firebase functions:secrets:set STRIPE_SECRET_KEY
firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
firebase functions:secrets:set GEMINI_API_KEY
# ...repeat for every secret in .env.example
```

## 5. Deploy Firestore Rules, Indexes, and Storage Rules
```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
```

## 6. Deploy Cloud Functions
```bash
cd functions
npm run build
firebase deploy --only functions
```
After deploying, note the region + project ID in your function URLs
(e.g. `https://us-central1-flacron-auto-social-dev.cloudfunctions.net/...`)
and:
- Register `oauthCallback` as each social platform's OAuth redirect URI.
- Register `stripeWebhook` as your Stripe webhook endpoint, then copy the
  signing secret back into your secrets/`.env`.

## 7. Build & Deploy Flutter Web
```bash
cd frontend
flutter build web --release
firebase deploy --only hosting
```

## 8. Local Development (Emulator Suite)
```bash
# Terminal 1 — backend emulators
cd functions
npm run build:watch

# Terminal 2
firebase emulators:start

# Terminal 3 — Flutter Web against emulators
cd frontend
flutter run -d chrome --dart-define=USE_EMULATOR=true
```
Uncomment the emulator-connection block in `frontend/lib/main.dart` and
gate it behind `USE_EMULATOR` before running against emulators locally.

## 9. Mobile Builds (Android / iOS)
```bash
cd frontend
flutter build apk --release          # Android
flutter build ios --release          # iOS (requires macOS + Xcode + signing setup)
```
Run `flutterfire configure` again if you add Android/iOS as new
FlutterFire platforms (it will add `google-services.json` /
`GoogleService-Info.plist` automatically).

## 10. Post-Deploy Checklist
- [ ] Stripe webhook receiving events (check Stripe Dashboard → Webhooks → recent deliveries)
- [ ] `runScheduledPosts` and `collectInsights` show green runs in Cloud Scheduler
- [ ] Firestore rules deployed match `firestore.rules` in this repo (no console drift)
- [ ] Real social platform credentials configured and app review completed (Meta especially)
- [ ] `TOKEN_ENCRYPTION_KEY` is a strong, unique value — never reused across environments
- [ ] Admin custom claim set for at least one account (see `SECURITY_PLAN.md` §3)
