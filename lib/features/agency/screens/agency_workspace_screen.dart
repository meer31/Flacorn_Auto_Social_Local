import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/user_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/upgrade_prompt_banner.dart';

/// Agency Workspace (PDF Section 22 & 24).
/// Architecturally prepared in the MVP; fully wired client-management UI
/// (approval workflow, white-label reports, team members) is Phase 2 —
/// see docs/PRODUCT_ROADMAP.md. The Firestore structure
/// (agencies/{agencyId}/clients/{clientId}) and security rules already
/// support this, so the UI can be built out without backend changes.
class AgencyWorkspaceScreen extends ConsumerWidget {
  const AgencyWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(currentSubscriptionProvider).valueOrNull;
    final hasAgencyAccess = subscription?.agencyAccess ?? false;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Agency Workspace', style: AppTextStyles.headlineLarge(AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text('Manage multiple clients from a single dashboard.',
              style: AppTextStyles.bodyMedium(AppColors.textSecondary)),
          const SizedBox(height: 20),
          if (!hasAgencyAccess) ...[
            const UpgradePromptBanner(message: 'Client workspaces are available on the Agency plan.'),
            const SizedBox(height: 20),
          ],
          Expanded(
            child: EmptyState(
              icon: Icons.groups_outlined,
              title: hasAgencyAccess ? 'No clients added yet' : 'Agency features locked',
              message: hasAgencyAccess
                  ? 'Add your first client to start managing their content, calendar, and reports.'
                  : 'Upgrade to the Agency plan to unlock client workspaces, approval workflows, and white-label reports.',
              actionLabel: hasAgencyAccess ? 'Add Client' : null,
              onAction: hasAgencyAccess
                  ? () {
                      // TODO: open "Add Client" dialog — writes to
                      // agencies/{agencyId}/clients/{clientId} via a future
                      // Cloud Function (createAgencyClient, Phase 2).
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
