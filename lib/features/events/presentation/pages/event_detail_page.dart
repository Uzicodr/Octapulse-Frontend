import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fighter_avatar.dart';
import '../../domain/entities/event.dart';

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(event.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            event.name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            [event.date, event.location].whereType<String>().join(' | '),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          if (event.fights.isEmpty)
            _EmptyFights(isUpcoming: event.isUpcoming)
          else
            ...event.fights.map(
              (fight) => _FightCard(fight: fight, isUpcoming: event.isUpcoming),
            ),
        ],
      ),
    );
  }
}

class _FightCard extends StatelessWidget {
  const _FightCard({required this.fight, required this.isUpcoming});

  final Fight fight;
  final bool isUpcoming;

  @override
  Widget build(BuildContext context) {
    final showResults = !isUpcoming && (fight.winner?.isNotEmpty ?? false);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    fight.weightClass?.isNotEmpty == true
                        ? fight.weightClass!
                        : 'Fight ${fight.fightOrder}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (fight.isChampionshipFight) const _ChampionshipBadge(),
              ],
            ),
            const SizedBox(height: 14),
            _MatchupRow(
              redName: fight.fighterRed,
              blueName: fight.fighterBlue,
              winner: showResults ? fight.winner : null,
            ),
            if (showResults) ...[
              const SizedBox(height: 14),
              _ResultSummary(fight: fight),
              const SizedBox(height: 12),
              _FightStatsTable(fight: fight),
            ],
          ],
        ),
      ),
    );
  }
}

class _MatchupRow extends StatelessWidget {
  const _MatchupRow({
    required this.redName,
    required this.blueName,
    required this.winner,
  });

  final String redName;
  final String blueName;
  final String? winner;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FighterCorner(
            name: redName,
            resultBorder: _borderFor(redName),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'VS',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: _FighterCorner(
            name: blueName,
            resultBorder: _borderFor(blueName),
            alignEnd: true,
          ),
        ),
      ],
    );
  }

  Color? _borderFor(String name) {
    if (winner == null || winner!.isEmpty) return null;
    return winner == name ? const Color(0xFF29C76F) : AppColors.primary;
  }
}

class _FighterCorner extends StatelessWidget {
  const _FighterCorner({
    required this.name,
    this.resultBorder,
    this.alignEnd = false,
  });

  final String name;
  final Color? resultBorder;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final avatar = FighterAvatar(
      name: name,
      radius: 26,
      borderColor: resultBorder,
      borderWidth: 2,
    );
    final nameText = Expanded(
      child: Text(
        name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: alignEnd ? TextAlign.right : TextAlign.left,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
    );

    return Row(
      children: alignEnd
          ? [nameText, const SizedBox(width: 10), avatar]
          : [avatar, const SizedBox(width: 10), nameText],
    );
  }
}

class _ResultSummary extends StatelessWidget {
  const _ResultSummary({required this.fight});

  final Fight fight;

  @override
  Widget build(BuildContext context) {
    final methodDetails = fight.methodDetails?.trim();
    final method = [
      fight.method,
      if (methodDetails != null && methodDetails.isNotEmpty) methodDetails,
    ].whereType<String>().join(' - ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outline),
      ),
      child: Text(
        '${fight.winner} wins'
        '${method.isNotEmpty ? ' by $method' : ''}'
        '${fight.round?.isNotEmpty == true ? ' | R${fight.round}' : ''}'
        '${fight.time?.isNotEmpty == true ? ' ${fight.time}' : ''}',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _FightStatsTable extends StatelessWidget {
  const _FightStatsTable({required this.fight});

  final Fight fight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatRow(label: 'KD', red: fight.kd.red, blue: fight.kd.blue),
        _StatRow(label: 'STR', red: fight.str.red, blue: fight.str.blue),
        _StatRow(label: 'TD', red: fight.td.red, blue: fight.td.blue),
        _StatRow(label: 'SUB', red: fight.sub.red, blue: fight.sub.blue),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.red, required this.blue});

  final String label;
  final String? red;
  final String? blue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              red ?? '--',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              blue ?? '--',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChampionshipBadge extends StatelessWidget {
  const _ChampionshipBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFB88920),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFD86B)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            'Title Fight',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFights extends StatelessWidget {
  const _EmptyFights({required this.isUpcoming});

  final bool isUpcoming;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outline),
      ),
      child: Text(
        isUpcoming ? 'Fight card not available yet' : 'No fight results found',
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
      ),
    );
  }
}
