/// Mirrors Firestore path: users/{userId}/scheduledPosts/{postId}
/// (PDF Section 14 & 26).
class ScheduledPost {
  final String id;
  final String platform;
  final String socialAccountRef;
  final String captionText;
  final List<String> hashtags;
  final String? mediaUrl;
  final DateTime scheduledAt;
  final String timezone;
  final String status; // draft | pending | sent | failed | cancelled | needs_reconnect
  final String? externalPostId;
  final String? errorMessage;
  final int retryCount;

  const ScheduledPost({
    required this.id,
    required this.platform,
    required this.socialAccountRef,
    required this.captionText,
    required this.hashtags,
    this.mediaUrl,
    required this.scheduledAt,
    required this.timezone,
    required this.status,
    this.externalPostId,
    this.errorMessage,
    required this.retryCount,
  });

  factory ScheduledPost.fromMap(String id, Map<String, dynamic> map) {
    return ScheduledPost(
      id: id,
      platform: map['platform'] as String? ?? '',
      socialAccountRef: map['socialAccountRef'] as String? ?? '',
      captionText: map['captionText'] as String? ?? '',
      hashtags: (map['hashtags'] as List?)?.cast<String>() ?? const [],
      mediaUrl: map['mediaUrl'] as String?,
      scheduledAt: DateTime.tryParse(map['scheduledAt'] as String? ?? '') ?? DateTime.now(),
      timezone: map['timezone'] as String? ?? 'UTC',
      status: map['status'] as String? ?? 'draft',
      externalPostId: map['externalPostId'] as String?,
      errorMessage: map['errorMessage'] as String?,
      retryCount: map['retryCount'] as int? ?? 0,
    );
  }
}
