import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/session.dart';
import '../../core/providers.dart';
import 'view_models/notifications_view_model.dart';
import 'views/notifications_view.dart';

/// Connects push notifications to the app: registers this device after sign-in, opens the right
/// screen when a notification is tapped, and shows a banner for ones that arrive while the app is open.
class PushBinding extends ConsumerStatefulWidget {
  const PushBinding({super.key, required this.router, required this.messengerKey, required this.child});

  final GoRouter router;
  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final Widget child;

  @override
  ConsumerState<PushBinding> createState() => _PushBindingState();
}

class _PushBindingState extends ConsumerState<PushBinding> {
  final _subscriptions = <StreamSubscription<RemoteMessage>>[];

  @override
  void initState() {
    super.initState();
    final push = ref.read(pushServiceProvider);
    _subscriptions
      ..add(push.opened.listen(_open))
      ..add(push.foreground.listen(_showBanner));
    push.launchMessage().then((message) {
      if (message != null) _open(message);
    });
    // Register whenever a session appears: on sign-in, and at start when already signed in.
    ref.listenManual<AsyncValue<Session?>>(authControllerProvider, (previous, next) {
      final was = previous?.valueOrNull;
      final now = next.valueOrNull;
      if (now != null && (was == null || was.userId != now.userId)) {
        push.register().catchError((Object e) => debugPrint('Push registration failed: $e'));
      }
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    super.dispose();
  }

  void _open(RemoteMessage message) {
    final type = message.data['type'] as String? ?? '';
    final url = message.data['url'] as String?;
    if (type == 'fighter_news' && url != null) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      return;
    }
    final route = NotificationsView.routeForData(type, message.data);
    widget.router.push(route ?? '/notifications');
  }

  void _showBanner(RemoteMessage message) {
    ref.invalidate(unreadCountProvider);
    ref.invalidate(notificationsProvider);
    final title = message.notification?.title;
    if (title == null) return;
    widget.messengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
      action: SnackBarAction(label: 'View', onPressed: () => _open(message)),
      duration: const Duration(seconds: 5),
    ));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
