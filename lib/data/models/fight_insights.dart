import 'event.dart';
import 'fight.dart';
import 'pick.dart';

class FightDetail {
  const FightDetail({required this.fight, required this.event, required this.commentCount});

  final Fight fight;
  final EventSummary event;
  final int commentCount;

  factory FightDetail.fromJson(Map<String, dynamic> json) => FightDetail(
        fight: Fight.fromJson(json['fight'] as Map<String, dynamic>),
        event: EventSummary.fromJson(json['event'] as Map<String, dynamic>),
        commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      );
}

class ConsensusSide {
  const ConsensusSide({required this.fighterId, required this.picks, required this.percent});

  final String? fighterId;
  final int picks;

  /// 0 to 100.
  final double percent;

  factory ConsensusSide.fromJson(Map<String, dynamic>? json) => ConsensusSide(
        fighterId: json?['fighterId'] as String?,
        picks: (json?['picks'] as num?)?.toInt() ?? 0,
        percent: (json?['percent'] as num?)?.toDouble() ?? 0,
      );
}

class Consensus {
  const Consensus({
    required this.totalPicks,
    required this.red,
    required this.blue,
    required this.methods,
  });

  final int totalPicks;
  final ConsensusSide red;
  final ConsensusSide blue;

  /// Counts keyed by method: koTko, submission, decision, unspecified.
  final Map<String, int> methods;

  factory Consensus.fromJson(Map<String, dynamic> json) => Consensus(
        totalPicks: (json['totalPicks'] as num?)?.toInt() ?? 0,
        red: ConsensusSide.fromJson(json['red'] as Map<String, dynamic>?),
        blue: ConsensusSide.fromJson(json['blue'] as Map<String, dynamic>?),
        methods: {
          for (final e in (json['methods'] as Map<String, dynamic>? ?? const {}).entries)
            e.key: (e.value as num?)?.toInt() ?? 0,
        },
      );
}

class RoundStats {
  const RoundStats({
    required this.round,
    required this.fighterId,
    this.strikesLanded,
    this.strikesAttempted,
    this.sigStrikesLanded,
    this.sigStrikesAttempted,
    this.takedownsLanded,
    this.takedownsAttempted,
    this.controlTimeSeconds,
  });

  final int round;
  final String fighterId;
  final int? strikesLanded;
  final int? strikesAttempted;
  final int? sigStrikesLanded;
  final int? sigStrikesAttempted;
  final int? takedownsLanded;
  final int? takedownsAttempted;
  final int? controlTimeSeconds;

  factory RoundStats.fromJson(Map<String, dynamic> json) => RoundStats(
        round: (json['round'] as num).toInt(),
        fighterId: json['fighterId'] as String,
        strikesLanded: json['strikesLanded'] as int?,
        strikesAttempted: json['strikesAttempted'] as int?,
        sigStrikesLanded: json['sigStrikesLanded'] as int?,
        sigStrikesAttempted: json['sigStrikesAttempted'] as int?,
        takedownsLanded: json['takedownsLanded'] as int?,
        takedownsAttempted: json['takedownsAttempted'] as int?,
        controlTimeSeconds: json['controlTimeSeconds'] as int?,
      );
}

class FightPreview {
  const FightPreview({required this.content, this.model, this.generatedAt});

  final String content;
  final String? model;
  final DateTime? generatedAt;

  factory FightPreview.fromJson(Map<String, dynamic> json) => FightPreview(
        content: json['content'] as String? ?? '',
        model: json['model'] as String?,
        generatedAt: parseDate(json['generatedAt']),
      );
}
