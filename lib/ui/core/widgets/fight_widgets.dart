import 'package:flutter/material.dart';

import '../../../data/models/event.dart';
import '../../../data/models/fight.dart';
import '../../../data/models/fighter.dart';
import '../theme/app_colors.dart';
import 'common.dart';
import 'country_flag.dart';
import 'fighter_avatar.dart';

/// Poster-style card for an event: both main-event fighters facing off.
class EventHeroCard extends StatelessWidget {
  const EventHeroCard({
    super.key,
    required this.event,
    required this.red,
    required this.blue,
    required this.onTap,
    this.height = 340,
  });

  final EventSummary event;
  final Fighter? red;
  final Fighter? blue;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final headline = red != null && blue != null ? '${red!.lastName} vs. ${blue!.lastName}' : null;
    final watermark = (red?.lastName ?? event.name).toUpperCase();

    return SizedBox(
      height: height,
      child: AppCard(
        padding: EdgeInsets.zero,
        radius: 26,
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.7, -0.9),
                  radius: 1.3,
                  colors: [Color(0xAA7A1019), AppColors.surface],
                ),
              ),
            ),
            Positioned(
              top: 34,
              left: 0,
              right: 0,
              child: Text(
                watermark,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontSize: 84,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  letterSpacing: -2,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 44,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final half = constraints.maxWidth / 2;
                  return Row(
                    children: [
                      FighterPortrait(
                        fighter: red,
                        height: height * 0.6,
                        width: half,
                        fadeEdge: AxisDirection.right,
                      ),
                      FighterPortrait(
                        fighter: blue,
                        height: height * 0.6,
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
                  stops: [0.25, 0.62, 1],
                  colors: [Colors.transparent, Color(0xD91E2127), AppColors.surface],
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  _DateTag(event.startsAt),
                  const Spacer(),
                  StatusChip.forEvent(event),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.15),
                  ),
                  if (headline != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      headline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, size: 15, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.shortLocation.isEmpty ? 'Location TBA' : event.shortLocation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  PillButton(label: 'View Event', onPressed: onTap, height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTag extends StatelessWidget {
  const _DateTag(this.date);

  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        Dates.relative(date).toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4),
      ),
    );
  }
}

/// Result card with corner flags, both fighters and the finish details.
class FightResultCard extends StatelessWidget {
  const FightResultCard({
    super.key,
    required this.fight,
    required this.red,
    required this.blue,
    this.onFighterTap,
    this.onTap,
  });

  final Fight fight;
  final Fighter? red;
  final Fighter? blue;
  final void Function(Fighter fighter)? onFighterTap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 40,
            child: Row(
              children: [
                _FlagCorner(country: red?.country, alignLeft: true),
                Expanded(
                  child: Text(
                    fight.methodLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                ),
                _FlagCorner(country: blue?.country, alignLeft: false),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            child: FightMatchup(fight: fight, red: red, blue: blue, onFighterTap: onFighterTap),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
            child: Row(
              children: [
                _Detail(label: 'Round', value: fight.resultRound?.toString() ?? '—'),
                _Detail(label: 'Time', value: fight.resultTime ?? '—'),
                _Detail(
                  label: fight.titleFight ? 'Title fight' : 'Division',
                  value: (fight.weightClass ?? '—').replaceAll(' Title', ''),
                  flex: 2,
                  highlight: fight.titleFight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FlagCorner extends StatelessWidget {
  const _FlagCorner({required this.country, required this.alignLeft});

  final String? country;
  final bool alignLeft;

  @override
  Widget build(BuildContext context) {
    final radius = alignLeft
        ? const BorderRadius.only(bottomRight: Radius.circular(14))
        : const BorderRadius.only(bottomLeft: Radius.circular(14));
    return Container(
      width: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: AppColors.surfaceHigh, borderRadius: radius),
      child: CountryFlag(country, size: 24),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value, this.flex = 1, this.highlight = false});

  final String label;
  final String value;
  final int flex;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: highlight ? AppColors.gold : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// Red corner on the left, blue on the right, winner ringed in green.
class FightMatchup extends StatelessWidget {
  const FightMatchup({
    super.key,
    required this.fight,
    required this.red,
    required this.blue,
    this.onFighterTap,
    this.avatarSize = 48,
  });

  final Fight fight;
  final Fighter? red;
  final Fighter? blue;
  final void Function(Fighter fighter)? onFighterTap;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _side(red, fight.redFighterId, alignLeft: true)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            'vs',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w800,
              color: AppColors.textMuted.withValues(alpha: 0.9),
            ),
          ),
        ),
        Expanded(child: _side(blue, fight.blueFighterId, alignLeft: false)),
      ],
    );
  }

  Widget _side(Fighter? fighter, String? id, {required bool alignLeft}) {
    final won = fight.winnerFighterId != null && fight.winnerFighterId == id;
    final lost = fight.winnerFighterId != null && !won;

    final avatar = FighterAvatar(
      fighter: fighter,
      size: avatarSize,
      ringColor: won ? AppColors.win : null,
      dimmed: lost,
    );
    final text = Column(
      crossAxisAlignment: alignLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          fighter?.lastName ?? 'TBA',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: lost ? AppColors.textMuted : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        _resultLine(fighter, won: won, lost: lost, alignLeft: alignLeft),
      ],
    );

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: fighter == null || onFighterTap == null ? null : () => onFighterTap!(fighter),
      child: Row(
        mainAxisAlignment: alignLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: alignLeft
            ? [avatar, const SizedBox(width: 10), Flexible(child: text)]
            : [Flexible(child: text), const SizedBox(width: 10), avatar],
      ),
    );
  }

  Widget _resultLine(Fighter? fighter, {required bool won, required bool lost, required bool alignLeft}) {
    final children = <Widget>[];
    if (won) {
      children.add(const Icon(Icons.arrow_drop_up_rounded, color: AppColors.win, size: 20));
      children.add(const Text('WIN', style: TextStyle(color: AppColors.win, fontWeight: FontWeight.w800, fontSize: 12)));
    } else if (lost) {
      children.add(const Icon(Icons.arrow_drop_down_rounded, color: AppColors.loss, size: 20));
      children.add(const Text('LOSS', style: TextStyle(color: AppColors.loss, fontWeight: FontWeight.w800, fontSize: 12)));
    } else {
      children.add(CountryFlag(fighter?.country, size: 13));
      final record = fighter?.record;
      if (record != null) {
        children.add(const SizedBox(width: 4));
        children.add(Text(record, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)));
      }
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: alignLeft ? children : children.reversed.toList(),
    );
  }
}
