import { CallableRequest, HttpsError } from "firebase-functions/v2/https";
import { db } from "../config/firebase";
import { requireAuth } from "./authGuard";

export type WorkspaceRole = "owner" | "admin" | "editor" | "viewer";

const ROLE_RANK: Record<WorkspaceRole, number> = {
  viewer: 0,
  editor: 1,
  admin: 2,
  owner: 3,
};

/**
 * Throws if the caller is not a member of the given workspace. Returns
 * their membership doc (including role) on success.
 *
 * This replaces the old `requireAgencyMember` TODO stub's intent, but
 * generalized: EVERY workspace (not just agency-owned ones) now has a
 * members subcollection, because Team collaboration is a feature every
 * plan tier gets — see docs/TEAM_RBAC.md for why this isn't scoped to
 * Agency accounts only.
 *
 * Usage:
 *   export const myFn = onCall(async (request) => {
 *     const uid = requireAuth(request);
 *     const membership = await requireWorkspaceMember(request, workspaceId);
 *     requireRole(membership.role, "editor"); // editor or above
 *     ...
 *   });
 */
export async function requireWorkspaceMember(
  request: CallableRequest,
  workspaceId: string
): Promise<{ uid: string; role: WorkspaceRole }> {
  const uid = requireAuth(request);
  const memberDoc = await db.doc(`workspaces/${workspaceId}/members/${uid}`).get();
  if (!memberDoc.exists) {
    throw new HttpsError("permission-denied", "You are not a member of this workspace.");
  }
  const role = (memberDoc.data()?.role as WorkspaceRole) ?? "viewer";
  return { uid, role };
}

/**
 * Throws unless `role` is at least `minimumRole` (owner > admin > editor >
 * viewer). Call after requireWorkspaceMember.
 */
export function requireRole(role: WorkspaceRole, minimumRole: WorkspaceRole): void {
  if (ROLE_RANK[role] < ROLE_RANK[minimumRole]) {
    throw new HttpsError(
      "permission-denied",
      `This action requires the "${minimumRole}" role or above.`
    );
  }
}

/**
 * Convenience: requireWorkspaceMember + requireRole in one call, since
 * almost every callable that touches workspace content needs both.
 */
export async function requireWorkspaceRole(
  request: CallableRequest,
  workspaceId: string,
  minimumRole: WorkspaceRole
): Promise<{ uid: string; role: WorkspaceRole }> {
  const membership = await requireWorkspaceMember(request, workspaceId);
  requireRole(membership.role, minimumRole);
  return membership;
}

/** Never allow removing the last owner — a workspace must always have one. */
export async function assertNotLastOwner(workspaceId: string, memberUidBeingRemoved: string): Promise<void> {
  const membersSnap = await db.collection(`workspaces/${workspaceId}/members`).where("role", "==", "owner").get();
  const remainingOwners = membersSnap.docs.filter((d) => d.id !== memberUidBeingRemoved);
  if (remainingOwners.length === 0) {
    throw new HttpsError("failed-precondition", "A workspace must always have at least one owner.");
  }
}
