/// Mirrors Firestore path: users/{userId}/arCampaigns/{arCampaignId}
/// (PDF Section 17 & 26).
class ArCampaignModel {
  final String id;
  final String campaignName;
  final String arType; // promo_preview | product_showcase | qr_promo | before_and_after
  final String sourceMediaUrl;
  final String? previewScene;
  final String? generatedPreviewUrl;
  final String? qrCodeUrl;
  final String? linkedPostRef;
  final String status; // processing | ready | published

  const ArCampaignModel({
    required this.id,
    required this.campaignName,
    required this.arType,
    required this.sourceMediaUrl,
    this.previewScene,
    this.generatedPreviewUrl,
    this.qrCodeUrl,
    this.linkedPostRef,
    required this.status,
  });

  factory ArCampaignModel.fromMap(String id, Map<String, dynamic> map) {
    return ArCampaignModel(
      id: id,
      campaignName: map['campaignName'] as String? ?? '',
      arType: map['arType'] as String? ?? 'promo_preview',
      sourceMediaUrl: map['sourceMediaUrl'] as String? ?? '',
      previewScene: map['previewScene'] as String?,
      generatedPreviewUrl: map['generatedPreviewUrl'] as String?,
      qrCodeUrl: map['qrCodeUrl'] as String?,
      linkedPostRef: map['linkedPostRef'] as String?,
      status: map['status'] as String? ?? 'processing',
    );
  }
}
