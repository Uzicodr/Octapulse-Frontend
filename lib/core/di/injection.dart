import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/constants.dart';
import '../../features/events/data/datasources/events_remote_datasource.dart';
import '../../features/events/data/repositories/events_repository_impl.dart';
import '../../features/events/domain/repositories/events_repository.dart';
import '../../features/events/domain/usecases/get_past_events.dart';
import '../../features/events/domain/usecases/get_upcoming_events.dart';
import '../../features/fighter_logs/data/datasources/fighter_logs_remote_datasource.dart';
import '../../features/fighter_logs/data/repositories/fighter_logs_repository_impl.dart';
import '../../features/fighter_logs/domain/repositories/fighter_logs_repository.dart';
import '../../features/fighter_logs/domain/usecases/get_fighter_logs.dart';
import '../../features/rankings/data/datasources/rankings_remote_datasource.dart';
import '../../features/rankings/data/repositories/rankings_repository_impl.dart';
import '../../features/rankings/domain/repositories/rankings_repository.dart';
import '../../features/rankings/domain/usecases/get_rankings.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
});

// Fighter Logs
final fighterLogsRemoteDataSourceProvider =
    Provider<FighterLogsRemoteDataSource>((ref) {
  return FighterLogsRemoteDataSourceImpl(ref.watch(dioProvider));
});

final fighterLogsRepositoryProvider = Provider<FighterLogsRepository>((ref) {
  return FighterLogsRepositoryImpl(
      ref.watch(fighterLogsRemoteDataSourceProvider));
});

final getFighterLogsProvider = Provider<GetFighterLogs>((ref) {
  return GetFighterLogs(ref.watch(fighterLogsRepositoryProvider));
});

// Events
final eventsRemoteDataSourceProvider = Provider<EventsRemoteDataSource>((ref) {
  return EventsRemoteDataSourceImpl(ref.watch(dioProvider));
});

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  return EventsRepositoryImpl(ref.watch(eventsRemoteDataSourceProvider));
});

final getPastEventsProvider = Provider<GetPastEvents>((ref) {
  return GetPastEvents(ref.watch(eventsRepositoryProvider));
});

final getUpcomingEventsProvider = Provider<GetUpcomingEvents>((ref) {
  return GetUpcomingEvents(ref.watch(eventsRepositoryProvider));
});

// Rankings
final rankingsRemoteDataSourceProvider =
    Provider<RankingsRemoteDataSource>((ref) {
  return RankingsRemoteDataSourceImpl(ref.watch(dioProvider));
});

final rankingsRepositoryProvider = Provider<RankingsRepository>((ref) {
  return RankingsRepositoryImpl(ref.watch(rankingsRemoteDataSourceProvider));
});

final getRankingsProvider = Provider<GetRankings>((ref) {
  return GetRankings(ref.watch(rankingsRepositoryProvider));
});
