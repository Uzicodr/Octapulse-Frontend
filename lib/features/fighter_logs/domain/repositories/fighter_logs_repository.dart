import '../entities/fighter_log.dart';

abstract class FighterLogsRepository {
  Future<List<FighterLog>> getFighterLogs({String? search});
}
