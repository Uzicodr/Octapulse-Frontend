import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/fighter_log.dart';

final fighterLogsSearchProvider = StateProvider<String>((ref) => '');

final _allFighterLogsProvider =
    FutureProvider.autoDispose<List<FighterLog>>((ref) async {
  final getFighterLogs = ref.watch(getFighterLogsProvider);
  return getFighterLogs(search: null);
});

final fighterLogsProvider = FutureProvider.autoDispose
    .family<List<FighterLog>, String>((ref, searchQuery) async {
  final allLogsAsyncValue = ref.watch(_allFighterLogsProvider);

  return allLogsAsyncValue.when(
    data: (allLogs) {
      if (searchQuery.isEmpty) {
        return allLogs;
      }

      final query = searchQuery.toLowerCase().trim();
      return allLogs.where((fighter) {
        final fullName =
            '${fighter.first_name} ${fighter.last_name}'.toLowerCase();
        return fullName.contains(query);
      }).toList();
    },
    loading: () => throw Exception('Loading fighters...'),
    error: (err, stack) => throw err,
  );
});
