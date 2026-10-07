class Fighter {
  const Fighter({
    required this.id,
    required this.slug,
    required this.name,
    this.nickname,
    this.wins,
    this.losses,
    this.draws,
    this.weightClass,
    this.height,
    this.reach,
    this.stance,
    this.country,
  });

  final String id;
  final String slug;
  final String name;
  final String? nickname;
  final int? wins;
  final int? losses;
  final int? draws;
  final String? weightClass;
  final String? height;
  final String? reach;
  final String? stance;
  final String? country;

  /// "21-5-1", or null when the backend has no record yet.
  String? get record {
    if (wins == null && losses == null) return null;
    return '${wins ?? 0}-${losses ?? 0}-${draws ?? 0}';
  }

  String get lastName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.length > 1 ? parts.sublist(1).join(' ') : name;
  }

  factory Fighter.fromJson(Map<String, dynamic> json) {
    return Fighter(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      nickname: json['nickname'] as String?,
      wins: json['recordWins'] as int?,
      losses: json['recordLosses'] as int?,
      draws: json['recordDraws'] as int?,
      weightClass: json['weightClass'] as String?,
      height: json['heightInches'] as String?,
      reach: json['reachInches'] as String?,
      stance: json['stance'] as String?,
      country: json['country'] as String?,
    );
  }
}
