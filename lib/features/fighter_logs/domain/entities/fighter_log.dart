class FighterLog {
  final String id;
  final String first_name;
  final String last_name;
  final String? wins;
  final String? losses;
  final String? draws;
  String? record;

  FighterLog({
    required this.id,
    required this.first_name,
    required this.last_name,
    this.wins,
    this.losses,
    this.draws,
  });

  String getrecord() {
    return "${wins} - ${losses} - ${draws}";
  }
}
