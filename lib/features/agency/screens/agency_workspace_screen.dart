import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/business_categories.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/functions_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/user_providers.dart';
import '../../../shared/providers/workspace_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../../shared/widgets/upgrade_prompt_banner.dart';

/// Agency Workspace (PDF Section 22 & 24).
/// Client list + Add Client dialog. The Firestore path is
/// agencies/{agencyId}/clients/{clientId}; all writes go through the
/// createAgencyClient Cloud Function so role checks happen server-side.
class AgencyWorkspaceScreen extends ConsumerStatefulWidget {
  const AgencyWorkspaceScreen({super.key});

  @override
  ConsumerState<AgencyWorkspaceScreen> createState() => _AgencyWorkspaceScreenState();
}

class _AgencyWorkspaceScreenState extends ConsumerState<AgencyWorkspaceScreen> {
  Future<void> _showAddClientDialog(BuildContext context, String agencyId) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    var category = kBusinessCategories.first;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Add Client'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Client / business name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Contact email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Business category'),
                items: [
                  for (final c in kBusinessCategories)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (v) => setDialogState(() => category = v ?? category),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final email = emailController.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(dialogContext);
                try {
                  await FunctionsService.instance.call<void>('createAgencyClient', {
                    'agencyId': agencyId,
                    'clientName': name,
                    'contactEmail': email,
                    'businessCategory': category,
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$name added to your agency.')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Could not add client: $e')));
                  }
                }
              },
              child: const Text('Add Client'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeClient(String agencyId, String clientId, String clientName) async {
    try {
      await FunctionsService.instance
          .call<void>('removeAgencyClient', {'agencyId': agencyId, 'clientId': clientId});
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$clientName removed.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not remove client: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(currentSubscriptionProvider).valueOrNull;
    final hasAgencyAccess = subscription?.agencyAccess ?? false;
    final workspaceId = ref.watch(currentWorkspaceIdProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Agency Workspace',
                  style: AppTextStyles.headlineLarge(AppColors.textPrimary)),
              if (hasAgencyAccess && workspaceId != null)
                ElevatedButton.icon(
                  onPressed: () => _showAddClientDialog(context, workspaceId),
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                  label: const Text('Add Client'),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Manage multiple clients from a single dashboard.',
            style: AppTextStyles.bodyMedium(AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          if (!hasAgencyAccess) ...[
            const UpgradePromptBanner(
              message:
                  'Client workspaces are available on the Agency plan. Upgrade to manage multiple clients, run approval workflows, and export white-label reports.',
            ),
            const SizedBox(height: 20),
          ],

          if (!hasAgencyAccess)
            const Expanded(
              child: EmptyState(
                icon: Icons.groups_outlined,
                title: 'Agency features locked',
                message:
                    'Upgrade to the Agency plan to unlock client workspaces, approval workflows, and white-label reports.',
              ),
            )
          else if (workspaceId == null)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: _ClientList(
                agencyId: workspaceId,
                onRemove: (clientId, clientName) =>
                    _removeClient(workspaceId, clientId, clientName),
              ),
            ),
        ],
      ),
    );
  }
}

class _ClientList extends StatelessWidget {
  const _ClientList({required this.agencyId, required this.onRemove});
  final String agencyId;
  final void Function(String clientId, String clientName) onRemove;

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseService.instance.firestore
        .collection('agencies')
        .doc(agencyId)
        .collection('clients')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return ListView.separated(
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, __) => const SkeletonCard(height: 88),
          );
        }
        if (snap.hasError) {
          return Center(
            child: Text('Error loading clients: ${snap.error}',
                style: AppTextStyles.bodyMedium(AppColors.error)),
          );
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const EmptyState(
            icon: Icons.groups_outlined,
            title: 'No clients yet',
            message:
                'Add your first client to start managing their content, calendar, and reports.',
          );
        }
        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final clientId = docs[index].id;
            final name = data['clientName']?.toString() ?? 'Unnamed Client';
            final email = data['contactEmail']?.toString() ?? '';
            final category = data['businessCategory']?.toString() ?? '';
            return _ClientCard(
              name: name,
              email: email,
              category: category,
              onRemove: () => onRemove(clientId, name),
            );
          },
        );
      },
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({
    required this.name,
    required this.email,
    required this.category,
    required this.onRemove,
  });
  final String name;
  final String email;
  final String category;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.flacronRed.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.business_outlined,
                size: 20, color: AppColors.flacronRed),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.titleMedium(AppColors.textPrimary)),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(email, style: AppTextStyles.bodySmall(AppColors.textSecondary)),
                ],
                if (category.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(category,
                        style: AppTextStyles.caption(AppColors.textSecondary)),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (action) {
              if (action == 'remove') onRemove();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'remove', child: Text('Remove client')),
            ],
          ),
        ],
      ),
    );
  }
}
