import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/data/training_catalog.dart';
import 'package:test_app/data/illustrated_lesson_data.dart';
import 'package:test_app/data/shot_route_data.dart';
import 'package:test_app/screens/skills_screen.dart';
import 'package:test_app/screens/illustrated_lesson_screen.dart';
import 'package:test_app/services/progress_service.dart';
import 'package:test_app/screens/ai_coach_screen.dart';
import 'package:test_app/data/skill_data.dart';

void main() {
  testWidgets('教學入口預選原有AI技術，但不接受新增發球作為AI分析項目', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final clear = badmintonSkills.firstWhere((s) => s.name == '高遠球');
    await tester.pumpWidget(
      MaterialApp(home: AiCoachScreen(initialSkill: clear)),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<AiCoachScreen>(find.byType(AiCoachScreen))
          .initialSupportedSkill,
      clear,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      MaterialApp(
        home: AiCoachScreen(
          initialSkill: trainingSkills.firstWhere((s) => s.name == '反手短發球'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<AiCoachScreen>(find.byType(AiCoachScreen))
          .initialSupportedSkill,
      isNull,
    );
    expect(find.text('選擇影片來源'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  Future<void> reveal(WidgetTester tester, Finder target) async {
    final scrolling = find
        .descendant(
          of: find.byKey(const ValueKey('training-scroll')),
          matching: find.byType(Scrollable),
        )
        .first;
    tester.state<ScrollableState>(scrolling).position.jumpTo(0);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      target,
      300,
      scrollable: scrolling,
      maxScrolls: 100,
    );
    await tester.pumpAndSettle();
  }

  test('每課只屬一個情境分類，問題入口只指向存在課程，球路不混淆', () {
    final names = trainingSkills.map((s) => s.name).toSet();
    final grouped = trainingGroups.expand((g) => g.skills).toList();
    expect(grouped, hasLength(13));
    expect(grouped.toSet(), names);
    for (final p in trainingProblems) {
      expect(p.explanation, isNotEmpty);
      for (final s in p.skills) {
        expect(names.contains(s), isTrue);
      }
    }
    for (final lesson in illustratedLessons) {
      final r = shotRoutes[lesson.key]!;
      expect(r.origin.$2, greaterThan(.5));
      expect(
        r.target.$2,
        lesson.key == 'split' ? greaterThan(.5) : lessThan(.5),
      );
      if (r.serve) {
        expect(r.origin.$1, greaterThan(.5));
        expect(r.target.$1, lessThan(.5));
        expect(r.target.$2, lessThan(.5 - 1.98 / 13.4));
      }
    }
    expect(shotRoutes['slice']!.purpose, contains('吊球的一種變化'));
    expect(shotRoutes['defence']!.caution, contains('僅代表反手擋網'));
  });

  testWidgets('搜尋問題能找到課程，問題選擇與發球分類能取消', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: SkillsScreen()));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('training-search')),
      '打不遠',
    );
    await tester.pumpAndSettle();
    await reveal(tester, find.byKey(const ValueKey('training-course-高遠球')));
    expect(find.byKey(const ValueKey('training-course-高遠球')), findsOneWidget);
    expect(find.byKey(const ValueKey('training-course-殺球')), findsNothing);
    await reveal(tester, find.byKey(const ValueKey('training-search')));
    await tester.enterText(find.byKey(const ValueKey('training-search')), '');
    await tester.tap(find.byKey(const ValueKey('training-by-problem')));
    await tester.pumpAndSettle();
    await reveal(tester, find.byKey(const ValueKey('problem-1')));
    await tester.tap(find.byKey(const ValueKey('problem-1')));
    await tester.pumpAndSettle();
    await reveal(tester, find.byKey(const ValueKey('training-course-吊球')));
    expect(find.byKey(const ValueKey('training-course-吊球')), findsOneWidget);
    expect(find.byKey(const ValueKey('training-course-切球')), findsOneWidget);
    expect(find.byKey(const ValueKey('training-course-高遠球')), findsNothing);
    await reveal(tester, find.text('取消分類／問題篩選'));
    await tester.tap(find.text('取消分類／問題篩選'));
    await tester.pumpAndSettle();
    await reveal(tester, find.byKey(const ValueKey('training-by-area')));
    await tester.tap(find.byKey(const ValueKey('training-by-area')));
    await tester.pumpAndSettle();
    await reveal(tester, find.text('發球').first);
    await tester.tap(find.text('發球').first);
    await tester.pumpAndSettle();
    await reveal(tester, find.byKey(const ValueKey('training-course-反手短發球')));
    expect(find.byKey(const ValueKey('training-course-反手短發球')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('training-course-正手高遠發球')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('training-course-高遠球')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('320寬2倍字體的分類首頁不溢位', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const SkillsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await reveal(tester, find.text('先知道的三件事'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('教材已讀需明確操作且全部看過，不會自動記成掌握', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final lesson = lessonFor('吊球');
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(home: IllustratedLessonScreen(lesson: lesson)),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('lesson-mark-read')))
          .onPressed,
      isNull,
    );
    expect(await ProgressService.getProgress('吊球'), 0);
    for (var i = 1; i < lesson.steps.length; i++) {
      await tester.ensureVisible(find.byKey(ValueKey('lesson-step-$i')));
      await tester.tap(find.byKey(ValueKey('lesson-step-$i')));
      await tester.pumpAndSettle();
    }
    expect(await ProgressService.getProgress('吊球'), 0);
    await tester.ensureVisible(find.byKey(const ValueKey('lesson-mark-read')));
    await tester.tap(find.byKey(const ValueKey('lesson-mark-read')));
    await tester.pumpAndSettle();
    expect(await ProgressService.getProgress('吊球'), 100);
    expect(find.text('已記錄教材已讀'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
