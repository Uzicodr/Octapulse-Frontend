import '../models/fight_insights.dart';
import '../models/social.dart';
import '../services/api_client.dart';

class FightsRepository {
  FightsRepository(this._api);

  final ApiClient _api;

  Future<FightDetail> detail(String fightId) async =>
      FightDetail.fromJson(await _api.get<Map<String, dynamic>>('/fights/$fightId'));

  Future<List<RoundStats>> stats(String fightId) async {
    final json = await _api.get<List<dynamic>>('/fights/$fightId/stats');
    return json.map((r) => RoundStats.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<Consensus> consensus(String fightId) async =>
      Consensus.fromJson(await _api.get<Map<String, dynamic>>('/fights/$fightId/consensus'));

  /// null when no preview has been generated (the API answers 404).
  Future<FightPreview?> preview(String fightId) async {
    try {
      return FightPreview.fromJson(await _api.get<Map<String, dynamic>>('/fights/$fightId/preview'));
    } catch (e) {
      if (isStatus(e, 404)) return null;
      rethrow;
    }
  }

  Future<Page<Comment>> comments(String fightId, {int page = 1, int limit = 30}) async {
    final json = await _api.get<Map<String, dynamic>>(
      '/fights/$fightId/comments',
      query: {'page': page, 'limit': limit},
    );
    return Page.fromJson(json, Comment.fromJson);
  }

  Future<Comment> postComment(String fightId, String body) async =>
      Comment.fromJson(await _api.post<Map<String, dynamic>>('/fights/$fightId/comments', {'body': body}));

  Future<void> deleteComment(String commentId) => _api.delete('/comments/$commentId');
}
