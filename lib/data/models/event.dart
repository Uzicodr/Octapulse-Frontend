import 'fight.dart';

class EventSummary {
  const EventSummary({
    required this.id,
    required this.slug,
    required this.name,
    required this.status,
    this.startsAt,
    this.venue,
    this.city,
    this.country,
  });

  final String id;
  final String slug;
  final String name;
  final String status;
  final DateTime? startsAt;
  final String? venue;
  final String? city;
  final String? country;

  bool get isCompleted => status == 'completed';
  bool get isLive => status == 'live';

  String get location =>
      [venue, city, country].whereType<String>().where((s) => s.isNotEmpty).join(', ');

  String get shortLocation =>
      [city, country].whereType<String>().where((s) => s.isNotEmpty).join(', ');

  factory EventSummary.fromJson(Map<String, dynamic> json) {
    return EventSummary(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      status: json['status'] as String? ?? 'scheduled',
      startsAt: _parseDate(json['startsAt']),
      venue: json['venue'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
    );
  }
}

class EventDetail {
  const EventDetail({required this.summary, required this.fights});

  final EventSummary summary;
  final List<Fight> fights;

  Fight? get mainEvent => fights.isEmpty ? null : fights.first;

  /// Fights grouped by card section, keeping the backend's bout order.
  Map<String, List<Fight>> get fightsBySection {
    final sections = <String, List<Fight>>{};
    for (final fight in fights) {
      sections.putIfAbsent(fight.cardSection ?? 'Card', () => []).add(fight);
    }
    return sections;
  }

  factory EventDetail.fromJson(Map<String, dynamic> json) {
    return EventDetail(
      summary: EventSummary.fromJson(json),
      fights: (json['fights'] as List? ?? const [])
          .map((f) => Fight.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }
}

DateTime? _parseDate(Object? value) =>
    value is String ? DateTime.tryParse(value)?.toLocal() : null;
