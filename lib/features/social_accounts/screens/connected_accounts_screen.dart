import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../../shared/widgets/empty_state.dart';

/// Connected Accounts screen (PDF Section 24 & 10).
class ConnectedAccountsScreen extends ConsumerStatefulWidget {
  const ConnectedAccountsScreen({super.key});

  @override
  ConsumerState<ConnectedAccountsScreen> createState() => _ConnectedAccountsScreenState();
}

class _ConnectedAccountsScreenState extends ConsumerState<ConnectedAccountsScreen> {
  String? _busyPlatform;

  Future<void> _connect(String platform) async {
    setState(() => _busyPlatform = platform);
    try {
      final url = await ref.read(socialAccountRepositoryProvider).getOAuthUrl(platform);
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Connection failed: $err')));
      }
    } finally {
      if (mounted) setState(() => _busyPlatform = null);
    }
  }

  Future<void> _disconnect(String accountId) async {
    await ref.read(socialAccountRepositoryProvider).disconnect(accountId);
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(dashboardSocialAccountsProvider).valueOrNull ?? [];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Connected Accounts', style: AppTextStyles.headlineLarge(AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(
            'Connect your social platforms so Flacron can publish and analyze on your behalf.',
            style: AppTextStyles.bodyMedium(AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final platform in AppConstants.supportedPlatforms)
                OutlinedButton.icon(
                  onPressed: _busyPlatform == platform ? null : () => _connect(platform),
                  icon: _busyPlatform == platform
                      ? const SizedBox(
                          height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.add, size: 18),
                  label: Text('Connect ${platform[0].toUpperCase()}${platform.substring(1)}'),
                ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: accounts.isEmpty
                ? const EmptyState(
                    icon: Icons.link_off,
                    title: 'No accounts connected yet',
                    message: 'Connect Instagram, Facebook, X, or LinkedIn to start publishing.',
                  )
                : ListView.separated(
                    itemCount: accounts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.surface,
                              child: Icon(
                                account.platform == 'instagram'
                                    ? Icons.camera_alt_outlined
                                    : account.platform == 'facebook'
                                        ? Icons.facebook_outlined
                                        : account.platform == 'twitter'
                                            ? Icons.close
                                            : Icons.business_center_outlined,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(account.accountName,
                                      style: AppTextStyles.titleMedium(AppColors.textPrimary)),
                                  const SizedBox(height: 2),
                                  Text(
                                    account.needsReconnect ? 'Reconnect required' : 'Connected',
                                    style: AppTextStyles.bodySmall(
                                      account.needsReconnect ? AppColors.warning : AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (account.needsReconnect)
                              TextButton(
                                onPressed: () => _connect(account.platform),
                                child: const Text('Reconnect'),
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.error),
                              onPressed: () => _disconnect(account.id),
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
