import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/repository_providers.dart';
import '../widgets/onboarding_scaffold.dart';

/// Onboarding Step 6: Connect First Social Account (PDF Section 8 & 10).
class ConnectFirstAccountScreen extends ConsumerStatefulWidget {
  const ConnectFirstAccountScreen({super.key});

  @override
  ConsumerState<ConnectFirstAccountScreen> createState() =>
      _ConnectFirstAccountScreenState();
}

class _ConnectFirstAccountScreenState extends ConsumerState<ConnectFirstAccountScreen> {
  String? _connectingPlatform;

  Future<void> _connect(String platform) async {
    setState(() => _connectingPlatform = platform);
    try {
      final url = await ref.read(socialAccountRepositoryProvider).getOAuthUrl(platform);
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } finally {
      if (mounted) setState(() => _connectingPlatform = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    const platforms = [
      ('instagram', 'Instagram Business', Icons.camera_alt_outlined),
      ('facebook', 'Facebook Page', Icons.facebook_outlined),
      ('twitter', 'X / Twitter', Icons.close),
      ('linkedin', 'LinkedIn', Icons.business_center_outlined),
    ];

    return OnboardingScaffold(
      stepIndex: 6,
      totalSteps: 7,
      title: 'Connect your first account',
      subtitle: 'Connect at least one platform so we can generate and schedule content for you.',
      onContinue: () => context.go(AppRoutes.onboardingFirstPlan),
      child: Column(
        children: [
          for (final (key, label, icon) in platforms)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: Icon(icon, color: AppColors.textPrimary),
                  title: Text(label, style: AppTextStyles.bodyLarge(AppColors.textPrimary)),
                  trailing: _connectingPlatform == key
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : OutlinedButton(
                          onPressed: () => _connect(key),
                          child: const Text('Connect'),
                        ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            "Don't want to connect right now? You can do this later from Connected Accounts.",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall(AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
