import '../models/pick.dart';
import '../models/social.dart';
import '../services/api_client.dart';

enum LeaderboardScope { all, month, following }

class PicksRepository {
  PicksRepository(this._api);

  final ApiClient _api;

  Future<List<Pick>> mine() async {
    final json = await _api.get<List<dynamic>>('/picks/me');
    return json.map((p) => Pick.fromJson(p as Map<String, dynamic>)).toList();
  }

  /// Creates or replaces the pick for [fightId]. Fails with 409 once locked.
  Future<Pick> submit({
    required String fightId,
    required String fighterId,
    PickMethod? method,
    int? round,
    int confidence = 1,
  }) async {
    final json = await _api.post<Map<String, dynamic>>('/picks', {
      'fightId': fightId,
      'pickedFighterId': fighterId,
      if (method != null) 'method': method.api,
      if (round != null) 'round': round,
      'confidence': confidence,
    });
    return Pick.fromJson(json);
  }

  Future<void> remove(String fightId) => _api.delete('/picks/$fightId');

  /// The AI's picks for an event, keyed by fight id.
  Future<Map<String, Pick>> aiPicks(String eventId) async {
    final json = await _api.get<List<dynamic>>('/ai/picks', query: {'eventId': eventId});
    final picks = json.map((p) => Pick.fromJson(p as Map<String, dynamic>));
    return {for (final p in picks) p.fightId: p};
  }

  Future<({UserSummary user, UserStats stats})> aiProfile() async {
    final json = await _api.get<Map<String, dynamic>>('/ai');
    return (
      user: UserSummary.fromJson(json['user'] as Map<String, dynamic>),
      stats: UserStats.fromJson(json['stats'] as Map<String, dynamic>),
    );
  }

  Future<List<LeaderboardEntry>> leaderboard({
    LeaderboardScope scope = LeaderboardScope.all,
    String? eventId,
    int limit = 100,
  }) async {
    final json = await _api.get<List<dynamic>>('/leaderboard', query: {
      'scope': scope.name,
      if (eventId != null) 'eventId': eventId,
      'limit': limit,
    });
    return json.map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>)).toList();
  }
}
