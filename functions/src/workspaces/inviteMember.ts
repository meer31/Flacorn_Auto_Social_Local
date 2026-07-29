import { onCall } from "firebase-functions/v2/https";
import { z } from "zod";
import { db, FieldValue } from "../config/firebase";
import { env } from "../config/env";
import { requireWorkspaceRole } from "../middleware/workspaceGuard";
import { createNotification } from "../notifications/createNotification";

const InputSchema = z.object({
  workspaceId: z.string().min(1),
  email: z.string().email(),
  role: z.enum(["admin", "editor", "viewer"]), // can't invite as owner
});

/**
 * inviteMember — HTTPS Callable.
 * Requires "admin" role or above in the target workspace. Creates a
 * pending invite doc; the invited person accepts via `acceptInvite` once
 * they sign up/in with the matching email.
 *
 * TODO: no email-sending infrastructure exists in this codebase yet
 * (no nodemailer/SendGrid/Resend dependency). Until that's added, the
 * invite is discoverable only via the in-app "Pending Invites" list for
 * a signed-in user whose email matches — good enough for internal/beta
 * use, not for inviting someone who doesn't have an account yet.
 */
export const inviteMember = onCall({ region: env.functionsRegion, timeoutSeconds: 30 }, async (request) => {
  const input = InputSchema.parse(request.data ?? {});
  const { uid } = await requireWorkspaceRole(request, input.workspaceId, "admin");

  const existingSnap = await db
    .collection("invites")
    .where("workspaceId", "==", input.workspaceId)
    .where("email", "==", input.email)
    .where("status", "==", "pending")
    .limit(1)
    .get();
  if (!existingSnap.empty) {
    return { inviteId: existingSnap.docs[0].id, alreadyPending: true };
  }

  const ref = db.collection("invites").doc();
  await ref.set({
    workspaceId: input.workspaceId,
    email: input.email,
    role: input.role,
    invitedBy: uid,
    status: "pending",
    createdAt: FieldValue.serverTimestamp(),
  });

  // If the invited email already has an account, notify them in-app.
  const userSnap = await db.collection("users").where("email", "==", input.email).limit(1).get();
  if (!userSnap.empty) {
    await createNotification({
      workspaceId: input.workspaceId,
      targetUid: userSnap.docs[0].id,
      type: "member_invited",
      title: "You've been invited to a workspace",
      message: `You've been invited to join as ${input.role}.`,
      actionRoute: "/settings/invites",
    });
  }

  return { inviteId: ref.id, alreadyPending: false };
});
