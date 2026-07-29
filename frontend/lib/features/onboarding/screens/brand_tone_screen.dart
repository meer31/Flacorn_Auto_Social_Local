import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/business_categories.dart';
import '../../../core/routing/app_router.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_scaffold.dart';

/// Onboarding Step 4: Brand Tone (PDF Section 8).
class BrandToneScreen extends ConsumerWidget {
  const BrandToneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider);

    return OnboardingScaffold(
      stepIndex: 4,
      totalSteps: 7,
      title: 'How should your brand sound?',
      subtitle: 'This sets the tone for every caption the AI writes.',
      continueEnabled: draft.brandTone.isNotEmpty,
      onContinue: () async {
        await ref.read(onboardingControllerProvider.notifier).persist();
        if (context.mounted) context.go(AppRoutes.onboardingPlan);
      },
      child: SelectableChipGrid(
        options: kBrandTones,
        selected: draft.brandTone.isEmpty ? null : draft.brandTone,
        onSelect: (value) => ref.read(onboardingControllerProvider.notifier).selectTone(value),
      ),
    );
  }
}
