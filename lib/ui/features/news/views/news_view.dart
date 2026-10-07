import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/news.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/skeleton.dart';
import '../view_models/news_view_models.dart';
import 'news_card.dart';

/// Every headline, newest first, with kind filters and endless scroll.
class NewsView extends ConsumerWidget {
  const NewsView({super.key});

  static const _filters = <(NewsKind?, String)>[
    (null, 'All'),
    (NewsKind.announcement, 'Announcements'),
    (NewsKind.result, 'Results'),
    (NewsKind.injury, 'Injuries'),
    (NewsKind.rumor, 'Rumors'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kind = ref.watch(newsKindFilterProvider);
    final feed = ref.watch(newsFeedProvider(kind));

    return Scaffold(
      appBar: AppBar(title: const Text('News')),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final (value, label) = _filters[i];
                final selected = value == kind;
                return ChoiceChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (_) => ref.read(newsKindFilterProvider.notifier).state = value,
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  side: BorderSide(color: selected ? AppColors.primary : AppColors.outline),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                  shape: const StadiumBorder(),
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => ref.refresh(newsFeedProvider(kind).future),
              child: AsyncBody<NewsFeed>(
                value: feed,
                skeleton: const SkeletonList(item: SkeletonCard(height: 318, child: SizedBox.expand()), count: 3, spacing: 14),
                onRetry: () => ref.invalidate(newsFeedProvider(kind)),
                data: (data) => data.items.isEmpty
                    ? ListView(
                        children: const [
                          EmptyState(
                            icon: Icons.newspaper_rounded,
                            title: 'No news yet',
                            message: 'Headlines from ESPN, UFC.com and Sherdog show up here. Check back soon.',
                          ),
                        ],
                      )
                    : NotificationListener<ScrollNotification>(
                        onNotification: (n) {
                          if (n.metrics.extentAfter < 400) ref.read(newsFeedProvider(kind).notifier).loadMore();
                          return false;
                        },
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                          itemCount: data.items.length + (data.hasMore ? 1 : 0),
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (_, i) => i < data.items.length
                              ? NewsCard(item: data.items[i])
                              : const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
