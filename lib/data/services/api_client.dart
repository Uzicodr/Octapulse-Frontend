import 'package:dio/dio.dart';

import '../../config/env.dart';
import 'session_store.dart';

/// Thin wrapper around the Octapulse REST API.
///
/// Attaches the access token to every request and transparently refreshes it
/// once on a 401. Refresh tokens are single use, so concurrent 401s are queued
/// behind one refresh by [QueuedInterceptorsWrapper].
class ApiClient {
  ApiClient(this._sessions, {void Function()? onSessionExpired})
      : _onSessionExpired = onSessionExpired,
        dio = Dio(_options) {
    dio.interceptors.add(QueuedInterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _sessions.current?.accessToken;
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (error, handler) async {
        final request = error.requestOptions;
        final isAuthCall = request.path.startsWith('/auth/');
        if (error.response?.statusCode != 401 ||
            isAuthCall ||
            request.extra['retried'] == true ||
            _sessions.current == null) {
          return handler.next(error);
        }
        // Another queued request may already have refreshed the pair.
        final sentToken = (request.headers['Authorization'] as String?)?.substring(7);
        try {
          if (sentToken == _sessions.current!.accessToken) await _refresh();
          request.extra['retried'] = true;
          request.headers['Authorization'] = 'Bearer ${_sessions.current!.accessToken}';
          handler.resolve(await dio.fetch(request));
        } catch (_) {
          await _sessions.clear();
          _onSessionExpired?.call();
          handler.next(error);
        }
      },
    ));
  }

  // The free Render instance can take up to a minute to wake up.
  static final _options = BaseOptions(
    baseUrl: Env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    contentType: Headers.jsonContentType,
  );

  final SessionStore _sessions;
  final void Function()? _onSessionExpired;
  final Dio dio;

  Future<void> _refresh() async {
    final session = _sessions.current!;
    final response = await Dio(_options).post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': session.refreshToken},
    );
    final data = response.data!;
    await _sessions.save(session.copyWith(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    ));
  }

  Future<T> get<T>(String path, {Map<String, dynamic>? query}) async {
    final response = await dio.get<T>(path, queryParameters: query);
    return response.data as T;
  }

  Future<T> post<T>(String path, [Object? body]) async {
    final response = await dio.post<T>(path, data: body);
    return response.data as T;
  }

  Future<T> patch<T>(String path, Object body) async {
    final response = await dio.patch<T>(path, data: body);
    return response.data as T;
  }

  Future<void> delete(String path) => dio.delete<void>(path);
}

/// Whether [error] is an HTTP response with [status].
bool isStatus(Object error, int status) =>
    error is DioException && error.response?.statusCode == status;

/// Turns any API failure into a sentence a user can read. The backend writes
/// `message` for humans, so it wins whenever present.
String describeError(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String && (data['message'] as String).isNotEmpty) {
      return data['message'] as String;
    }
    final status = error.response?.statusCode;
    if (status == 429) {
      final wait = error.response?.headers.value('retry-after');
      return wait == null ? 'Too many attempts. Try again shortly.' : 'Too many attempts. Try again in ${wait}s.';
    }
    switch (status) {
      case 400:
        return 'Check your details and try again.';
      case 401:
        return 'Please sign in again.';
      case 403:
        return "You don't have access to that.";
      case 404:
        return 'Not found.';
      case 409:
        return 'That is already taken or locked.';
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      return "Can't reach the server. Is the backend running?";
    }
    if (error.type == DioExceptionType.receiveTimeout) {
      return 'The server is taking too long. Try again.';
    }
    return 'Something went wrong (${status ?? error.type.name}).';
  }
  return 'Something went wrong.';
}
