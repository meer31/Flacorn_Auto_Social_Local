import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/user_repository.dart';
import '../repositories/subscription_repository.dart';
import '../repositories/social_account_repository.dart';
import '../repositories/content_repository.dart';
import '../repositories/scheduling_repository.dart';
import '../repositories/analytics_repository.dart';
import '../repositories/ar_repository.dart';
import '../repositories/search_repository.dart';
import '../repositories/workspace_repository.dart';

/// Central place all repository singletons are exposed to the widget tree.
/// Screens/feature providers should depend on these rather than
/// constructing repositories themselves, which keeps everything mockable
/// in widget tests via ProviderScope overrides.
final userRepositoryProvider = Provider<UserRepository>((ref) => UserRepository());

final subscriptionRepositoryProvider =
    Provider<SubscriptionRepository>((ref) => SubscriptionRepository());

final socialAccountRepositoryProvider =
    Provider<SocialAccountRepository>((ref) => SocialAccountRepository());

final contentRepositoryProvider = Provider<ContentRepository>((ref) => ContentRepository());

final schedulingRepositoryProvider =
    Provider<SchedulingRepository>((ref) => SchedulingRepository());

final analyticsRepositoryProvider =
    Provider<AnalyticsRepository>((ref) => AnalyticsRepository());

final arRepositoryProvider = Provider<ArRepository>((ref) => ArRepository());

final searchRepositoryProvider = Provider<SearchRepository>((ref) => SearchRepository());

final workspaceRepositoryProvider = Provider<WorkspaceRepository>((ref) => WorkspaceRepository());
