import { beforeUserCreated } from "firebase-functions/v2/identity";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { db, FieldValue } from "../config/firebase";
import { env } from "../config/env";

/**
 * onUserCreate — Auth Trigger (PDF Section 7).
 * Fires when a new Firebase Auth user is created and auto-provisions:
 *   1. Their Firestore user PROFILE document (identity only).
 *   2. A default WORKSPACE they own (all content — social accounts,
 *      posts, campaigns, etc. — lives under workspaces/{workspaceId}/**,
 *      not under users/{uid}/** — see docs/TEAM_RBAC.md for why every
 *      account, not just Agency, needs a workspace to support the Team
 *      feature).
 *   3. Their OWNER membership in that workspace.
 *   4. A default "incomplete" subscription record, now keyed by
 *      workspaceId (billing belongs to the workspace, shared by every
 *      teammate in it — not to the individual user).
 *
 * Note: The Flutter app should still call `updateUserProfile` right after
 * signup to fill in businessName/businessCategory/etc. from onboarding,
 * and `updateWorkspaceDetails` (TODO) for workspace-level business info.
 */
export const onAuthUserCreate = beforeUserCreated({ region: env.functionsRegion }, async (event) => {
  const user = event.data;
  if (!user) return;

  const workspaceRef = db.collection("workspaces").doc();
  const workspaceId = workspaceRef.id;

  await db.doc(`users/${user.uid}`).set(
    {
      name: user.displayName ?? "",
      email: user.email ?? "",
      businessName: "",
      businessCategory: "",
      // NOTE: `role` here is a legacy field from the old single-tenant
      // model — the real, enforced role now lives on the workspace
      // membership doc (workspaces/{workspaceId}/members/{uid}.role).
      role: "owner",
      timezone: "UTC",
      mainGoal: "",
      brandTone: "",
      defaultWorkspaceId: workspaceId,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true }
  );

  await workspaceRef.set({
    name: user.displayName ? `${user.displayName}'s Workspace` : "My Workspace",
    ownerUid: user.uid,
    businessCategory: "",
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });

  await workspaceRef.collection("members").doc(user.uid).set({
    role: "owner",
    invitedBy: null,
    joinedAt: FieldValue.serverTimestamp(),
  });

  await db.doc(`subscriptions/${workspaceId}`).set(
    {
      planName: "starter",
      status: "incomplete",
      aiGenerationLimit: 10,
      scheduledPostLimit: 10,
      socialAccountLimit: 3,
      aiGenerationsUsed: 0,
      scheduledPostsUsed: 0,
      arAccess: false,
      agencyAccess: false,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true }
  );
});

/**
 * Alternative Firestore-trigger version, useful if you prefer provisioning
 * to happen only after the client writes the initial `users/{uid}` doc
 * (e.g. if you collect extra onboarding fields client-side before creation).
 * Keep only ONE of these two triggers active depending on your chosen flow.
 *
 * NOTE: this variant does NOT currently create a workspace (it assumes
 * onAuthUserCreate above already did). Only relevant if you switch flows —
 * update it to mirror onAuthUserCreate's workspace provisioning if so.
 */
export const onUserDocCreate = onDocumentCreated(
  { document: "users/{userId}", region: env.functionsRegion },
  async (event) => {
    const userId = event.params.userId;
    const userDoc = await db.doc(`users/${userId}`).get();
    const workspaceId = userDoc.data()?.defaultWorkspaceId;
    if (!workspaceId) return; // onAuthUserCreate variant is active; nothing to do here

    const subRef = db.doc(`subscriptions/${workspaceId}`);
    const subSnap = await subRef.get();
    if (!subSnap.exists) {
      await subRef.set({
        planName: "starter",
        status: "incomplete",
        aiGenerationLimit: 10,
        scheduledPostLimit: 10,
        socialAccountLimit: 3,
        aiGenerationsUsed: 0,
        scheduledPostsUsed: 0,
        arAccess: false,
        agencyAccess: false,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
  }
);
