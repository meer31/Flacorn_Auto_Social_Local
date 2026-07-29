import { CallableRequest, HttpsError } from "firebase-functions/v2/https";

/**
 * Throws an HttpsError if the caller is not authenticated.
 * Use at the top of every callable Cloud Function that requires a signed-in user.
 *
 * Usage:
 *   export const myFn = onCall((request) => {
 *     const uid = requireAuth(request);
 *     ...
 *   });
 */
export function requireAuth(request: CallableRequest): string {
  if (!request.auth || !request.auth.uid) {
    throw new HttpsError("unauthenticated", "You must be signed in to perform this action.");
  }
  return request.auth.uid;
}

/**
 * Throws an HttpsError if the caller does not have the `admin` custom claim.
 * Admin claims are set exclusively via a secure backend process
 * (see admin/promoteUserToAdmin.ts — Phase 2), never client-writable.
 */
export function requireAdmin(request: CallableRequest): string {
  const uid = requireAuth(request);
  if (request.auth?.token?.admin !== true) {
    throw new HttpsError("permission-denied", "Admin privileges are required for this action.");
  }
  return uid;
}

/**
 * Throws if the caller is not a verified member of the given agency.
 * TODO: wire up to agencies/{agencyId}/members/{uid} lookup once the
 * agency workspace feature (Phase 2 / Priority 5) is fully implemented.
 */
export async function requireAgencyMember(
  request: CallableRequest,
  agencyId: string
): Promise<string> {
  const uid = requireAuth(request);
  // Placeholder — replace with a Firestore existence check:
  // const memberDoc = await db.doc(`agencies/${agencyId}/members/${uid}`).get();
  // if (!memberDoc.exists) throw new HttpsError("permission-denied", ...);
  void agencyId;
  return uid;
}
