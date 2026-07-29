import { onCall, HttpsError } from "firebase-functions/v2/https";
import { z } from "zod";
import { requireAuth } from "../middleware/authGuard";
import { db, FieldValue } from "../config/firebase";
import { env } from "../config/env";

const InputSchema = z.object({
  notificationId: z.string().min(1),
});

/**
 * markNotificationRead — HTTPS Callable.
 * Client-facing counterpart to createNotification — this is also mirrored
 * by the Firestore rule permitting the owner to update only `read`/`readAt`.
 */
export const markNotificationRead = onCall(
  { region: env.functionsRegion, timeoutSeconds: 10 },
  async (request) => {
    const uid = requireAuth(request);
    const { notificationId } = InputSchema.parse(request.data);

    const ref = db.doc(`users/${uid}/notifications/${notificationId}`);
    const snap = await ref.get();
    if (!snap.exists) {
      throw new HttpsError("not-found", "Notification not found.");
    }

    await ref.update({ read: true, readAt: FieldValue.serverTimestamp() });
    return { success: true };
  }
);
