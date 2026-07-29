import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_router.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_scaffold.dart';

/// Onboarding Step 2: Business Profile (PDF Section 8).
class BusinessProfileSetupScreen extends ConsumerStatefulWidget {
  const BusinessProfileSetupScreen({super.key});

  @override
  ConsumerState<BusinessProfileSetupScreen> createState() =>
      _BusinessProfileSetupScreenState();
}

class _BusinessProfileSetupScreenState extends ConsumerState<BusinessProfileSetupScreen> {
  final _businessNameController = TextEditingController();
  final _websiteController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    setState(() => _saving = true);
    ref.read(onboardingControllerProvider.notifier).updateBusinessProfile(
          businessName: _businessNameController.text.trim(),
          website: _websiteController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          city: _cityController.text.trim(),
          timezone: DateTime.now().timeZoneName,
        );
    await ref.read(onboardingControllerProvider.notifier).persist();
    setState(() => _saving = false);
    if (mounted) context.go(AppRoutes.onboardingCategory);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      stepIndex: 1,
      totalSteps: 7,
      title: 'Tell us about your business',
      subtitle: "We'll use this to personalize your content and CTAs.",
      isLoading: _saving,
      continueEnabled: _businessNameController.text.trim().isNotEmpty,
      onContinue: _onContinue,
      child: Column(
        children: [
          TextField(
            controller: _businessNameController,
            decoration: const InputDecoration(labelText: 'Business name'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _websiteController,
            decoration: const InputDecoration(labelText: 'Website (optional)'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone number'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _cityController,
            decoration: const InputDecoration(labelText: 'City / service area'),
          ),
        ],
      ),
    );
  }
}
