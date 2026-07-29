import '../../core/services/firebase_service.dart';
import '../../core/services/functions_service.dart';
import '../models/ar_campaign.dart';

class ArRepository {
  ArRepository({FirebaseService? firebaseService, FunctionsService? functionsService})
      : _firebase = firebaseService ?? FirebaseService.instance,
        _functions = functionsService ?? FunctionsService.instance;

  final FirebaseService _firebase;
  final FunctionsService _functions;

  Stream<List<ArCampaignModel>> watchArCampaigns(String userId) {
    return _firebase
        .userSubcollection(userId, 'arCampaigns')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ArCampaignModel.fromMap(d.id, d.data())).toList());
  }

  Future<String> createCampaign(Map<String, dynamic> input) async {
    final result = await _functions.createArCampaign(input);
    return result['arCampaignId'] as String;
  }

  Future<String> generatePreview(String arCampaignId) async {
    final result = await _functions.generateArPreview(arCampaignId);
    return result['generatedPreviewUrl'] as String;
  }

  Future<String> createQrPromo({required String arCampaignId, required String destinationUrl}) async {
    final result = await _functions.createQrPromo({
      'arCampaignId': arCampaignId,
      'destinationUrl': destinationUrl,
    });
    return result['qrCodeUrl'] as String;
  }
}
