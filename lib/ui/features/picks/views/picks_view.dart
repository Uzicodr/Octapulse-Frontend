import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/event.dart';
import '../../../../data/models/fight.dart';
import '../../../../data/models/fighter.dart';
import '../../../../data/models/pick.dart';
import '../../../../data/services/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/country_flag.dart';
import '../../../core/widgets/fighter_avatar.dart';
import '../../../core/widgets/skeleton.dart';
import '../../events/view_models/events_view_models.dart';
import '../../shell/main_shell.dart';
import '../view_models/picks_view_model.dart';
import 'pick_sheet.dart';

class PicksView extends ConsumerWidget {
  const PicksView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(pickableEventsProvider);

    return SafeArea(
      bottom: false,
      child: AsyncBody<List<EventSummary>>(
        value: events,
        skeleton: const PicksSkeleton(),
        onRetry: () => ref.invalidate(pickableEventsProvider),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.track_changes_rounded,
              title: 'No upcoming events',
              message: 'Picks open as soon as the next card is announced.',
            );
          }
          final selectedId = ref.watch(selectedPickEventProvider);
          final selected = list.firstWhere(
            (e) => e.id == selectedId,
            orElse: () => list.firstWhere(
              (e) => e.startsAt == null || e.startsAt!.isAfter(DateTime.now()),
              orElse: () => list.first,
            ),
          );
          return _PicksBody(events: list, selected: selected);
        },
      ),
    );
  }
}

class _PicksBody extends ConsumerWidget {
  const _PicksBody({required this.events, required this.selected});

  final List<EventSummary> events;
  final EventSummary selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(eventDetailProvider(selected.id));
    final session = ref.watch(authControllerProvider).valueOrNull;
    final picks = ref.watch(myPicksProvider).valueOrNull ?? const <String, Pick>{};
    final aiPicks = ref.watch(aiPicksProvider(selected.id)).valueOrNull ?? const <String, Pick>{};

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () {
        ref.invalidate(myPicksProvider);
        ref.invalidate(aiPicksProvider(selected.id));
        return ref.refresh(eventDetailProvider(selected.id).future);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
              child: Text('Picks', style: Theme.of(context).textTheme.headlineMedium),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Text(
                'Call every winner before the cage door closes.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: events.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final e = events[i];
                  return _EventChip(
                    event: e,
                    selected: e.id == selected.id,
                    onTap: () => ref.read(selectedPickEventProvider.notifier).state = e.id,
                  );
                },
              ),
            ),
          ),
          if (session == null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _SignInBanner(
                  onTap: () => ref.read(currentTabProvider.notifier).state = AppTab.profile,
                ),
              ),
            ),
          ...detail.when(
            skipLoadingOnRefresh: true,
            loading: () => [
              const SliverToBoxAdapter(
                child: Padding(padding: EdgeInsets.only(top: 28), child: PickCardsSkeleton()),
              ),
            ],
            error: (e, _) => [
              SliverFillRemaining(
                hasScrollBody: false,
                child: ErrorState(
                  message: describeError(e),
                  onRetry: () => ref.invalidate(eventDetailProvider(selected.id)),
                ),
              ),
            ],
            data: (event) => _fightSlivers(context, ref, event, picks, aiPicks, canPick: session != null),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  List<Widget> _fightSlivers(
    BuildContext context,
    WidgetRef ref,
    EventDetail event,
    Map<String, Pick> picks,
    Map<String, Pick> aiPicks, {
    required bool canPick,
  }) {
    if (event.fights.isEmpty) {
      return const [
        SliverToBoxAdapter(
          child: EmptyState(icon: Icons.sports_mma_rounded, title: 'Fight card not announced'),
        ),
      ];
    }
    final made = event.fights.where((f) => picks.containsKey(f.id)).length;
    final total = event.fights.length;

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      Dates.dayTime(event.summary.startsAt),
                      style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(text: '$made', style: const TextStyle(fontWeight: FontWeight.w800)),
                      TextSpan(text: ' / $total picked', style: const TextStyle(color: AppColors.textSecondary)),
                    ]),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : made / total,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceHigh,
                ),
              ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList.separated(
          itemCount: event.fights.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final fight = event.fights[i];
            return _PickCard(
              fight: fight,
              red: fight.redFighter,
              blue: fight.blueFighter,
              pick: picks[fight.id],
              aiPickFighterId: aiPicks[fight.id]?.pickedFighterId,
              locked: fight.locked,
              onPick: canPick ? (id) => showPickSheet(context, fight, preselectFighterId: id) : null,
              onOpen: () => context.push('/fight/${fight.id}'),
            );
          },
        ),
      ),
    ];
  }

}

class _EventChip extends StatelessWidget {
  const _EventChip({required this.event, required this.selected, required this.onTap});

  final EventSummary event;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = event.name.replaceFirst('UFC Fight Night: ', '').replaceFirst("Dana White's Contender Series", 'DWCS');
    return Material(
      color: selected ? AppColors.textPrimary : AppColors.surface,
      shape: StadiumBorder(side: BorderSide(color: selected ? AppColors.textPrimary : AppColors.outline)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Text(
              '$label · ${Dates.relative(event.startsAt)}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.background : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignInBanner extends StatelessWidget {
  const _SignInBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderColor: AppColors.primary.withValues(alpha: 0.5),
      color: AppColors.primaryDeep.withValues(alpha: 0.25),
      onTap: onTap,
      child: const Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: AppColors.primaryBright),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sign in to lock in your picks and climb the leaderboard.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _PickCard extends StatelessWidget {
  const _PickCard({
    required this.fight,
    required this.red,
    required this.blue,
    required this.pick,
    required this.aiPickFighterId,
    required this.locked,
    required this.onPick,
    required this.onOpen,
  });

  final Fight fight;
  final Fighter? red;
  final Fighter? blue;
  final Pick? pick;
  final String? aiPickFighterId;
  final bool locked;
  final void Function(String fighterId)? onPick;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final p = pick;
    final extras = p?.extrasLabel;
    return AppCard(
      onTap: onOpen,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                if (fight.titleFight) ...[
                  const Icon(Icons.emoji_events_rounded, size: 16, color: AppColors.gold),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    fight.weightClass ?? 'Catchweight',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: fight.titleFight ? AppColors.gold : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (p != null && p.result == PickResult.won)
                  _Tag('WON +${p.points ?? 0}', AppColors.win)
                else if (p != null && p.result == PickResult.lost)
                  const _Tag('LOST', AppColors.loss)
                else if (p != null && p.result == PickResult.voided)
                  const _Tag('VOID', AppColors.textMuted)
                else if (locked)
                  _Tag(fight.hasResult ? 'FINAL' : 'LIVE', AppColors.textMuted, icon: Icons.lock_rounded),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _side(red, fight.redFighterId)),
              const SizedBox(width: 10),
              Expanded(child: _side(blue, fight.blueFighterId)),
            ],
          ),
          if (extras != null || (p != null && !locked))
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
              child: Row(
                children: [
                  if (extras != null)
                    Expanded(
                      child: Text(
                        extras,
                        style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    )
                  else
                    const Spacer(),
                  if (p != null && !locked && onPick != null)
                    GestureDetector(
                      onTap: () => onPick!(p.pickedFighterId),
                      child: const Text(
                        'Edit pick',
                        style: TextStyle(color: AppColors.primaryBright, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _side(Fighter? fighter, String? id) {
    final picked = id != null && pick?.pickedFighterId == id;
    final won = fight.winnerFighterId != null && fight.winnerFighterId == id;
    final enabled = !locked && onPick != null && id != null;

    return _PickSide(
      fighter: fighter,
      picked: picked,
      won: won,
      aiPicked: id != null && aiPickFighterId == id,
      onTap: enabled ? () => onPick!(id) : null,
      locked: locked || onPick == null,
    );
  }
}

class _PickSide extends StatelessWidget {
  const _PickSide({
    required this.fighter,
    required this.picked,
    required this.won,
    required this.aiPicked,
    required this.onTap,
    required this.locked,
  });

  final Fighter? fighter;
  final bool picked;
  final bool won;
  final bool aiPicked;
  final VoidCallback? onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: picked ? AppColors.primary.withValues(alpha: 0.14) : AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: picked ? AppColors.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    FighterAvatar(
                      fighter: fighter,
                      size: 64,
                      ringColor: won ? AppColors.win : (picked ? AppColors.primary : null),
                    ),
                    if (picked)
                      const Positioned(
                        right: -4,
                        bottom: -2,
                        child: CircleAvatar(
                          radius: 11,
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.check_rounded, size: 15, color: Colors.white),
                        ),
                      ),
                    if (aiPicked)
                      const Positioned(left: -6, top: -4, child: AiBadge()),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  fighter?.name ?? 'TBA',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CountryFlag(fighter?.country, size: 12),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        fighter?.record ?? fighter?.country ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, this.color, {this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 13, color: color), const SizedBox(width: 3)],
        Text(
          label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
        ),
      ],
    );
  }
}
