import { onCall, HttpsError } from "firebase-functions/v2/https";
import { z } from "zod";
import { db, FieldValue } from "../config/firebase";
import { env } from "../config/env";
import { requireWorkspaceRole } from "../middleware/workspaceGuard";
import { createNotification } from "../notifications/createNotification";

const InputSchema = z.object({
  workspaceId: z.string().min(1),
  approvalId: z.string().min(1),
  approve: z.boolean(),
  note: z.string().optional(),
});

/**
 * decideApproval — HTTPS Callable.
 * Requires "admin" role or above. Approving sets the linked scheduled
 * post back to "pending" (i.e. queued for the normal runScheduledPosts
 * worker to publish it at its scheduledAt time); rejecting sets it to
 * "draft" so the original author can revise and resubmit.
 */
export const decideApproval = onCall({ region: env.functionsRegion, timeoutSeconds: 30 }, async (request) => {
  const input = InputSchema.parse(request.data ?? {});
  const { uid } = await requireWorkspaceRole(request, input.workspaceId, "admin");

  const approvalRef = db.doc(`workspaces/${input.workspaceId}/approvals/${input.approvalId}`);
  const approvalSnap = await approvalRef.get();
  if (!approvalSnap.exists) {
    throw new HttpsError("not-found", "Approval request not found.");
  }
  const approval = approvalSnap.data()!;
  if (approval.status !== "pending") {
    throw new HttpsError("failed-precondition", "This approval has already been decided.");
  }

  const newStatus = input.approve ? "approved" : "rejected";
  await approvalRef.update({
    status: newStatus,
    reviewedBy: uid,
    note: input.note ?? null,
    decidedAt: FieldValue.serverTimestamp(),
  });

  const postRef = db.doc(
    `workspaces/${input.workspaceId}/scheduledPosts/${approval.scheduledPostId}`
  );
  await postRef.update({
    status: input.approve ? "pending" : "draft",
  });

  await createNotification({
    workspaceId: input.workspaceId,
    targetUid: approval.requestedBy,
    type: "approval_decided",
    title: input.approve ? "Your post was approved" : "Your post needs changes",
    message: input.approve
      ? "Your scheduled post was approved and will publish as planned."
      : `Your scheduled post was sent back for revision.${input.note ? ` Note: ${input.note}` : ""}`,
    actionRoute: "/scheduler",
  });

  return { ok: true, status: newStatus };
});
