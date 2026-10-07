import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/social.dart';
import '../../../../data/services/api_client.dart';
import '../../../../data/services/push_service.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/skeleton.dart';

final notificationSettingsProvider =
    AsyncNotifierProvider.autoDispose<NotificationSettingsController, NotificationSettings>(
        NotificationSettingsController.new);

class NotificationSettingsController extends AutoDisposeAsyncNotifier<NotificationSettings> {
  @override
  Future<NotificationSettings> build() => ref.read(socialRepositoryProvider).notificationSettings();

  /// Flips one switch at once, then keeps what the server saved (or rolls back on error).
  Future<void> set(String key, bool value, NotificationSettings optimistic) async {
    final previous = state.valueOrNull;
    state = AsyncData(optimistic);
    try {
      state = AsyncData(await ref.read(socialRepositoryProvider).updateNotificationSettings({key: value}));
    } catch (_) {
      if (previous != null) state = AsyncData(previous);
      rethrow;
    }
  }
}

/// Push switches. Turning one off only stops the push; the notification still lands in the inbox.
class NotificationSettingsView extends ConsumerWidget {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: AsyncBody<NotificationSettings>(
        value: settings,
        skeleton: const SkeletonList(item: SkeletonTile(avatar: 36), count: 5),
        onRetry: () => ref.invalidate(notificationSettingsProvider),
        data: (s) {
          Future<void> toggle(String key, bool value, NotificationSettings next) async {
            try {
              await ref.read(notificationSettingsProvider.notifier).set(key, value, next);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(e))));
              }
            }
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              if (!PushService.available)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Push notifications are not set up in this build yet. Everything still shows in your inbox.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              _Switch(
                icon: Icons.sensors_rounded,
                title: 'Live events',
                subtitle: 'When an event you picked or follow starts',
                value: s.live,
                onChanged: (v) => toggle('live', v, s.copyWith(live: v)),
              ),
              _Switch(
                icon: Icons.sports_mma_rounded,
                title: 'Results',
                subtitle: 'Fight results and your score once an event is settled',
                value: s.results,
                onChanged: (v) => toggle('results', v, s.copyWith(results: v)),
              ),
              _Switch(
                icon: Icons.event_available_rounded,
                title: 'Fight announcements',
                subtitle: 'When a fighter you follow is booked',
                value: s.announcements,
                onChanged: (v) => toggle('announcements', v, s.copyWith(announcements: v)),
              ),
              _Switch(
                icon: Icons.newspaper_rounded,
                title: 'Fighter news',
                subtitle: 'Bookings and injuries for fighters you follow, at most 3 a day',
                value: s.news,
                onChanged: (v) => toggle('news', v, s.copyWith(news: v)),
              ),
              _Switch(
                icon: Icons.alarm_rounded,
                title: 'Pick reminders',
                subtitle: 'A day before an event while you still have fights to pick',
                value: s.reminders,
                onChanged: (v) => toggle('reminders', v, s.copyWith(reminders: v)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  const _Switch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        radius: 18,
        padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
        child: SwitchListTile(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
          secondary: Icon(icon, color: AppColors.primaryBright),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ),
      ),
    );
  }
}
