import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/event.dart';

final pastEventsProvider = FutureProvider.autoDispose<List<Event>>((ref) async {
  final getPastEvents = ref.watch(getPastEventsProvider);
  return getPastEvents();
});

final upcomingEventsProvider = FutureProvider.autoDispose<List<Event>>((ref) async {
  final getUpcomingEvents = ref.watch(getUpcomingEventsProvider);
  return getUpcomingEvents();
});
