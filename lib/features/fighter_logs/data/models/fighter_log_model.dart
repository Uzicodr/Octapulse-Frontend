import '../../domain/entities/fighter_log.dart';

class FighterLogModel extends FighterLog {
  FighterLogModel({
    required super.id,
    required super.first_name,
    required super.last_name,
    super.wins,
    super.losses,
    super.draws
  });

  factory FighterLogModel.fromJson(Map<String, dynamic> json) {
    return FighterLogModel(
      id: json['_id']?.toString() ?? '',
      first_name: json['first_name']?.toString() ?? '',
      last_name: json['last_name']?.toString() ?? '',
      wins: json['wins']?.toString(),
      losses: json['losses']?.toString(),
      draws: json['draws']?.toString(),
    );
  }

  static List<FighterLog> fromJsonList(dynamic json) {
    if (json == null) return [];
    if (json is Map) {
      json = json['data'] ?? json['results'] ?? json['fighter_logs'] ?? json;
    }
    if (json is! List) return [];
    return (json)
        .map((e) => FighterLogModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
