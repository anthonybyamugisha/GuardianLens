import 'package:child_agent/widgets/unsafe_warning.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('unsafe warning shows the safety message and confidence',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: UnsafeWarningDialog(score: 0.9)),
    );

    expect(find.text('Stop for a moment'), findsOneWidget);
    expect(find.text('Confidence: 90%'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'I understand'), findsOneWidget);
  });
}
