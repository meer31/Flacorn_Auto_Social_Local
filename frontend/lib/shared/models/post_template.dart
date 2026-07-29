/// Mirrors Firestore path: users/{userId}/postTemplates/{templateId}
/// (PDF Section 11 & 26).
class PostTemplate {
  final String id;
  final String platform;
  final String title;
  final String postIdea;
  final String captionText;
  final List<String> hashtags;
  final String cta;
  final String? mediaUrl;
  final int? contentScore;
  final DateTime? suggestedDateTime;
  final String createdBy;

  const PostTemplate({
    required this.id,
    required this.platform,
    required this.title,
    required this.postIdea,
    required this.captionText,
    required this.hashtags,
    required this.cta,
    this.mediaUrl,
    this.contentScore,
    this.suggestedDateTime,
    required this.createdBy,
  });

  factory PostTemplate.fromMap(String id, Map<String, dynamic> map) {
    return PostTemplate(
      id: id,
      platform: map['platform'] as String? ?? map['suggestedPlatform'] as String? ?? '',
      title: map['title'] as String? ?? '',
      postIdea: map['postIdea'] as String? ?? '',
      captionText: map['captionText'] as String? ?? '',
      hashtags: (map['hashtags'] as List?)?.cast<String>() ?? const [],
      cta: map['cta'] as String? ?? '',
      mediaUrl: map['mediaUrl'] as String?,
      contentScore: map['contentScore'] as int?,
      suggestedDateTime: map['suggestedDateTime'] != null
          ? DateTime.tryParse(map['suggestedDateTime'] as String)
          : null,
      createdBy: map['createdBy'] as String? ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'platform': platform,
      'title': title,
      'postIdea': postIdea,
      'captionText': captionText,
      'hashtags': hashtags,
      'cta': cta,
      'mediaUrl': mediaUrl,
      'contentScore': contentScore,
      'suggestedDateTime': suggestedDateTime?.toIso8601String(),
      'createdBy': createdBy,
    };
  }
}
