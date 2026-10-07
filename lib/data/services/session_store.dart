import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/session.dart';

/// Persists the signed-in session in the platform keystore.
class SessionStore {
  SessionStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _access = 'access_token';
  static const _refresh = 'refresh_token';
  static const _email = 'email';

  Session? _current;
  Session? get current => _current;

  Future<Session?> load() async {
    final values = await _storage.readAll();
    final access = values[_access];
    final refresh = values[_refresh];
    if (access == null || refresh == null) return null;
    try {
      _current = Session(
        userId: Session.subjectOf(access),
        accessToken: access,
        refreshToken: refresh,
        email: values[_email],
      );
    } on FormatException {
      await clear();
    }
    return _current;
  }

  Future<void> save(Session session) async {
    _current = session;
    await _storage.write(key: _access, value: session.accessToken);
    await _storage.write(key: _refresh, value: session.refreshToken);
    if (session.email != null) {
      await _storage.write(key: _email, value: session.email);
    }
  }

  Future<void> clear() async {
    _current = null;
    await _storage.deleteAll();
  }
}
