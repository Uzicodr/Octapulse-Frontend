import 'fighter.dart';

class Fight {
  const Fight({
    required this.id,
    required this.status,
    required this.titleFight,
    required this.locked,
    this.redFighterId,
    this.blueFighterId,
    this.redFighter,
    this.blueFighter,
    this.weightClass,
    this.cardSection,
    this.boutOrder,
    this.winnerFighterId,
    this.method,
    this.resultRound,
    this.resultTime,
    this.startsAt,
  });

  final String id;
  final String status;
  final bool titleFight;

  /// Picks are closed: the fight started, finished or was cancelled.
  final bool locked;
  final String? redFighterId;
  final String? blueFighterId;

  /// Embedded by the backend; null when the fighter isn't loaded yet.
  final Fighter? redFighter;
  final Fighter? blueFighter;
  final String? weightClass;
  final String? cardSection;
  final int? boutOrder;
  final String? winnerFighterId;
  final String? method;
  final int? resultRound;
  final String? resultTime;
  final DateTime? startsAt;

  bool get hasResult => winnerFighterId != null || status == 'completed';

  bool get isDraw => status == 'completed' && winnerFighterId == null;

  /// Rounds a pick can name: five for title fights, three otherwise.
  int get maxRounds => titleFight ? 5 : 3;

  Fighter? fighterById(String? id) {
    if (id == null) return null;
    if (id == redFighterId) return redFighter;
    if (id == blueFighterId) return blueFighter;
    return null;
  }

  String get matchupLabel =>
      '${redFighter?.lastName ?? 'TBA'} vs. ${blueFighter?.lastName ?? 'TBA'}';

  /// Short label for the finish: "Decision", "KO/TKO", "Submission"...
  String get methodLabel {
    final m = method?.toUpperCase() ?? '';
    if (m.isEmpty) return hasResult ? 'Result' : (locked ? 'Live' : 'Upcoming');
    if (m.contains('DEC')) {
      if (m.startsWith('U')) return 'Unanimous Decision';
      if (m.startsWith('S')) return 'Split Decision';
      if (m.startsWith('M')) return 'Majority Decision';
      return 'Decision';
    }
    if (m.contains('SUB')) return 'Submission';
    if (m.contains('KO')) return 'KO/TKO';
    if (m.contains('DQ')) return 'Disqualification';
    if (m.contains('NC')) return 'No Contest';
    return method!;
  }

  factory Fight.fromJson(Map<String, dynamic> json) {
    return Fight(
      id: json['id'] as String,
      status: json['status'] as String? ?? 'scheduled',
      titleFight: json['titleFight'] as bool? ?? false,
      locked: json['locked'] as bool? ?? false,
      redFighterId: json['redFighterId'] as String?,
      blueFighterId: json['blueFighterId'] as String?,
      redFighter: _fighter(json['redFighter']),
      blueFighter: _fighter(json['blueFighter']),
      weightClass: json['weightClass'] as String?,
      cardSection: json['cardSection'] as String?,
      boutOrder: json['boutOrder'] as int?,
      winnerFighterId: json['winnerFighterId'] as String?,
      method: json['method'] as String?,
      resultRound: json['resultRound'] as int?,
      resultTime: json['resultTime'] as String?,
      startsAt: json['startsAt'] is String
          ? DateTime.tryParse(json['startsAt'] as String)?.toLocal()
          : null,
    );
  }

  static Fighter? _fighter(Object? json) =>
      json is Map<String, dynamic> ? Fighter.fromJson(json) : null;
}
