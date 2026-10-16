import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/data/beginner_course_data.dart';
import 'package:test_app/data/training_catalog.dart';
import 'package:test_app/screens/beginner_grip_screen.dart';
import 'package:test_app/screens/skills_screen.dart';
import 'package:test_app/screens/learning_screen.dart';
import 'package:test_app/services/progress_service.dart';

Future<void> reveal(WidgetTester tester, Finder target) async {
  final scroll = find.byType(Scrollable).first;
  tester.state<ScrollableState>(scroll).position.jumpTo(0);
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    target,
    300,
    scrollable: scroll,
    maxScrolls: 100,
  );
  await Scrollable.ensureVisible(tester.element(target), alignment: .25);
  await tester.pumpAndSettle();
}

void main() {
  test('入門三段與兩張近景，不擴張AI或十一項肌肉動作清單', () {
    expect(gripLessonSteps, hasLength(3));
    expect(beginnerGripAssets, hasLength(2));
    for (final asset in beginnerGripAssets) {
      final file = File(asset);
      expect(file.existsSync(), isTrue);
      final bytes = file.readAsBytesSync();
      expect(bytes[25], anyOf(2, 6));
      expect(bytes.length, lessThan(2000000));
    }
    expect(trainingSkills, hasLength(13));
    expect(trainingSkills.any((s) => s.name == beginnerCourseName), isFalse);
    expect(gripLessonSteps[1].scope, contains('不能直接套用'));
  });
  testWidgets('搜尋正拍反拍握拍換握均找到入門，已讀時不越界', (tester) async {
    SharedPreferences.setMockInitialValues({
      'skill_progress_$beginnerCourseName': 100,
    });
    await tester.pumpWidget(const MaterialApp(home: SkillsScreen()));
    await tester.pumpAndSettle();
    for (final query in ['握拍', '正拍', '反拍', '換握']) {
      await reveal(tester, find.byKey(const ValueKey('training-search')));
      await tester.enterText(
        find.byKey(const ValueKey('training-search')),
        query,
      );
      await tester.pumpAndSettle();
      await reveal(
        tester,
        find.byKey(const ValueKey('training-beginner-grips')),
      );
      expect(find.textContaining('教材已讀（本機）'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets('入門分類可打開握拍課，初始不自动寫進度', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: SkillsScreen()));
    await tester.pumpAndSettle();
    await reveal(tester, find.text('入門與步法').first);
    await tester.tap(find.text('入門與步法').first);
    await tester.pumpAndSettle();
    await reveal(tester, find.byKey(const ValueKey('training-beginner-grips')));
    await tester.tap(find.byKey(const ValueKey('training-beginner-grips')));
    await tester.pumpAndSettle();
    expect(find.byType(BeginnerGripScreen), findsOneWidget);
    expect(await ProgressService.getProgress(beginnerCourseName), 0);
    expect(tester.takeException(), isNull);
  });
  testWidgets('握拍小螢幕大字體切換、放大、手動記已讀', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: const BeginnerGripScreen(),
      ),
    );
    await tester.runAsync(() async {
      for (final asset in beginnerGripAssets) {
        await precacheImage(
          ResizeImage(AssetImage(asset), width: 512),
          tester.element(find.byType(BeginnerGripScreen)),
        );
      }
    });
    await tester.pumpAndSettle();
    expect(await ProgressService.getProgress(beginnerCourseName), 0);
    for (var i = 0; i < 3; i++) {
      await reveal(tester, find.byKey(ValueKey('grip-step-$i')));
      await tester.tap(find.byKey(ValueKey('grip-step-$i')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ChoiceChip>(find.byKey(ValueKey('grip-step-$i')))
            .selected,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    }
    await reveal(tester, find.byKey(const ValueKey('grip-enlarge-0')));
    await tester.tap(find.byKey(const ValueKey('grip-enlarge-0')));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('grip-close-enlarged')));
    await tester.pumpAndSettle();
    await reveal(tester, find.byKey(const ValueKey('grip-mark-read')));
    await tester.tap(find.byKey(const ValueKey('grip-mark-read')));
    await tester.pumpAndSettle();
    expect(await ProgressService.getProgress(beginnerCourseName), 100);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
  testWidgets('我的學習包括入門讀取及總數14', (tester) async {
    SharedPreferences.setMockInitialValues({
      'skill_progress_$beginnerCourseName': 100,
    });
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: const LearningScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1 / 14 教材已讀'), findsOneWidget);
    await reveal(tester, find.byKey(const ValueKey('training-beginner-grips')));
    expect(find.textContaining('教材已讀（本機）'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
