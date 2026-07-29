import '../../core/services/firebase_service.dart';
import '../../core/services/functions_service.dart';
import '../models/social_account.dart';

class SocialAccountRepository {
  SocialAccountRepository({FirebaseService? firebaseService, FunctionsService? functionsService})
      : _firebase = firebaseService ?? FirebaseService.instance,
        _functions = functionsService ?? FunctionsService.instance;

  final FirebaseService _firebase;
  final FunctionsService _functions;

  Stream<List<SocialAccount>> watchAccounts(String userId) {
    return _firebase
        .userSubcollection(userId, 'socialAccounts')
        .snapshots()
        .map((snap) => snap.docs.map((d) => SocialAccount.fromMap(d.id, d.data())).toList());
  }

  Future<String> getOAuthUrl(String platform) async {
    final result = await _functions.getOAuthUrl(platform);
    return result['url'] as String;
  }

  Future<void> disconnect(String socialAccountId) {
    return _functions.disconnectSocialAccount(socialAccountId);
  }
}
