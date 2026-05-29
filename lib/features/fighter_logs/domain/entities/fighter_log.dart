class FighterLog {
  final String id;
  final String first_name;
  final String last_name;
  final String? wins;
  final String? losses;
  final String? draws;
  final String? height;
  final String? weight;
  final String? reach;
  final String? stance;
  final String? dob;
  final String? nickname;
  final String? profileLink;
  final String? lastUpdated;
  final String? sapm;
  final String? slpm;
  final String? strikingAccuracy;
  final String? strikingDefense;
  final String? submissionAvg;
  final String? tdAccuracy;
  final String? tdAvg;
  final String? tdDefense;
  String? record;

  FighterLog({
    required this.id,
    required this.first_name,
    required this.last_name,
    this.wins,
    this.losses,
    this.draws,
    this.height,
    this.weight,
    this.reach,
    this.stance,
    this.dob,
    this.nickname,
    this.profileLink,
    this.lastUpdated,
    this.sapm,
    this.slpm,
    this.strikingAccuracy,
    this.strikingDefense,
    this.submissionAvg,
    this.tdAccuracy,
    this.tdAvg,
    this.tdDefense,
  });

  String getrecord() {
    return "$wins - $losses - $draws";
  }
}
