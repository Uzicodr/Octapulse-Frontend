import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/social.dart';
import '../../../../data/repositories/picks_repository.dart';
import '../../../../data/services/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/skeleton.dart';
import '../../picks/view_models/picks_view_model.dart';
import '../../picks/views/pick_tile.dart';
import '../../shell/main_shell.dart';
import '../view_models/community_view_models.dart';
import 'leaderboard_list.dart';

enum _Section { leaderboard, feed, leagues }

final _sectionProvider = StateProvider<_Section>((ref) => _Section.leaderboard);

class CommunityView extends ConsumerWidget {
  const CommunityView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(_sectionProvider);
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Text('Community', style: Theme.of(context).textTheme.headlineMedium),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SegmentedTabs<_Section>(
              values: _Section.values,
              selected: section,
              label: (s) => switch (s) {
                _Section.leaderboard => 'Leaderboard',
                _Section.feed => 'Feed',
                _Section.leagues => 'Leagues',
              },
              onChanged: (s) => ref.read(_sectionProvider.notifier).state = s,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: switch (section) {
              _Section.leaderboard => const _LeaderboardSection(),
              _Section.feed => const _FeedSection(),
              _Section.leagues => const _LeaguesSection(),
            },
          ),
        ],
      ),
    );
  }
}

final _scopeProvider = StateProvider<LeaderboardScope>((ref) => LeaderboardScope.all);

class _LeaderboardSection extends ConsumerWidget {
  const _LeaderboardSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(isSignedInProvider);
    var scope = ref.watch(_scopeProvider);
    if (!signedIn && scope == LeaderboardScope.following) scope = LeaderboardScope.all;
    final board = ref.watch(leaderboardProvider(scope));
    final ai = ref.watch(aiProfileProvider).valueOrNull;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () {
        ref.invalidate(aiProfileProvider);
        return ref.refresh(leaderboardProvider(scope).future);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          Wrap(
            spacing: 8,
            children: [
              for (final s in LeaderboardScope.values)
                if (s != LeaderboardScope.following || signedIn)
                  ChoiceChip(
                    label: Text(switch (s) {
                      LeaderboardScope.all => 'All time',
                      LeaderboardScope.month => 'This month',
                      LeaderboardScope.following => 'Friends',
                    }),
                    selected: s == scope,
                    onSelected: (_) => ref.read(_scopeProvider.notifier).state = s,
                    showCheckmark: false,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    side: BorderSide(color: s == scope ? AppColors.primary : AppColors.outline),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: s == scope ? Colors.white : AppColors.textSecondary,
                    ),
                    shape: const StadiumBorder(),
                  ),
            ],
          ),
          if (ai != null) ...[
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(14),
              borderColor: AppColors.blueCorner.withValues(alpha: 0.4),
              color: AppColors.blueCorner.withValues(alpha: 0.06),
              onTap: () => context.push('/user/${ai.user.id}'),
              child: Row(
                children: [
                  const UserAvatar(name: 'AI', ai: true, size: 44),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Beat the AI', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                        Text('Octapulse AI picks every fight before lock.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${ai.stats.points} pts', style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text(ai.stats.accuracyLabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          board.when(
            skipLoadingOnRefresh: true,
            loading: () => const Shimmer(child: LeaderboardSkeleton()),
            error: (e, _) => ErrorState(message: describeError(e), onRetry: () => ref.invalidate(leaderboardProvider(scope))),
            data: (rows) => rows.isEmpty
                ? EmptyState(
                    icon: Icons.leaderboard_rounded,
                    title: scope == LeaderboardScope.following ? 'No friends ranked yet' : 'Leaderboard is empty',
                    message: scope == LeaderboardScope.following
                        ? 'Follow people from comments or the leaderboard to compare picks.'
                        : 'Ranks appear once the first picks are settled.',
                  )
                : LeaderboardList(rows: rows),
          ),
        ],
      ),
    );
  }
}

class _FeedSection extends ConsumerWidget {
  const _FeedSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(isSignedInProvider)) return const _SignInPrompt(text: 'Sign in to see picks from people you follow.');
    final feed = ref.watch(feedProvider);
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.refresh(feedProvider.future),
      child: AsyncBody<List<FeedItem>>(
        value: feed,
        skeleton: const SkeletonList(item: SkeletonFightCard(withDetails: false), count: 4),
        onRetry: () => ref.invalidate(feedProvider),
        data: (items) => items.isEmpty
            ? ListView(
                children: const [
                  EmptyState(
                    icon: Icons.dynamic_feed_rounded,
                    title: 'Your feed is quiet',
                    message: 'Follow people to see their picks once fights lock.',
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, i) => _FeedCard(item: items[i]),
              ),
      ),
    );
  }
}

class _FeedCard extends StatelessWidget {
  const _FeedCard({required this.item});

  final FeedItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => context.push('/user/${item.user.id}'),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                UserAvatar(name: item.user.name, url: item.user.avatarUrl, ai: item.user.ai, size: 30),
                const SizedBox(width: 10),
                Flexible(child: Text(item.user.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                if (item.user.ai) ...[const SizedBox(width: 6), const AiBadge()],
                Expanded(
                  child: Text(
                    '  · ${item.event.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        PickTile(pick: item.pick, fight: item.fight),
      ],
    );
  }
}

class _LeaguesSection extends ConsumerWidget {
  const _LeaguesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(isSignedInProvider)) return const _SignInPrompt(text: 'Sign in to create or join private leagues.');
    final leagues = ref.watch(myLeaguesProvider);
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.refresh(myLeaguesProvider.future),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          Row(
            children: [
              Expanded(
                child: PillButton(
                  label: 'Create',
                  icon: Icons.add_rounded,
                  filled: true,
                  height: 46,
                  onPressed: () => _createLeague(context, ref),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PillButton(
                  label: 'Join',
                  icon: Icons.vpn_key_outlined,
                  height: 46,
                  onPressed: () => joinLeagueDialog(context, ref),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          leagues.when(
            skipLoadingOnRefresh: true,
            loading: () => const Shimmer(child: Column(children: [SkeletonTile(), SizedBox(height: 10), SkeletonTile()])),
            error: (e, _) => ErrorState(message: describeError(e), onRetry: () => ref.invalidate(myLeaguesProvider)),
            data: (list) => list.isEmpty
                ? const EmptyState(
                    icon: Icons.groups_rounded,
                    title: 'No leagues yet',
                    message: 'Create one and share the invite code with friends.',
                  )
                : Column(
                    children: [
                      for (final l in list)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AppCard(
                            radius: 18,
                            padding: const EdgeInsets.all(14),
                            onTap: () => context.push('/league/${l.id}'),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    l.name.isEmpty ? '?' : l.name[0].toUpperCase(),
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryBright),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(l.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                      Text(
                                        '${l.memberCount} ${l.memberCount == 1 ? 'member' : 'members'}',
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _createLeague(BuildContext context, WidgetRef ref) async {
    final name = await textPrompt(context, title: 'New league', hint: 'League name', action: 'Create', maxLength: 60);
    if (name == null || name.trim().isEmpty || !context.mounted) return;
    try {
      final league = await ref.read(socialRepositoryProvider).createLeague(name.trim());
      ref.invalidate(myLeaguesProvider);
      if (context.mounted) context.push('/league/${league.id}');
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(e))));
    }
  }
}

/// Asks for an invite code and joins; also used by `/join/<code>` links.
Future<void> joinLeagueDialog(BuildContext context, WidgetRef ref, {String? code}) async {
  final input = code ??
      await textPrompt(context, title: 'Join a league', hint: '8-character invite code', action: 'Join', maxLength: 8, caps: true);
  if (input == null || input.trim().isEmpty || !context.mounted) return;
  try {
    final league = await ref.read(socialRepositoryProvider).joinLeague(input);
    ref.invalidate(myLeaguesProvider);
    if (context.mounted) context.push('/league/${league.id}');
  } catch (e) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(e))));
  }
}

class _SignInPrompt extends ConsumerWidget {
  const _SignInPrompt({required this.text});

  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline_rounded, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          SizedBox(
            width: 180,
            child: PillButton(
              label: 'Sign In',
              filled: true,
              height: 46,
              onPressed: () => ref.read(currentTabProvider.notifier).state = AppTab.profile,
            ),
          ),
        ],
      ),
    );
  }
}
