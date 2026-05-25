import '../entities/event.dart';
import '../repositories/events_repository.dart';

class GetPastEvents {
  final EventsRepository _repository;

  GetPastEvents(this._repository);

  Future<List<Event>> call() => _repository.getPastEvents();
}
