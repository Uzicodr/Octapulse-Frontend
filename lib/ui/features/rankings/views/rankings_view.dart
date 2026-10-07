import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/fighter.dart';
import '../../../../data/models/ranking.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/country_flag.dart';
import '../../../core/widgets/fighter_avatar.dart';
import '../../../core/widgets/skeleton.dart';
import '../../events/views/home_view.dart';

final rankingsProvider = FutureProvider<Map<String, List<RankingEntry>>>(
  (ref) => ref.watch(rankingsRepositoryProvider).byDivision(),
);

final selectedDivisionProvider = StateProvider<String?>((ref) => null);

class RankingsView extends ConsumerWidget {
  const RankingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankings = ref.watch(rankingsProvider);

    return SafeArea(
      bottom: false,
      child: AsyncBody<Map<String, List<RankingEntry>>>(
        value: rankings,
        skeleton: const RankingsSkeleton(),
        onRetry: () => ref.invalidate(rankingsProvider),
        data: (divisions) {
          if (divisions.isEmpty) {
            return const EmptyState(icon: Icons.leaderboard_rounded, title: 'No rankings yet');
          }
          final names = divisions.keys.toList();
          final selected = ref.watch(selectedDivisionProvider) ?? names.first;
          final entries = divisions[selected] ?? const <RankingEntry>[];
          final top = entries.isEmpty ? null : entries.first;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                  child: Text('Rankings', style: Theme.of(context).textTheme.headlineMedium),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: names.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => _DivisionChip(
                      label: names[i],
                      selected: names[i] == selected,
                      onTap: () => ref.read(selectedDivisionProvider.notifier).state = names[i],
                    ),
                  ),
                ),
              ),
              if (top != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                    child: _TopCard(entry: top, fighter: top.fighter),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                sliver: SliverList.separated(
                  itemCount: entries.length > 1 ? entries.length - 1 : 0,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final entry = entries[i + 1];
                    return _RankRow(entry: entry, fighter: entry.fighter);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DivisionChip extends StatelessWidget {
  const _DivisionChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      shape: StadiumBorder(side: BorderSide(color: selected ? AppColors.primary : AppColors.outline)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopCard extends StatelessWidget {
  const _TopCard({required this.entry, required this.fighter});

  final RankingEntry entry;
  final Fighter? fighter;

  @override
  Widget build(BuildContext context) {
    final accent = entry.champion ? AppColors.gold : AppColors.primaryBright;
    return SizedBox(
      height: 190,
      child: AppCard(
        padding: EdgeInsets.zero,
        radius: 26,
        onTap: fighter == null ? null : () => openFighter(context, fighter!),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.8, 0),
                    radius: 1.2,
                    colors: [accent.withValues(alpha: 0.28), AppColors.surface],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: FighterPortrait(fighter: fighter, height: 180, flip: true),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        entry.champion ? Icons.emoji_events_rounded : Icons.military_tech_rounded,
                        color: accent,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        entry.champion ? 'CHAMPION' : 'NO. ${entry.rank ?? 1}',
                        style: TextStyle(color: accent, fontWeight: FontWeight.w800, letterSpacing: 1.4, fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 190,
                    child: Text(
                      fighter?.name ?? 'Unknown',
                      maxLines: 2,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.1),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      CountryFlag(fighter?.country, size: 15),
                      const SizedBox(width: 6),
                      Text(
                        fighter?.record ?? fighter?.country ?? '',
                        style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.entry, required this.fighter});

  final RankingEntry entry;
  final Fighter? fighter;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      radius: 18,
      onTap: fighter == null ? null : () => openFighter(context, fighter!),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              entry.champion ? 'C' : '${entry.rank ?? '-'}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: entry.champion ? AppColors.gold : AppColors.textMuted,
              ),
            ),
          ),
          FighterAvatar(fighter: fighter, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fighter?.name ?? 'Unknown',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                Text(
                  fighter?.record ?? fighter?.country ?? '',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                ),
              ],
            ),
          ),
          CountryFlag(fighter?.country, size: 20),
        ],
      ),
    );
  }
}
