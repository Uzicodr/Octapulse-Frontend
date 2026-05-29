/// Domain entity representing an MMA/combat sports event.
class Event {
  final String id;
  final String name;
  final String date;
  final String? location;
  final String? imageUrl;
  final String? eventLink;
  final bool isUpcoming;
  final List<Fight> fights;

  const Event({
    required this.id,
    required this.name,
    required this.date,
    this.location,
    this.imageUrl,
    this.eventLink,
    this.isUpcoming = false,
    this.fights = const [],
  });
}

class Fight {
  final int fightOrder;
  final String? fightDetailLink;
  final String fighterRed;
  final String fighterBlue;
  final String? winner;
  final FightMetric kd;
  final FightMetric str;
  final FightMetric td;
  final FightMetric sub;
  final List<FighterFightStat> fighterStats;
  final String? weightClass;
  final String? method;
  final String? methodDetails;
  final String? round;
  final String? time;
  final bool isChampionshipFight;

  const Fight({
    required this.fightOrder,
    this.fightDetailLink,
    required this.fighterRed,
    required this.fighterBlue,
    this.winner,
    this.kd = const FightMetric(),
    this.str = const FightMetric(),
    this.td = const FightMetric(),
    this.sub = const FightMetric(),
    this.fighterStats = const [],
    this.weightClass,
    this.method,
    this.methodDetails,
    this.round,
    this.time,
    this.isChampionshipFight = false,
  });
}

class FightMetric {
  final String? red;
  final String? blue;

  const FightMetric({this.red, this.blue});
}

class FighterFightStat {
  final String fighterName;
  final String corner;
  final String? kd;
  final String? str;
  final String? td;
  final String? sub;

  const FighterFightStat({
    required this.fighterName,
    required this.corner,
    this.kd,
    this.str,
    this.td,
    this.sub,
  });
}
