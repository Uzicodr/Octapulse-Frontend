import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/event.dart';
import '../../../../data/models/fighter.dart';
import '../../../../data/repositories/events_repository.dart';
import '../../../core/providers.dart';
import '../../news/views/news_card.dart';
import '../../news/view_models/news_view_models.dart';
import '../../notifications/view_models/notifications_view_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common.dart';
import '../../../../data/services/api_client.dart';
import '../../../core/widgets/fight_widgets.dart';
import '../../../core/widgets/skeleton.dart';
import '../view_models/events_view_models.dart';
import 'event_row.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeProvider);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () {
          ref.invalidate(latestNewsProvider);
          return ref.refresh(homeProvider.future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _HomeHeader(updatedAt: home.valueOrNull?.updatedAt)),
            ...home.when(
              skipLoadingOnRefresh: true,
              loading: () => [const SliverFillRemaining(child: HomeSkeleton())],
              error: (e, _) => [
                SliverFillRemaining(
                  child: ErrorState(
                    message: describeError(e),
                    onRetry: () => ref.invalidate(homeProvider),
                  ),
                ),
              ],
              data: (data) => _content(context, data),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, HomeData data) {
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = width * 0.86;
    final latest = data.latest;

    return [
      SliverToBoxAdapter(child: _LatestNews(cardWidth: cardWidth)),
      SliverToBoxAdapter(
        child: SectionHeader(
          'Upcoming Events',
          action: 'View All',
          onAction: () => context.push('/events/upcoming'),
        ),
      ),
      SliverToBoxAdapter(
        child: data.upcoming.isEmpty
            ? const EmptyState(icon: Icons.event_busy_rounded, title: 'No events scheduled')
            : SizedBox(
                height: 340,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: data.upcoming.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final detail = data.upcoming[i];
                    final main = detail.mainEvent;
                    return SizedBox(
                      width: cardWidth,
                      child: EventHeroCard(
                        event: detail.summary,
                        red: main?.redFighter,
                        blue: main?.blueFighter,
                        onTap: () => context.push('/event/${detail.summary.id}'),
                      ),
                    );
                  },
                ),
              ),
      ),
      if (latest != null && latest.fights.isNotEmpty) ...[
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(
          child: SectionHeader(
            'Latest Results',
            action: 'Full Card',
            onAction: () => context.push('/event/${latest.summary.id}'),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              '${latest.summary.name} · ${Dates.day(latest.summary.startsAt)}',
              style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 186,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: latest.fights.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final fight = latest.fights[i];
                return SizedBox(
                  width: cardWidth,
                  child: FightResultCard(
                    fight: fight,
                    red: fight.redFighter,
                    blue: fight.blueFighter,
                    onFighterTap: (f) => openFighter(context, f),
                    onTap: () => context.push('/fight/${fight.id}'),
                  ),
                );
              },
            ),
          ),
        ),
      ],
      if (data.past.isNotEmpty) ...[
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(
          child: SectionHeader(
            'Past Events',
            action: 'View All',
            onAction: () => context.push('/events/past'),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.separated(
            itemCount: data.past.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => EventRow(event: data.past[i]),
          ),
        ),
      ],
    ];
  }
}

/// Newest headlines as a swipeable row of big cards, first thing on Home.
/// Hidden on error or when empty, so news never breaks the page.
class _LatestNews extends ConsumerWidget {
  const _LatestNews({required this.cardWidth});

  final double cardWidth;
  static const _height = 318.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final news = ref.watch(latestNewsProvider);
    final items = news.valueOrNull ?? const [];
    if (!news.isLoading && items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader('Latest News', action: 'See All', onAction: () => context.push('/news')),
        SizedBox(
          height: _height,
          child: items.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Shimmer(child: SkeletonCard(height: _height, child: const SizedBox.expand())),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => SizedBox(width: cardWidth, child: NewsCard(item: items[i], fill: true)),
                ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader({required this.updatedAt});

  final DateTime? updatedAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(isSignedInProvider);
    final unread = signedIn ? ref.watch(unreadCountProvider).valueOrNull ?? 0 : 0;
    final stamp = updatedAt;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandMark(),
                if (stamp != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 2),
                    child: Text(
                      'Updated ${Dates.ago(stamp)}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          CircleIconButton(icon: Icons.search_rounded, onTap: () => context.push('/search')),
          const SizedBox(width: 8),
          CircleIconButton(
            icon: Icons.notifications_none_rounded,
            badge: unread,
            onTap: () => signedIn
                ? context.push('/notifications')
                : ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sign in to get notifications.')),
                  ),
          ),
        ],
      ),
    );
  }
}

void openFighter(BuildContext context, Fighter fighter) {
  context.push('/fighter/${fighter.slug}', extra: fighter);
}

/// Full list behind "View All".
class EventListView extends ConsumerWidget {
  const EventListView({super.key, required this.window});

  final EventWindow window;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventListProvider(window));
    return Scaffold(
      appBar: AppBar(
        title: Text(window == EventWindow.upcoming ? 'Upcoming Events' : 'Past Events'),
      ),
      body: AsyncBody<List<EventSummary>>(
        value: events,
        skeleton: const SkeletonList(
          item: SkeletonEventRow(),
          count: 9,
          padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
        ),
        onRetry: () => ref.invalidate(eventListProvider(window)),
        data: (list) => list.isEmpty
            ? const EmptyState(icon: Icons.event_busy_rounded, title: 'Nothing here yet')
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => EventRow(event: list[i]),
              ),
      ),
    );
  }
}
