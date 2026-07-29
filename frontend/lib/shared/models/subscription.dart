/// Mirrors Firestore path: subscriptions/{userId} (PDF Section 9 & 26).
class SubscriptionModel {
  final String planName;
  final String status;
  final int? aiGenerationLimit;
  final int aiGenerationsUsed;
  final int? scheduledPostLimit;
  final int scheduledPostsUsed;
  final int? socialAccountLimit;
  final int socialAccountsUsed;
  final bool arAccess;
  final bool agencyAccess;

  const SubscriptionModel({
    required this.planName,
    required this.status,
    required this.aiGenerationLimit,
    required this.aiGenerationsUsed,
    required this.scheduledPostLimit,
    required this.scheduledPostsUsed,
    required this.socialAccountLimit,
    required this.socialAccountsUsed,
    required this.arAccess,
    required this.agencyAccess,
  });

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      planName: map['planName'] as String? ?? 'starter',
      status: map['status'] as String? ?? 'incomplete',
      aiGenerationLimit: map['aiGenerationLimit'] as int?,
      aiGenerationsUsed: map['aiGenerationsUsed'] as int? ?? 0,
      scheduledPostLimit: map['scheduledPostLimit'] as int?,
      scheduledPostsUsed: map['scheduledPostsUsed'] as int? ?? 0,
      socialAccountLimit: map['socialAccountLimit'] as int?,
      socialAccountsUsed: map['socialAccountsUsed'] as int? ?? 0,
      arAccess: map['arAccess'] as bool? ?? false,
      agencyAccess: map['agencyAccess'] as bool? ?? false,
    );
  }

  bool get isActive => status == 'active' || status == 'trialing';

  /// Returns a 0.0–1.0 usage fraction, or null if the limit is unlimited.
  double? get aiUsageFraction =>
      aiGenerationLimit == null ? null : aiGenerationsUsed / aiGenerationLimit!;
}
