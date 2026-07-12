/// Mirrors Firestore path: users/{userId}/campaigns/{campaignId}
/// (PDF Section 13 & 26).
class CampaignModel {
  final String id;
  final String campaignName;
  final String campaignType;
  final String goal;
  final DateTime startDate;
  final DateTime endDate;
  final List<Map<String, dynamic>> posts;
  final bool arEnabled;
  final String status;

  const CampaignModel({
    required this.id,
    required this.campaignName,
    required this.campaignType,
    required this.goal,
    required this.startDate,
    required this.endDate,
    required this.posts,
    required this.arEnabled,
    required this.status,
  });

  factory CampaignModel.fromMap(String id, Map<String, dynamic> map) {
    return CampaignModel(
      id: id,
      campaignName: map['campaignName'] as String? ?? '',
      campaignType: map['campaignType'] as String? ?? '',
      goal: map['goal'] as String? ?? '',
      startDate: DateTime.tryParse(map['startDate'] as String? ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(map['endDate'] as String? ?? '') ?? DateTime.now(),
      posts: (map['posts'] as List?)?.cast<Map<String, dynamic>>() ?? const [],
      arEnabled: map['arEnabled'] as bool? ?? false,
      status: map['status'] as String? ?? 'draft',
    );
  }
}
