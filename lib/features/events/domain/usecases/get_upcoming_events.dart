import '../entities/event.dart';
import '../repositories/events_repository.dart';

class GetUpcomingEvents {
  final EventsRepository _repository;

  GetUpcomingEvents(this._repository);

  Future<List<Event>> call() => _repository.getUpcomingEvents();
}
