import '../entities/event.dart';

abstract class EventsRepository {
  Future<List<Event>> getPastEvents();
  Future<List<Event>> getUpcomingEvents();
}
