/// Mirrors Firestore path: users/{userId}/searchIndex/{indexId}
///
/// Populated server-side only (see functions/src/search/*) whenever a
/// scheduled post, campaign, or media item is created/updated/deleted —
/// the client never writes to this collection, it only reads.
class SearchResult {
  final String id;
  final String type; // scheduledPost | campaign | media | template
  final String title;
  final String? subtitle;
  final String? thumbnailUrl;
  final String refPath; // Firestore path of the entity this result points to
  final DateTime updatedAt;

  const SearchResult({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.thumbnailUrl,
    required this.refPath,
    required this.updatedAt,
  });

  factory SearchResult.fromMap(String id, Map<String, dynamic> map) {
    return SearchResult(
      id: id,
      type: map['type'] as String? ?? '',
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String?,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      refPath: map['refPath'] as String? ?? '',
      updatedAt: map['updatedAt'] is DateTime
          ? map['updatedAt'] as DateTime
          : (map['updatedAt']?.toDate() ?? DateTime.now()),
    );
  }
}
