import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:octapulsev2/features/home/presentation/pages/main_nav_screen.dart';

void main() {
  testWidgets('MainNavScreen renders custom asset icons', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: MainNavScreen())),
    );

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == 'assets/images/glove.png',
      ),
      findsOneWidget,
    );

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == 'assets/images/belt.png',
      ),
      findsOneWidget,
    );
  });
}
