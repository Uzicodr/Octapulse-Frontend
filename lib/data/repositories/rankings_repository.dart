import '../models/ranking.dart';
import '../services/api_client.dart';

class RankingsRepository {
  RankingsRepository(this._api);

  final ApiClient _api;

  /// Men's divisions light to heavy, then women's light to heavy.
  static const divisionOrder = [
    'Flyweight',
    'Bantamweight',
    'Featherweight',
    'Lightweight',
    'Welterweight',
    'Middleweight',
    'Light Heavyweight',
    'Heavyweight',
    "Women's Strawweight",
    "Women's Flyweight",
    "Women's Bantamweight",
    "Women's Featherweight",
  ];

  /// Each division with its champion first, then contenders by rank.
  Future<Map<String, List<RankingEntry>>> byDivision() async {
    final json = await _api.get<List<dynamic>>('/rankings');
    final divisions = <String, List<RankingEntry>>{};
    for (final row in json) {
      final entry = RankingEntry.fromJson(row as Map<String, dynamic>);
      divisions.putIfAbsent(entry.division, () => []).add(entry);
    }
    for (final list in divisions.values) {
      // The champion has no rank and the backend sorts nulls last.
      list.sort((a, b) {
        if (a.champion != b.champion) return a.champion ? -1 : 1;
        return (a.rank ?? 999).compareTo(b.rank ?? 999);
      });
    }
    final names = divisions.keys.toList()..sort((a, b) => _orderOf(a).compareTo(_orderOf(b)));
    return {for (final name in names) name: divisions[name]!};
  }

  static int _orderOf(String division) {
    final i = divisionOrder.indexOf(division);
    return i == -1 ? divisionOrder.length : i;
  }
}
