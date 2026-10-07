import 'pick.dart' show parseDate;

/// How a story was sorted from its headline. Keyword-based, so treat it as a hint.
enum NewsKind { announcement, result, injury, rumor, news }

class NewsFighter {
  const NewsFighter({required this.id, required this.slug, required this.name});

  final String id;
  final String slug;
  final String name;

  factory NewsFighter.fromJson(Map<String, dynamic> json) => NewsFighter(
        id: json['id'] as String,
        slug: json['slug'] as String,
        name: json['name'] as String,
      );
}

/// Who to credit for a story's photo. [license] and [url] are set for photos the agent added
/// (Wikimedia Commons, Unsplash); link the credit to [url] when present.
class ImageCredit {
  const ImageCredit({required this.text, this.license, this.url});

  final String text;
  final String? license;
  final String? url;

  factory ImageCredit.fromJson(Map<String, dynamic> json) => ImageCredit(
        text: json['text'] as String,
        license: json['license'] as String?,
        url: json['url'] as String?,
      );
}

/// A publisher headline. Show [title] and [summary] unchanged, credit [sourceName],
/// and open [url] in the browser for the full story.
class NewsItem {
  const NewsItem({
    required this.id,
    required this.source,
    required this.sourceName,
    required this.title,
    required this.url,
    required this.kind,
    required this.publishedAt,
    required this.fighters,
    this.summary,
    this.imageUrl,
    this.imageCredit,
  });

  final String id;
  final String source;
  final String sourceName;
  final String title;
  final String? summary;
  final String url;
  final String? imageUrl;
  final ImageCredit? imageCredit;
  final NewsKind kind;
  final DateTime publishedAt;
  final List<NewsFighter> fighters;

  factory NewsItem.fromJson(Map<String, dynamic> json) => NewsItem(
        id: json['id'] as String,
        source: json['source'] as String,
        sourceName: json['sourceName'] as String,
        title: json['title'] as String,
        summary: json['summary'] as String?,
        url: json['url'] as String,
        imageUrl: json['imageUrl'] as String?,
        imageCredit: json['imageCredit'] is Map<String, dynamic>
            ? ImageCredit.fromJson(json['imageCredit'] as Map<String, dynamic>)
            : null,
        kind: NewsKind.values.asNameMap()[json['kind']] ?? NewsKind.news,
        publishedAt: parseDate(json['publishedAt']) ?? DateTime.now(),
        fighters: (json['fighters'] as List? ?? const [])
            .map((f) => NewsFighter.fromJson(f as Map<String, dynamic>))
            .toList(),
      );
}
