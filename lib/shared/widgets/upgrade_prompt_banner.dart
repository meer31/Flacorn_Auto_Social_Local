import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Reusable upgrade-prompt banner (PDF Section 28: Upgrade Prompts).
///
/// Usage examples per the developer document:
///   "You reached your Starter AI limit. Upgrade to Pro for 300 AI
///    generations and unlimited scheduling."
///   "AR Campaigns are available on Pro and Agency plans."
///   "You reached your social account limit. Upgrade to Pro to connect
///    more accounts."
///   "Client workspaces are available on the Agency plan."
class UpgradePromptBanner extends StatelessWidget {
  const UpgradePromptBanner({required this.message, this.ctaLabel = 'Upgrade Plan', super.key});

  final String message;
  final String ctaLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.goldAccentGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_outlined, color: AppColors.flacronBlack),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium(AppColors.flacronBlack),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.billing),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.flacronBlack,
              foregroundColor: Colors.white,
            ),
            child: Text(ctaLabel),
          ),
        ],
      ),
    );
  }
}
