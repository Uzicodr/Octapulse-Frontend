import '../../domain/entities/event.dart';

class EventModel extends Event {
  const EventModel({
    required super.id,
    required super.name,
    required super.date,
    super.location,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['_id']?.toString() ?? '',
      name: json['event_name']?.toString() ?? '',
      date: json['event_date']?.toString() ?? '',
      location: json['event_location']?.toString(),
    );
  }

  static List<Event> fromJsonList(dynamic json) {
    if (json == null) return [];
    if (json is Map) {
      json = json['data'] ?? json['results'] ?? json['events'] ?? json;
    }
    if (json is! List) return [];
    return (json as List)
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
