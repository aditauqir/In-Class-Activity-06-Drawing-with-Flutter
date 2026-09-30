import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smiley_painter/main.dart';

void main() {
  testWidgets('SmileyApp renders CustomPaint, presets, and Mood slider', (WidgetTester tester) async {
    await tester.pumpWidget(const SmileyApp());

    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.textContaining('Mood:'), findsOneWidget);

    // Verify presets exist
    expect(find.widgetWithText(ActionChip, 'Happy'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, 'Sad'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, 'Wink vibe'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, 'Robot'), findsOneWidget);
  });

  testWidgets('Tapping Sad preset updates mood to Sad and changes label', (WidgetTester tester) async {
    await tester.pumpWidget(const SmileyApp());

    await tester.tap(find.text('Sad'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Sad (0.20)'), findsOneWidget);
  });

  testWidgets('Tapping Happy preset updates mood to Beaming', (WidgetTester tester) async {
    await tester.pumpWidget(const SmileyApp());

    await tester.tap(find.text('Sad'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Happy'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Beaming (0.85)'), findsOneWidget);
  });

  testWidgets('Fine-tune details toggle exposes Eye radius and gap sliders', (WidgetTester tester) async {
    await tester.pumpWidget(const SmileyApp());

    // Initially fine tuning sliders are hidden
    expect(find.text('Eye radius'), findsNothing);

    // Tap tune icon
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    expect(find.text('Eye radius'), findsOneWidget);
    expect(find.text('Eye gap'), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);
  });

  testWidgets('Undo button restores prior state', (WidgetTester tester) async {
    await tester.pumpWidget(const SmileyApp());

    await tester.tap(find.text('Sad'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Sad (0.20)'), findsOneWidget);

    // Tap Undo
    await tester.tap(find.byIcon(Icons.undo));
    await tester.pumpAndSettle();

    expect(find.textContaining('Beaming (0.85)'), findsOneWidget);
  });
}
