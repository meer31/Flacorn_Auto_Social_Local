import '../../core/services/firebase_service.dart';
import '../../core/services/functions_service.dart';
import '../models/subscription.dart';

class SubscriptionRepository {
  SubscriptionRepository({FirebaseService? firebaseService, FunctionsService? functionsService})
      : _firebase = firebaseService ?? FirebaseService.instance,
        _functions = functionsService ?? FunctionsService.instance;

  final FirebaseService _firebase;
  final FunctionsService _functions;

  /// MIGRATION NOTE (Team/RBAC): keyed by workspaceId now, not userId —
  /// see FirebaseService.subscriptionDoc.
  Stream<SubscriptionModel?> watchSubscription(String workspaceId) {
    return _firebase.subscriptionDoc(workspaceId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return SubscriptionModel.fromMap(snap.data()!);
    });
  }

  Future<Map<String, dynamic>> checkFeatureAccess(String feature) {
    return _functions.checkPlanAccess({'feature': feature});
  }

  /// MIGRATION NOTE (Team/RBAC): billing is per-workspace now — the
  /// backend enforces "admin" role or above for this call (an editor/
  /// viewer teammate can't change the plan).
  Future<String> startCheckout({
    required String workspaceId,
    required String plan,
    required String successUrl,
    required String cancelUrl,
  }) async {
    final result = await _functions.createCheckoutSession({
      'workspaceId': workspaceId,
      'plan': plan,
      'successUrl': successUrl,
      'cancelUrl': cancelUrl,
    });
    return result['checkoutUrl'] as String;
  }

  Future<String> getBillingPortalUrl() async {
    final result = await _functions.getBillingPortalUrl();
    return result['url'] as String;
  }
}
