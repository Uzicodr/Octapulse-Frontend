import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/fight_insights.dart';
import '../../../../data/models/social.dart';
import '../../../core/providers.dart';

final fightDetailProvider = FutureProvider.family<FightDetail, String>(
  (ref, id) => ref.watch(fightsRepositoryProvider).detail(id),
);

final fightStatsProvider = FutureProvider.family<List<RoundStats>, String>(
  (ref, id) => ref.watch(fightsRepositoryProvider).stats(id),
);

final consensusProvider = FutureProvider.family<Consensus, String>(
  (ref, id) => ref.watch(fightsRepositoryProvider).consensus(id),
);

final previewProvider = FutureProvider.family<FightPreview?, String>(
  (ref, id) => ref.watch(fightsRepositoryProvider).preview(id),
);

final commentsProvider =
    AsyncNotifierProvider.family<CommentsController, List<Comment>, String>(CommentsController.new);

class CommentsController extends FamilyAsyncNotifier<List<Comment>, String> {
  @override
  Future<List<Comment>> build(String fightId) async {
    final page = await ref.read(fightsRepositoryProvider).comments(fightId);
    return page.items;
  }

  Future<void> post(String body) async {
    final comment = await ref.read(fightsRepositoryProvider).postComment(arg, body.trim());
    state = AsyncData([comment, ...state.valueOrNull ?? const []]);
  }

  Future<void> delete(Comment comment) async {
    await ref.read(fightsRepositoryProvider).deleteComment(comment.id);
    state = AsyncData([...?state.valueOrNull?.where((c) => c.id != comment.id)]);
  }
}
