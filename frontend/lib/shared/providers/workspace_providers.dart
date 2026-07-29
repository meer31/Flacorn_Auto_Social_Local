import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../models/workspace.dart';
import 'repository_providers.dart';
import 'user_providers.dart';

/// The workspace the signed-in user currently has open. Derived from their
/// profile's `defaultWorkspaceId` for now (no workspace-switcher UI yet —
/// add one before a user can meaningfully belong to more than one).
///
/// Every screen/repository call that used to take a bare `userId` for
/// content (posts, campaigns, media, etc.) should read this instead.
final currentWorkspaceIdProvider = Provider<String?>((ref) {
  final profile = ref.watch(currentUserProfileProvider).valueOrNull;
  return profile?.defaultWorkspaceId;
});

final currentWorkspaceProvider = StreamProvider<Workspace?>((ref) {
  final workspaceId = ref.watch(currentWorkspaceIdProvider);
  if (workspaceId == null) return Stream.value(null);
  return ref.watch(workspaceRepositoryProvider).watchWorkspace(workspaceId);
});

/// The signed-in user's own membership (and therefore role) in the current
/// workspace. This is what every permission check below reads.
final currentMembershipProvider = FutureProvider<WorkspaceMember?>((ref) async {
  final workspaceId = ref.watch(currentWorkspaceIdProvider);
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (workspaceId == null || uid == null) return null;
  return ref.watch(workspaceRepositoryProvider).getMyMembership(workspaceId, uid);
});

final currentMembersProvider = StreamProvider<List<WorkspaceMember>>((ref) {
  final workspaceId = ref.watch(currentWorkspaceIdProvider);
  if (workspaceId == null) return Stream.value(const []);
  return ref.watch(workspaceRepositoryProvider).watchMembers(workspaceId);
});

final pendingApprovalsProvider = StreamProvider<List<ApprovalRequest>>((ref) {
  final workspaceId = ref.watch(currentWorkspaceIdProvider);
  if (workspaceId == null) return Stream.value(const []);
  return ref.watch(workspaceRepositoryProvider).watchPendingApprovals(workspaceId);
});

/// Convenience booleans for gating UI. Prefer these over reading
/// `currentMembershipProvider` and checking `.role` inline everywhere —
/// if the permission rules ever change, they change in exactly one place.
///
/// IMPORTANT: these are UX convenience only. The real enforcement is
/// server-side (see functions/src/middleware/workspaceGuard.ts) — never
/// trust a hidden button as the actual security boundary.
final canManageMembersProvider = Provider<bool>((ref) {
  return ref.watch(currentMembershipProvider).valueOrNull?.canManageMembers ?? false;
});

final canApproveProvider = Provider<bool>((ref) {
  return ref.watch(currentMembershipProvider).valueOrNull?.canApprove ?? false;
});

final canCreateContentProvider = Provider<bool>((ref) {
  return ref.watch(currentMembershipProvider).valueOrNull?.canCreateContent ?? false;
});

final canPublishDirectlyProvider = Provider<bool>((ref) {
  return ref.watch(currentMembershipProvider).valueOrNull?.canPublishDirectly ?? false;
});
