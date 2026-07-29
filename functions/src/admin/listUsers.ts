import { onCall } from "firebase-functions/v2/https";
import { z } from "zod";
import { requireAdmin } from "../middleware/authGuard";
import { db } from "../config/firebase";
import { env } from "../config/env";

const InputSchema = z.object({
  limit: z.number().int().min(1).max(200).default(50),
  startAfterUserId: z.string().optional(),
  planFilter: z.string().optional(),
});

/**
 * listUsers — HTTPS Callable, admin-only.
 * Powers the Admin Panel's user list (PDF Section 30).
 * Requires the caller's Firebase Auth token to carry the `admin: true`
 * custom claim (set via a secure out-of-band process — never client-writable).
 */
export const listUsers = onCall(
  { region: env.functionsRegion, timeoutSeconds: 30 },
  async (request) => {
    requireAdmin(request);
    const input = InputSchema.parse(request.data ?? {});

    let query = db.collection("users").orderBy("createdAt", "desc").limit(input.limit);
    if (input.startAfterUserId) {
      const cursorDoc = await db.doc(`users/${input.startAfterUserId}`).get();
      if (cursorDoc.exists) {
        query = query.startAfter(cursorDoc);
      }
    }

    const snap = await query.get();
    const users = await Promise.all(
      snap.docs.map(async (doc) => {
        const subSnap = await db.doc(`subscriptions/${doc.id}`).get();
        const sub = subSnap.data();
        if (input.planFilter && sub?.planName !== input.planFilter) return null;
        return {
          userId: doc.id,
          ...doc.data(),
          plan: sub?.planName ?? null,
          subscriptionStatus: sub?.status ?? null,
        };
      })
    );

    return { users: users.filter(Boolean) };
  }
);
