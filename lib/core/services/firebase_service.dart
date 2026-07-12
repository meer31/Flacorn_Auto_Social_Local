import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Thin wrapper around the Firebase SDK singletons.
///
/// Screens/providers should depend on this service (or the Riverpod
/// providers in shared/providers/firebase_providers.dart) rather than
/// calling `FirebaseAuth.instance` etc. directly everywhere, so tests can
/// swap in fakes and so any future multi-tenant / multi-project Firebase
/// setup (white-label, PDF Section 6) only requires changes here.
///
/// MIGRATION NOTE (Team/RBAC): content collections (socialAccounts,
/// scheduledPosts, campaigns, media, postTemplates, contentPlans,
/// brandVoice, businessSettings, notifications, weeklyReports,
/// arCampaigns, searchIndex) are moving from `users/{userId}/**` to
/// `workspaces/{workspaceId}/**` so multiple teammates can share one
/// workspace's content. Use [workspaceSubcollection] for all of those.
/// [userSubcollection] / [userDoc] remain for the user's own PROFILE only
/// (name, email, defaultWorkspaceId) — never for content.
class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  String? get currentUserId => auth.currentUser?.uid;

  // ---- User profile (identity only, not content) ----

  DocumentReference<Map<String, dynamic>> userDoc(String userId) =>
      firestore.collection('users').doc(userId);

  CollectionReference<Map<String, dynamic>> userSubcollection(
    String userId,
    String subcollection,
  ) =>
      userDoc(userId).collection(subcollection);

  // ---- Workspace (owns all content — see migration note above) ----

  DocumentReference<Map<String, dynamic>> workspaceDoc(String workspaceId) =>
      firestore.collection('workspaces').doc(workspaceId);

  CollectionReference<Map<String, dynamic>> workspaceSubcollection(
    String workspaceId,
    String subcollection,
  ) =>
      workspaceDoc(workspaceId).collection(subcollection);

  DocumentReference<Map<String, dynamic>> subscriptionDoc(String workspaceId) =>
      firestore.collection('subscriptions').doc(workspaceId);
}
