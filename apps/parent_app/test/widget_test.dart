import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parent_app/main.dart';
import 'package:parent_app/theme.dart';

void main() {
  tearDown(() {
    AppThemeMode.notifier.value = ThemeMode.system;
  });

  testWidgets('GuardianLens shows the welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GuardianLensApp());

    expect(find.textContaining('GuardianLens', findRichText: true), findsWidgets);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });

  testWidgets('Navigates to signup screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GuardianLensApp());

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Create Account'), findsWidgets);
    expect(find.textContaining('Join GuardianLens'), findsWidgets);
  });

  testWidgets('Login shows a validation error for an invalid email', (WidgetTester tester) async {
    await tester.pumpWidget(const GuardianLensApp());

    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'not-an-email');
    final loginButton = find.text('Log In');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid email address.'), findsOneWidget);
  });

  testWidgets('Renders in dark mode and reflects the selected theme', (WidgetTester tester) async {
    AppThemeMode.notifier.value = ThemeMode.dark;
    await tester.pumpWidget(const GuardianLensApp());
    await tester.pumpAndSettle();

    final context = tester.element(find.text('Get Started'));
    expect(Theme.of(context).brightness, Brightness.dark);
  });
}