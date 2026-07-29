import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/business_categories.dart';
import '../../../core/routing/app_router.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_scaffold.dart';

/// Onboarding Step 3: Main Goal (PDF Section 8).
class GoalSelectionScreen extends ConsumerWidget {
  const GoalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider);

    return OnboardingScaffold(
      stepIndex: 3,
      totalSteps: 7,
      title: "What's your main goal?",
      subtitle: 'Your AI content plan will be built around this goal.',
      continueEnabled: draft.mainGoal.isNotEmpty,
      onContinue: () async {
        await ref.read(onboardingControllerProvider.notifier).persist();
        if (context.mounted) context.go(AppRoutes.onboardingBrandTone);
      },
      child: SelectableChipGrid(
        options: kMainGoals,
        selected: draft.mainGoal.isEmpty ? null : draft.mainGoal,
        onSelect: (value) => ref.read(onboardingControllerProvider.notifier).selectGoal(value),
      ),
    );
  }
}
