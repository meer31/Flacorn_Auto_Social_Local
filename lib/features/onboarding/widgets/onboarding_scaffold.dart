import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Shared layout for every onboarding step (PDF Section 8), with a
/// progress indicator so the flow feels short and conversion-focused.
class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    required this.stepIndex,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.onContinue,
    this.continueLabel = 'Continue',
    this.continueEnabled = true,
    this.isLoading = false,
    super.key,
  });

  final int stepIndex;
  final int totalSteps;
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback? onContinue;
  final String continueLabel;
  final bool continueEnabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (stepIndex + 1) / totalSteps,
                      minHeight: 6,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation(AppColors.flacronRed),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Step ${stepIndex + 1} of $totalSteps',
                    style: AppTextStyles.caption(AppColors.textMuted),
                  ),
                  const SizedBox(height: 24),
                  Text(title, style: AppTextStyles.headlineLarge(AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text(subtitle, style: AppTextStyles.bodyMedium(AppColors.textSecondary)),
                  const SizedBox(height: 32),
                  Expanded(child: SingleChildScrollView(child: child)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: continueEnabled && !isLoading ? onContinue : null,
                    child: isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(continueLabel),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable single-select chip grid used across several onboarding steps
/// (category, goal, tone selection).
class SelectableChipGrid extends StatelessWidget {
  const SelectableChipGrid({
    required this.options,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final option in options)
          ChoiceChip(
            label: Text(option),
            selected: selected == option,
            onSelected: (_) => onSelect(option),
            selectedColor: AppColors.flacronRed.withValues(alpha: 0.12),
            labelStyle: AppTextStyles.bodyMedium(
              selected == option ? AppColors.flacronRed : AppColors.textPrimary,
            ),
            side: BorderSide(
              color: selected == option ? AppColors.flacronRed : AppColors.border,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
      ],
    );
  }
}
