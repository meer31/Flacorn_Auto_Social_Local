import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/functions_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/providers/user_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Booking CTA Generator (PDF Section 19).
///
/// User saves their booking link, phone, website, promo code, service
/// area, and business hours. The AI generates stronger, platform-optimised
/// calls-to-action that get injected into every generated post automatically.
class BookingCtaScreen extends ConsumerStatefulWidget {
  const BookingCtaScreen({super.key});

  @override
  ConsumerState<BookingCtaScreen> createState() => _BookingCtaScreenState();
}

class _BookingCtaScreenState extends ConsumerState<BookingCtaScreen> {
  final _bookingLinkController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _promoCodeController = TextEditingController();
  final _serviceAreaController = TextEditingController();
  final _businessHoursController = TextEditingController();
  final _customCtaController = TextEditingController();

  bool _saving = false;
  bool _generating = false;
  List<String>? _generatedCtas;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefillFromProfile());
  }

  void _prefillFromProfile() {
    final profile = ref.read(currentUserProfileProvider).valueOrNull;
    if (profile == null) return;
    _bookingLinkController.text = profile.bookingLink ?? '';
    _phoneController.text = profile.phoneNumber ?? '';
    _websiteController.text = profile.website ?? '';
  }

  @override
  void dispose() {
    _bookingLinkController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _promoCodeController.dispose();
    _serviceAreaController.dispose();
    _businessHoursController.dispose();
    _customCtaController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    setState(() => _saving = true);
    try {
      await ref.read(userRepositoryProvider).updateProfile({
        'bookingLink': _bookingLinkController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'website': _websiteController.text.trim(),
        'promoCode': _promoCodeController.text.trim(),
        'serviceArea': _serviceAreaController.text.trim(),
        'businessHours': _businessHoursController.text.trim(),
        'defaultCTA': _customCtaController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Business settings saved.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not save: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _generateCtas() async {
    setState(() {
      _generating = true;
      _generatedCtas = null;
      _error = null;
    });
    try {
      final result = await FunctionsService.instance
          .call<Map<String, dynamic>>('generateBookingCta', {
        'bookingLink': _bookingLinkController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'website': _websiteController.text.trim(),
        'promoCode': _promoCodeController.text.trim().isEmpty
            ? null
            : _promoCodeController.text.trim(),
        'serviceArea': _serviceAreaController.text.trim().isEmpty
            ? null
            : _serviceAreaController.text.trim(),
        'businessHours': _businessHoursController.text.trim().isEmpty
            ? null
            : _businessHoursController.text.trim(),
      });
      final ctas = (result['ctas'] as List?)?.cast<String>() ??
          (result['ctaList'] as List?)?.cast<String>() ??
          [];
      setState(() {
        _generatedCtas = ctas;
        _generating = false;
      });
    } catch (err) {
      setState(() {
        _error = err.toString();
        _generating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Input / settings panel ----
          SizedBox(
            width: 340,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Booking CTA Generator',
                    style: AppTextStyles.headlineMedium(AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text(
                  'Save your booking details and generate stronger calls-to-action for every post.',
                  style: AppTextStyles.bodyMedium(AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _bookingLinkController,
                  decoration: const InputDecoration(
                    labelText: 'Booking link',
                    hintText: 'https://calendly.com/...',
                    prefixIcon: Icon(Icons.link_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _websiteController,
                  decoration: const InputDecoration(
                    labelText: 'Website',
                    hintText: 'https://yourbusiness.com',
                    prefixIcon: Icon(Icons.language_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _promoCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Promo code (optional)',
                    prefixIcon: Icon(Icons.local_offer_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _serviceAreaController,
                  decoration: const InputDecoration(
                    labelText: 'Service area (optional)',
                    hintText: 'e.g. Greater London, Tacoma WA',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _businessHoursController,
                  decoration: const InputDecoration(
                    labelText: 'Business hours (optional)',
                    hintText: 'e.g. Mon–Sat 9am–6pm',
                    prefixIcon: Icon(Icons.schedule_outlined),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving ? null : _saveSettings,
                        child: _saving
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.flacronRed),
                              )
                            : const Text('Save Settings'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _generating ? null : _generateCtas,
                        child: _generating
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Generate CTAs'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),

          // ---- Results panel ----
          Expanded(
            child: _generating
                ? ListView.separated(
                    itemCount: 5,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, __) => const SkeletonCard(height: 72),
                  )
                : _error != null
                    ? Center(
                        child: Text('Error: $_error',
                            style: AppTextStyles.bodyMedium(AppColors.error)),
                      )
                    : _generatedCtas == null
                        ? const EmptyState(
                            icon: Icons.ads_click_outlined,
                            title: 'No CTAs generated yet',
                            message:
                                'Fill in your booking details and tap "Generate CTAs" to create high-converting calls-to-action.',
                          )
                        : _CtaResultsList(ctas: _generatedCtas!),
          ),
        ],
      ),
    );
  }
}

class _CtaResultsList extends StatelessWidget {
  const _CtaResultsList({required this.ctas});
  final List<String> ctas;

  static const List<String> _ctaExamples = [
    'Book now',
    'DM to reserve your spot',
    'Call today',
    'Schedule your consultation',
    'Claim this offer',
    'Visit our website',
    'Limited spots available this week',
  ];

  @override
  Widget build(BuildContext context) {
    final displayCtas = ctas.isNotEmpty ? ctas : _ctaExamples;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Generated CTAs', style: AppTextStyles.headlineSmall(AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(
          'Tap to copy any CTA. These are auto-injected into posts when you generate content.',
          style: AppTextStyles.bodySmall(AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: displayCtas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final cta = displayCtas[index];
              return _CtaTile(cta: cta, index: index);
            },
          ),
        ),
      ],
    );
  }
}

class _CtaTile extends StatelessWidget {
  const _CtaTile({required this.cta, required this.index});
  final String cta;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.flacronRed.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: AppTextStyles.caption(AppColors.flacronRed),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(cta, style: AppTextStyles.bodyMedium(AppColors.textPrimary)),
          ),
          IconButton(
            icon: const Icon(Icons.copy_outlined, size: 18),
            tooltip: 'Copy',
            color: AppColors.textMuted,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: cta));
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('CTA copied')));
            },
          ),
        ],
      ),
    );
  }
}
