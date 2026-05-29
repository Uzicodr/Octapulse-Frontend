import '../../domain/entities/fighter_log.dart';

class FighterLogModel extends FighterLog {
  FighterLogModel({
    required super.id,
    required super.first_name,
    required super.last_name,
    super.wins,
    super.losses,
    super.draws,
    super.height,
    super.weight,
    super.reach,
    super.stance,
    super.dob,
    super.nickname,
    super.profileLink,
    super.lastUpdated,
    super.sapm,
    super.slpm,
    super.strikingAccuracy,
    super.strikingDefense,
    super.submissionAvg,
    super.tdAccuracy,
    super.tdAvg,
    super.tdDefense,
  });

  factory FighterLogModel.fromJson(Map<String, dynamic> json) {
    return FighterLogModel(
      id: _stringValue(json['_id']),
      first_name: json['first_name']?.toString() ?? '',
      last_name: json['last_name']?.toString() ?? '',
      wins: json['wins']?.toString(),
      losses: json['losses']?.toString(),
      draws: json['draws']?.toString(),
      height: json['height']?.toString(),
      weight: json['weight']?.toString(),
      reach: json['reach']?.toString(),
      stance: json['stance']?.toString(),
      dob: json['dob']?.toString(),
      nickname: json['nickname']?.toString(),
      profileLink: json['profile_link']?.toString(),
      lastUpdated: json['last_updated']?.toString(),
      sapm: json['sapm']?.toString(),
      slpm: json['slpm']?.toString(),
      strikingAccuracy: json['striking_accuracy']?.toString(),
      strikingDefense: json['striking_defense']?.toString(),
      submissionAvg: json['submission_avg']?.toString(),
      tdAccuracy: json['td_accuracy']?.toString(),
      tdAvg: json['td_avg']?.toString(),
      tdDefense: json['td_defense']?.toString(),
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

  static String _stringValue(dynamic value) {
    if (value is Map && value[r'$oid'] != null) {
      return value[r'$oid'].toString();
    }
    return value?.toString() ?? '';
  }
}
