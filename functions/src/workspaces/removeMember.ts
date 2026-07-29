import { onCall } from "firebase-functions/v2/https";
import { z } from "zod";
import { db } from "../config/firebase";
import { env } from "../config/env";
import { requireWorkspaceRole, assertNotLastOwner } from "../middleware/workspaceGuard";

const InputSchema = z.object({
  workspaceId: z.string().min(1),
  memberUid: z.string().min(1),
});

/**
 * removeMember — HTTPS Callable.
 * Requires "admin" role or above. Refuses to remove the last remaining
 * owner (see assertNotLastOwner) so a workspace can never end up
 * ownerless.
 */
export const removeMember = onCall({ region: env.functionsRegion, timeoutSeconds: 30 }, async (request) => {
  const input = InputSchema.parse(request.data ?? {});
  await requireWorkspaceRole(request, input.workspaceId, "admin");
  await assertNotLastOwner(input.workspaceId, input.memberUid);

  await db.doc(`workspaces/${input.workspaceId}/members/${input.memberUid}`).delete();

  return { ok: true };
});
