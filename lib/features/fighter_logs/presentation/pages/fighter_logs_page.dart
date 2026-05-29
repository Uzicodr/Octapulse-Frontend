import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fighter_avatar.dart';
import '../../domain/entities/fighter_log.dart';
import '../providers/fighter_logs_provider.dart';

class FighterLogsPage extends ConsumerWidget {
  const FighterLogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(fighterLogsSearchProvider);
    final asyncFighterLogs = ref.watch(fighterLogsProvider(searchQuery));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Fighter Logs'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (v) =>
                  ref.read(fighterLogsSearchProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Search for fighter...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.onSurfaceVariant,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.onSurfaceVariant,
                        ),
                        onPressed: () =>
                            ref.read(fighterLogsSearchProvider.notifier).state =
                                '',
                      )
                    : null,
              ),
              style: const TextStyle(color: AppColors.onSurface),
            ),
          ),
        ),
      ),
      body: asyncFighterLogs.when(
        data: (fighters) => _FighterLogsContent(fighters: fighters),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(fighterLogsProvider(searchQuery)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FighterLogsContent extends StatelessWidget {
  const _FighterLogsContent({required this.fighters});

  final List<FighterLog> fighters;

  @override
  Widget build(BuildContext context) {
    if (fighters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_alt_outlined,
              size: 64,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No fighters found',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: fighters.length,
      itemBuilder: (context, index) {
        final fighter = fighters[index];
        return _FighterLogCard(fighter: fighter);
      },
    );
  }
}

class _FighterLogCard extends StatelessWidget {
  const _FighterLogCard({required this.fighter});

  final FighterLog fighter;

  @override
  Widget build(BuildContext context) {
    final name = '${fighter.first_name} ${fighter.last_name}';
    final nickname = fighter.nickname?.trim();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: FighterAvatar(name: name),
          title: Text(name),
          subtitle: Text(
            [
              fighter.getrecord(),
              if (nickname != null && nickname.isNotEmpty) '"$nickname"',
            ].join('  |  '),
            style: const TextStyle(color: AppColors.onSurfaceVariant),
          ),
          trailing: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.onSurfaceVariant,
          ),
          children: [
            _StatGrid(
              stats: [
                _StatItem('Age', _ageFromDob(fighter.dob)),
                _StatItem('DOB', fighter.dob),
                _StatItem('Height', fighter.height),
                _StatItem('Weight', fighter.weight),
                _StatItem('Reach', fighter.reach),
                _StatItem('Stance', fighter.stance),
                _StatItem('SLpM', fighter.slpm),
                _StatItem('SApM', fighter.sapm),
                _StatItem('Str. Acc.', fighter.strikingAccuracy),
                _StatItem('Str. Def.', fighter.strikingDefense),
                _StatItem('TD Avg.', fighter.tdAvg),
                _StatItem('TD Acc.', fighter.tdAccuracy),
                _StatItem('TD Def.', fighter.tdDefense),
                _StatItem('Sub Avg.', fighter.submissionAvg),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String? _ageFromDob(String? dob) {
    if (dob == null || dob.trim().isEmpty || dob == '--') return null;
    final birthDate = DateTime.tryParse(dob);
    if (birthDate == null) {
      final match = RegExp(
        r'^([A-Za-z]{3}) (\d{1,2}), (\d{4})$',
      ).firstMatch(dob);
      if (match == null) return null;
      const months = {
        'Jan': 1,
        'Feb': 2,
        'Mar': 3,
        'Apr': 4,
        'May': 5,
        'Jun': 6,
        'Jul': 7,
        'Aug': 8,
        'Sep': 9,
        'Oct': 10,
        'Nov': 11,
        'Dec': 12,
      };
      final month = months[match.group(1)];
      if (month == null) return null;
      return _calculateAge(
        DateTime(int.parse(match.group(3)!), month, int.parse(match.group(2)!)),
      ).toString();
    }
    return _calculateAge(birthDate).toString();
  }

  static int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.stats});

  final List<_StatItem> stats;

  @override
  Widget build(BuildContext context) {
    final visibleStats = stats.where((stat) {
      final value = stat.value?.trim();
      return value != null && value.isNotEmpty;
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 360 ? 1 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleStats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: 68,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final stat = visibleStats[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    stat.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        stat.value!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StatItem {
  const _StatItem(this.label, this.value);

  final String label;
  final String? value;
}
