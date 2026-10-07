enum PickMethod {
  koTko('KO_TKO', 'KO/TKO'),
  submission('SUBMISSION', 'Submission'),
  decision('DECISION', 'Decision');

  const PickMethod(this.api, this.label);

  final String api;
  final String label;

  static PickMethod? fromApi(String? value) =>
      PickMethod.values.where((m) => m.api == value).firstOrNull;
}

enum PickResult { pending, won, lost, voided }

class Pick {
  const Pick({
    required this.id,
    required this.fightId,
    required this.pickedFighterId,
    this.method,
    this.round,
    this.confidence = 1,
    this.createdAt,
    this.lockedAt,
    this.settledAt,
    this.correct,
    this.points,
  });

  final String id;
  final String fightId;
  final String pickedFighterId;
  final PickMethod? method;
  final int? round;
  final int confidence;
  final DateTime? createdAt;
  final DateTime? lockedAt;
  final DateTime? settledAt;
  final bool? correct;
  final int? points;

  PickResult get result {
    if (settledAt == null) return PickResult.pending;
    return switch (correct) {
      true => PickResult.won,
      false => PickResult.lost,
      null => PickResult.voided,
    };
  }

  /// "KO/TKO · R2 · 3x" style summary of the optional extras.
  String? get extrasLabel {
    final parts = [
      if (method != null) method!.label,
      if (round != null) 'R$round',
      if (confidence > 1) '${confidence}x',
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  factory Pick.fromJson(Map<String, dynamic> json) {
    return Pick(
      id: json['id'] as String,
      fightId: json['fightId'] as String,
      pickedFighterId: json['pickedFighterId'] as String,
      method: PickMethod.fromApi(json['method'] as String?),
      round: json['round'] as int?,
      confidence: json['confidence'] as int? ?? 1,
      createdAt: parseDate(json['createdAt']),
      lockedAt: parseDate(json['lockedAt']),
      settledAt: parseDate(json['settledAt']),
      correct: json['correct'] as bool?,
      points: json['points'] as int?,
    );
  }
}

DateTime? parseDate(Object? value) =>
    value is String ? DateTime.tryParse(value)?.toLocal() : null;
