import '../models/event.dart';
import '../services/api_client.dart';

enum EventWindow { upcoming, past }

class EventsRepository {
  EventsRepository(this._api);

  final ApiClient _api;
  final _details = <String, EventDetail>{};

  Future<List<EventSummary>> list(EventWindow when, {int page = 1, int limit = 20}) async {
    final json = await _api.get<Map<String, dynamic>>('/events', query: {
      'when': when.name,
      'page': page,
      'limit': limit,
    });
    return (json['data'] as List)
        .map((e) => EventSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<EventDetail> detail(String id, {bool refresh = false}) async {
    final cached = _details[id];
    if (cached != null && !refresh) return cached;
    final json = await _api.get<Map<String, dynamic>>('/events/$id');
    return _details[id] = EventDetail.fromJson(json);
  }
}
