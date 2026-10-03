/// demo_widgets.dart
///
/// UI components for demo mode:
///   - DemoBanner: persistent top bar showing "Demo Mode" to client
///   - DemoOAuthBypass: shows "Connect" dialog that saves a fake account
///   - DemoBillingBypass: activates pro plan directly in Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flacron_auto_social/core/demo/demo_seed.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

// ── Demo Banner ───────────────────────────────────────────────────────────────

/// Wrap your app shell or any screen with this to show the demo badge.
/// Only visible when kDemoMode = true.
class DemoBanner extends StatelessWidget {
  const DemoBanner({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.amber.shade700,
            child: const SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.science_outlined,
                        size: 14, color: Colors.black87),
                    SizedBox(width: 6),
                    Text(
                      'DEMO MODE — No real accounts or payments connected',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Demo OAuth Bypass ─────────────────────────────────────────────────────────

/// Call this when getOAuthUrl returns a demo:// URL.
/// Shows a polished "Connecting..." flow and saves a fake account.
class DemoOAuthBypass {
  static Future<void> handle(
    BuildContext context,
    String platform,
    String uid,
  ) async {
    final platformName = _platformLabel(platform);

    // Show connecting dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(_platformIcon(platform), color: _platformColor(platform)),
            const SizedBox(width: 10),
            Text('Connecting $platformName'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Authorising with $platformName...',
              style: AppTextStyles.bodyMedium(AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );

    // Simulate OAuth flow delay
    await Future.delayed(const Duration(seconds: 2));

    // Save fake connected account to Firestore
    final db = FirebaseFirestore.instance;
    final now = FieldValue.serverTimestamp();
    final accountId =
        '${platform}_demo_${DateTime.now().millisecondsSinceEpoch}';

    await db.doc('users/$uid/socialAccounts/$accountId').set({
      'platform': platform,
      'accountName': _demoAccountName(platform),
      'accountIdFromPlatform': 'demo_${platform}_001',
      'accessTokenEncrypted': 'DEMO_TOKEN_$platform'.toUpperCase(),
      'refreshTokenEncrypted': null,
      'tokenExpiry': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 55)),
      ),
      'connectionStatus': 'connected',
      'lastRefreshedAt': now,
      'createdAt': now,
      'updatedAt': now,
    });

    if (context.mounted) {
      Navigator.of(context).pop(); // close connecting dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(_platformIcon(platform), color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text('$platformName connected successfully!'),
            ],
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  static String _platformLabel(String p) =>
      const {
        'instagram': 'Instagram',
        'facebook': 'Facebook',
        'twitter': 'X / Twitter',
        'linkedin': 'LinkedIn',
      }[p] ??
      p;

  static String _demoAccountName(String p) =>
      const {
        'instagram': '@glamourstudionyc',
        'facebook': 'Glamour Studio NYC',
        'twitter': '@glamourstudionyc',
        'linkedin': 'Glamour Studio NYC',
      }[p] ??
      'Demo Account';

  static IconData _platformIcon(String p) =>
      const {
        'instagram': Icons.camera_alt_outlined,
        'facebook': Icons.facebook,
        'twitter': Icons.alternate_email,
        'linkedin': Icons.work_outline,
      }[p] ??
      Icons.link;

  static Color _platformColor(String p) =>
      const {
        'instagram': Color(0xFFE1306C),
        'facebook': Color(0xFF1877F2),
        'twitter': Color(0xFF000000),
        'linkedin': Color(0xFF0A66C2),
      }[p] ??
      Colors.grey;
}

// ── Demo Billing Bypass ───────────────────────────────────────────────────────

/// Call this when createCheckoutSession returns a demo:// URL.
/// Shows a plan selector that updates Firestore directly — no Stripe needed.
class DemoBillingBypass {
  static Future<void> handle(
    BuildContext context,
    String plan,
    String uid,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.credit_card_outlined, color: AppColors.flacronRed),
            SizedBox(width: 10),
            Text('Demo Checkout'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.science_outlined, size: 16, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Demo mode — no real payment will be charged.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Activating plan: ${_planLabel(plan)}',
                style: AppTextStyles.bodyMedium(AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('This will unlock all ${_planLabel(plan)} features.',
                style: AppTextStyles.bodySmall(AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Activate Plan'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Update Firestore subscription directly
    final db = FirebaseFirestore.instance;
    final now = FieldValue.serverTimestamp();

    final limits = _planLimits(plan);
    await db.doc('subscriptions/$uid').update({
      'planName': plan,
      'status': 'active',
      'aiGenerationLimit': limits['aiLimit'],
      'scheduledPostLimit': limits['postLimit'],
      'socialAccountLimit': limits['accountLimit'],
      'arAccess': limits['arAccess'],
      'agencyAccess': limits['agencyAccess'],
      'currentPeriodEnd': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 30)),
      ),
      'updatedAt': now,
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_planLabel(plan)} plan activated! ✓'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  static String _planLabel(String p) =>
      {
        'starter': 'Starter (29/mo)',
        'pro': 'Pro (79/mo)',
        'agency': 'Agency (199/mo)',
        'enterprise': 'Enterprise',
      }[p] ??
      p;

  static Map<String, dynamic> _planLimits(String plan) =>
      const {
        'starter': {
          'aiLimit': 10,
          'postLimit': 10,
          'accountLimit': 3,
          'arAccess': false,
          'agencyAccess': false
        },
        'pro': {
          'aiLimit': 300,
          'postLimit': null,
          'accountLimit': 10,
          'arAccess': true,
          'agencyAccess': false
        },
        'agency': {
          'aiLimit': null,
          'postLimit': null,
          'accountLimit': 30,
          'arAccess': true,
          'agencyAccess': true
        },
        'enterprise': {
          'aiLimit': null,
          'postLimit': null,
          'accountLimit': null,
          'arAccess': true,
          'agencyAccess': true
        },
      }[plan] ??
      {
        'aiLimit': 10,
        'postLimit': 10,
        'accountLimit': 3,
        'arAccess': false,
        'agencyAccess': false
      };
}

// ── Seed Button (add to Settings screen during demo) ─────────────────────────

/// Add this button to your Settings screen so you can re-seed during the demo.
class DemoSeedButton extends StatefulWidget {
  const DemoSeedButton({super.key});
  @override
  State<DemoSeedButton> createState() => _DemoSeedButtonState();
}

class _DemoSeedButtonState extends State<DemoSeedButton> {
  bool _seeding = false;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _seeding ? null : _seed,
      icon: _seeding
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.science_outlined, size: 18),
      label: Text(_seeding ? 'Seeding demo data...' : 'Reset Demo Data'),
      style: OutlinedButton.styleFrom(foregroundColor: Colors.amber.shade700),
    );
  }

  Future<void> _seed() async {
    setState(() => _seeding = true);
    try {
      await DemoSeeder.seed();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demo data reset successfully ✓')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Seed failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _seeding = false);
    }
  }
}
