import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'api_client.dart';

/// Push notifications through Firebase Cloud Messaging.
///
/// Works only once the Firebase config files are in place (android/app/google-services.json,
/// ios/Runner/GoogleService-Info.plist). Without them [init] returns false and every other call
/// does nothing, so the app runs normally with the in-app inbox only.
class PushService {
  PushService(this._api);

  final ApiClient _api;

  static bool _available = false;

  /// Whether Firebase started. Set once by [init] in main().
  static bool get available => _available;

  String? _token;
  StreamSubscription<String>? _refresh;

  /// Starts Firebase. Call once before runApp.
  static Future<bool> init() async {
    if (kIsWeb) return false;
    try {
      await Firebase.initializeApp();
      _available = true;
    } catch (e) {
      debugPrint('Push disabled: Firebase did not start ($e)');
      _available = false;
    }
    return _available;
  }

  /// Asks for permission and sends this device's token to the backend. Call after sign-in.
  Future<void> register() async {
    if (!_available) return;
    final messaging = FirebaseMessaging.instance;
    final permission = await messaging.requestPermission();
    if (permission.authorizationStatus == AuthorizationStatus.denied) return;
    final token = await messaging.getToken();
    if (token == null) return;
    await _send(token);
    _refresh ??= messaging.onTokenRefresh.listen(_send);
  }

  /// Stops pushes to this device for the signed-in user. Call before signing out, while the
  /// access token still works.
  Future<void> unregister() async {
    if (!_available) return;
    await _refresh?.cancel();
    _refresh = null;
    final token = _token ?? await FirebaseMessaging.instance.getToken();
    if (token == null) return;
    try {
      await _api.post<void>('/me/devices/unregister', {'token': token});
    } catch (_) {
      // Signing out must not fail because of this; the backend drops dead tokens on its own.
    }
    _token = null;
  }

  Future<void> _send(String token) async {
    _token = token;
    await _api.post<void>('/me/devices', {'token': token, 'platform': Platform.isIOS ? 'ios' : 'android'});
  }

  /// Messages that arrive while the app is open (the system shows no banner for these).
  Stream<RemoteMessage> get foreground =>
      _available ? FirebaseMessaging.onMessage : const Stream.empty();

  /// Notifications the user tapped while the app was in the background.
  Stream<RemoteMessage> get opened =>
      _available ? FirebaseMessaging.onMessageOpenedApp : const Stream.empty();

  /// The notification that launched the app from closed, if any.
  Future<RemoteMessage?> launchMessage() async =>
      _available ? FirebaseMessaging.instance.getInitialMessage() : null;
}
