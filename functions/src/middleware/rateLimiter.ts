import { HttpsError } from "firebase-functions/v2/https";
import { db, FieldValue, Timestamp } from "../config/firebase";
import type { Timestamp as FirestoreTimestamp } from "firebase-admin/firestore";

/**
 * Simple Firestore-backed sliding-window rate limiter.
 *
 * Stores a counter document at `_rateLimits/{userId}_{bucket}` with a
 * `windowStart` timestamp and `count`. Good enough for MVP-scale traffic;
 * consider migrating to Redis/Memorystore if AI generation volume grows.
 *
 * Usage:
 *   await enforceRateLimit(uid, "ai-generation", env.rateLimits.aiPerMinute, 60);
 */
export async function enforceRateLimit(
  userId: string,
  bucket: string,
  maxRequests: number,
  windowSeconds: number
): Promise<void> {
  const ref = db.doc(`_rateLimits/${userId}_${bucket}`);

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const now = Timestamp.now();

    if (!snap.exists) {
      tx.set(ref, { windowStart: now, count: 1 });
      return;
    }

    const data = snap.data() as { windowStart: FirestoreTimestamp; count: number };;
    const elapsedSeconds = now.seconds - data.windowStart.seconds;

    if (elapsedSeconds > windowSeconds) {
      // Window expired — reset.
      tx.set(ref, { windowStart: now, count: 1 });
      return;
    }

    if (data.count >= maxRequests) {
      throw new HttpsError(
        "resource-exhausted",
        `Too many requests. Please wait a moment before trying again.`
      );
    }

    tx.update(ref, { count: FieldValue.increment(1) });
  });
}
