import '../../core/services/firebase_service.dart';
import '../models/search_result.dart';

/// Reads the pre-built search index at workspaces/{workspaceId}/searchIndex/**.
/// The index itself is maintained entirely server-side (see
/// functions/src/search/) — this repository only ever reads.
///
/// MIGRATION NOTE (Team/RBAC): moved from users/{userId}/searchIndex so
/// every teammate in a workspace searches the same shared content, not
/// just their own.
class SearchRepository {
  SearchRepository({FirebaseService? firebaseService})
      : _firebase = firebaseService ?? FirebaseService.instance;

  final FirebaseService _firebase;

  /// Simple client-side "starts with" / substring filter over the cached
  /// index. Fine at the current scale (one workspace's own content); if
  /// result counts grow large enough to matter, swap this for a hosted
  /// search service (Algolia/Typesense) without changing the call site.
  Future<List<SearchResult>> search(String workspaceId, String query) async {
    final snap = await _firebase.workspaceSubcollection(workspaceId, 'searchIndex').get();
    final all = snap.docs.map((d) => SearchResult.fromMap(d.id, d.data())).toList();

    if (query.trim().isEmpty) return const [];
    final needle = query.trim().toLowerCase();
    return all.where((r) {
      return r.title.toLowerCase().contains(needle) ||
          (r.subtitle?.toLowerCase().contains(needle) ?? false);
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
}
