import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/event.dart';
import '../../../../data/models/pick.dart';
import '../../../../data/models/social.dart';
import '../../../../data/repositories/events_repository.dart';
import '../../../../data/repositories/picks_repository.dart';
import '../../../core/providers.dart';

/// Events the user can still pick on, soonest first.
final pickableEventsProvider = FutureProvider<List<EventSummary>>(
  (ref) => ref.watch(eventsRepositoryProvider).list(EventWindow.upcoming, limit: 20),
);

/// Event chosen in the Picks tab; null means "first pickable event".
final selectedPickEventProvider = StateProvider<String?>((ref) => null);

/// The signed-in user's picks keyed by fight id.
final myPicksProvider = AsyncNotifierProvider<MyPicksController, Map<String, Pick>>(MyPicksController.new);

class MyPicksController extends AsyncNotifier<Map<String, Pick>> {
  @override
  Future<Map<String, Pick>> build() async {
    final session = await ref.watch(authControllerProvider.future);
    if (session == null) return {};
    final picks = await ref.read(picksRepositoryProvider).mine();
    return {for (final p in picks) p.fightId: p};
  }

  /// Optimistically records the pick, rolling back if the backend refuses.
  Future<void> pick({
    required String fightId,
    required String fighterId,
    PickMethod? method,
    int? round,
    int confidence = 1,
  }) async {
    final previous = state.valueOrNull ?? {};
    state = AsyncData({
      ...previous,
      fightId: Pick(
        id: previous[fightId]?.id ?? 'pending',
        fightId: fightId,
        pickedFighterId: fighterId,
        method: method,
        round: round,
        confidence: confidence,
      ),
    });
    try {
      final saved = await ref.read(picksRepositoryProvider).submit(
            fightId: fightId,
            fighterId: fighterId,
            method: method,
            round: round,
            confidence: confidence,
          );
      state = AsyncData({...state.valueOrNull ?? previous, fightId: saved});
      ref.invalidate(myStatsProvider);
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }

  Future<void> remove(String fightId) async {
    final previous = state.valueOrNull ?? {};
    state = AsyncData({...previous}..remove(fightId));
    try {
      await ref.read(picksRepositoryProvider).remove(fightId);
      ref.invalidate(myStatsProvider);
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }
}

/// The AI's picks for an event, keyed by fight id. Visible before lock.
final aiPicksProvider = FutureProvider.family<Map<String, Pick>, String>(
  (ref, eventId) => ref.watch(picksRepositoryProvider).aiPicks(eventId).catchError((_) => <String, Pick>{}),
);

final aiProfileProvider = FutureProvider<({UserSummary user, UserStats stats})>(
  (ref) => ref.watch(picksRepositoryProvider).aiProfile(),
);

/// Leaderboard rows for a tab; `following` needs a session.
final leaderboardProvider = FutureProvider.family<List<LeaderboardEntry>, LeaderboardScope>(
  (ref, scope) => ref.watch(picksRepositoryProvider).leaderboard(scope: scope),
);
