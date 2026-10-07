import 'dart:convert';

/// Tokens for the signed-in user. Profile data lives in `Me`, loaded from /me.
class Session {
  const Session({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    this.email,
  });

  final String userId;
  final String accessToken;
  final String refreshToken;
  final String? email;

  Session copyWith({String? accessToken, String? refreshToken}) {
    return Session(
      userId: userId,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      email: email,
    );
  }

  /// Reads the `sub` claim (user id) from a JWT without verifying it.
  static String subjectOf(String jwt) {
    final parts = jwt.split('.');
    if (parts.length != 3) throw const FormatException('Malformed token');
    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    return (jsonDecode(payload) as Map<String, dynamic>)['sub'] as String;
  }
}
