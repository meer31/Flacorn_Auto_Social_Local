# Team / RBAC Migration

**Decision: Option A — full `workspaces` migration** (not Agency-scoped).
Every account gets team collaboration, not just Agency-tier customers —
this is what the client's Team requirement (members/roles/approval
workflow) actually asks for, and what "Hair Salons, Restaurants, Real
Estate, Coaches..." as target customers implies: a restaurant owner
adding their social media manager has nothing to do with the Agency
feature (Agency = one agency managing several separate *client*
businesses; Team = several *people* sharing *one* business).

## The core change

Every content collection moved from `users/{userId}/**` to
`workspaces/{workspaceId}/**`. `users/{userId}` is now identity/profile
only (name, email, `defaultWorkspaceId`) — it owns nothing.

```
OLD                                    NEW
users/{uid}/socialAccounts/**    →    workspaces/{workspaceId}/socialAccounts/**
users/{uid}/scheduledPosts/**    →    workspaces/{workspaceId}/scheduledPosts/**
users/{uid}/campaigns/**         →    workspaces/{workspaceId}/campaigns/**
users/{uid}/media/**             →    workspaces/{workspaceId}/media/**
users/{uid}/postTemplates/**     →    workspaces/{workspaceId}/postTemplates/**
users/{uid}/contentPlans/**      →    workspaces/{workspaceId}/contentPlans/**
users/{uid}/brandVoice/**        →    workspaces/{workspaceId}/brandVoice/**
users/{uid}/businessSettings/**  →    workspaces/{workspaceId}/businessSettings/**
users/{uid}/notifications/**     →    workspaces/{workspaceId}/notifications/**
users/{uid}/weeklyReports/**     →    workspaces/{workspaceId}/weeklyReports/**
users/{uid}/arCampaigns/**       →    workspaces/{workspaceId}/arCampaigns/**
users/{uid}/searchIndex/**       →    workspaces/{workspaceId}/searchIndex/**
subscriptions/{uid}              →    subscriptions/{workspaceId}
```

New: `workspaces/{workspaceId}/members/{uid}` (role: owner/admin/editor/
viewer), `workspaces/{workspaceId}/approvals/{approvalId}`, top-level
`invites/{inviteId}`.

## What's done (this pass)

**Foundation:**
- `frontend/lib/shared/models/workspace.dart` — `Workspace`, `WorkspaceMember`, `ApprovalRequest`
- `frontend/lib/shared/repositories/workspace_repository.dart`
- `frontend/lib/shared/providers/workspace_providers.dart` — `currentWorkspaceIdProvider`, `currentMembershipProvider`, `canManageMembersProvider`, `canApproveProvider`, `canCreateContentProvider`, `canPublishDirectlyProvider` — **gate UI with these, never inline `if (role == ...)` checks**
- `frontend/lib/core/services/firebase_service.dart` — added `workspaceDoc`/`workspaceSubcollection`, `subscriptionDoc` now takes `workspaceId`
- `frontend/lib/shared/models/user_profile.dart` — added `defaultWorkspaceId`, deprecated the old `role` field
- `functions/src/middleware/workspaceGuard.ts` — `requireWorkspaceMember`, `requireRole`, `requireWorkspaceRole`, `assertNotLastOwner`
- `functions/src/user/onUserCreate.ts` — now provisions a default workspace + owner membership + workspace-keyed subscription at signup

**Team feature (functional, end to end):**
- Callables: `inviteMember`, `acceptInvite`, `updateMemberRole`, `removeMember`, `requestApproval`, `decideApproval` (`functions/src/workspaces/`)
- `frontend/lib/features/team/screens/team_screen.dart` — Members tab (invite dialog, role dropdown, remove) + Approvals tab
- `firestore.rules` — fully rewritten around `isWorkspaceMember`/`canEditWorkspaceContent`/`isWorkspaceAdmin`

**Fixed because they'd have broken immediately otherwise (not deferred to the checklist):**
- `functions/src/notifications/createNotification.ts` — workspace-scoped, added `targetUid` for per-member notifications (approval requests need to notify specific admins, not everyone)
- `functions/src/search/indexSearchableEntities.ts` + `frontend/.../search_repository.dart` + `global_search_screen.dart` — Global Search now indexes/reads per-workspace
- `functions/src/stripe/createCheckoutSession.ts` + `stripeWebhook.ts` — billing is per-workspace, checkout requires "admin" role, Stripe metadata carries `workspaceId` not `firebaseUid`
- `frontend/.../subscription_repository.dart` + `billing_screen.dart` — `startCheckout` now requires `workspaceId`

## What's left — mechanical, same pattern every time

For each file below: change the `userId`/`uid` parameter to `workspaceId`,
change every `users/${userId}/X` or `userSubcollection(userId, 'X')` to
`workspaces/${workspaceId}/X` / `workspaceSubcollection(workspaceId, 'X')`,
and where the function mutates content, swap `requireAuth(request)` alone
for `requireWorkspaceRole(request, workspaceId, 'editor')` (or `'admin'`
for settings/brand-voice-type changes — see `firestore.rules` for which
role each collection needs).

**Frontend repositories:**
- `shared/repositories/scheduling_repository.dart`
- `shared/repositories/social_account_repository.dart`
- `shared/repositories/content_repository.dart`
- `shared/repositories/analytics_repository.dart`
- `shared/repositories/ar_repository.dart`

**Frontend screens reading `userId`/`uid` directly instead of through a repository:**
- `features/brand_kit/screens/brand_kit_screen.dart`
- `features/media_library/screens/media_library_screen.dart`
- `features/notifications/screens/notifications_screen.dart`

**Backend Cloud Functions:**
- `functions/src/ai/generateCampaign.ts`, `generateContentPlan.ts`, `generatePosts.ts`, `generateWeeklyReport.ts`
- `functions/src/analytics/collectInsights.ts`, `generateAnalyticsSummary.ts`
- `functions/src/ar/createArCampaign.ts`, `createQrPromo.ts`, `generateArPreview.ts`, `saveArCampaign.ts`
- `functions/src/notifications/markNotificationRead.ts`
- `functions/src/scheduling/cancelScheduledPost.ts`, `createScheduledPost.ts`, `updateScheduledPost.ts`
- `functions/src/scheduling/runScheduledPosts.ts` — **no path change needed**, already a `collectionGroup('scheduledPosts')` query; just swap `requirePlanFeatureForUser(userId)` → a workspace-keyed equivalent (checks `subscriptions/{workspaceId}` instead)
- `functions/src/social-oauth/disconnectSocialAccount.ts`, `refreshTokenIfNeeded.ts`
- `functions/src/user/updateUserProfile.ts` — careful here: this one should probably **stay** user-scoped (name/timezone are personal), but check whether it's also writing `businessName`/`businessCategory`, which are workspace-level now and should move to a new `updateWorkspaceDetails.ts` callable instead.

**Also needed, not yet done:**
- `firestore.indexes.json` — add a composite index for `runScheduledPosts.ts`'s `collectionGroup('scheduledPosts')` query once its `where` clauses are finalized (Firestore will throw a "missing index" error with a direct console link the first time it runs against real data — follow that link, don't guess the index shape by hand)
- A workspace-switcher UI — right now `currentWorkspaceIdProvider` only ever reads `defaultWorkspaceId`; a user who's a member of more than one workspace (e.g. invited as a teammate elsewhere) has no way to switch. Not urgent for launch, but Team creates the first real scenario where it matters.
- `AuditLogEntry.userId` (`functions/src/utils/auditLog.ts`) is now getting a `workspaceId` value in the Stripe webhook calls, not an actual user id — small schema imprecision, worth widening to a proper `workspaceId?` field when convenient.

## Testing this before it ships

1. Sign up a fresh test account, confirm `workspaces/{newId}` and `workspaces/{newId}/members/{uid}` (role: owner) both get created.
2. From that account, invite a second test account's email as `editor`. Sign in as that second account, confirm the invite is visible (`invites` collection, filtered by email) and `acceptInvite` adds them to `members`.
3. As the editor, create a scheduled post and call `requestApproval` — confirm the post's `status` becomes `pending_approval` and the owner gets a notification.
4. As the owner, approve it — confirm `status` flips to `pending` and the editor gets notified. Reject a second one — confirm it goes to `draft`.
5. Confirm `runScheduledPosts` still only ever picks up `status == 'pending'` (never `pending_approval`) — this already works today with zero code changes, since the worker's existing query filters on exact status match.
