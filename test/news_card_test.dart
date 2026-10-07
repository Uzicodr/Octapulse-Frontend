import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octapulsev2/data/models/news.dart';
import 'package:octapulsev2/ui/features/news/views/news_card.dart';

NewsItem story({int fighters = 2, NewsKind kind = NewsKind.announcement}) => NewsItem(
      id: '1',
      source: 'espn',
      sourceName: 'ESPN',
      title: 'Natalia Silva vs. Valentina Shevchenko set for UFC 335 after record-breaking '
          'title win, with the trilogy bout confirmed for International Fight Week in Las Vegas',
      summary: 'Summary',
      url: 'https://www.espn.com/mma/story',
      kind: kind,
      publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
      fighters: [
        for (var i = 0; i < fighters; i++) NewsFighter(id: 'f$i', slug: 'fighter-$i', name: 'Fighter Number$i'),
      ],
    );

Widget host(Widget child, {double width = 320, double? height}) => MaterialApp(
      home: Scaffold(
        body: Center(child: SizedBox(width: width, height: height, child: child)),
      ),
    );

void main() {
  for (final fighters in [0, 1, 2]) {
    testWidgets('carousel card fits 318px with $fighters fighters', (tester) async {
      await tester.pumpWidget(host(NewsCard(item: story(fighters: fighters), fill: true), height: 318));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Read more'), findsOneWidget);
      expect(find.text('ANNOUNCED'), findsOneWidget);
    });
  }

  testWidgets('list card sizes to its content on a narrow phone', (tester) async {
    await tester.pumpWidget(host(SingleChildScrollView(child: NewsCard(item: story(kind: NewsKind.news))), width: 300));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('ESPN · 3h ago'), findsOneWidget);
    expect(find.text('ANNOUNCED'), findsNothing);
  });
}
