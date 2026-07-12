import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/business_categories.dart';
import '../../../core/routing/app_router.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_scaffold.dart';

/// Onboarding Step: Business Category selection (PDF Section 3 & 8).
class BusinessCategoryScreen extends ConsumerWidget {
  const BusinessCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingControllerProvider);

    return OnboardingScaffold(
      stepIndex: 2,
      totalSteps: 7,
      title: 'What type of business do you run?',
      subtitle: 'This controls the templates, CTAs, and campaigns the AI generates for you.',
      continueEnabled: draft.businessCategory.isNotEmpty,
      onContinue: () async {
        await ref.read(onboardingControllerProvider.notifier).persist();
        if (context.mounted) context.go(AppRoutes.onboardingGoal);
      },
      child: SelectableChipGrid(
        options: kBusinessCategories,
        selected: draft.businessCategory.isEmpty ? null : draft.businessCategory,
        onSelect: (value) => ref.read(onboardingControllerProvider.notifier).selectCategory(value),
      ),
    );
  }
}
