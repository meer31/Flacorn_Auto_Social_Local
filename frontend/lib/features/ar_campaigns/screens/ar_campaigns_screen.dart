import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/providers/user_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../../shared/widgets/upgrade_prompt_banner.dart';

/// AR Campaigns screen (PDF Section 17).
/// Covers all four AR feature types: Promo Preview, Product Showcase,
/// QR Promo, and Before-and-After content. MVP renders a realistic
/// web-based composited preview (see functions/src/ar/generateArPreview.ts);
/// true WebAR/WebXR and mobile ARCore/ARKit rendering are Phase 2 — see
/// docs/AR_ROADMAP.md.
class ArCampaignsScreen extends ConsumerStatefulWidget {
  const ArCampaignsScreen({super.key});

  @override
  ConsumerState<ArCampaignsScreen> createState() => _ArCampaignsScreenState();
}

class _ArCampaignsScreenState extends ConsumerState<ArCampaignsScreen> {
  String _arType = AppConstants.arTypes.first;
  String _scene = AppConstants.arPreviewScenes.first;
  final _mediaUrlController = TextEditingController();
  bool _creating = false;

  @override
  void dispose() {
    _mediaUrlController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_mediaUrlController.text.trim().isEmpty) return;
    setState(() => _creating = true);
    try {
      final id = await ref.read(arRepositoryProvider).createCampaign({
        'campaignName': '$_arType — ${DateTime.now().toIso8601String().split('T').first}',
        'arType': _arType,
        'sourceMediaUrl': _mediaUrlController.text.trim(),
        'previewScene': _scene,
      });
      await ref.read(arRepositoryProvider).generatePreview(id);
      _mediaUrlController.clear();
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('AR generation failed: $err')));
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    final subscription = ref.watch(currentSubscriptionProvider).valueOrNull;
    final hasArAccess = subscription?.arAccess ?? false;

    if (uid == null) return const SizedBox.shrink();
    final campaignsAsync = ref.watch(_arCampaignsProvider(uid));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AR Campaigns', style: AppTextStyles.headlineMedium(AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text('Preview your promo in a storefront, salon mirror, or product display.',
                    style: AppTextStyles.bodyMedium(AppColors.textSecondary)),
                const SizedBox(height: 20),
                if (!hasArAccess) ...[
                  const UpgradePromptBanner(message: 'AR Campaigns are available on Pro and Agency plans.'),
                  const SizedBox(height: 20),
                ],
                DropdownButtonFormField<String>(
                  initialValue: _arType,
                  decoration: const InputDecoration(labelText: 'AR type'),
                  items: [for (final t in AppConstants.arTypes) DropdownMenuItem(value: t, child: Text(t))],
                  onChanged: hasArAccess ? (v) => setState(() => _arType = v!) : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _scene,
                  decoration: const InputDecoration(labelText: 'Preview scene'),
                  items: [for (final s in AppConstants.arPreviewScenes) DropdownMenuItem(value: s, child: Text(s))],
                  onChanged: hasArAccess ? (v) => setState(() => _scene = v!) : null,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _mediaUrlController,
                  enabled: hasArAccess,
                  decoration: const InputDecoration(
                    labelText: 'Source media URL',
                    hintText: 'Upload to Media Library first, then paste the URL',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: hasArAccess && !_creating ? _create : null,
                  child: _creating
                      ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Generate AR Preview'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: campaignsAsync.when(
              loading: () => ListView.separated(
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => const SkeletonCard(height: 140),
              ),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (campaigns) {
                if (campaigns.isEmpty) {
                  return const EmptyState(
                    icon: Icons.view_in_ar_outlined,
                    title: 'No AR campaigns yet',
                    message: 'Upload a promo image and generate your first AR-style preview.',
                  );
                }
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: campaigns.length,
                  itemBuilder: (context, index) {
                    final c = campaigns[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                              child: c.generatedPreviewUrl != null
                                  ? Image.network(c.generatedPreviewUrl!, fit: BoxFit.cover, width: double.infinity)
                                  : Container(
                                      color: AppColors.surface,
                                      child: const Icon(Icons.view_in_ar_outlined, size: 40, color: AppColors.textMuted),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.campaignName, style: AppTextStyles.bodyMedium(AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(c.status, style: AppTextStyles.caption(AppColors.textMuted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

final _arCampaignsProvider = StreamProvider.family((ref, String userId) {
  return ref.watch(arRepositoryProvider).watchArCampaigns(userId);
});
