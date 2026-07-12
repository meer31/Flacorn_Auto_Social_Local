import '../../core/services/firebase_service.dart';
import '../../core/services/functions_service.dart';
import '../models/user_profile.dart';

/// Data access layer for user profile reads/writes.
/// Screens/providers should go through repositories rather than calling
/// FirebaseService/FunctionsService directly, so query logic stays testable
/// and reusable.
class UserRepository {
  UserRepository({FirebaseService? firebaseService, FunctionsService? functionsService})
      : _firebase = firebaseService ?? FirebaseService.instance,
        _functions = functionsService ?? FunctionsService.instance;

  final FirebaseService _firebase;
  final FunctionsService _functions;

  Stream<UserProfile?> watchUserProfile(String userId) {
    return _firebase.userDoc(userId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return UserProfile.fromMap(snap.id, snap.data()!);
    });
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    final snap = await _firebase.userDoc(userId).get();
    if (!snap.exists) return null;
    return UserProfile.fromMap(snap.id, snap.data()!);
  }

  /// Calls the `updateUserProfile` Cloud Function (never writes directly to
  /// Firestore for fields that affect plan/role logic — see PDF Section 7).
  Future<void> updateProfile(Map<String, dynamic> partialUpdate) {
    return _functions.updateUserProfile(partialUpdate);
  }
}
