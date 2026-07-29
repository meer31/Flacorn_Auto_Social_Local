import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/providers/workspace_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../widgets/approval_card.dart';
import '../widgets/member_row.dart';

/// Team — members, roles, and the approval queue (PDF-adjacent: added per
/// client's UI-review requirements, see docs/TEAM_RBAC.md).
class TeamScreen extends ConsumerStatefulWidget {
  const TeamScreen({super.key});

  @override
  ConsumerState<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends ConsumerState<TeamScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showInviteDialog(BuildContext context, String workspaceId) async {
    final emailController = TextEditingController();
    var role = 'editor';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Invite a teammate'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email address'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin — manage team, approve posts')),
                  DropdownMenuItem(value: 'editor', child: Text('Editor — create & schedule content')),
                  DropdownMenuItem(value: 'viewer', child: Text('Viewer — read-only access')),
                ],
                onChanged: (value) => setDialogState(() => role = value ?? role),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty) return;
                Navigator.pop(dialogContext);
                try {
                  await ref.read(workspaceRepositoryProvider).inviteMember(
                        workspaceId: workspaceId,
                        email: email,
                        role: role,
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Invite sent to $email')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Could not send invite: $e')));
                  }
                }
              },
              child: const Text('Send Invite'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workspaceId = ref.watch(currentWorkspaceIdProvider);
    final myUid = ref.watch(authStateProvider).valueOrNull?.uid;
    final canManage = ref.watch(canManageMembersProvider);
    final canApprove = ref.watch(canApproveProvider);
    final members = ref.watch(currentMembersProvider).valueOrNull ?? const [];
    final approvals = ref.watch(pendingApprovalsProvider).valueOrNull ?? const [];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Team', style: AppTextStyles.headlineLarge(AppColors.textPrimary)),
              if (canManage && workspaceId != null)
                ElevatedButton.icon(
                  onPressed: () => _showInviteDialog(context, workspaceId),
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                  label: const Text('Invite Teammate'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.flacronRed,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.flacronRed,
            tabs: [
              const Tab(text: 'Members'),
              Tab(text: 'Approvals${approvals.isNotEmpty ? ' (${approvals.length})' : ''}'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ---- Members tab ----
                members.isEmpty
                    ? const EmptyState(
                        icon: Icons.group_outlined,
                        title: 'Just you so far',
                        message: 'Invite a teammate to collaborate on this workspace.',
                      )
                    : ListView.separated(
                        itemCount: members.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final member = members[i];
                          return MemberRow(
                            member: member,
                            canManage: canManage,
                            isSelf: member.uid == myUid,
                            onRoleChanged: (role) {
                              if (workspaceId == null) return;
                              ref.read(workspaceRepositoryProvider).updateMemberRole(
                                    workspaceId: workspaceId,
                                    memberUid: member.uid,
                                    role: role,
                                  );
                            },
                            onRemove: () {
                              if (workspaceId == null) return;
                              ref.read(workspaceRepositoryProvider).removeMember(
                                    workspaceId: workspaceId,
                                    memberUid: member.uid,
                                  );
                            },
                          );
                        },
                      ),

                // ---- Approvals tab ----
                !canApprove
                    ? const EmptyState(
                        icon: Icons.lock_outline,
                        title: 'Admins and owners only',
                        message: 'Only workspace admins and owners can review approval requests.',
                      )
                    : approvals.isEmpty
                        ? const EmptyState(
                            icon: Icons.check_circle_outline,
                            title: 'Nothing pending',
                            message: 'Posts submitted for approval by your team will show up here.',
                          )
                        : ListView.separated(
                            itemCount: approvals.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final approval = approvals[i];
                              return ApprovalCard(
                                approval: approval,
                                onApprove: () {
                                  if (workspaceId == null) return;
                                  ref.read(workspaceRepositoryProvider).decideApproval(
                                        workspaceId: workspaceId,
                                        approvalId: approval.id,
                                        approve: true,
                                      );
                                },
                                onReject: () {
                                  if (workspaceId == null) return;
                                  ref.read(workspaceRepositoryProvider).decideApproval(
                                        workspaceId: workspaceId,
                                        approvalId: approval.id,
                                        approve: false,
                                      );
                                },
                              );
                            },
                          ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
