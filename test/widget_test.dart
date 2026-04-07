// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:shop/core/app/app_scope.dart';
import 'package:shop/main.dart';

void main() {
  testWidgets('App boots into onboarding flow', (WidgetTester tester) async {
    await tester.pumpWidget(const AppScope(child: MyApp()));
    await tester.pumpAndSettle();

    expect(find.text('Later'), findsOneWidget);
    expect(find.textContaining('Find trusted products'), findsOneWidget);
  });
}
