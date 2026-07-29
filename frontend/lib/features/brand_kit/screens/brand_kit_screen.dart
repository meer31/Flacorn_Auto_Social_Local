import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/workspace_providers.dart';

/// AI Brand Voice Builder (PDF Section 21) — stores the brand voice profile
/// that all future AI content generation (generatePosts, generateContentPlan,
/// generateCampaign) references automatically via the backend.
class BrandKitScreen extends ConsumerStatefulWidget {
  const BrandKitScreen({super.key});

  @override
  ConsumerState<BrandKitScreen> createState() => _BrandKitScreenState();
}

class _BrandKitScreenState extends ConsumerState<BrandKitScreen> {
  final _toneController = TextEditingController();
  final _audienceController = TextEditingController();
  final _styleController = TextEditingController();
  final _ctaController = TextEditingController();
  final _wordsToUseController = TextEditingController();
  final _wordsToAvoidController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _toneController.dispose();
    _audienceController.dispose();
    _styleController.dispose();
    _ctaController.dispose();
    _wordsToUseController.dispose();
    _wordsToAvoidController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final workspaceId = ref.read(currentWorkspaceIdProvider);
    if (workspaceId == null) return;

    setState(() => _saving = true);
    try {
      await FirebaseService.instance.workspaceSubcollection(workspaceId, 'brandVoice').doc('default').set({
        'tone': _toneController.text.trim(),
        'audience': _audienceController.text.trim(),
        'style': _styleController.text.trim(),
        'preferredCTA': _ctaController.text.trim(),
        'wordsToUse': _wordsToUseController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
        'wordsToAvoid': _wordsToAvoidController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      }, SetOptions(merge: true));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI Brand Voice Builder', style: AppTextStyles.headlineLarge(AppColors.textPrimary)),
              const SizedBox(height: 6),
              Text(
                'All future AI content will follow this brand voice profile automatically.',
                style: AppTextStyles.bodyMedium(AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              TextField(controller: _toneController, decoration: const InputDecoration(labelText: 'Tone (e.g. Friendly, professional, confident)')),
              const SizedBox(height: 14),
              TextField(controller: _audienceController, decoration: const InputDecoration(labelText: 'Audience (e.g. Women 18-45 in Tacoma)')),
              const SizedBox(height: 14),
              TextField(controller: _styleController, decoration: const InputDecoration(labelText: 'Style')),
              const SizedBox(height: 14),
              TextField(controller: _ctaController, decoration: const InputDecoration(labelText: 'Preferred CTA')),
              const SizedBox(height: 14),
              TextField(controller: _wordsToUseController, decoration: const InputDecoration(labelText: 'Words to use (comma-separated)')),
              const SizedBox(height: 14),
              TextField(controller: _wordsToAvoidController, decoration: const InputDecoration(labelText: 'Words to avoid (comma-separated)')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save Brand Voice'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
