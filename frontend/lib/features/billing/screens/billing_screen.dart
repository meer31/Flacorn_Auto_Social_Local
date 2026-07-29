import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/providers/user_providers.dart';
import '../../../shared/providers/workspace_providers.dart';
import '../../onboarding/widgets/plan_card.dart';

/// Billing screen (PDF Section 9 & 24). Lets the user change plans (via
/// Stripe Checkout) or manage their existing subscription (via the Stripe
/// Billing Portal — cancellations, payment methods, invoices).
class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  bool _busy = false;

  Future<void> _openPortal() async {
    setState(() => _busy = true);
    try {
      final url = await ref.read(subscriptionRepositoryProvider).getBillingPortalUrl();
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open billing portal: $err')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _switchPlan(String plan) async {
    final workspaceId = ref.read(currentWorkspaceIdProvider);
    if (workspaceId == null) return;
    setState(() => _busy = true);
    try {
      final url = await ref.read(subscriptionRepositoryProvider).startCheckout(
            workspaceId: workspaceId,
            plan: plan,
            successUrl: 'https://app.flacronsocialauto.com/billing',
            cancelUrl: 'https://app.flacronsocialauto.com/billing',
          );
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not start checkout: $err')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(currentSubscriptionProvider).valueOrNull;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Billing', style: AppTextStyles.headlineLarge(AppColors.textPrimary)),
              OutlinedButton(
                onPressed: _busy ? null : _openPortal,
                child: const Text('Manage Billing / Invoices'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subscription != null
                ? 'Current plan: ${subscription.planName.toUpperCase()} · Status: ${subscription.status}'
                : 'Loading subscription...',
            style: AppTextStyles.bodyMedium(AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: [
                PlanCard(
                  planKey: 'starter',
                  name: 'Starter',
                  price: '\$29/month',
                  features: const ['3 social accounts', '10 AI generations/mo', '10 scheduled posts/mo'],
                  selected: subscription?.planName == 'starter',
                  onTap: () => _switchPlan('starter'),
                ),
                PlanCard(
                  planKey: 'pro',
                  name: 'Pro',
                  price: '\$79/month',
                  highlighted: true,
                  features: const ['10 social accounts', '300 AI generations/mo', 'Unlimited scheduling', 'AR preview'],
                  selected: subscription?.planName == 'pro',
                  onTap: () => _switchPlan('pro'),
                ),
                PlanCard(
                  planKey: 'agency',
                  name: 'Agency',
                  price: '\$199/month',
                  features: const ['30 social accounts', 'Unlimited AI', 'Client workspaces', 'AR campaign builder'],
                  selected: subscription?.planName == 'agency',
                  onTap: () => _switchPlan('agency'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
