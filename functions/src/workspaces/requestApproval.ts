import { onCall, HttpsError } from "firebase-functions/v2/https";
import { z } from "zod";
import { db, FieldValue } from "../config/firebase";
import { env } from "../config/env";
import { requireWorkspaceRole } from "../middleware/workspaceGuard";
import { createNotification } from "../notifications/createNotification";

const InputSchema = z.object({
  workspaceId: z.string().min(1),
  scheduledPostId: z.string().min(1),
});

/**
 * requestApproval — HTTPS Callable.
 * Requires "editor" role or above (an editor can propose content but
 * can't publish directly — see WorkspaceMember.canPublishDirectly on the
 * frontend, and the mirrored rule in this function). Sets the scheduled
 * post's status to "pending_approval" and notifies every admin/owner in
 * the workspace.
 *
 * TODO: this fires unconditionally for editors. If a workspace later
 * wants a "no approval needed" toggle (e.g. a solo owner who added one
 * trusted editor), read that setting from workspaces/{workspaceId} here
 * and skip straight to publish-ready instead.
 */
export const requestApproval = onCall({ region: env.functionsRegion, timeoutSeconds: 30 }, async (request) => {
  const input = InputSchema.parse(request.data ?? {});
  const { uid } = await requireWorkspaceRole(request, input.workspaceId, "editor");

  const postRef = db.doc(`workspaces/${input.workspaceId}/scheduledPosts/${input.scheduledPostId}`);
  const postSnap = await postRef.get();
  if (!postSnap.exists) {
    throw new HttpsError("not-found", "Scheduled post not found.");
  }

  const approvalRef = db.collection(`workspaces/${input.workspaceId}/approvals`).doc();
  await approvalRef.set({
    scheduledPostId: input.scheduledPostId,
    requestedBy: uid,
    status: "pending",
    reviewedBy: null,
    note: null,
    createdAt: FieldValue.serverTimestamp(),
  });

  await postRef.update({ status: "pending_approval", approvalId: approvalRef.id });

  const adminsSnap = await db
    .collection(`workspaces/${input.workspaceId}/members`)
    .where("role", "in", ["owner", "admin"])
    .get();

  await Promise.all(
    adminsSnap.docs.map((doc) =>
      createNotification({
        workspaceId: input.workspaceId,
        targetUid: doc.id,
        type: "approval_requested",
        title: "Post awaiting your approval",
        message: "A teammate scheduled a post that needs your approval before it goes live.",
        actionRoute: "/team/approvals",
      })
    )
  );

  return { approvalId: approvalRef.id };
});
