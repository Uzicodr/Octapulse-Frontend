import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/social.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/skeleton.dart';
import '../view_models/notifications_view_model.dart';

class NotificationsView extends ConsumerWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(notificationsProvider);
    final hasUnread = inbox.valueOrNull?.any((n) => !n.isRead) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: () => ref.read(notificationsProvider.notifier).markAllRead(),
              style: TextButton.styleFrom(foregroundColor: AppColors.primaryBright),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () {
          ref.invalidate(unreadCountProvider);
          return ref.refresh(notificationsProvider.future);
        },
        child: AsyncBody<List<AppNotification>>(
          value: inbox,
          skeleton: const SkeletonList(item: SkeletonTile(avatar: 40), count: 7),
          onRetry: () => ref.invalidate(notificationsProvider),
          data: (items) => items.isEmpty
              ? ListView(
                  children: const [
                    EmptyState(
                      icon: Icons.notifications_none_rounded,
                      title: "You're all caught up",
                      message: 'Event reminders, bookings and results for fighters you follow land here.',
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _NotificationTile(
                    notification: items[i],
                    onTap: () {
                      ref.read(notificationsProvider.notifier).markRead(items[i]);
                      final route = routeFor(items[i]);
                      if (route != null) context.push(route);
                    },
                  ),
                ),
        ),
      ),
    );
  }

  /// Where a tap should go, based on `type` and `data`.
  static String? routeFor(AppNotification n) {
    final fightId = n.data['fightId'] as String?;
    final eventId = n.data['eventId'] as String?;
    return switch (n.type) {
      'fight_booked' || 'fight_result' when fightId != null => '/fight/$fightId',
      'event_reminder' || 'event_settled' when eventId != null => '/event/$eventId',
      _ when fightId != null => '/fight/$fightId',
      _ when eventId != null => '/event/$eventId',
      _ => null,
    };
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final (icon, color) = switch (n.type) {
      'event_reminder' => (Icons.alarm_rounded, AppColors.gold),
      'fight_booked' => (Icons.event_available_rounded, AppColors.blueCorner),
      'fight_result' => (Icons.sports_mma_rounded, AppColors.primaryBright),
      'event_settled' => (Icons.emoji_events_rounded, AppColors.win),
      _ => (Icons.notifications_rounded, AppColors.textSecondary),
    };
    return AppCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      borderColor: n.isRead ? null : AppColors.primary.withValues(alpha: 0.45),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 2),
                Text(n.body, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
                if (n.createdAt != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    Dates.ago(n.createdAt!),
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          if (!n.isRead)
            Container(
              width: 9,
              height: 9,
              margin: const EdgeInsets.only(top: 4, left: 8),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}
