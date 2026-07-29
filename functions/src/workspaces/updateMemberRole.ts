import { onCall, HttpsError } from "firebase-functions/v2/https";
import { z } from "zod";
import { db, FieldValue } from "../config/firebase";
import { env } from "../config/env";
import { requireWorkspaceRole } from "../middleware/workspaceGuard";

const InputSchema = z.object({
  workspaceId: z.string().min(1),
  memberUid: z.string().min(1),
  role: z.enum(["owner", "admin", "editor", "viewer"]),
});

/**
 * updateMemberRole — HTTPS Callable.
 * Requires "admin" role or above. Admins cannot promote themselves (or
 * anyone) to "owner" — only an existing owner can hand off ownership,
 * and only "owner" role can create another owner.
 */
export const updateMemberRole = onCall({ region: env.functionsRegion, timeoutSeconds: 30 }, async (request) => {
  const input = InputSchema.parse(request.data ?? {});
  const { uid, role: callerRole } = await requireWorkspaceRole(request, input.workspaceId, "admin");

  if (input.role === "owner" && callerRole !== "owner") {
    throw new HttpsError("permission-denied", "Only an owner can grant ownership.");
  }
  if (input.memberUid === uid && input.role !== callerRole) {
    // Prevent accidentally locking yourself out by changing your own role
    // via this endpoint — ownership transfer should be an explicit,
    // separate confirmed action (TODO: add transferOwnership.ts if needed).
    throw new HttpsError("failed-precondition", "You cannot change your own role here.");
  }

  await db.doc(`workspaces/${input.workspaceId}/members/${input.memberUid}`).update({
    role: input.role,
    updatedAt: FieldValue.serverTimestamp(),
  });

  return { ok: true };
});
