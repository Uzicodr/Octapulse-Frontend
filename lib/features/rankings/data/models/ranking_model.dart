import '../../domain/entities/rankings.dart';

class RankingModel extends Ranking {
  RankingModel({
    required super.id,
    required super.category,
    required super.gender,
    super.champion,
    required super.fighters,
    required super.lastUpdated,
  });

  factory RankingModel.fromJson(Map<String, dynamic> json) {
    return RankingModel(
      id: json['_id'] as String,
      category: json['category'] as String,
      gender: json['gender'] as String,
      champion: json['champion'] as String?,
      fighters: List<String>.from(json['fighters'] as List),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }

  static List<Ranking> fromJsonList(dynamic json) {
    if (json == null) return [];
    if (json is Map) {
      json = json['data'] ?? json['results'] ?? json['rankings'] ?? json;
    }
    if (json is! List) return [];
    print(json);
    return json
        .map((e) => RankingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
