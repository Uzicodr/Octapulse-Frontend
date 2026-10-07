import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/event.dart';
import '../../../../data/models/fight.dart';
import '../../../../data/models/fighter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fight_widgets.dart';
import '../../../core/widgets/fighter_avatar.dart';
import '../../../core/widgets/skeleton.dart';
import '../../picks/view_models/picks_view_model.dart';
import '../../shell/main_shell.dart';
import '../view_models/events_view_models.dart';
import 'home_view.dart';

class EventDetailView extends ConsumerWidget {
  const EventDetailView({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(eventDetailProvider(eventId));

    return Scaffold(
      // Back button while loading or on error; the loaded page brings its own.
      extendBodyBehindAppBar: true,
      appBar: detail.hasValue ? null : AppBar(backgroundColor: Colors.transparent),
      body: AsyncBody<EventDetail>(
        value: detail,
        skeleton: const EventDetailSkeleton(),
        onRetry: () => ref.invalidate(eventDetailProvider(eventId)),
        data: (event) => CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 330,
              backgroundColor: AppColors.background,
              title: Text(event.summary.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _Header(event: event),
              ),
            ),
            SliverToBoxAdapter(child: _InfoStrip(event: event.summary)),
            if (!event.summary.isCompleted && event.fights.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: PillButton(
                    label: 'Make Your Picks',
                    icon: Icons.track_changes_rounded,
                    filled: true,
                    onPressed: () {
                      ref.read(selectedPickEventProvider.notifier).state = event.summary.id;
                      ref.read(currentTabProvider.notifier).state = AppTab.picks;
                      context.go('/home');
                    },
                  ),
                ),
              ),
            if (event.fights.isEmpty)
              SliverToBoxAdapter(
                child: event.summary.isCompleted
                    ? const EmptyState(
                        icon: Icons.sports_mma_rounded,
                        title: 'Results not available yet',
                        message: 'This card has not been synced to the database.',
                      )
                    : const EmptyState(
                        icon: Icons.sports_mma_rounded,
                        title: 'Fight card not announced',
                        message: 'Check back closer to fight night.',
                      ),
              ),
            for (final section in event.fightsBySection.entries) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: [
                      Text(section.key, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(width: 8),
                      Text(
                        '${section.value.length} fights',
                        style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemCount: section.value.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final fight = section.value[i];
                    final red = fight.redFighter;
                    final blue = fight.blueFighter;
                    if (fight.hasResult) {
                      return FightResultCard(
                        fight: fight,
                        red: red,
                        blue: blue,
                        onFighterTap: (f) => openFighter(context, f),
                        onTap: () => context.push('/fight/${fight.id}'),
                      );
                    }
                    return _UpcomingFightCard(
                      fight: fight,
                      red: red,
                      blue: blue,
                      isMainEvent: fight == event.mainEvent,
                    );
                  },
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.event});

  final EventDetail event;

  @override
  Widget build(BuildContext context) {
    final main = event.mainEvent;
    final red = main?.redFighter;
    final blue = main?.blueFighter;

    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.4),
              radius: 1.1,
              colors: [Color(0xCC7A1019), AppColors.background],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 70,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final half = constraints.maxWidth / 2;
              return Row(
                children: [
                  FighterPortrait(
                    fighter: red,
                    height: constraints.maxHeight,
                    width: half,
                    fadeEdge: AxisDirection.right,
                  ),
                  FighterPortrait(
                    fighter: blue,
                    height: constraints.maxHeight,
                    width: half,
                    flip: true,
                    fadeEdge: AxisDirection.left,
                  ),
                ],
              );
            },
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.4, 0.85],
              colors: [Colors.transparent, AppColors.background],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusChip.forEvent(event.summary),
              const SizedBox(height: 10),
              Text(
                event.summary.name,
                style: Theme.of(context).textTheme.headlineMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (red != null && blue != null)
                Text(
                  '${red.name} vs. ${blue.name}',
                  style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({required this.event});

  final EventSummary event;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _InfoPill(icon: Icons.calendar_today_rounded, text: Dates.dayTime(event.startsAt)),
          if (event.location.isNotEmpty) _InfoPill(icon: Icons.place_outlined, text: event.location),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primaryBright),
          const SizedBox(width: 6),
          Flexible(
            child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _UpcomingFightCard extends StatelessWidget {
  const _UpcomingFightCard({
    required this.fight,
    required this.red,
    required this.blue,
    required this.isMainEvent,
  });

  final Fight fight;
  final Fighter? red;
  final Fighter? blue;
  final bool isMainEvent;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push('/fight/${fight.id}'),
      borderColor: isMainEvent ? AppColors.primary.withValues(alpha: 0.6) : null,
      child: Column(
        children: [
          Row(
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
              if (isMainEvent)
                const Text(
                  'MAIN EVENT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: AppColors.primaryBright,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          FightMatchup(
            fight: fight,
            red: red,
            blue: blue,
            onFighterTap: (f) => openFighter(context, f),
          ),
        ],
      ),
    );
  }
}
