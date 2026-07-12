import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/repository_providers.dart';

/// Holds the result of the most recent AI Content Generator call so the
/// results list can be reviewed/edited/scheduled without re-fetching.
class AiContentState {
  final bool isLoading;
  final List<Map<String, dynamic>> posts;
  final String? errorMessage;

  const AiContentState({this.isLoading = false, this.posts = const [], this.errorMessage});

  AiContentState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? posts,
    String? errorMessage,
  }) {
    return AiContentState(
      isLoading: isLoading ?? this.isLoading,
      posts: posts ?? this.posts,
      errorMessage: errorMessage,
    );
  }
}

class AiContentController extends StateNotifier<AiContentState> {
  AiContentController(this._ref) : super(const AiContentState());

  final Ref _ref;

  Future<void> generate(Map<String, dynamic> input) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _ref.read(contentRepositoryProvider).generatePosts(input);
      final posts = (result['posts'] as List).cast<Map<String, dynamic>>();
      state = state.copyWith(isLoading: false, posts: posts);
    } catch (err) {
      state = state.copyWith(isLoading: false, errorMessage: err.toString());
    }
  }
}

final aiContentControllerProvider =
    StateNotifierProvider<AiContentController, AiContentState>(
  (ref) => AiContentController(ref),
);
