import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/event.dart';
import '../../../../data/repositories/events_repository.dart';
import '../../../core/providers.dart';

class HomeData {
  const HomeData({required this.upcoming, required this.latest, required this.past, this.updatedAt});

  /// Upcoming events with their card loaded so the main event can be shown.
  final List<EventDetail> upcoming;

  /// Most recent completed event, for the results strip.
  final EventDetail? latest;
  final List<EventSummary> past;

  /// Newest data write on the backend, for the "Updated 2h ago" label.
  final DateTime? updatedAt;
}

final homeProvider = FutureProvider<HomeData>((ref) async {
  final events = ref.watch(eventsRepositoryProvider);
  final updatedAt = ref.watch(socialRepositoryProvider).lastDataUpdate().catchError((_) => null);

  final lists = await Future.wait([
    events.list(EventWindow.upcoming, limit: 8),
    events.list(EventWindow.past, limit: 8),
  ]);
  final upcoming = lists[0];
  final past = lists[1];

  final details = await Future.wait([
    for (final e in upcoming.take(6)) events.detail(e.id),
    if (past.isNotEmpty) events.detail(past.first.id),
  ]);

  final hasLatest = past.isNotEmpty;
  return HomeData(
    upcoming: hasLatest ? details.sublist(0, details.length - 1) : details,
    latest: hasLatest ? details.last : null,
    past: past.skip(1).toList(),
    updatedAt: await updatedAt,
  );
});

final eventListProvider = FutureProvider.family<List<EventSummary>, EventWindow>(
  (ref, when) => ref.watch(eventsRepositoryProvider).list(when, limit: 100),
);

final eventDetailProvider = FutureProvider.family<EventDetail, String>(
  (ref, id) => ref.watch(eventsRepositoryProvider).detail(id),
);
