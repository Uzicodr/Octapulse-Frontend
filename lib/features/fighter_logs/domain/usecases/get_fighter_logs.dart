import '../entities/fighter_log.dart';
import '../repositories/fighter_logs_repository.dart';

class GetFighterLogs {
  final FighterLogsRepository _repository;

  GetFighterLogs(this._repository);

  Future<List<FighterLog>> call({String? search}) {
    return _repository.getFighterLogs(search: search);
  }
}
