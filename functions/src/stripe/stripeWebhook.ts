import { onRequest } from "firebase-functions/v2/https";
import Stripe from "stripe";
import { stripe } from "./stripeClient";
import { env } from "../config/env";
import { db, FieldValue } from "../config/firebase";
import { writeAuditLog } from "../utils/auditLog";
import { PlanName } from "../config/plans";

/**
 * stripeWebhook — HTTPS Request Function (PDF Section 9).
 *
 * IMPORTANT: This must be deployed as a raw HTTP function (not a callable),
 * because Stripe needs to POST directly with a verifiable signature header.
 * In `firebase.json` / hosting config, make sure this endpoint receives the
 * *raw* request body (do not JSON-parse it upstream) so signature
 * verification succeeds.
 *
 * Configure the endpoint URL in the Stripe Dashboard as:
 *   https://{region}-{projectId}.cloudfunctions.net/stripeWebhook
 *
 * MIGRATION NOTE (Team/RBAC): subscriptions are now keyed by workspaceId,
 * not firebaseUid — createCheckoutSession.ts sets metadata.workspaceId /
 * client_reference_id to the workspace, and every handler below reads
 * that instead of the old metadata.firebaseUid. writeAuditLog's `userId`
 * field is a known imprecision here (Stripe webhooks don't carry which
 * specific teammate triggered the original checkout) — it currently
 * receives the workspaceId as a placeholder. Widening AuditLogEntry to a
 * proper `workspaceId` field is a separate, small follow-up.
 */
export const stripeWebhook = onRequest(
  { region: env.functionsRegion, timeoutSeconds: 30 },
  async (req, res) => {
    const signature = req.headers["stripe-signature"];
    if (!signature) {
      res.status(400).send("Missing Stripe signature header.");
      return;
    }

    let event: Stripe.Event;
    try {
      // req.rawBody is provided by Firebase Functions for onRequest handlers.
      event = stripe.webhooks.constructEvent(
        (req as unknown as { rawBody: Buffer }).rawBody,
        signature,
        env.stripe.webhookSecret
      );
    } catch (err) {
      console.error("stripeWebhook: signature verification failed", err);
      res.status(400).send(`Webhook signature verification failed.`);
      return;
    }

    try {
      switch (event.type) {
        case "checkout.session.completed": {
          const session = event.data.object as Stripe.Checkout.Session;
          const workspaceId = session.client_reference_id ?? session.metadata?.workspaceId;
          const plan = session.metadata?.plan as PlanName | undefined;
          if (workspaceId) {
            await db.doc(`subscriptions/${workspaceId}`).set(
              {
                planName: plan ?? "starter",
                stripeCustomerId: session.customer as string,
                stripeSubscriptionId: session.subscription as string,
                status: "active",
                aiGenerationsUsed: 0,
                scheduledPostsUsed: 0,
                updatedAt: FieldValue.serverTimestamp(),
              },
              { merge: true }
            );
            await writeAuditLog({
              userId: workspaceId,
              action: "subscription.activated",
              resourceType: "subscription",
              resourceId: session.subscription as string,
            });
          }
          break;
        }

        case "customer.subscription.updated": {
          const subscription = event.data.object as Stripe.Subscription;
          const workspaceId = subscription.metadata?.workspaceId;
          if (workspaceId) {
            await db.doc(`subscriptions/${workspaceId}`).set(
              {
                status: subscription.status,
                currentPeriodStart: new Date(subscription.current_period_start * 1000).toISOString(),
                currentPeriodEnd: new Date(subscription.current_period_end * 1000).toISOString(),
                updatedAt: FieldValue.serverTimestamp(),
              },
              { merge: true }
            );
          }
          break;
        }

        case "customer.subscription.deleted": {
          const subscription = event.data.object as Stripe.Subscription;
          const workspaceId = subscription.metadata?.workspaceId;
          if (workspaceId) {
            await db.doc(`subscriptions/${workspaceId}`).set(
              { status: "canceled", updatedAt: FieldValue.serverTimestamp() },
              { merge: true }
            );
            await writeAuditLog({
              userId: workspaceId,
              action: "subscription.canceled",
              resourceType: "subscription",
              resourceId: subscription.id,
            });
          }
          break;
        }

        case "invoice.payment_succeeded": {
          const invoice = event.data.object as Stripe.Invoice;
          const workspaceId = invoice.subscription_details?.metadata?.workspaceId;
          if (workspaceId) {
            // Reset monthly usage counters on successful renewal payment —
            // more precise than the calendar-based resetMonthlyUsage job.
            await db.doc(`subscriptions/${workspaceId}`).set(
              {
                aiGenerationsUsed: 0,
                scheduledPostsUsed: 0,
                status: "active",
                updatedAt: FieldValue.serverTimestamp(),
              },
              { merge: true }
            );
          }
          break;
        }

        case "invoice.payment_failed": {
          const invoice = event.data.object as Stripe.Invoice;
          const workspaceId = invoice.subscription_details?.metadata?.workspaceId;
          if (workspaceId) {
            await db.doc(`subscriptions/${workspaceId}`).set(
              { status: "past_due", updatedAt: FieldValue.serverTimestamp() },
              { merge: true }
            );
            // TODO (Phase 2): trigger a "payment failed" notification/email
            // to every admin/owner in the workspace (see createNotification).
          }
          break;
        }

        default:
          console.log(`stripeWebhook: unhandled event type ${event.type}`);
      }

      res.status(200).json({ received: true });
    } catch (err) {
      console.error("stripeWebhook: handler error", err);
      res.status(500).send("Webhook handler failed.");
    }
  }
);
