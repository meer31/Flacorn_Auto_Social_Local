import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/routing/app_router.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/providers/workspace_providers.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_scaffold.dart';
import '../widgets/plan_card.dart';

/// Onboarding Step 5: Choose Plan (PDF Section 4 & 8).
///
/// Selecting a plan and continuing kicks off a Stripe Checkout Session via
/// `createCheckoutSession`. Per the PDF's conversion-focused flow, the user
/// is NOT blocked from continuing onboarding even if they don't complete
/// checkout immediately — they'll see an upgrade prompt after their first
/// AI content plan is generated (Step 8).
class PlanSelectionScreen extends ConsumerStatefulWidget {
  const PlanSelectionScreen({super.key});

  @override
  ConsumerState<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends ConsumerState<PlanSelectionScreen> {
  bool _launchingCheckout = false;

  Future<void> _onContinue() async {
    final draft = ref.read(onboardingControllerProvider);
    final workspaceId = ref.read(currentWorkspaceIdProvider);
    if (workspaceId == null) {
      // Workspace doc from onAuthUserCreate hasn't synced to the client
      // yet (rare race right after signup) — skip checkout rather than
      // crash; the user reaches the same upgrade prompt later per the
      // comment above.
      return;
    }
    setState(() => _launchingCheckout = true);
    try {
      final checkoutUrl = await ref.read(subscriptionRepositoryProvider).startCheckout(
            workspaceId: workspaceId,
            plan: draft.selectedPlan,
            successUrl: 'https://app.flacronsocialauto.com/onboarding/connect-account',
            cancelUrl: 'https://app.flacronsocialauto.com/onboarding/plan',
          );
      final uri = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // TODO: surface a proper error toast; for MVP we still let the user
      // continue onboarding even if Stripe Checkout couldn't be launched
      // (e.g. offline in the emulator, price IDs not yet configured).
    } finally {
      if (mounted) setState(() => _launchingCheckout = false);
    }
    if (mounted) context.go(AppRoutes.onboardingConnectAccount);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(onboardingControllerProvider);
    final notifier = ref.read(onboardingControllerProvider.notifier);

    return OnboardingScaffold(
      stepIndex: 5,
      totalSteps: 7,
      title: 'Choose your plan',
      subtitle: 'You can change or cancel anytime from Billing.',
      isLoading: _launchingCheckout,
      onContinue: _onContinue,
      continueLabel: 'Continue to Checkout',
      child: Column(
        children: [
          PlanCard(
            planKey: 'starter',
            name: 'Starter',
            price: '\$29/month',
            features: const [
              '3 social media accounts',
              '10 AI generations per month',
              '10 scheduled posts per month',
              'Basic templates & analytics',
            ],
            selected: draft.selectedPlan == 'starter',
            onTap: () => notifier.selectPlan('starter'),
          ),
          const SizedBox(height: 12),
          PlanCard(
            planKey: 'pro',
            name: 'Pro',
            price: '\$79/month',
            highlighted: true,
            features: const [
              '10 social media accounts',
              '300 AI generations per month',
              'Unlimited scheduled posts',
              '30-day AI content calendar & campaigns',
              'Basic AR post preview',
            ],
            selected: draft.selectedPlan == 'pro',
            onTap: () => notifier.selectPlan('pro'),
          ),
          const SizedBox(height: 12),
          PlanCard(
            planKey: 'agency',
            name: 'Agency',
            price: '\$199/month',
            features: const [
              '30 social media accounts',
              'Unlimited AI generations & scheduling',
              'Client workspaces & approval workflow',
              'AR campaign builder',
              'White-label reports',
            ],
            selected: draft.selectedPlan == 'agency',
            onTap: () => notifier.selectPlan('agency'),
          ),
        ],
      ),
    );
  }
}
