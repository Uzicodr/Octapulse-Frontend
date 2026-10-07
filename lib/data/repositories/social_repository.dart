import '../models/pick.dart';
import '../models/social.dart';
import '../services/api_client.dart';

/// Public profiles, follows, feed, leagues and the notification inbox.
class SocialRepository {
  SocialRepository(this._api);

  final ApiClient _api;

  // Users
  Future<UserProfile> profile(String userId) async =>
      UserProfile.fromJson(await _api.get<Map<String, dynamic>>('/users/$userId'));

  /// Locked fights only, so open picks can't be copied.
  Future<List<Pick>> userPicks(String userId) async {
    final json = await _api.get<List<dynamic>>('/users/$userId/picks');
    return json.map((p) => Pick.fromJson(p as Map<String, dynamic>)).toList();
  }

  Future<void> setFollowing(String userId, bool follow) =>
      follow ? _api.post<void>('/users/$userId/follow') : _api.delete('/users/$userId/follow');

  Future<Page<UserSummary>> followers(String userId, {int page = 1}) => _users('/users/$userId/followers', page);

  Future<Page<UserSummary>> following(String userId, {int page = 1}) => _users('/users/$userId/following', page);

  Future<Page<UserSummary>> _users(String path, int page) async {
    final json = await _api.get<Map<String, dynamic>>(path, query: {'page': page, 'limit': 50});
    return Page.fromJson(json, UserSummary.fromJson);
  }

  Future<Page<FeedItem>> feed({int page = 1}) async {
    final json = await _api.get<Map<String, dynamic>>('/me/feed', query: {'page': page, 'limit': 30});
    return Page.fromJson(json, FeedItem.fromJson);
  }

  // Leagues
  Future<List<League>> myLeagues() async {
    final json = await _api.get<List<dynamic>>('/me/leagues');
    return json.map((l) => League.fromJson(l as Map<String, dynamic>)).toList();
  }

  Future<League> createLeague(String name) async =>
      League.fromJson(await _api.post<Map<String, dynamic>>('/leagues', {'name': name}));

  Future<League> joinLeague(String inviteCode) async => League.fromJson(
        await _api.post<Map<String, dynamic>>('/leagues/join', {'inviteCode': inviteCode.trim()}),
      );

  Future<LeagueDetail> league(String leagueId) async =>
      LeagueDetail.fromJson(await _api.get<Map<String, dynamic>>('/leagues/$leagueId'));

  Future<List<LeaderboardEntry>> leagueLeaderboard(String leagueId) async {
    final json = await _api.get<List<dynamic>>('/leagues/$leagueId/leaderboard');
    return json.map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> leaveLeague(String leagueId) => _api.post<void>('/leagues/$leagueId/leave');

  Future<League> regenerateInvite(String leagueId) async =>
      League.fromJson(await _api.post<Map<String, dynamic>>('/leagues/$leagueId/invite-code'));

  Future<void> removeMember(String leagueId, String userId) =>
      _api.delete('/leagues/$leagueId/members/$userId');

  Future<void> deleteLeague(String leagueId) => _api.delete('/leagues/$leagueId');

  // Notifications
  Future<Page<AppNotification>> notifications({int page = 1}) async {
    final json = await _api.get<Map<String, dynamic>>(
      '/me/notifications',
      query: {'unreadOnly': false, 'page': page, 'limit': 50},
    );
    return Page.fromJson(json, AppNotification.fromJson);
  }

  Future<int> unreadCount() async {
    final json = await _api.get<Map<String, dynamic>>('/me/notifications/unread-count');
    return (json['unread'] as num?)?.toInt() ?? 0;
  }

  Future<void> markRead(String id) => _api.post<void>('/me/notifications/$id/read');

  Future<void> markAllRead() => _api.post<void>('/me/notifications/read-all');

  Future<NotificationSettings> notificationSettings() async =>
      NotificationSettings.fromJson(await _api.get<Map<String, dynamic>>('/me/notification-settings'));

  /// Sends only the given switch; returns the full settings.
  Future<NotificationSettings> updateNotificationSettings(Map<String, bool> change) async =>
      NotificationSettings.fromJson(await _api.patch<Map<String, dynamic>>('/me/notification-settings', change));

  // Meta
  /// Newest data write across events, fights, fighters and rankings.
  Future<DateTime?> lastDataUpdate() async {
    final json = await _api.get<Map<String, dynamic>>('/meta/last-sync');
    final stamps = (json['dataUpdatedAt'] as Map<String, dynamic>? ?? const {})
        .values
        .map((v) => parseDate(v))
        .whereType<DateTime>()
        .toList()
      ..sort();
    return stamps.isEmpty ? null : stamps.last;
  }
}
