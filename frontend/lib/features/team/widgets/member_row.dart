import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/workspace.dart';

const _roles = ['owner', 'admin', 'editor', 'viewer'];

class MemberRow extends StatelessWidget {
  const MemberRow({
    required this.member,
    required this.canManage,
    required this.isSelf,
    required this.onRoleChanged,
    required this.onRemove,
    super.key,
  });

  final WorkspaceMember member;
  final bool canManage;
  final bool isSelf;
  final ValueChanged<String> onRoleChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.flacronRed.withValues(alpha: 0.12),
            child: Text(
              member.uid.isNotEmpty ? member.uid[0].toUpperCase() : '?',
              style: AppTextStyles.labelLarge(AppColors.flacronRed),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSelf ? 'You' : member.uid,
                  style: AppTextStyles.bodyMedium(AppColors.textPrimary),
                ),
                Text('Joined ${member.joinedAt.toLocal()}'.split('.').first,
                    style: AppTextStyles.bodySmall(AppColors.textMuted)),
              ],
            ),
          ),
          if (canManage && !isSelf && member.role != 'owner') ...[
            DropdownButton<String>(
              value: member.role,
              underline: const SizedBox.shrink(),
              items: _roles
                  .where((r) => r != 'owner') // only an owner can grant ownership — separate flow
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (value) {
                if (value != null) onRoleChanged(value);
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_remove_outlined, size: 20),
              color: AppColors.error,
              tooltip: 'Remove from workspace',
              onPressed: onRemove,
            ),
          ] else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(member.role, style: AppTextStyles.labelLarge(AppColors.textSecondary)),
            ),
        ],
      ),
    );
  }
}
