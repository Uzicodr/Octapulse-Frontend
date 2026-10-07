import 'fighter.dart';

class RankingEntry {
  const RankingEntry({
    required this.division,
    required this.fighterId,
    required this.champion,
    this.rank,
    this.fighter,
  });

  final String division;
  final String fighterId;
  final bool champion;
  final int? rank;
  final Fighter? fighter;

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    return RankingEntry(
      division: json['division'] as String,
      fighterId: json['fighterId'] as String,
      champion: json['champion'] as bool? ?? false,
      rank: json['rank'] as int?,
      fighter: json['fighter'] is Map<String, dynamic>
          ? Fighter.fromJson(json['fighter'] as Map<String, dynamic>)
          : null,
    );
  }
}
