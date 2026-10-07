import '../models/fight.dart';
import '../models/fighter.dart';
import '../services/api_client.dart';

class FightersRepository {
  FightersRepository(this._api);

  final ApiClient _api;

  Future<List<Fighter>> search(String query, {int limit = 50}) async {
    final json = await _api.get<Map<String, dynamic>>('/fighters', query: {
      if (query.trim().isNotEmpty) 'q': query.trim(),
      'limit': limit,
    });
    return (json['data'] as List)
        .map((f) => Fighter.fromJson(f as Map<String, dynamic>))
        .toList();
  }

  Future<Fighter> bySlug(String slug) async =>
      Fighter.fromJson(await _api.get<Map<String, dynamic>>('/fighters/$slug'));

  /// Every fight for the fighter, upcoming and past, newest first.
  Future<List<Fight>> fights(String slug) async {
    final json = await _api.get<List<dynamic>>('/fighters/$slug/fights');
    return json.map((f) => Fight.fromJson(f as Map<String, dynamic>)).toList();
  }

  /// Returns whether the user now follows the fighter.
  Future<bool> setFollowing(String slug, bool follow) async {
    if (follow) {
      final json = await _api.post<Map<String, dynamic>>('/fighters/$slug/follow');
      return json['following'] as bool? ?? true;
    }
    await _api.delete('/fighters/$slug/follow');
    return false;
  }

  Future<List<Fighter>> followed() async {
    final json = await _api.get<List<dynamic>>('/me/fighter-follows');
    return json.map((f) => Fighter.fromJson(f as Map<String, dynamic>)).toList();
  }
}
