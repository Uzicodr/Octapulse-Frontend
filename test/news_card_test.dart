import 'dart:ui' as ui;

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

// Fighter portraits load through cached_network_image, whose cache needs platform channels that
// never answer in widget tests, so these use untagged stories. Portraits are sized to the artwork
// box, so they don't change the layout being checked here.
void main() {
  for (final width in [300.0, 360.0]) {
    testWidgets('carousel card fits 318px at width $width', (tester) async {
      await tester.pumpWidget(host(NewsCard(item: story(fighters: 0), fill: true), width: width, height: 318));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Read more'), findsOneWidget);
      expect(find.text('ANNOUNCED'), findsOneWidget);
    });
  }

  testWidgets('list card sizes to its content on a narrow phone', (tester) async {
    await tester.pumpWidget(host(SingleChildScrollView(child: NewsCard(item: story(fighters: 0, kind: NewsKind.news))), width: 300));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('ESPN · 3h ago'), findsOneWidget);
    expect(find.text('ANNOUNCED'), findsNothing);
  });

  Future<ImageProvider> png(WidgetTester tester, int width, int height) async {
    final bytes = await tester.runAsync(() async {
      final image = await createTestImage(width: width, height: height);
      return (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
    });
    return MemoryImage(bytes!);
  }

  Future<void> pumpPhoto(WidgetTester tester, ImageProvider image) async {
    await tester.pumpWidget(host(NewsPhoto(image: image), width: 320, height: 190));
    // Decoding happens off the test clock.
    await tester.runAsync(() => precacheImage(image, tester.element(find.byType(NewsPhoto))));
    await tester.pump();
  }

  testWidgets('portrait photo is shown whole over a blurred copy', (tester) async {
    await pumpPhoto(tester, await png(tester, 300, 450));
    expect(find.byType(ImageFiltered), findsOneWidget);
    final whole = tester.widgetList<Image>(find.byType(Image)).last;
    expect(whole.fit, BoxFit.contain);
  });

  testWidgets('landscape photo fills the box, cropped towards the top', (tester) async {
    await pumpPhoto(tester, await png(tester, 800, 450));
    expect(find.byType(ImageFiltered), findsNothing);
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.fit, BoxFit.cover);
    expect(image.alignment, const Alignment(0, -0.4));
  });
}
