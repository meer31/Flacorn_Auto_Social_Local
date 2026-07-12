import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/providers/user_providers.dart';
import '../../auth/providers/auth_provider.dart';

/// Settings screen (PDF Section 24) — profile, booking/business settings
/// (PDF Section 19), and account actions.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _bookingLinkController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _promoCodeController = TextEditingController();
  bool _saving = false;

  Future<void> _saveBusinessSettings() async {
    setState(() => _saving = true);
    await ref.read(userRepositoryProvider).updateProfile({
      'bookingLink': _bookingLinkController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'website': _websiteController.text.trim(),
      'promoCode': _promoCodeController.text.trim(),
    });
    if (mounted) setState(() => _saving = false);
  }

  @override
  void dispose() {
    _bookingLinkController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentUserProfileProvider).valueOrNull;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: AppTextStyles.headlineLarge(AppColors.textPrimary)),
              const SizedBox(height: 24),
              Text('Business Profile', style: AppTextStyles.headlineSmall(AppColors.textPrimary)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Text('Business name', style: AppTextStyles.bodyMedium(AppColors.textSecondary)),
                    const Spacer(),
                    Text(profile?.businessName.isNotEmpty == true ? profile!.businessName : '—',
                        style: AppTextStyles.bodyMedium(AppColors.textPrimary)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Booking CTA Settings', style: AppTextStyles.headlineSmall(AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text('Used to auto-generate stronger CTAs (PDF Section 19).',
                  style: AppTextStyles.bodySmall(AppColors.textSecondary)),
              const SizedBox(height: 12),
              TextField(controller: _bookingLinkController, decoration: const InputDecoration(labelText: 'Booking link')),
              const SizedBox(height: 12),
              TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone number')),
              const SizedBox(height: 12),
              TextField(controller: _websiteController, decoration: const InputDecoration(labelText: 'Website')),
              const SizedBox(height: 12),
              TextField(controller: _promoCodeController, decoration: const InputDecoration(labelText: 'Promo code')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saving ? null : _saveBusinessSettings,
                child: _saving
                    ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save Settings'),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (context.mounted) context.go(AppRoutes.login);
                },
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
