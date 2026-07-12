import '../../core/services/firebase_service.dart';
import '../../core/services/functions_service.dart';
import '../models/post_template.dart';
import '../models/content_plan.dart';
import '../models/campaign.dart';

/// Data access for AI-generated content: post templates, content plans,
/// and campaigns (PDF Sections 11, 12, 13).
class ContentRepository {
  ContentRepository({FirebaseService? firebaseService, FunctionsService? functionsService})
      : _firebase = firebaseService ?? FirebaseService.instance,
        _functions = functionsService ?? FunctionsService.instance;

  final FirebaseService _firebase;
  final FunctionsService _functions;

  // ---- Post templates ----
  Stream<List<PostTemplate>> watchTemplates(String userId) {
    return _firebase
        .userSubcollection(userId, 'postTemplates')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => PostTemplate.fromMap(d.id, d.data())).toList());
  }

  Future<Map<String, dynamic>> generatePosts(Map<String, dynamic> input) {
    return _functions.generatePosts(input);
  }

  Future<void> saveTemplateEdits(String userId, String templateId, Map<String, dynamic> updates) {
    return _firebase
        .userSubcollection(userId, 'postTemplates')
        .doc(templateId)
        .update(updates);
  }

  // ---- Content plans (30-day calendar) ----
  Stream<List<ContentPlan>> watchContentPlans(String userId) {
    return _firebase
        .userSubcollection(userId, 'contentPlans')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ContentPlan.fromMap(d.id, d.data())).toList());
  }

  Future<Map<String, dynamic>> generateContentPlan(Map<String, dynamic> input) {
    return _functions.generateContentPlan(input);
  }

  // ---- Campaigns ----
  Stream<List<CampaignModel>> watchCampaigns(String userId) {
    return _firebase
        .userSubcollection(userId, 'campaigns')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => CampaignModel.fromMap(d.id, d.data())).toList());
  }

  Future<Map<String, dynamic>> generateCampaign(Map<String, dynamic> input) {
    return _functions.generateCampaign(input);
  }
}
