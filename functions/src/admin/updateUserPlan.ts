import { onCall } from "firebase-functions/v2/https";
import { z } from "zod";
import { requireAdmin } from "../middleware/authGuard";
import { db, FieldValue } from "../config/firebase";
import { writeAuditLog, extractRequestMeta } from "../utils/auditLog";
import { env } from "../config/env";

const InputSchema = z.object({
  userId: z.string().min(1),
  planName: z.enum(["starter", "pro", "agency", "enterprise"]),
  reason: z.string().optional(),
});

/**
 * updateUserPlan — HTTPS Callable, admin-only (PDF Section 30: Admin Panel —
 * "Change plan manually"). Bypasses Stripe entirely — use for support
 * overrides, comps, or enterprise custom deals. Does NOT create/modify any
 * Stripe subscription; billing must be reconciled separately if needed.
 */
export const updateUserPlan = onCall(
  { region: env.functionsRegion, timeoutSeconds: 15 },
  async (request) => {
    const adminUid = requireAdmin(request);
    const input = InputSchema.parse(request.data);

    await db.doc(`subscriptions/${input.userId}`).set(
      {
        planName: input.planName,
        status: "active",
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    await writeAuditLog({
      userId: adminUid,
      action: "admin.plan_override",
      resourceType: "subscription",
      resourceId: input.userId,
      ...extractRequestMeta(request),
    });

    return { success: true };
  }
);
