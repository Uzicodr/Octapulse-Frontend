import '../../domain/entities/event.dart';
import '../../domain/repositories/events_repository.dart';
import '../datasources/events_remote_datasource.dart';

class EventsRepositoryImpl implements EventsRepository {
  final EventsRemoteDataSource _remoteDataSource;

  EventsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Event>> getPastEvents() => _remoteDataSource.getPastEvents();

  @override
  Future<List<Event>> getUpcomingEvents() =>
      _remoteDataSource.getUpcomingEvents();
}
