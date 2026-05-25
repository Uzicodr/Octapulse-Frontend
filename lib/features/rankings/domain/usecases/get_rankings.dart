import '../entities/rankings.dart';
import '../repositories/rankings_repository.dart';

class GetRankings {
  final RankingsRepository repository;

  GetRankings(this.repository);

  Future<List<Ranking>> call({String? division}) {
    return repository.getRankings(division: division);
  }
}
