import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../models/user_profile.dart';
import '../models/subscription.dart';
import 'repository_providers.dart';

/// Streams the current signed-in user's Firestore profile document.
final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  final authState = ref.watch(authStateProvider);
  final uid = authState.valueOrNull?.uid;
  if (uid == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).watchUserProfile(uid);
});

/// Streams the current workspace's subscription document — the single
/// source of truth for plan-gated UI (usage counters, locked features,
/// upgrade prompts) across every screen.
///
/// MIGRATION NOTE (Team/RBAC): subscriptions moved from being keyed by
/// userId to workspaceId — billing belongs to the workspace/business, not
/// individual teammates, so everyone in a workspace shares one plan.
/// Derives workspaceId from the profile directly (rather than importing
/// workspace_providers.dart) to avoid a circular import, since
/// workspace_providers.dart itself depends on currentUserProfileProvider.
final currentSubscriptionProvider = StreamProvider<SubscriptionModel?>((ref) {
  final profile = ref.watch(currentUserProfileProvider).valueOrNull;
  final workspaceId = profile?.defaultWorkspaceId;
  if (workspaceId == null) return Stream.value(null);
  return ref.watch(subscriptionRepositoryProvider).watchSubscription(workspaceId);
});
