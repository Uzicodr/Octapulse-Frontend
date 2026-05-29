import '../../domain/entities/event.dart';

class EventModel extends Event {
  const EventModel({
    required super.id,
    required super.name,
    required super.date,
    super.location,
    super.eventLink,
    super.isUpcoming,
    super.fights,
  });

  factory EventModel.fromJson(
    Map<String, dynamic> json, {
    bool isUpcoming = false,
  }) {
    return EventModel(
      id: _stringValue(json['_id']),
      name: json['event_name']?.toString() ?? '',
      date: json['event_date']?.toString() ?? '',
      location: json['event_location']?.toString(),
      eventLink: json['event_link']?.toString(),
      isUpcoming: isUpcoming,
      fights: _fightsFromJson(json['fights']),
    );
  }

  static List<Event> fromJsonList(dynamic json, {bool isUpcoming = false}) {
    if (json == null) return [];
    if (json is Map) {
      json = json['data'] ?? json['results'] ?? json['events'] ?? json;
    }
    if (json is! List) return [];
    return json
        .map(
          (e) => EventModel.fromJson(
            e as Map<String, dynamic>,
            isUpcoming: isUpcoming,
          ),
        )
        .toList();
  }

  static List<Fight> _fightsFromJson(dynamic json) {
    if (json is! List) return const [];
    return json
        .whereType<Map<String, dynamic>>()
        .map(
          (fight) => Fight(
            fightOrder:
                int.tryParse(fight['fight_order']?.toString() ?? '') ?? 0,
            fightDetailLink: fight['fight_detail_link']?.toString(),
            fighterRed:
                fight['fighter_red']?.toString() ??
                _fighterAt(fight['fighters'], 0),
            fighterBlue:
                fight['fighter_blue']?.toString() ??
                _fighterAt(fight['fighters'], 1),
            winner: fight['winner']?.toString(),
            kd: _metricFromJson(fight['kd']),
            str: _metricFromJson(fight['str']),
            td: _metricFromJson(fight['td']),
            sub: _metricFromJson(fight['sub']),
            fighterStats: _fighterStatsFromJson(fight['fighter_stats']),
            weightClass: fight['weight_class']?.toString(),
            method: fight['method']?.toString(),
            methodDetails: fight['method_details']?.toString(),
            round: fight['round']?.toString(),
            time: fight['time']?.toString(),
            isChampionshipFight:
                fight['is_championship_fight'] == true ||
                fight['is_championship_fight']?.toString().toLowerCase() ==
                    'true',
          ),
        )
        .toList();
  }

  static FightMetric _metricFromJson(dynamic json) {
    if (json is! Map) return const FightMetric();
    return FightMetric(
      red: json['red']?.toString(),
      blue: json['blue']?.toString(),
    );
  }

  static List<FighterFightStat> _fighterStatsFromJson(dynamic json) {
    if (json is! List) return const [];
    return json
        .whereType<Map<String, dynamic>>()
        .map(
          (stat) => FighterFightStat(
            fighterName: stat['fighter_name']?.toString() ?? '',
            corner: stat['corner']?.toString() ?? '',
            kd: stat['kd']?.toString(),
            str: stat['str']?.toString(),
            td: stat['td']?.toString(),
            sub: stat['sub']?.toString(),
          ),
        )
        .toList();
  }

  static String _fighterAt(dynamic fighters, int index) {
    if (fighters is List && fighters.length > index) {
      return fighters[index]?.toString() ?? '';
    }
    return '';
  }

  static String _stringValue(dynamic value) {
    if (value is Map && value[r'$oid'] != null) {
      return value[r'$oid'].toString();
    }
    return value?.toString() ?? '';
  }
}
