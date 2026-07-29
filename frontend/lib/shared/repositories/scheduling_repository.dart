import '../../core/services/firebase_service.dart';
import '../../core/services/functions_service.dart';
import '../models/scheduled_post.dart';

class SchedulingRepository {
  SchedulingRepository({FirebaseService? firebaseService, FunctionsService? functionsService})
      : _firebase = firebaseService ?? FirebaseService.instance,
        _functions = functionsService ?? FunctionsService.instance;

  final FirebaseService _firebase;
  final FunctionsService _functions;

  Stream<List<ScheduledPost>> watchScheduledPosts(String userId) {
    return _firebase
        .userSubcollection(userId, 'scheduledPosts')
        .orderBy('scheduledAt')
        .snapshots()
        .map((snap) => snap.docs.map((d) => ScheduledPost.fromMap(d.id, d.data())).toList());
  }

  Future<String> createScheduledPost(Map<String, dynamic> input) async {
    final result = await _functions.createScheduledPost(input);
    return result['scheduledPostId'] as String;
  }

  Future<void> updateScheduledPost(Map<String, dynamic> input) {
    return _functions.updateScheduledPost(input);
  }

  Future<void> cancelScheduledPost(String scheduledPostId) {
    return _functions.cancelScheduledPost(scheduledPostId);
  }
}
