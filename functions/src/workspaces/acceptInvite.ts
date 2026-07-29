import { onCall, HttpsError } from "firebase-functions/v2/https";
import { z } from "zod";
import { db, FieldValue } from "../config/firebase";
import { env } from "../config/env";
import { requireAuth } from "../middleware/authGuard";

const InputSchema = z.object({
  inviteId: z.string().min(1),
});

/**
 * acceptInvite — HTTPS Callable.
 * The signed-in user must have the same email the invite was sent to
 * (checked server-side against their Auth token, never trusted from the
 * client). Creates their workspace membership doc and marks the invite
 * accepted.
 */
export const acceptInvite = onCall({ region: env.functionsRegion, timeoutSeconds: 30 }, async (request) => {
  const uid = requireAuth(request);
  const input = InputSchema.parse(request.data ?? {});
  const callerEmail = request.auth?.token?.email as string | undefined;

  const inviteRef = db.doc(`invites/${input.inviteId}`);
  const inviteSnap = await inviteRef.get();
  if (!inviteSnap.exists) {
    throw new HttpsError("not-found", "Invite not found.");
  }
  const invite = inviteSnap.data()!;

  if (invite.status !== "pending") {
    throw new HttpsError("failed-precondition", "This invite has already been used.");
  }
  if (!callerEmail || callerEmail.toLowerCase() !== (invite.email as string).toLowerCase()) {
    throw new HttpsError("permission-denied", "This invite was sent to a different email address.");
  }

  const workspaceId = invite.workspaceId as string;
  const batch = db.batch();
  batch.set(db.doc(`workspaces/${workspaceId}/members/${uid}`), {
    role: invite.role,
    invitedBy: invite.invitedBy,
    joinedAt: FieldValue.serverTimestamp(),
  });
  batch.update(inviteRef, { status: "accepted", acceptedAt: FieldValue.serverTimestamp(), acceptedBy: uid });
  await batch.commit();

  return { workspaceId };
});
