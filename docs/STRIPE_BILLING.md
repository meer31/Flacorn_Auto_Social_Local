# Stripe Billing Integration

## Setup Checklist
1. Create a Stripe account (or use an existing one) and switch to Test mode.
2. Create three **Products**, each with one recurring monthly **Price**:
   - Starter — $29/month
   - Pro — $79/month
   - Agency — $199/month
3. Copy each Price ID into `functions/.env`:
   ```
   STRIPE_PRICE_ID_STARTER=price_...
   STRIPE_PRICE_ID_PRO=price_...
   STRIPE_PRICE_ID_AGENCY=price_...
   ```
4. Copy your Stripe **Secret key** into `STRIPE_SECRET_KEY`.
5. Deploy functions, then in the Stripe Dashboard add a webhook endpoint:
   ```
   https://{region}-{projectId}.cloudfunctions.net/stripeWebhook
   ```
   Subscribe to: `checkout.session.completed`,
   `customer.subscription.updated`, `customer.subscription.deleted`,
   `invoice.payment_succeeded`, `invoice.payment_failed`.
6. Copy the webhook's **Signing secret** into `STRIPE_WEBHOOK_SECRET`.

## Flow
1. Flutter calls `createCheckoutSession` with `{ plan, successUrl,
   cancelUrl }`.
2. The function creates (or reuses) a Stripe Customer tied to the user's
   `subscriptions/{userId}.stripeCustomerId`, then creates a Checkout
   Session and returns its URL.
3. Flutter opens the URL externally (`url_launcher`) — Stripe hosts the
   actual payment form; no card data ever touches our servers or the
   Flutter app.
4. On success, Stripe redirects to `successUrl` AND fires
   `checkout.session.completed` to our webhook, which activates the
   subscription in Firestore (`status: "active"`, correct `planName`,
   usage counters reset).
5. Ongoing lifecycle events (renewals, cancellations, failed payments)
   keep `subscriptions/{userId}` in sync automatically via the webhook.

## Managing an Existing Subscription
`getBillingPortalUrl` returns a Stripe-hosted Customer Portal link where
users can update payment methods, view invoices, or cancel — no custom
billing UI required for that part.

## Add-Ons (Phase 1.5 / Not Yet Wired to Checkout)
`functions/src/config/plans.ts` documents the intended add-on pricing
(extra AI generations, extra social accounts, AR campaign packs,
done-for-you setup, AI Brand Kit, agency white-label mode, industry
template packs). Wiring these to Stripe requires either:
- Separate one-time/recurring Prices + a dedicated
  `createAddOnCheckoutSession` function, or
- Stripe "quantity" on an existing subscription item.
Left as a clearly-scoped Phase 2 task since it depends on final go-to-market
pricing decisions.

## Manual Overrides
Admins can bypass Stripe entirely via `updateUserPlan` (Admin Panel) for
comps, support cases, or enterprise custom deals — this does not create
or modify any Stripe object, so reconcile manually if the customer should
also be billed outside Stripe.
