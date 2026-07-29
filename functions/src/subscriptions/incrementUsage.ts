import { db, FieldValue } from "../config/firebase";

export type UsageField = "aiGenerationsUsed" | "scheduledPostsUsed" | "socialAccountsUsed";

/**
 * Shared helper to atomically increment a usage counter on a user's
 * subscription document. Called from AI generation functions, the
 * scheduling functions, and the social OAuth connect function.
 *
 * Not exposed as a public callable — internal helper only, since usage
 * should only ever be incremented as a side effect of a verified action.
 */
export async function incrementUsage(userId: string, field: UsageField, by = 1): Promise<void> {
  await db.doc(`subscriptions/${userId}`).set({ [field]: FieldValue.increment(by) }, { merge: true });
}

export async function decrementUsage(userId: string, field: UsageField, by = 1): Promise<void> {
  await db.doc(`subscriptions/${userId}`).set({ [field]: FieldValue.increment(-by) }, { merge: true });
}
