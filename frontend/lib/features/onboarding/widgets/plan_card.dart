import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PlanCard extends StatelessWidget {
  const PlanCard({
    required this.planKey,
    required this.name,
    required this.price,
    required this.features,
    required this.selected,
    required this.onTap,
    this.highlighted = false,
    super.key,
  });

  final String planKey;
  final String name;
  final String price;
  final List<String> features;
  final bool selected;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? AppColors.flacronRed : AppColors.border;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: selected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: AppTextStyles.titleMedium(AppColors.textPrimary)),
                if (highlighted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.goldAccentGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Popular', style: AppTextStyles.caption(AppColors.flacronBlack)),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(price, style: AppTextStyles.headlineSmall(AppColors.textPrimary)),
            const SizedBox(height: 14),
            for (final feature in features)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(feature, style: AppTextStyles.bodySmall(AppColors.textSecondary)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
