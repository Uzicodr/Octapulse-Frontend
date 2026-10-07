import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/pick.dart';
import '../../../../data/models/social.dart';
import '../../../../data/services/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/skeleton.dart';
import '../../picks/views/pick_tile.dart';
import '../view_models/community_view_models.dart';
import 'profile_widgets.dart';

class UserProfileView extends ConsumerWidget {
  const UserProfileView({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider(userId));
    final myId = ref.watch(authControllerProvider).valueOrNull?.userId;
    final isMe = myId == userId;

    return Scaffold(
      appBar: AppBar(title: Text(profile.valueOrNull?.user.name ?? 'Profile')),
      body: AsyncBody<UserProfile>(
        value: profile,
        skeleton: const ProfileSkeleton(),
        onRetry: () => ref.invalidate(userProfileProvider(userId)),
        data: (p) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () {
            ref.invalidate(userPicksProvider(userId));
            return ref.refresh(userProfileProvider(userId).future);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              ProfileHeader(
                user: p.user,
                bio: p.bio,
                followers: p.followers,
                following: p.following,
                isMe: isMe,
                onFollowers: () => context.push('/user/$userId/followers'),
                onFollowing: () => context.push('/user/$userId/following'),
              ),
              if (myId != null && !isMe && !p.user.ai) ...[
                const SizedBox(height: 16),
                PillButton(
                  label: (p.followedByMe ?? false) ? 'Following' : 'Follow',
                  icon: (p.followedByMe ?? false) ? Icons.check_rounded : Icons.person_add_alt_rounded,
                  filled: !(p.followedByMe ?? false),
                  height: 46,
                  onPressed: () async {
                    try {
                      await ref.read(userProfileProvider(userId).notifier).toggleFollow();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(e))));
                      }
                    }
                  },
                ),
              ],
              const SizedBox(height: 18),
              StatsCard(stats: p.stats),
              const SizedBox(height: 12),
              DivisionBreakdown(divisions: p.stats.byDivision),
              const SizedBox(height: 24),
              Text('Picks', style: Theme.of(context).textTheme.titleLarge),
              const Padding(
                padding: EdgeInsets.only(top: 2, bottom: 12),
                child: Text('Only locked fights are shown.', style: TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
              ),
              ref.watch(userPicksProvider(userId)).when(
                    loading: () => const Shimmer(child: Column(children: [SkeletonTile(), SizedBox(height: 10), SkeletonTile()])),
                    error: (e, _) => Text(describeError(e), style: const TextStyle(color: AppColors.textSecondary)),
                    data: (picks) => picks.isEmpty
                        ? const EmptyState(icon: Icons.track_changes_rounded, title: 'No locked picks yet')
                        : Column(
                            children: [
                              for (final pick in _newestFirst(picks))
                                Padding(padding: const EdgeInsets.only(bottom: 10), child: PickTile(pick: pick)),
                            ],
                          ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  static List<Pick> _newestFirst(List<Pick> picks) => [...picks]
    ..sort((a, b) => (b.lockedAt ?? b.createdAt ?? DateTime(0)).compareTo(a.lockedAt ?? a.createdAt ?? DateTime(0)));
}

class FollowListView extends ConsumerWidget {
  const FollowListView({super.key, required this.userId, required this.list});

  final String userId;
  final FollowList list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(followListProvider((userId, list)));
    return Scaffold(
      appBar: AppBar(title: Text(list == FollowList.followers ? 'Followers' : 'Following')),
      body: AsyncBody<List<UserSummary>>(
        value: users,
        skeleton: const SkeletonList(item: SkeletonTile(carded: false), count: 10, spacing: 1),
        onRetry: () => ref.invalidate(followListProvider((userId, list))),
        data: (items) => items.isEmpty
            ? EmptyState(
                icon: Icons.people_outline_rounded,
                title: list == FollowList.followers ? 'No followers yet' : 'Not following anyone',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(indent: 72),
                itemBuilder: (context, i) {
                  final u = items[i];
                  return ListTile(
                    onTap: () => context.push('/user/${u.id}'),
                    leading: UserAvatar(name: u.name, url: u.avatarUrl, ai: u.ai, size: 42),
                    title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: (u.displayName?.isNotEmpty ?? false)
                        ? Text('@${u.username}', style: const TextStyle(color: AppColors.textSecondary))
                        : null,
                    trailing: u.ai ? const AiBadge() : const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                  );
                },
              ),
      ),
    );
  }
}
