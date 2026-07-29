import '../../core/services/firebase_service.dart';
import '../../core/services/functions_service.dart';

class AnalyticsRepository {
  AnalyticsRepository({FirebaseService? firebaseService, FunctionsService? functionsService})
      : _firebase = firebaseService ?? FirebaseService.instance,
        _functions = functionsService ?? FunctionsService.instance;

  final FirebaseService _firebase;
  final FunctionsService _functions;

  Future<Map<String, dynamic>> getSummary({int rangeDays = 30}) {
    return _functions.generateAnalyticsSummary({'rangeDays': rangeDays});
  }

  Stream<List<Map<String, dynamic>>> watchWeeklyReports(String userId) {
    return _firebase
        .userSubcollection(userId, 'weeklyReports')
        .orderBy('createdAt', descending: true)
        .limit(12)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }
}
