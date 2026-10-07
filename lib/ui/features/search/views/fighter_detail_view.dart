import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../../data/models/fight.dart';
import '../../../../data/models/fighter.dart';
import '../../../../data/services/api_client.dart';
import '../../../../data/models/ranking.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/country_flag.dart';
import '../../../core/widgets/fighter_avatar.dart';
import '../../../core/widgets/skeleton.dart';
import '../../news/view_models/news_view_models.dart';
import '../../news/views/news_tile.dart';
import '../../rankings/views/rankings_view.dart';

final fighterDetailProvider = FutureProvider.family<Fighter, String>(
  (ref, slug) => ref.watch(fightersRepositoryProvider).bySlug(slug),
);

final fighterFightsProvider = FutureProvider.family<List<Fight>, String>(
  (ref, slug) => ref.watch(fightersRepositoryProvider).fights(slug),
);

/// Ids of fighters the user follows; empty when signed out.
final followedFightersProvider = AsyncNotifierProvider<FollowedFighters, Set<String>>(FollowedFighters.new);

class FollowedFighters extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final session = await ref.watch(authControllerProvider.future);
    if (session == null) return {};
    final fighters = await ref.read(fightersRepositoryProvider).followed();
    return fighters.map((f) => f.id).toSet();
  }

  Future<void> toggle(Fighter fighter) async {
    final current = state.valueOrNull ?? {};
    final follow = !current.contains(fighter.id);
    state = AsyncData(follow ? {...current, fighter.id} : ({...current}..remove(fighter.id)));
    try {
      await ref.read(fightersRepositoryProvider).setFollowing(fighter.slug, follow);
    } catch (_) {
      state = AsyncData(current);
      rethrow;
    }
  }
}

class FighterDetailView extends ConsumerWidget {
  const FighterDetailView({super.key, required this.slug, this.initial});

  final String slug;

  /// Shown immediately while the fresh profile loads.
  final Fighter? initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(fighterDetailProvider(slug));
    final fighter = detail.valueOrNull ?? initial;

    if (fighter == null) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: AsyncBody<Fighter>(
          value: detail,
          skeleton: const FighterDetailSkeleton(),
          onRetry: () => ref.invalidate(fighterDetailProvider(slug)),
          data: (_) => const SizedBox(),
        ),
      );
    }

    final rankings = ref.watch(rankingsProvider).valueOrNull;
    final ranking = rankings?.values
        .expand((list) => list)
        .where((r) => r.fighterId == fighter.id)
        .firstOrNull;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 380,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _Hero(fighter: fighter),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (fighter.nickname != null && fighter.nickname!.isNotEmpty)
                    Text(
                      '"${fighter.nickname}"',
                      style: const TextStyle(
                        color: AppColors.primaryBright,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  Text(fighter.name, style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (fighter.country != null)
                        _Chip(
                          leading: CountryFlag(fighter.country, size: 14),
                          label: fighter.country!,
                        ),
                      if (fighter.weightClass != null) _Chip(label: fighter.weightClass!),
                      if (ranking != null) _RankChip(ranking: ranking),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.9,
                    padding: EdgeInsets.zero,
                    children: [
                      _StatTile(icon: Icons.sports_mma_rounded, label: 'Record', value: fighter.record),
                      _StatTile(icon: Icons.height_rounded, label: 'Height', value: _inches(fighter.height)),
                      _StatTile(icon: Icons.open_in_full_rounded, label: 'Reach', value: _inches(fighter.reach)),
                      _StatTile(icon: Icons.directions_walk_rounded, label: 'Stance', value: fighter.stance),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _FollowButton(fighter: fighter),
                  _FighterNews(slug: fighter.slug),
                  const SizedBox(height: 28),
                  Text('Fight history', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _History(fighter: fighter),
                  if (detail.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String? _inches(String? value) {
    if (value == null || value.isEmpty) return null;
    final n = double.tryParse(value);
    if (n == null) return value;
    final feet = n ~/ 12;
    final inches = (n % 12).round();
    return '$feet\'$inches" · ${n.round()} in';
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.fighter});

  final Fighter fighter;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, 0.1),
              radius: 0.9,
              colors: [Color(0xCC7A1019), AppColors.background],
            ),
          ),
        ),
        Positioned(
          top: 70,
          left: 0,
          right: 0,
          child: Text(
            fighter.lastName.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: TextStyle(
              fontSize: 96,
              fontWeight: FontWeight.w800,
              letterSpacing: -3,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: FighterPortrait(fighter: fighter, height: 320),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.6, 1],
              colors: [Colors.transparent, AppColors.background],
            ),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.leading, this.color = AppColors.textPrimary});

  final String label;
  final Widget? leading;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 6)],
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: color)),
        ],
      ),
    );
  }
}

class _RankChip extends StatelessWidget {
  const _RankChip({required this.ranking});

  final RankingEntry ranking;

  @override
  Widget build(BuildContext context) {
    final label = ranking.champion
        ? '${ranking.division} Champion'
        : '#${ranking.rank} ${ranking.division}';
    return _Chip(
      leading: Icon(
        ranking.champion ? Icons.emoji_events_rounded : Icons.military_tech_rounded,
        size: 15,
        color: AppColors.gold,
      ),
      label: label,
      color: AppColors.gold,
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 20,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primaryBright),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
          Text(
            value ?? '—',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _FollowButton extends ConsumerWidget {
  const _FollowButton({required this.fighter});

  final Fighter fighter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(isSignedInProvider)) return const SizedBox.shrink();
    final following = ref.watch(followedFightersProvider).valueOrNull?.contains(fighter.id) ?? false;
    return PillButton(
      label: following ? 'Following' : 'Follow fighter',
      icon: following ? Icons.notifications_active_rounded : Icons.add_rounded,
      filled: !following,
      onPressed: () async {
        try {
          await ref.read(followedFightersProvider.notifier).toggle(fighter);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(e))));
          }
        }
      },
    );
  }
}

/// Recent stories naming this fighter. Hidden unless there are some.
class _FighterNews extends ConsumerWidget {
  const _FighterNews({required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(fighterNewsProvider(slug)).valueOrNull ?? const [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Text('Latest news', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        for (final item in items) ...[
          NewsTile(item: item, showSummary: false),
          if (item != items.last) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _History extends ConsumerWidget {
  const _History({required this.fighter});

  final Fighter fighter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fights = ref.watch(fighterFightsProvider(fighter.slug));
    return fights.when(
      loading: () => const Shimmer(
        child: Column(children: [SkeletonTile(), SizedBox(height: 8), SkeletonTile(), SizedBox(height: 8), SkeletonTile()]),
      ),
      error: (e, _) => Text(describeError(e), style: const TextStyle(color: AppColors.textSecondary)),
      data: (list) {
        if (list.isEmpty) {
          return const Text('No fights on record.', style: TextStyle(color: AppColors.textMuted));
        }
        return Column(
          children: [
            for (final f in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _HistoryRow(fight: f, fighterId: fighter.id),
              ),
          ],
        );
      },
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.fight, required this.fighterId});

  final Fight fight;
  final String fighterId;

  @override
  Widget build(BuildContext context) {
    final isRed = fight.redFighterId == fighterId;
    final opponent = isRed ? fight.blueFighter : fight.redFighter;
    final (tag, color) = !fight.hasResult
        ? (fight.locked ? 'LIVE' : 'NEXT', AppColors.primaryBright)
        : fight.winnerFighterId == null
            ? ('D/NC', AppColors.textMuted)
            : fight.winnerFighterId == fighterId
                ? ('W', AppColors.win)
                : ('L', AppColors.loss);
    final detail = fight.hasResult
        ? [fight.methodLabel, if (fight.resultRound != null) 'R${fight.resultRound}', if (fight.resultTime != null) fight.resultTime!].join(' · ')
        : (fight.weightClass ?? 'Upcoming');

    return AppCard(
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      onTap: () => context.push('/fight/${fight.id}'),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(tag, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          FighterAvatar(fighter: opponent, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('vs ${opponent?.name ?? 'TBA'}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
              ],
            ),
          ),
          if (fight.titleFight) const Icon(Icons.emoji_events_rounded, size: 18, color: AppColors.gold),
        ],
      ),
    );
  }
}
