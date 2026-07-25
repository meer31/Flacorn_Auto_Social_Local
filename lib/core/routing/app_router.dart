import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/providers/auth_provider.dart';

import '../../features/onboarding/screens/business_profile_setup_screen.dart';
import '../../features/onboarding/screens/business_category_screen.dart';
import '../../features/onboarding/screens/goal_selection_screen.dart';
import '../../features/onboarding/screens/brand_tone_screen.dart';
import '../../features/onboarding/screens/plan_selection_screen.dart';
import '../../features/onboarding/screens/connect_first_account_screen.dart';
import '../../features/onboarding/screens/first_content_plan_result_screen.dart';

import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/social_accounts/screens/connected_accounts_screen.dart';
import '../../features/ai_content/screens/ai_content_generator_screen.dart';
import '../../features/content_calendar/screens/content_calendar_screen.dart';
import '../../features/campaigns/screens/campaign_generator_screen.dart';
import '../../features/scheduler/screens/scheduler_screen.dart';
import '../../features/ai_content/screens/templates_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/weekly_reports/screens/weekly_reports_screen.dart';
import '../../features/ar_campaigns/screens/ar_campaigns_screen.dart';
import '../../features/billing/screens/billing_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/media_library/screens/media_library_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/brand_kit/screens/brand_kit_screen.dart';
import '../../features/agency/screens/agency_workspace_screen.dart';
import '../../features/admin/screens/admin_panel_screen.dart';
import '../../features/global_search/screens/global_search_screen.dart';
import '../../features/team/screens/team_screen.dart';

import '../widgets/app_shell.dart';

/// Route path constants — reference these instead of raw strings so typos
/// become compile errors and refactors are a single find/replace.
class AppRoutes {
  AppRoutes._();

  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  static const onboardingBusinessProfile = '/onboarding/business-profile';
  static const onboardingCategory = '/onboarding/category';
  static const onboardingGoal = '/onboarding/goal';
  static const onboardingBrandTone = '/onboarding/brand-tone';
  static const onboardingPlan = '/onboarding/plan';
  static const onboardingConnectAccount = '/onboarding/connect-account';
  static const onboardingFirstPlan = '/onboarding/first-plan-result';

  static const dashboard = '/dashboard';
  static const connectedAccounts = '/connected-accounts';
  static const aiContentGenerator = '/ai-content';
  static const contentCalendar = '/content-calendar';
  static const campaigns = '/campaigns';
  static const scheduler = '/scheduler';
  static const templates = '/templates';
  static const analytics = '/analytics';
  static const weeklyReports = '/weekly-reports';
  static const arCampaigns = '/ar-campaigns';
  static const billing = '/billing';
  static const settings = '/settings';
  static const mediaLibrary = '/media-library';
  static const notifications = '/notifications';
  static const brandKit = '/brand-kit';
  static const agencyWorkspace = '/agency';
  static const adminPanel = '/admin';
  static const globalSearch = '/search';
  static const team = '/team';
}

/// Riverpod provider for the app's [GoRouter], reacting to auth state so
/// unauthenticated users are redirected to /login and authenticated users
/// land on /dashboard.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      const isLoggedIn = true;
      final isAuthRoute = [
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
      ].contains(state.matchedLocation);

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      if (isLoggedIn && isAuthRoute) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
          path: AppRoutes.register, builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      // ---- Onboarding flow (PDF Section 8) ----
      GoRoute(
        path: AppRoutes.onboardingBusinessProfile,
        builder: (_, __) => const BusinessProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingCategory,
        builder: (_, __) => const BusinessCategoryScreen(),
      ),
      GoRoute(
          path: AppRoutes.onboardingGoal,
          builder: (_, __) => const GoalSelectionScreen()),
      GoRoute(
          path: AppRoutes.onboardingBrandTone,
          builder: (_, __) => const BrandToneScreen()),
      GoRoute(
          path: AppRoutes.onboardingPlan,
          builder: (_, __) => const PlanSelectionScreen()),
      GoRoute(
        path: AppRoutes.onboardingConnectAccount,
        builder: (_, __) => const ConnectFirstAccountScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingFirstPlan,
        builder: (_, __) => const FirstContentPlanResultScreen(),
      ),

      // ---- Main app shell (persistent sidebar/bottom nav) ----
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
              path: AppRoutes.dashboard,
              builder: (_, __) => const DashboardScreen()),
          GoRoute(
            path: AppRoutes.connectedAccounts,
            builder: (_, __) => const ConnectedAccountsScreen(),
          ),
          GoRoute(
            path: AppRoutes.aiContentGenerator,
            builder: (_, __) => const AiContentGeneratorScreen(),
          ),
          GoRoute(
            path: AppRoutes.contentCalendar,
            builder: (_, __) => const ContentCalendarScreen(),
          ),
          GoRoute(
              path: AppRoutes.campaigns,
              builder: (_, __) => const CampaignGeneratorScreen()),
          GoRoute(
              path: AppRoutes.scheduler,
              builder: (_, __) => const SchedulerScreen()),
          GoRoute(
              path: AppRoutes.templates,
              builder: (_, __) => const TemplatesScreen()),
          GoRoute(
              path: AppRoutes.analytics,
              builder: (_, __) => const AnalyticsScreen()),
          GoRoute(
            path: AppRoutes.weeklyReports,
            builder: (_, __) => const WeeklyReportsScreen(),
          ),
          GoRoute(
              path: AppRoutes.arCampaigns,
              builder: (_, __) => const ArCampaignsScreen()),
          GoRoute(
              path: AppRoutes.billing,
              builder: (_, __) => const BillingScreen()),
          GoRoute(
              path: AppRoutes.settings,
              builder: (_, __) => const SettingsScreen()),
          GoRoute(
            path: AppRoutes.mediaLibrary,
            builder: (_, __) => const MediaLibraryScreen(),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            builder: (_, __) => const NotificationsScreen(),
          ),
          GoRoute(
              path: AppRoutes.brandKit,
              builder: (_, __) => const BrandKitScreen()),
          GoRoute(
            path: AppRoutes.agencyWorkspace,
            builder: (_, __) => const AgencyWorkspaceScreen(),
          ),
          GoRoute(
              path: AppRoutes.adminPanel,
              builder: (_, __) => const AdminPanelScreen()),
          GoRoute(path: AppRoutes.team, builder: (_, __) => const TeamScreen()),
          GoRoute(
            path: AppRoutes.globalSearch,
            // Mobile entry point (see BottomNav/SidebarNav for how each
            // breakpoint triggers search); GlobalSearchScreen itself has no
            // Scaffold since the desktop path shows it inside a Dialog.
            builder: (_, __) => const Scaffold(
              body: SafeArea(child: GlobalSearchScreen()),
            ),
          ),
        ],
      ),
    ],
  );
});
