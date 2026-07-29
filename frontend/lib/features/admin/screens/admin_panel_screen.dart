import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/functions_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/empty_state.dart';

/// Admin Panel (PDF Section 30). Guarded server-side by the `admin` custom
/// claim (see functions/src/middleware/authGuard.ts requireAdmin) — this
/// screen should also be hidden from the sidebar/bottom nav for non-admin
/// users at the router/shell level (TODO: wire an `isAdmin` check into
/// AppShell once custom claims are exposed to the client via ID token
/// refresh, e.g. through a `currentUserClaimsProvider`).
class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen> {
  List<Map<String, dynamic>>? _users;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUsers());
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      final result = await FunctionsService.instance.call<Map<String, dynamic>>('listUsers', {'limit': 50});
      setState(() {
        _users = (result['users'] as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (err) {
      setState(() {
        _error = 'Could not load users (are you an admin?): $err';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Admin Panel', style: AppTextStyles.headlineLarge(AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text('Users, plans, subscriptions, and platform health.',
              style: AppTextStyles.bodyMedium(AppColors.textSecondary)),
          const SizedBox(height: 20),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!, style: AppTextStyles.bodyMedium(AppColors.error)))
                    : (_users?.isEmpty ?? true)
                        ? const EmptyState(
                            icon: Icons.admin_panel_settings_outlined,
                            title: 'No users found',
                            message: 'Users will appear here as they sign up.',
                          )
                        : ListView.separated(
                            itemCount: _users!.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final u = _users![index];
                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(u['email']?.toString() ?? u['userId'].toString(),
                                              style: AppTextStyles.bodyMedium(AppColors.textPrimary)),
                                          Text(
                                            'Plan: ${u['plan'] ?? '—'} · Status: ${u['subscriptionStatus'] ?? '—'}',
                                            style: AppTextStyles.bodySmall(AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (action) async {
                                        if (action == 'disable') {
                                          await FunctionsService.instance
                                              .call('disableUser', {'userId': u['userId'], 'disabled': true});
                                        } else {
                                          await FunctionsService.instance
                                              .call('updateUserPlan', {'userId': u['userId'], 'planName': action});
                                        }
                                        _loadUsers();
                                      },
                                      itemBuilder: (_) => const [
                                        PopupMenuItem(value: 'starter', child: Text('Set plan: Starter')),
                                        PopupMenuItem(value: 'pro', child: Text('Set plan: Pro')),
                                        PopupMenuItem(value: 'agency', child: Text('Set plan: Agency')),
                                        PopupMenuItem(value: 'disable', child: Text('Disable user')),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
