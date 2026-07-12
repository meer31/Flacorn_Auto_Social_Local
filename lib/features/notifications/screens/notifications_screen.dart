import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/services/firebase_service.dart';
import '../../../core/services/functions_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/empty_state.dart';

/// Notifications Center (PDF Section 24) — surfaces the Smart Alerts
/// described in PDF Section 23 (reconnect required, usage limits, top-post
/// highlights, weekly report ready, etc).
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    if (uid == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notifications', style: AppTextStyles.headlineLarge(AppColors.textPrimary)),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseService.instance
                  .userSubcollection(uid, 'notifications')
                  .orderBy('createdAt', descending: true)
                  .limit(50)
                  .snapshots(),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const EmptyState(
                    icon: Icons.notifications_none,
                    title: "You're all caught up",
                    message: 'New alerts about your accounts, posts, and reports will show up here.',
                  );
                }
                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final read = data['read'] as bool? ?? false;
                    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: read ? AppColors.surface : AppColors.flacronRed.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            read ? Icons.notifications_none : Icons.notifications_active,
                            color: read ? AppColors.textMuted : AppColors.flacronRed,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['title']?.toString() ?? '', style: AppTextStyles.bodyMedium(AppColors.textPrimary)),
                                Text(data['message']?.toString() ?? '', style: AppTextStyles.bodySmall(AppColors.textSecondary)),
                                if (createdAt != null)
                                  Text(timeago.format(createdAt), style: AppTextStyles.caption(AppColors.textMuted)),
                              ],
                            ),
                          ),
                          if (!read)
                            TextButton(
                              onPressed: () => FunctionsService.instance
                                  .call('markNotificationRead', {'notificationId': docs[index].id}),
                              child: const Text('Mark read'),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
