import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/fight.dart';
import '../../../../data/models/pick.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fighter_avatar.dart';
import '../../../core/widgets/skeleton.dart';
import '../../fights/view_models/fight_view_models.dart';

/// A pick with its fight: picked fighter, opponent, extras and result.
/// Pass [fight] when already known (feed); otherwise it is fetched.
class PickTile extends ConsumerWidget {
  const PickTile({super.key, required this.pick, this.fight});

  final Pick pick;
  final Fight? fight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final known = fight;
    if (known != null) return _tile(context, known);
    return ref.watch(fightDetailProvider(pick.fightId)).when(
          loading: () => const Shimmer(child: SkeletonTile()),
          error: (_, __) => const SizedBox.shrink(),
          data: (d) => _tile(context, d.fight),
        );
  }

  Widget _tile(BuildContext context, Fight fight) {
    final picked = fight.fighterById(pick.pickedFighterId);
    final opponent = pick.pickedFighterId == fight.redFighterId ? fight.blueFighter : fight.redFighter;
    final tag = PickResultTag.of(pick, fight);
    final extras = pick.extrasLabel;

    return AppCard(
      radius: 18,
      padding: const EdgeInsets.all(12),
      onTap: () => context.push('/fight/${fight.id}'),
      borderColor: pick.result == PickResult.won ? AppColors.win.withValues(alpha: 0.4) : null,
      child: Row(
        children: [
          FighterAvatar(
            fighter: picked,
            size: 46,
            ringColor: pick.result == PickResult.won ? AppColors.win : null,
            dimmed: pick.result == PickResult.lost,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  picked?.name ?? 'Unknown fighter',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                Text(
                  ['over ${opponent?.lastName ?? 'TBA'}', if (extras != null) extras].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                ),
              ],
            ),
          ),
          tag,
        ],
      ),
    );
  }
}

class PickResultTag extends StatelessWidget {
  const PickResultTag(this.label, this.color, {super.key});

  factory PickResultTag.of(Pick pick, Fight fight) => switch (pick.result) {
        PickResult.won => PickResultTag('WON +${pick.points ?? 0}', AppColors.win),
        PickResult.lost => const PickResultTag('LOST', AppColors.loss),
        PickResult.voided => const PickResultTag('VOID', AppColors.textMuted),
        PickResult.pending => PickResultTag(fight.locked ? 'LIVE' : 'PENDING', AppColors.textMuted),
      };

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.1)),
    );
  }
}
