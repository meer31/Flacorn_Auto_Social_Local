import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/search_result.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/providers/workspace_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../widgets/search_result_tile.dart';

/// Searches across the current user's scheduled posts, campaigns, media,
/// and templates. Opened as a full screen on mobile and as a dialog overlay
/// on desktop (see [showGlobalSearch] below) — either way this widget is
/// the shared implementation.
class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  /// Opens search as a centered dialog — used by the desktop sidebar's
  /// search entry. On mobile, push AppRoutes.globalSearch as a full screen
  /// instead (dialogs are cramped on small widths).
  static Future<void> showAsDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 80, vertical: 100),
        child: SizedBox(width: 560, child: GlobalSearchScreen()),
      ),
    );
  }

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<SearchResult> _results = const [];
  bool _loading = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _runSearch(query));
  }

  Future<void> _runSearch(String query) async {
    final workspaceId = ref.read(currentWorkspaceIdProvider);
    if (workspaceId == null || query.trim().isEmpty) {
      setState(() => _results = const []);
      return;
    }
    setState(() => _loading = true);
    try {
      final results = await ref.read(searchRepositoryProvider).search(workspaceId, query);
      if (mounted) setState(() => _results = results);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 480),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onChanged,
              style: AppTextStyles.bodyLarge(AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Search posts, campaigns, media, templates…',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Flexible(
            child: _loading
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _results.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: EmptyState(
                          icon: Icons.search_off,
                          title: _controller.text.trim().isEmpty ? 'Search everything' : 'No results',
                          message: _controller.text.trim().isEmpty
                              ? 'Find scheduled posts, campaigns, media, and templates in one place.'
                              : 'Try a different search term.',
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _results.length,
                        itemBuilder: (context, i) => SearchResultTile(result: _results[i]),
                      ),
          ),
        ],
      ),
    );
  }
}
