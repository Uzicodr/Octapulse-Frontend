import '../models/news.dart';
import '../models/social.dart' show Page;
import '../services/api_client.dart';

/// MMA headlines that the agent pulls from publisher RSS feeds.
class NewsRepository {
  NewsRepository(this._api);

  final ApiClient _api;

  Future<Page<NewsItem>> list({String? fighterSlug, NewsKind? kind, int page = 1, int limit = 20}) async {
    final json = await _api.get<Map<String, dynamic>>('/news', query: {
      if (fighterSlug != null) 'fighter': fighterSlug,
      if (kind != null) 'kind': kind.name,
      'page': page,
      'limit': limit,
    });
    return Page.fromJson(json, NewsItem.fromJson);
  }
}
