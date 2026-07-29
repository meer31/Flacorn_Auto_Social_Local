import { onCall, HttpsError } from "firebase-functions/v2/https";
import { z } from "zod";
import { requireAuth } from "../middleware/authGuard";
import { db } from "../config/firebase";
import { decrementUsage } from "../subscriptions/incrementUsage";
import { writeAuditLog, extractRequestMeta } from "../utils/auditLog";
import { env } from "../config/env";

const InputSchema = z.object({
  socialAccountId: z.string().min(1),
});

/**
 * disconnectSocialAccount — HTTPS Callable (PDF Section 10).
 * Deletes the stored (encrypted) tokens and removes the account document.
 * Frees up one slot in the user's socialAccountLimit.
 */
export const disconnectSocialAccount = onCall(
  { region: env.functionsRegion, timeoutSeconds: 15 },
  async (request) => {
    const uid = requireAuth(request);
    const { socialAccountId } = InputSchema.parse(request.data);

    const ref = db.doc(`users/${uid}/socialAccounts/${socialAccountId}`);
    const snap = await ref.get();
    if (!snap.exists) {
      throw new HttpsError("not-found", "Social account not found.");
    }

    await ref.delete();
    await decrementUsage(uid, "socialAccountsUsed");
    await writeAuditLog({
      userId: uid,
      action: "social_account.disconnected",
      resourceType: "socialAccount",
      resourceId: socialAccountId,
      ...extractRequestMeta(request),
    });

    return { success: true };
  }
);
