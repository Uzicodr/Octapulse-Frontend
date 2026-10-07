import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/social.dart';
import '../../../core/providers.dart';

/// Badge count, refreshed whenever the inbox changes or the app resumes.
final unreadCountProvider = FutureProvider<int>((ref) async {
  final session = await ref.watch(authControllerProvider.future);
  if (session == null) return 0;
  return ref.read(socialRepositoryProvider).unreadCount();
});

final notificationsProvider =
    AsyncNotifierProvider<NotificationsController, List<AppNotification>>(NotificationsController.new);

class NotificationsController extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    final page = await ref.read(socialRepositoryProvider).notifications();
    return page.items;
  }

  Future<void> markRead(AppNotification n) async {
    if (n.isRead) return;
    await ref.read(socialRepositoryProvider).markRead(n.id);
    ref.invalidateSelf();
    ref.invalidate(unreadCountProvider);
  }

  Future<void> markAllRead() async {
    await ref.read(socialRepositoryProvider).markAllRead();
    ref.invalidateSelf();
    ref.invalidate(unreadCountProvider);
  }
}
