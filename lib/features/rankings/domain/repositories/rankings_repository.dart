import '../entities/rankings.dart';

abstract class RankingsRepository {
  Future<List<Ranking>> getRankings({String? division});
}
