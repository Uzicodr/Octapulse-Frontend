import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fighter_avatar.dart';
import '../../domain/entities/rankings.dart';

final rankingsProvider = FutureProvider<List<Ranking>>((ref) async {
  return ref.watch(getRankingsProvider).call();
});

class RankingsPage extends ConsumerWidget {
  const RankingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingsAsyncValue = ref.watch(rankingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Rankings')),
      body: rankingsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: AppColors.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'Error Loading Rankings',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        data: (rankings) => _buildRankingsList(context, rankings),
      ),
    );
  }

  Widget _buildRankingsList(BuildContext context, List<Ranking> rankings) {
    if (rankings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard_outlined,
              size: 80,
              color: AppColors.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Rankings Available',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    // Group rankings by gender
    final menRankings = rankings.where((r) => r.gender == 'men').toList();
    final womenRankings = rankings.where((r) => r.gender == 'women').toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.onSurfaceVariant,
            tabs: const [
              Tab(text: 'Men'),
              Tab(text: 'Women'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildDivisionList(context, menRankings),
                _buildDivisionList(context, womenRankings),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivisionList(BuildContext context, List<Ranking> rankings) {
    return ListView.builder(
      itemCount: rankings.length,
      itemBuilder: (context, index) {
        final ranking = rankings[index];
        return _buildRankingCard(context, ranking);
      },
    );
  }

  Widget _buildRankingCard(BuildContext context, Ranking ranking) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                ranking.category,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (ranking.champion != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Champion',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        subtitle: ranking.champion != null
            ? Text(
                'Champion: ${ranking.champion}',
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Fighters',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ...List.generate(
                  ranking.fighters.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FighterAvatar(
                          name: ranking.fighters[index],
                          radius: 16,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            ranking.fighters[index],
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
