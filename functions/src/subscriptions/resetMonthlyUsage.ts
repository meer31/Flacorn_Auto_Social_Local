import { onSchedule } from "firebase-functions/v2/scheduler";
import { db, FieldValue } from "../config/firebase";
import { env } from "../config/env";

/**
 * resetMonthlyUsage — Scheduled Function
 * Runs at 00:00 UTC on the 1st of every month and resets aiGenerationsUsed /
 * scheduledPostsUsed counters for all active subscriptions.
 *
 * NOTE: For precise per-customer billing-cycle resets (rather than a fixed
 * calendar date), prefer driving this off Stripe's
 * `invoice.payment_succeeded` webhook event instead (see stripe/stripeWebhook.ts).
 * This scheduled job is a simple MVP-friendly fallback / safety net.
 */
export const resetMonthlyUsage = onSchedule(
  { schedule: "0 0 1 * *", timeZone: "UTC", region: env.functionsRegion, timeoutSeconds: 300 },
  async () => {
    const subsSnap = await db.collection("subscriptions").where("status", "==", "active").get();

    const batchSize = 400;
    let batch = db.batch();
    let count = 0;

    for (const doc of subsSnap.docs) {
      batch.update(doc.ref, {
        aiGenerationsUsed: 0,
        scheduledPostsUsed: 0,
        updatedAt: FieldValue.serverTimestamp(),
      });
      count++;
      if (count % batchSize === 0) {
        await batch.commit();
        batch = db.batch();
      }
    }
    if (count % batchSize !== 0) {
      await batch.commit();
    }

    console.log(`resetMonthlyUsage: reset usage counters for ${count} active subscriptions.`);
  }
);
