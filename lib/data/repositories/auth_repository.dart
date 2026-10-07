import '../models/session.dart';
import '../models/social.dart';
import '../services/api_client.dart';
import '../services/session_store.dart';

class AuthRepository {
  AuthRepository(this._api, this._store);

  final ApiClient _api;
  final SessionStore _store;

  Future<Session?> restore() => _store.load();

  Future<Session> login({required String email, required String password}) {
    return _authenticate('/auth/login', {'email': email, 'password': password}, email: email);
  }

  Future<Session> signup({
    required String email,
    required String username,
    required String password,
  }) {
    return _authenticate(
      '/auth/signup',
      {'email': email, 'username': username, 'password': password},
      email: email,
    );
  }

  Future<Session> google(String idToken) => _authenticate('/auth/google', {'idToken': idToken});

  /// Revokes the refresh token server-side, then forgets it locally even if
  /// the call fails (offline, already revoked).
  Future<void> logout({bool everywhere = false}) async {
    final session = _store.current;
    try {
      if (everywhere) {
        await _api.post<void>('/auth/logout-all');
      } else if (session != null) {
        await _api.post<void>('/auth/logout', {'refreshToken': session.refreshToken});
      }
    } catch (_) {}
    await _store.clear();
  }

  Future<void> requestPasswordReset(String email) =>
      _api.post<void>('/auth/password-reset/request', {'email': email});

  Future<void> confirmPasswordReset({required String token, required String newPassword}) =>
      _api.post<void>('/auth/password-reset/confirm', {'token': token, 'newPassword': newPassword});

  Future<Me> me() async => Me.fromJson(await _api.get<Map<String, dynamic>>('/me'));

  /// Only the given fields change; pass "" to clear displayName, avatarUrl or bio.
  Future<Me> updateMe({String? username, String? displayName, String? avatarUrl, String? bio}) async {
    final json = await _api.patch<Map<String, dynamic>>('/me', {
      if (username != null) 'username': username,
      if (displayName != null) 'displayName': displayName,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (bio != null) 'bio': bio,
    });
    return Me.fromJson(json);
  }

  Future<UserStats> myStats() async =>
      UserStats.fromJson(await _api.get<Map<String, dynamic>>('/me/stats'));

  Future<Session> _authenticate(String path, Map<String, String> body, {String? email}) async {
    final json = await _api.post<Map<String, dynamic>>(path, body);
    final access = json['accessToken'] as String;
    final session = Session(
      userId: Session.subjectOf(access),
      accessToken: access,
      refreshToken: json['refreshToken'] as String,
      email: email,
    );
    await _store.save(session);
    return session;
  }
}
