import '../../domain/entities/rankings.dart';
import '../../domain/repositories/rankings_repository.dart';
import '../datasources/rankings_remote_datasource.dart';

class RankingsRepositoryImpl implements RankingsRepository {
  final RankingsRemoteDataSource _remoteDataSource;

  RankingsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Ranking>> getRankings({String? division}) async {
    return await _remoteDataSource.getRankings(division: division);
  }
}
