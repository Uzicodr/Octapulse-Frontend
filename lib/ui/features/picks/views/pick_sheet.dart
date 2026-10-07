import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/fight.dart';
import '../../../../data/models/fighter.dart';
import '../../../../data/models/pick.dart';
import '../../../../data/services/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fighter_avatar.dart';
import '../view_models/picks_view_model.dart';

/// Opens the full pick editor: winner, method, round and confidence.
Future<void> showPickSheet(BuildContext context, Fight fight, {String? preselectFighterId}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => _PickSheet(fight: fight, preselectFighterId: preselectFighterId),
  );
}

class _PickSheet extends ConsumerStatefulWidget {
  const _PickSheet({required this.fight, this.preselectFighterId});

  final Fight fight;
  final String? preselectFighterId;

  @override
  ConsumerState<_PickSheet> createState() => _PickSheetState();
}

class _PickSheetState extends ConsumerState<_PickSheet> {
  String? _fighterId;
  PickMethod? _method;
  int? _round;
  int _confidence = 1;
  bool _saving = false;
  Pick? _existing;

  Fight get fight => widget.fight;

  @override
  void initState() {
    super.initState();
    _existing = ref.read(myPicksProvider).valueOrNull?[fight.id];
    final e = _existing;
    _fighterId = widget.preselectFighterId ?? e?.pickedFighterId;
    _method = e?.method;
    _round = e?.round;
    _confidence = e?.confidence ?? 1;
  }

  Future<void> _save() async {
    final fighterId = _fighterId;
    if (fighterId == null) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await ref.read(myPicksProvider.notifier).pick(
            fightId: fight.id,
            fighterId: fighterId,
            method: _method,
            round: _method == PickMethod.decision ? null : _round,
            confidence: _confidence,
          );
      navigator.pop();
    } catch (e) {
      if (isStatus(e, 409)) navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(describeError(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _remove() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await ref.read(myPicksProvider.notifier).remove(fight.id);
      navigator.pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describeError(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final roundsAllowed = _method != PickMethod.decision;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.outline, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text('Your pick', style: Theme.of(context).textTheme.titleLarge),
              Text(
                '${fight.weightClass ?? 'Bout'}${fight.titleFight ? ' · Title fight' : ''}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _winner(fight.redFighter, fight.redFighterId)),
                  const SizedBox(width: 10),
                  Expanded(child: _winner(fight.blueFighter, fight.blueFighterId)),
                ],
              ),
              const _Label('Method', optional: true),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in PickMethod.values)
                    _Choice(
                      label: m.label,
                      selected: _method == m,
                      onTap: () => setState(() {
                        _method = _method == m ? null : m;
                        if (_method == PickMethod.decision) _round = null;
                      }),
                    ),
                ],
              ),
              if (roundsAllowed) ...[
                const _Label('Round', optional: true),
                Wrap(
                  spacing: 8,
                  children: [
                    for (var r = 1; r <= fight.maxRounds; r++)
                      _Choice(
                        label: 'R$r',
                        selected: _round == r,
                        onTap: () => setState(() => _round = _round == r ? null : r),
                      ),
                  ],
                ),
              ],
              const _Label('Confidence'),
              Row(
                children: [
                  for (var c = 1; c <= 3; c++) ...[
                    Expanded(
                      child: _Choice(
                        label: const ['1x Lean', '2x Solid', '3x Lock'][c - 1],
                        selected: _confidence == c,
                        onTap: () => setState(() => _confidence = c),
                        expand: true,
                      ),
                    ),
                    if (c < 3) const SizedBox(width: 8),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Right winner scores your confidence (1–3), +1 for the method, +1 for the round on a finish. Max 5.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12.5, height: 1.4),
              ),
              const SizedBox(height: 20),
              PillButton(
                label: _existing == null ? 'Lock In Pick' : 'Update Pick',
                filled: true,
                loading: _saving,
                onPressed: _fighterId == null ? null : _save,
              ),
              if (_existing != null) ...[
                const SizedBox(height: 10),
                PillButton(label: 'Remove Pick', icon: Icons.delete_outline_rounded, onPressed: _remove),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _winner(Fighter? fighter, String? id) {
    final selected = id != null && _fighterId == id;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: id == null ? null : () => setState(() => _fighterId = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.14) : AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? AppColors.primary : Colors.transparent, width: 1.5),
        ),
        child: Column(
          children: [
            FighterAvatar(fighter: fighter, size: 60, ringColor: selected ? AppColors.primary : null),
            const SizedBox(height: 8),
            Text(
              fighter?.name ?? 'TBA',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            if (fighter?.record != null)
              Text(fighter!.record!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {this.optional = false});

  final String text;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        children: [
          Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
          if (optional) ...[
            const SizedBox(width: 6),
            const Text('optional', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({required this.label, required this.selected, required this.onTap, this.expand = false});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surfaceHigh,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            textAlign: expand ? TextAlign.center : null,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
