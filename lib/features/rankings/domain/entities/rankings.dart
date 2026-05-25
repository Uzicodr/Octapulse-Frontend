class Ranking {
  final String id;
  final String category;
  final String gender;
  final String? champion;
  final List<String> fighters;
  final DateTime lastUpdated;

  Ranking({
    required this.id,
    required this.category,
    required this.gender,
    this.champion,
    required this.fighters,
    required this.lastUpdated,
  });

  factory Ranking.fromJson(Map<String, dynamic> json) {
    return Ranking(
      id: json['_id'] as String,
      category: json['category'] as String,
      gender: json['gender'] as String,
      champion: json['champion'],
      fighters: List<String>.from(json['fighters']),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'category': category,
      'gender': gender,
      'champion': champion,
      'fighters': fighters
    };
  }
}
