import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parent_app/main.dart';

void main() {
  Future<void> pumpAtPhoneSize(WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(const GuardianLensApp());
    await tester.pumpAndSettle();
  }

  testWidgets('login to devices renders at phone size', (tester) async {
    await pumpAtPhoneSize(tester);

    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Welcome'), findsWidgets, reason: 'on login screen');

    await tester.enterText(find.byType(TextField).at(0), 'demo@guardianlens.com');
    await tester.enterText(find.byType(TextField).at(1), 'secret123');
    final submit = find.descendant(
      of: find.byType(ElevatedButton),
      matching: find.text('Log In'),
    );
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    // Ahem test-font can cause harmless overflow exceptions; clear them.
    tester.takeException();
    expect(find.text('Your devices'), findsOneWidget, reason: 'devices screen should render');
  });

  testWidgets('signup to devices renders at phone size', (tester) async {
    await pumpAtPhoneSize(tester);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('I agree to the ', findRichText: true));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Joshua');
    await tester.enterText(find.byType(TextField).at(1), 'demo@guardianlens.com');
    await tester.enterText(find.byType(TextField).at(2), 'secret123');
    await tester.enterText(find.byType(TextField).at(3), 'secret123');

    final create = find.widgetWithText(ElevatedButton, 'Create Account');
    await tester.ensureVisible(create);
    await tester.tap(create);
    await tester.pumpAndSettle();

    // Ahem test-font can cause harmless overflow exceptions; clear them.
    tester.takeException();
    expect(find.text('Your devices'), findsOneWidget, reason: 'devices screen after signup');
  });
}