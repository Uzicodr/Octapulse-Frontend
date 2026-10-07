import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/fight.dart';
import '../../../../data/models/fight_insights.dart';
import '../../../../data/models/fighter.dart';
import '../../../../data/models/pick.dart';
import '../../../../data/models/social.dart';
import '../../../../data/services/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fighter_avatar.dart';
import '../../../core/widgets/skeleton.dart';
import '../../events/views/home_view.dart';
import '../../picks/view_models/picks_view_model.dart';
import '../../picks/views/pick_sheet.dart';
import '../../shell/main_shell.dart';
import '../view_models/fight_view_models.dart';

class FightDetailView extends ConsumerWidget {
  const FightDetailView({super.key, required this.fightId});

  final String fightId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(fightDetailProvider(fightId));

    return Scaffold(
      appBar: AppBar(
        title: Text(detail.valueOrNull?.event.name ?? 'Fight'),
        actions: [
          if (detail.valueOrNull != null)
            IconButton(
              tooltip: 'Full card',
              icon: const Icon(Icons.view_list_rounded),
              onPressed: () => context.push('/event/${detail.value!.event.id}'),
            ),
        ],
      ),
      body: AsyncBody<FightDetail>(
        value: detail,
        skeleton: const SkeletonList(item: SkeletonFightCard(), count: 4, padding: EdgeInsets.all(20)),
        onRetry: () => ref.invalidate(fightDetailProvider(fightId)),
        data: (d) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () {
            ref.invalidate(consensusProvider(fightId));
            ref.invalidate(commentsProvider(fightId));
            ref.invalidate(myPicksProvider);
            return ref.refresh(fightDetailProvider(fightId).future);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
            children: [
              _Matchup(fight: d.fight),
              const SizedBox(height: 14),
              _MyPickCard(fight: d.fight),
              _AiPickCard(fight: d.fight, eventId: d.event.id),
              const SizedBox(height: 14),
              _ConsensusCard(fight: d.fight),
              _PreviewCard(fightId: fightId),
              _StatsCard(fight: d.fight),
              const SizedBox(height: 24),
              _Comments(fightId: fightId, initialCount: d.commentCount),
            ],
          ),
        ),
      ),
    );
  }
}

class _Matchup extends StatelessWidget {
  const _Matchup({required this.fight});

  final Fight fight;

  @override
  Widget build(BuildContext context) {
    final status = fight.hasResult
        ? '${fight.methodLabel}${fight.resultRound != null ? ' · R${fight.resultRound}' : ''}${fight.resultTime != null ? ' · ${fight.resultTime}' : ''}'
        : fight.locked
            ? 'Live now · picks closed'
            : 'Picks open until the fight starts';

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (fight.titleFight) ...[
                const Icon(Icons.emoji_events_rounded, size: 16, color: AppColors.gold),
                const SizedBox(width: 4),
              ],
              Text(
                fight.weightClass ?? 'Bout',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: fight.titleFight ? AppColors.gold : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _corner(context, fight.redFighter, fight.redFighterId, AppColors.primary)),
              const Padding(
                padding: EdgeInsets.only(top: 30),
                child: Text(
                  'VS',
                  style: TextStyle(fontWeight: FontWeight.w800, fontStyle: FontStyle.italic, color: AppColors.textMuted),
                ),
              ),
              Expanded(child: _corner(context, fight.blueFighter, fight.blueFighterId, AppColors.blueCorner)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(color: AppColors.surfaceHigh, borderRadius: BorderRadius.circular(14)),
            child: Text(
              status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _corner(BuildContext context, Fighter? fighter, String? id, Color corner) {
    final won = fight.winnerFighterId != null && fight.winnerFighterId == id;
    final lost = fight.winnerFighterId != null && !won;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: fighter == null ? null : () => openFighter(context, fighter),
      child: Column(
        children: [
          FighterAvatar(fighter: fighter, size: 84, ringColor: won ? AppColors.win : corner, dimmed: lost),
          const SizedBox(height: 10),
          Text(
            fighter?.name ?? 'TBA',
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: lost ? AppColors.textMuted : null),
          ),
          if (fighter?.record != null)
            Text(fighter!.record!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
          if (won)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('WINNER', style: TextStyle(color: AppColors.win, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.2)),
            ),
        ],
      ),
    );
  }
}

class _MyPickCard extends ConsumerWidget {
  const _MyPickCard({required this.fight});

  final Fight fight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(isSignedInProvider);
    final pick = ref.watch(myPicksProvider).valueOrNull?[fight.id];

    if (!signedIn) {
      if (fight.locked) return const SizedBox.shrink();
      return PillButton(
        label: 'Sign in to pick',
        icon: Icons.lock_outline_rounded,
        onPressed: () {
          ref.read(currentTabProvider.notifier).state = AppTab.profile;
          context.go('/home');
        },
      );
    }
    if (pick == null) {
      if (fight.locked) {
        return const _InfoLine(icon: Icons.lock_rounded, text: "You didn't pick this fight.");
      }
      return PillButton(
        label: 'Make Your Pick',
        icon: Icons.track_changes_rounded,
        filled: true,
        onPressed: () => showPickSheet(context, fight),
      );
    }

    final fighter = fight.fighterById(pick.pickedFighterId);
    final (label, color) = switch (pick.result) {
      PickResult.won => ('WON +${pick.points ?? 0}', AppColors.win),
      PickResult.lost => ('LOST', AppColors.loss),
      PickResult.voided => ('VOID', AppColors.textMuted),
      PickResult.pending => (fight.locked ? 'LOCKED' : 'PENDING', AppColors.textSecondary),
    };
    return AppCard(
      borderColor: AppColors.primary.withValues(alpha: 0.5),
      padding: const EdgeInsets.all(14),
      onTap: fight.locked ? null : () => showPickSheet(context, fight),
      child: Row(
        children: [
          FighterAvatar(fighter: fighter, size: 44, ringColor: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('YOUR PICK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: AppColors.primaryBright)),
                Text(fighter?.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                if (pick.extrasLabel != null)
                  Text(pick.extrasLabel!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
              ],
            ),
          ),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1)),
          if (!fight.locked) ...[
            const SizedBox(width: 6),
            const Icon(Icons.edit_rounded, size: 18, color: AppColors.textSecondary),
          ],
        ],
      ),
    );
  }
}

class _AiPickCard extends ConsumerWidget {
  const _AiPickCard({required this.fight, required this.eventId});

  final Fight fight;
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ai = ref.watch(aiPicksProvider(eventId)).valueOrNull?[fight.id];
    if (ai == null) return const SizedBox.shrink();
    final fighter = fight.fighterById(ai.pickedFighterId);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        borderColor: AppColors.blueCorner.withValues(alpha: 0.4),
        color: AppColors.blueCorner.withValues(alpha: 0.06),
        child: Row(
          children: [
            const UserAvatar(name: 'AI', ai: true, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('OCTAPULSE AI PICKS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: AppColors.blueCorner)),
                  Text(fighter?.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  if (ai.extrasLabel != null)
                    Text(ai.extrasLabel!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                ],
              ),
            ),
            const Text('Beat it', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _ConsensusCard extends ConsumerWidget {
  const _ConsensusCard({required this.fight});

  final Fight fight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consensus = ref.watch(consensusProvider(fight.id)).valueOrNull;
    if (consensus == null) return const SizedBox.shrink();
    final total = consensus.totalPicks;
    final redPct = total == 0 ? 50.0 : consensus.red.percent;
    final bluePct = total == 0 ? 50.0 : consensus.blue.percent;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Crowd picks', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const Spacer(),
              Text('$total ${total == 1 ? 'pick' : 'picks'}', style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text('${redPct.round()}%', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryBright)),
              const Spacer(),
              Text('${bluePct.round()}%', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.blueCorner)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(
                    flex: (redPct * 10).round().clamp(1, 1000),
                    child: Container(color: total == 0 ? AppColors.surfaceHigh : AppColors.primary),
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    flex: (bluePct * 10).round().clamp(1, 1000),
                    child: Container(color: total == 0 ? AppColors.surfaceHigh : AppColors.blueCorner),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(fight.redFighter?.lastName ?? 'Red', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
              const Spacer(),
              Text(fight.blueFighter?.lastName ?? 'Blue', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MethodChip('KO/TKO', consensus.methods['koTko'] ?? 0, total),
                _MethodChip('Submission', consensus.methods['submission'] ?? 0, total),
                _MethodChip('Decision', consensus.methods['decision'] ?? 0, total),
              ],
            ),
          ] else
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text('No picks yet. Be the first.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ),
        ],
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  const _MethodChip(this.label, this.count, this.total);

  final String label;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppColors.surfaceHigh, borderRadius: BorderRadius.circular(14)),
      child: Text(
        '$label ${(count / total * 100).round()}%',
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
      ),
    );
  }
}

class _PreviewCard extends ConsumerStatefulWidget {
  const _PreviewCard({required this.fightId});

  final String fightId;

  @override
  ConsumerState<_PreviewCard> createState() => _PreviewCardState();
}

class _PreviewCardState extends ConsumerState<_PreviewCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final preview = ref.watch(previewProvider(widget.fightId)).valueOrNull;
    if (preview == null || preview.content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: AppCard(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.blueCorner),
                SizedBox(width: 8),
                Text('AI Preview', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              preview.content,
              maxLines: _expanded ? null : 5,
              overflow: _expanded ? null : TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 6),
            Text(
              _expanded ? 'Show less' : 'Read more',
              style: const TextStyle(color: AppColors.primaryBright, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends ConsumerWidget {
  const _StatsCard({required this.fight});

  final Fight fight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(fightStatsProvider(fight.id)).valueOrNull ?? const <RoundStats>[];
    if (stats.isEmpty) return const SizedBox.shrink();

    final rounds = stats.map((s) => s.round).toSet().toList()..sort();
    RoundStats? of(int round, String? fighterId) =>
        stats.where((s) => s.round == round && s.fighterId == fighterId).firstOrNull;

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Round stats', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const Spacer(),
                Text(fight.redFighter?.lastName ?? 'Red', style: const TextStyle(color: AppColors.primaryBright, fontWeight: FontWeight.w700, fontSize: 12.5)),
                const Text('  vs  ', style: TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                Text(fight.blueFighter?.lastName ?? 'Blue', style: const TextStyle(color: AppColors.blueCorner, fontWeight: FontWeight.w700, fontSize: 12.5)),
              ],
            ),
            for (final round in rounds) ...[
              const SizedBox(height: 14),
              Text('ROUND $round', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: AppColors.textMuted)),
              const SizedBox(height: 6),
              _statRow('Sig. strikes', of(round, fight.redFighterId), of(round, fight.blueFighterId),
                  (s) => _ratio(s.sigStrikesLanded, s.sigStrikesAttempted)),
              _statRow('Takedowns', of(round, fight.redFighterId), of(round, fight.blueFighterId),
                  (s) => _ratio(s.takedownsLanded, s.takedownsAttempted)),
              _statRow('Control', of(round, fight.redFighterId), of(round, fight.blueFighterId),
                  (s) => _clock(s.controlTimeSeconds)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, RoundStats? red, RoundStats? blue, String Function(RoundStats) value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(red == null ? '—' : value(red), style: const TextStyle(fontWeight: FontWeight.w700))),
          Expanded(child: Text(label, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
          SizedBox(width: 70, child: Text(blue == null ? '—' : value(blue), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  static String _ratio(int? landed, int? attempted) =>
      landed == null ? '—' : attempted == null ? '$landed' : '$landed/$attempted';

  static String _clock(int? seconds) {
    if (seconds == null) return '—';
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }
}

class _Comments extends ConsumerStatefulWidget {
  const _Comments({required this.fightId, required this.initialCount});

  final String fightId;
  final int initialCount;

  @override
  ConsumerState<_Comments> createState() => _CommentsState();
}

class _CommentsState extends ConsumerState<_Comments> {
  final _controller = TextEditingController();
  bool _posting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _posting = true);
    try {
      await ref.read(commentsProvider(widget.fightId).notifier).post(text);
      _controller.clear();
      if (mounted) FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(e))));
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(commentsProvider(widget.fightId));
    final me = ref.watch(meProvider).valueOrNull;
    final count = comments.valueOrNull?.length ?? widget.initialCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Comments · $count', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (me != null)
          TextField(
            controller: _controller,
            maxLength: 1000,
            minLines: 1,
            maxLines: 4,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _post(),
            decoration: InputDecoration(
              hintText: 'Say something about this fight',
              counterText: '',
              suffixIcon: _posting
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : IconButton(icon: const Icon(Icons.send_rounded, color: AppColors.primaryBright), onPressed: _post),
            ),
          )
        else
          const _InfoLine(icon: Icons.chat_bubble_outline_rounded, text: 'Sign in to join the conversation.'),
        const SizedBox(height: 12),
        comments.when(
          skipLoadingOnRefresh: true,
          loading: () => const Shimmer(child: Column(children: [SkeletonTile(carded: false), SkeletonTile(carded: false)])),
          error: (e, _) => Text(describeError(e), style: const TextStyle(color: AppColors.textSecondary)),
          data: (list) => list.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('No comments yet.', style: TextStyle(color: AppColors.textMuted)),
                )
              : Column(
                  children: [
                    for (final c in list)
                      _CommentTile(
                        comment: c,
                        canDelete: me != null && (me.id == c.user.id || me.isAdmin),
                        onDelete: () => ref.read(commentsProvider(widget.fightId).notifier).delete(c),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment, required this.canDelete, required this.onDelete});

  final Comment comment;
  final bool canDelete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final user = comment.user;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.push('/user/${user.id}'),
            child: UserAvatar(name: user.name, url: user.avatarUrl, ai: user.ai, size: 36),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(user.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    if (user.ai) ...[const SizedBox(width: 6), const AiBadge()],
                    if (comment.createdAt != null)
                      Text('  · ${Dates.ago(comment.createdAt!)}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(comment.body, style: const TextStyle(height: 1.4)),
              ],
            ),
          ),
          if (canDelete)
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.delete_outline_rounded, size: 19, color: AppColors.textMuted),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.outline)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: AppColors.textSecondary))),
        ],
      ),
    );
  }
}
