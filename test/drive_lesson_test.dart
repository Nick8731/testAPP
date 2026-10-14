import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/data/skill_data.dart';
import 'package:test_app/screens/drive_lesson_screen.dart';
import 'package:test_app/screens/skill_detail_screen.dart';
import 'package:test_app/widgets/drive_pose_diagram.dart';
import 'package:video_player/video_player.dart';

void main() {
  test('Four local character cutouts are compact RGBA PNG assets', () {
    for (final asset in driveCharacterAssets) {
      final file = File(asset);
      expect(file.existsSync(), isTrue);
      final bytes = file.readAsBytesSync();
      expect(bytes[25], 6, reason: 'PNG must preserve RGBA transparency');
      expect(bytes.length, lessThan(asset.contains('-v2') ? 1000000 : 160000));
    }
  });
  Future<void> open(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double scale = 1,
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final drive = badmintonSkills.firstWhere((skill) => skill.name == '平球');
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: SkillDetailScreen(skill: drive),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final context = tester.element(find.byType(DriveLessonScreen));
      for (final asset in driveCharacterAssets) {
        await precacheImage(
          ResizeImage(AssetImage(asset), width: 512),
          context,
        );
      }
    });
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, String key) async {
    final target = find.byKey(ValueKey(key));
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets(
    'Only Drive opens the illustrated pilot without a video player or progress writes',
    (tester) async {
      SharedPreferences.setMockInitialValues({'skill_progress_平球': 50});
      await open(tester);
      expect(find.byType(DriveLessonScreen), findsOneWidget);
      expect(find.byType(VideoPlayer), findsNothing);
      expect(find.text('平球｜圖解教學'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is RawImage && widget.image != null,
        ),
        findsWidgets,
      );
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getInt('skill_progress_平球'), 50);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Step controls are bounded and tolerate 80 repeated selections', (
    tester,
  ) async {
    await open(tester);
    final previous = tester.widget<OutlinedButton>(
      find.byKey(const ValueKey('drive-previous')),
    );
    expect(previous.onPressed, isNull);
    for (var i = 0; i < 80; i++) {
      final index = i % 4;
      await tapVisible(tester, 'drive-step-$index');
      expect(find.byKey(ValueKey('drive-diagram-$index')), findsOneWidget);
    }
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('drive-next')))
          .onPressed,
      isNull,
    );
    await tapVisible(tester, 'drive-previous');
    expect(find.text('3/4 · 向前擊球'), findsOneWidget);
    await tapVisible(tester, 'drive-next');
    expect(find.text('4/4 · 收拍回位'), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets(
    'Practice cap and self-check feedback work without leaving the page',
    (tester) async {
      await open(tester);
      for (var i = 0; i < 3; i++) {
        await tapVisible(tester, 'drive-record-set');
      }
      expect(find.text('本次完成 3/3 組'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const ValueKey('drive-record-set')),
            )
            .onPressed,
        isNull,
      );
      for (var i = 0; i < 3; i++) {
        await tapVisible(tester, 'drive-check-$i');
      }
      expect(find.textContaining('檢查完成！'), findsOneWidget);
      await tapVisible(tester, 'drive-check-1');
      expect(find.textContaining('不必一次全做到'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await open(tester);
      expect(find.text('本次完成 0/3 組'), findsOneWidget);
      expect(
        tester
            .widget<CheckboxListTile>(
              find.byKey(const ValueKey('drive-check-0')),
            )
            .value,
        isFalse,
      );
    },
  );

  for (final size in [const Size(320, 640), const Size(800, 1100)]) {
    testWidgets('Layout and scrolling remain usable at $size with 2x text', (
      tester,
    ) async {
      await open(tester, size: size, scale: 2);
      for (final key in ['drive-step-2', 'drive-record-set', 'drive-check-2']) {
        await tapVisible(tester, key);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Repeated opening and back navigation leave no pending work', (
    tester,
  ) async {
    final drive = badmintonSkills.firstWhere((skill) => skill.name == '平球');
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => SkillDetailScreen(skill: drive),
                ),
              ),
              child: const Text('開啟平球'),
            ),
          ),
        ),
      ),
    );
    for (var i = 0; i < 20; i++) {
      await tester.tap(find.text('開啟平球'));
      await tester.pumpAndSettle();
      await tapVisible(tester, 'drive-step-2');
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(DrivePoseDiagram), findsNothing);
      expect(tester.takeException(), isNull);
    }
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets(
    'Character detail dialog opens and closes repeatedly without pending work',
    (tester) async {
      await open(tester);
      for (var i = 0; i < 10; i++) {
        final enlarge = find.byKey(const ValueKey('drive-enlarge')).first;
        await tester.ensureVisible(enlarge);
        await tester.pumpAndSettle();
        await tester.tap(enlarge);
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsOneWidget);
        expect(find.byType(InteractiveViewer), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('drive-close-enlarged')));
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsNothing);
        expect(tester.takeException(), isNull);
      }
      expect(tester.binding.hasScheduledFrame, isFalse);
    },
  );
}
