import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/pick.dart';
import '../../../../data/models/social.dart';
import '../../../core/providers.dart';

final feedProvider = FutureProvider<List<FeedItem>>((ref) async {
  final session = await ref.watch(authControllerProvider.future);
  if (session == null) return const [];
  return (await ref.read(socialRepositoryProvider).feed()).items;
});

final myLeaguesProvider = FutureProvider<List<League>>((ref) async {
  final session = await ref.watch(authControllerProvider.future);
  if (session == null) return const [];
  return ref.read(socialRepositoryProvider).myLeagues();
});

final leagueProvider = FutureProvider.family<LeagueDetail, String>(
  (ref, id) => ref.watch(socialRepositoryProvider).league(id),
);

final leagueLeaderboardProvider = FutureProvider.family<List<LeaderboardEntry>, String>(
  (ref, id) => ref.watch(socialRepositoryProvider).leagueLeaderboard(id),
);

/// Public profile with a local follow toggle.
final userProfileProvider =
    AsyncNotifierProvider.family<UserProfileController, UserProfile, String>(UserProfileController.new);

class UserProfileController extends FamilyAsyncNotifier<UserProfile, String> {
  @override
  Future<UserProfile> build(String userId) {
    ref.watch(authControllerProvider);
    return ref.read(socialRepositoryProvider).profile(userId);
  }

  Future<void> toggleFollow() async {
    final current = state.valueOrNull;
    if (current == null) return;
    final follow = !(current.followedByMe ?? false);
    state = AsyncData(current.copyWith(
      followedByMe: follow,
      followers: current.followers + (follow ? 1 : -1),
    ));
    try {
      await ref.read(socialRepositoryProvider).setFollowing(arg, follow);
      ref.invalidate(feedProvider);
      // My own "Following" count and both users' follow lists are cached separately.
      final myId = ref.read(authControllerProvider).valueOrNull?.userId;
      if (myId != null) {
        ref.invalidate(userProfileProvider(myId));
        ref.invalidate(followListProvider((myId, FollowList.following)));
      }
      ref.invalidate(followListProvider((arg, FollowList.followers)));
    } catch (_) {
      state = AsyncData(current);
      rethrow;
    }
  }
}

final userPicksProvider = FutureProvider.family<List<Pick>, String>(
  (ref, userId) => ref.watch(socialRepositoryProvider).userPicks(userId),
);

enum FollowList { followers, following }

final followListProvider = FutureProvider.family<List<UserSummary>, (String, FollowList)>((ref, key) async {
  final repo = ref.watch(socialRepositoryProvider);
  final page = key.$2 == FollowList.followers ? await repo.followers(key.$1) : await repo.following(key.$1);
  return page.items;
});
