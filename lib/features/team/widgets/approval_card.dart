import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/workspace.dart';

class ApprovalCard extends StatelessWidget {
  const ApprovalCard({
    required this.approval,
    required this.onApprove,
    required this.onReject,
    super.key,
  });

  final ApprovalRequest approval;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.flacronGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.hourglass_top_outlined, color: AppColors.flacronGold, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Post awaiting approval', style: AppTextStyles.bodyMedium(AppColors.textPrimary)),
                Text(
                  'Requested by ${approval.requestedBy}',
                  style: AppTextStyles.bodySmall(AppColors.textMuted),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onReject, child: const Text('Reject')),
          const SizedBox(width: 4),
          ElevatedButton(onPressed: onApprove, child: const Text('Approve')),
        ],
      ),
    );
  }
}
