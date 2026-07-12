import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../../shared/models/scheduled_post.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/widgets/empty_state.dart';

/// Scheduler screen (PDF Section 14) — weekly/monthly calendar view with
/// create/edit/cancel actions and status labels + platform/account filters.
class SchedulerScreen extends ConsumerStatefulWidget {
  const SchedulerScreen({super.key});

  @override
  ConsumerState<SchedulerScreen> createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends ConsumerState<SchedulerScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _format = CalendarFormat.month;
  String? _platformFilter;

  Color _statusColor(String status) {
    switch (status) {
      case 'sent':
        return AppColors.statusSent;
      case 'failed':
        return AppColors.statusFailed;
      case 'pending':
        return AppColors.statusPending;
      case 'cancelled':
        return AppColors.statusCancelled;
      case 'needs_reconnect':
        return AppColors.statusNeedsReconnect;
      default:
        return AppColors.statusDraft;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allPosts = ref.watch(dashboardScheduledPostsProvider).valueOrNull ?? [];
    final filtered = _platformFilter == null
        ? allPosts
        : allPosts.where((p) => p.platform == _platformFilter).toList();

    final selectedDay = _selectedDay ?? _focusedDay;
    final postsForDay = filtered
        .where((p) =>
            p.scheduledAt.year == selectedDay.year &&
            p.scheduledAt.month == selectedDay.month &&
            p.scheduledAt.day == selectedDay.day)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 380,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Scheduler', style: AppTextStyles.headlineLarge(AppColors.textPrimary)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: _platformFilter,
                  decoration: const InputDecoration(labelText: 'Filter by platform'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All platforms')),
                    DropdownMenuItem(value: 'instagram', child: Text('Instagram')),
                    DropdownMenuItem(value: 'facebook', child: Text('Facebook')),
                    DropdownMenuItem(value: 'twitter', child: Text('X / Twitter')),
                    DropdownMenuItem(value: 'linkedin', child: Text('LinkedIn')),
                  ],
                  onChanged: (v) => setState(() => _platformFilter = v),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.now().subtract(const Duration(days: 365)),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: _focusedDay,
                    calendarFormat: _format,
                    selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                    onDaySelected: (selected, focused) =>
                        setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    }),
                    onFormatChanged: (format) => setState(() => _format = format),
                    eventLoader: (day) => filtered
                        .where((p) =>
                            p.scheduledAt.year == day.year &&
                            p.scheduledAt.month == day.month &&
                            p.scheduledAt.day == day.day)
                        .toList(),
                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(color: AppColors.flacronGold, shape: BoxShape.circle),
                      selectedDecoration: BoxDecoration(color: AppColors.flacronRed, shape: BoxShape.circle),
                      markerDecoration: BoxDecoration(color: AppColors.flacronRed, shape: BoxShape.circle),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Posts on ${selectedDay.toIso8601String().split('T').first}',
                  style: AppTextStyles.headlineSmall(AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: postsForDay.isEmpty
                      ? const EmptyState(
                          icon: Icons.event_busy_outlined,
                          title: 'Nothing scheduled for this day',
                          message: 'Generate content and schedule it to see it here.',
                        )
                      : ListView.separated(
                          itemCount: postsForDay.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) => _ScheduledPostTile(
                            post: postsForDay[index],
                            statusColor: _statusColor(postsForDay[index].status),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduledPostTile extends ConsumerWidget {
  const _ScheduledPostTile({required this.post, required this.statusColor});

  final ScheduledPost post;
  final Color statusColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.captionText, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium(AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(
                  '${post.platform} · ${post.scheduledAt.hour.toString().padLeft(2, '0')}:${post.scheduledAt.minute.toString().padLeft(2, '0')} · ${post.status}',
                  style: AppTextStyles.bodySmall(AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (post.status == 'pending' || post.status == 'draft')
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: AppColors.error),
              onPressed: () => ref.read(schedulingRepositoryProvider).cancelScheduledPost(post.id),
            ),
        ],
      ),
    );
  }
}
