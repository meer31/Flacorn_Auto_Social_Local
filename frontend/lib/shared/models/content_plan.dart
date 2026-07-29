/// Mirrors Firestore path: users/{userId}/contentPlans/{planId}
/// (PDF Section 12 & 26).
class ContentPlan {
  final String id;
  final String planName;
  final String businessCategory;
  final String goal;
  final DateTime startDate;
  final DateTime endDate;
  final List<Map<String, dynamic>> posts;
  final String status; // draft | scheduled | completed

  const ContentPlan({
    required this.id,
    required this.planName,
    required this.businessCategory,
    required this.goal,
    required this.startDate,
    required this.endDate,
    required this.posts,
    required this.status,
  });

  factory ContentPlan.fromMap(String id, Map<String, dynamic> map) {
    return ContentPlan(
      id: id,
      planName: map['planName'] as String? ?? '',
      businessCategory: map['businessCategory'] as String? ?? '',
      goal: map['goal'] as String? ?? '',
      startDate: DateTime.tryParse(map['startDate'] as String? ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(map['endDate'] as String? ?? '') ?? DateTime.now(),
      posts: (map['posts'] as List?)?.cast<Map<String, dynamic>>() ?? const [],
      status: map['status'] as String? ?? 'draft',
    );
  }
}
