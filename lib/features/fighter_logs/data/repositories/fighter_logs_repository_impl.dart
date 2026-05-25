import '../../domain/entities/fighter_log.dart';
import '../../domain/repositories/fighter_logs_repository.dart';
import '../datasources/fighter_logs_remote_datasource.dart';

class FighterLogsRepositoryImpl implements FighterLogsRepository {
  final FighterLogsRemoteDataSource _remoteDataSource;

  FighterLogsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<FighterLog>> getFighterLogs({String? search}) {
    return _remoteDataSource.getFighterLogs(search: search);
  }
}
