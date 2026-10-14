import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/main.dart';
import 'package:test_app/screens/profile_screen.dart';
import 'package:test_app/screens/skills_screen.dart';
import 'package:test_app/screens/ai_coach_screen.dart';
import 'package:test_app/screens/tactical_academy_screen.dart';
import 'package:test_app/screens/muscle_training_screen.dart';
import 'package:test_app/services/auth_service.dart';
import 'package:test_app/theme/app_theme.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets('Four home entries are visible and open their existing pages', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(theme: buildAppTheme(), home: const HomePage()),
    );
    for (final entry in {
      '技術訓練': SkillsScreen,
      'AI 動作分析': AiCoachScreen,
      '戰術學院': TacticalAcademyScreen,
      '肌肉與發力': MuscleTrainingScreen,
    }.entries) {
      final target = find.byKey(ValueKey('home-${entry.key}'));
      expect(target.hitTestable(), findsOneWidget);
      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(find.byType(entry.value), findsOneWidget);
      Navigator.of(tester.element(find.byType(entry.value))).pop();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets('Bottom navigation switches all four tabs', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const SmashCoachApp());
    await tester.pumpAndSettle();
    for (final label in ['學習', 'AI教練', '我的', '首頁']) {
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    expect(find.text('SmashCoach').hitTestable(), findsOneWidget);
  });
  for (final scale in [1.0, 2.0]) {
    testWidgets('Home and profile fit 320px at text scale $scale', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      for (final page in [const HomePage(), const ProfileScreen()]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: MediaQuery(
              data: MediaQueryData(
                size: const Size(320, 640),
                textScaler: TextScaler.linear(scale),
              ),
              child: page,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.drag(
          find.byType(Scrollable).first,
          const Offset(0, -1700),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }
  testWidgets('Main entry opens existing technical curriculum', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: buildAppTheme(), home: const HomePage()),
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('home-start-learning')),
    );
    await tester.tap(find.byKey(const ValueKey('home-start-learning')));
    await tester.pumpAndSettle();
    expect(find.byType(SkillsScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Profile immediately reflects member updates without reload', (
    tester,
  ) async {
    final notifier = AuthService.instance.currentUserChanges;
    final previous = notifier.value;
    addTearDown(() => notifier.value = previous);
    notifier.value = null;
    await tester.pumpWidget(
      MaterialApp(theme: buildAppTheme(), home: const ProfileScreen()),
    );
    expect(find.text('尚未登入'), findsOneWidget);
    notifier.value = const AppUser(
      id: 999,
      name: '測試會員',
      email: 'sample@example.invalid',
    );
    await tester.pump();
    expect(find.text('測試會員'), findsOneWidget);
    expect(find.text('已登入'), findsOneWidget);
    notifier.value = null;
    await tester.pump();
    expect(find.text('尚未登入'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
