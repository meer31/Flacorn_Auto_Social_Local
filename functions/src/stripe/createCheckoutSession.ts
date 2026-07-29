import { onCall, HttpsError } from "firebase-functions/v2/https";
import { z } from "zod";
import { requireAuth } from "../middleware/authGuard";
import { requireWorkspaceRole } from "../middleware/workspaceGuard";
import { stripe } from "./stripeClient";
import { env } from "../config/env";
import { db } from "../config/firebase";
import { PlanName } from "../config/plans";

const InputSchema = z.object({
  workspaceId: z.string().min(1),
  plan: z.enum(["starter", "pro", "agency"]),
  successUrl: z.string().url(),
  cancelUrl: z.string().url(),
});

const PRICE_ID_BY_PLAN: Record<"starter" | "pro" | "agency", string> = {
  starter: env.stripe.priceIds.starter,
  pro: env.stripe.priceIds.pro,
  agency: env.stripe.priceIds.agency,
};

/**
 * createCheckoutSession — HTTPS Callable (PDF Section 9).
 * Creates (or reuses) a Stripe Customer for the WORKSPACE, then returns a
 * Stripe Checkout Session URL for the Flutter app to open in a webview/browser.
 *
 * MIGRATION NOTE (Team/RBAC): billing is per-workspace now, shared by every
 * member — requires "admin" role or above to start checkout (an editor/
 * viewer teammate shouldn't be able to change the workspace's plan).
 * client_reference_id / metadata carry workspaceId (not firebaseUid) so
 * stripeWebhook.ts writes the resulting subscription to the right doc —
 * see that file's matching update.
 */
export const createCheckoutSession = onCall(
  { region: env.functionsRegion, timeoutSeconds: 30 },
  async (request) => {
    const uid = requireAuth(request);
    const input = InputSchema.parse(request.data);
    await requireWorkspaceRole(request, input.workspaceId, "admin");
    const priceId = PRICE_ID_BY_PLAN[input.plan as "starter" | "pro" | "agency"];

    if (!priceId) {
      throw new HttpsError("failed-precondition", "Stripe price ID is not configured for this plan.");
    }

    const workspaceSnap = await db.doc(`workspaces/${input.workspaceId}`).get();
    const workspaceData = workspaceSnap.data();
    if (!workspaceData) {
      throw new HttpsError("not-found", "Workspace not found.");
    }
    const userSnap = await db.doc(`users/${uid}`).get();
    const userData = userSnap.data();

    const subSnap = await db.doc(`subscriptions/${input.workspaceId}`).get();
    let stripeCustomerId = subSnap.exists ? (subSnap.data()?.stripeCustomerId as string) : undefined;

    if (!stripeCustomerId) {
      const customer = await stripe.customers.create({
        email: userData?.email,
        name: workspaceData.name ?? userData?.businessName ?? userData?.name,
        metadata: { workspaceId: input.workspaceId, createdByUid: uid },
      });
      stripeCustomerId = customer.id;
      await db.doc(`subscriptions/${input.workspaceId}`).set(
        { stripeCustomerId, planName: input.plan as PlanName, status: "incomplete" },
        { merge: true }
      );
    }

    const session = await stripe.checkout.sessions.create({
      mode: "subscription",
      customer: stripeCustomerId,
      line_items: [{ price: priceId, quantity: 1 }],
      success_url: input.successUrl,
      cancel_url: input.cancelUrl,
      client_reference_id: input.workspaceId,
      metadata: { workspaceId: input.workspaceId, plan: input.plan },
      subscription_data: {
        metadata: { workspaceId: input.workspaceId, plan: input.plan },
      },
      allow_promotion_codes: true,
    });

    return { checkoutUrl: session.url, sessionId: session.id };
  }
);
