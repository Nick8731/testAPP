// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test_app/main.dart';
import 'package:test_app/screens/tactical_academy_screen.dart';

void main() {
  testWidgets('SmashCoach app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const SmashCoachApp());

    expect(find.text('SmashCoach'), findsOneWidget);
    expect(find.text('AI教練'), findsOneWidget);
  });

  testWidgets('Tactical academy opens singles and doubles lessons', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: TacticalAcademyScreen()));
    expect(find.text('單打課程'), findsOneWidget);
    expect(find.text('四角拉吊'), findsOneWidget);

    await tester.tap(find.text('雙打戰術'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('雙打課程'), findsOneWidget);
    expect(find.text('前封後攻'), findsOneWidget);

    await tester.ensureVisible(find.text('前封後攻'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('tactic-doubles-front-back')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('戰術目的'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('場上執行順序'),
      300,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 40,
    );
    expect(find.text('場上執行順序'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('常見失誤'), 300);
    expect(find.text('常見失誤'), findsOneWidget);
  });
}
