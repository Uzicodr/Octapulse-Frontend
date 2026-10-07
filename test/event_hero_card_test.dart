import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octapulsev2/data/models/event.dart';
import 'package:octapulsev2/ui/core/widgets/fight_widgets.dart';

// Fighter portraits load through cached_network_image, whose cache needs platform channels that
// never answer in widget tests, so the card is checked with both corners still TBA. Portraits are
// sized to the corner, so they don't change the layout being checked.
void main() {
  final event = EventSummary(
    id: 'e1',
    slug: 'ufc-335',
    name: 'UFC 335: A Very Long Event Name That Has To Be Cut Off Somewhere',
    status: 'scheduled',
    startsAt: DateTime.now().add(const Duration(days: 3)),
    city: 'Las Vegas',
    country: 'USA',
  );

  for (final width in [300.0, 360.0]) {
    testWidgets('event card lays out at width $width', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              child: EventHeroCard(event: event, red: null, blue: null, onTap: () {}),
            ),
          ),
        ),
      ));
      expect(tester.takeException(), isNull);
      expect(find.text('VS'), findsOneWidget);
      expect(find.text('TBA'), findsNWidgets(2));
      expect(find.text('View Event'), findsOneWidget);
    });
  }
}
