import { onCall, HttpsError } from "firebase-functions/v2/https";
import { requireAuth } from "../middleware/authGuard";
import { stripe } from "./stripeClient";
import { env } from "../config/env";
import { db } from "../config/firebase";

/**
 * getBillingPortalUrl — HTTPS Callable (PDF Section 9).
 * Returns a Stripe Customer Portal URL so the user can manage/cancel their
 * subscription, update payment methods, and view invoices without any
 * custom billing UI needing to be built in Flutter.
 */
export const getBillingPortalUrl = onCall(
  { region: env.functionsRegion, timeoutSeconds: 20 },
  async (request) => {
    const uid = requireAuth(request);

    const subSnap = await db.doc(`subscriptions/${uid}`).get();
    const stripeCustomerId = subSnap.data()?.stripeCustomerId as string | undefined;

    if (!stripeCustomerId) {
      throw new HttpsError("failed-precondition", "No Stripe customer found for this account.");
    }

    const portalSession = await stripe.billingPortal.sessions.create({
      customer: stripeCustomerId,
      return_url: env.stripe.portalReturnUrl,
    });

    return { url: portalSession.url };
  }
);
