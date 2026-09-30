import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smiley_painter/main.dart';

void main() {
  testWidgets('SmileyApp renders CustomPaint and Slider', (WidgetTester tester) async {
    await tester.pumpWidget(const SmileyApp());

    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.textContaining('Mood:'), findsOneWidget);
  });
}
