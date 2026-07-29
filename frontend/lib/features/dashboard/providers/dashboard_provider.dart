import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/models/scheduled_post.dart';
import '../../../shared/models/social_account.dart';

/// Aggregates the pieces of state the Dashboard needs (PDF Section 23):
/// scheduled posts (for "next scheduled post" / "failed posts" / "today's
/// summary"), and connected accounts (for reconnect alerts).
final dashboardScheduledPostsProvider = StreamProvider<List<ScheduledPost>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(schedulingRepositoryProvider).watchScheduledPosts(uid);
});

final dashboardSocialAccountsProvider = StreamProvider<List<SocialAccount>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(socialAccountRepositoryProvider).watchAccounts(uid);
});
