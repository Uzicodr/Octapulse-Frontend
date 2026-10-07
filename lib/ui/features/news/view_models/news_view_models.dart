import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/news.dart';
import '../../../core/providers.dart';

/// The newest stories, shown as cards at the top of Home.
final latestNewsProvider = FutureProvider<List<NewsItem>>((ref) async {
  return (await ref.watch(newsRepositoryProvider).list(limit: 6)).items;
});

/// Stories that name one fighter, for the fighter page.
final fighterNewsProvider = FutureProvider.autoDispose.family<List<NewsItem>, String>((ref, slug) async {
  return (await ref.watch(newsRepositoryProvider).list(fighterSlug: slug, limit: 5)).items;
});

/// Filter on the News screen; null shows every kind.
final newsKindFilterProvider = StateProvider.autoDispose<NewsKind?>((ref) => null);

class NewsFeed {
  const NewsFeed({required this.items, required this.page, required this.hasMore, this.loadingMore = false});

  final List<NewsItem> items;
  final int page;
  final bool hasMore;
  final bool loadingMore;

  NewsFeed copyWith({List<NewsItem>? items, int? page, bool? hasMore, bool? loadingMore}) => NewsFeed(
        items: items ?? this.items,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

/// Paged feed for the News screen, one per kind filter.
final newsFeedProvider =
    AsyncNotifierProvider.autoDispose.family<NewsFeedController, NewsFeed, NewsKind?>(NewsFeedController.new);

class NewsFeedController extends AutoDisposeFamilyAsyncNotifier<NewsFeed, NewsKind?> {
  @override
  Future<NewsFeed> build(NewsKind? kind) async {
    final page = await ref.read(newsRepositoryProvider).list(kind: kind);
    return NewsFeed(items: page.items, page: page.page, hasMore: page.hasMore);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.loadingMore) return;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final next = await ref.read(newsRepositoryProvider).list(kind: arg, page: current.page + 1);
      final seen = current.items.map((n) => n.id).toSet();
      state = AsyncData(NewsFeed(
        items: [...current.items, ...next.items.where((n) => !seen.contains(n.id))],
        page: next.page,
        hasMore: next.hasMore,
      ));
    } catch (_) {
      // Keep what is on screen; scrolling to the end again retries.
      state = AsyncData(current.copyWith(loadingMore: false));
    }
  }
}
