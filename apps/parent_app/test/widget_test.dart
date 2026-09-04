import 'package:flutter_test/flutter_test.dart';

import 'package:parent_app/main.dart';

void main() {
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
}