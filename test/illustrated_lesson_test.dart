import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/data/illustrated_lesson_data.dart';
import 'package:test_app/data/lesson_timing_data.dart';
import 'package:test_app/data/skill_data.dart';
import 'package:test_app/data/training_catalog.dart';
import 'package:test_app/screens/illustrated_lesson_screen.dart';
import 'package:test_app/screens/skill_detail_screen.dart';
import 'package:video_player/video_player.dart';

void main() {
  test('十一項教材皆有圖解與時機，新增發球不進入原本九項 AI 選单', () {
    expect(illustratedLessons.length, trainingSkills.length);
    expect(illustratedLessons.map((l) => l.key).toSet(), hasLength(13));
    expect(badmintonSkills, hasLength(9));
    for (final skill in trainingSkills) {
      final lesson = lessonFor(skill.name);
      final timing = lessonTiming[lesson.key]!;
      expect(skill.hasVideo, isFalse);
      expect(lesson.steps.length, greaterThanOrEqualTo(4));
      expect(timing.contact, isNotEmpty);
      expect(timing.relax, isNotEmpty);
      expect(timing.power, isNotEmpty);
      expect(timing.contactStep, lessThan(lesson.steps.length));
      for (var i = 0; i < lesson.steps.length; i++) {
        expect(lesson.steps[i].how, isNotEmpty);
        expect(lesson.steps[i].why, isNotEmpty);
        expect(lesson.steps[i].avoid, isNotEmpty);
        final file = File(lesson.assetAt(i));
        expect(file.existsSync(), isTrue, reason: file.path);
        final bytes = file.readAsBytesSync();
        expect(bytes[25], 6, reason: 'RGBA PNG required: ${file.path}');
        expect(
          bytes.length,
          lessThan(
            lesson.assetAt(i).contains('-v2') ||
                    lesson.key == 'net_kill' ||
                    lesson.key == 'push'
                ? 1000000
                : 200000,
          ),
        );
      }
    }
  });

  for (final lesson in illustratedLessons.where((l) => l.key != 'drive')) {
    testWidgets('${lesson.skillName}在小螢幕、大字體切換每一張、放大及返回', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 640),
              textScaler: TextScaler.linear(1.5),
            ),
            child: SkillDetailScreen(
              skill: trainingSkills.firstWhere(
                (s) => s.name == lesson.skillName,
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        final context = tester.element(find.byType(IllustratedLessonScreen));
        for (var i = 0; i < lesson.steps.length; i++) {
          await precacheImage(
            ResizeImage(AssetImage(lesson.assetAt(i)), width: 512),
            context,
          );
        }
      });
      await tester.pumpAndSettle();
      expect(find.byType(VideoPlayer), findsNothing);
      for (var loop = 0; loop < 3; loop++) {
        for (var i = 0; i < lesson.steps.length; i++) {
          final chip = find.byKey(ValueKey('lesson-step-$i'));
          await tester.ensureVisible(chip);
          await tester.tap(chip);
          await tester.pumpAndSettle();
          expect(
            find.text(
              '${i + 1}/${lesson.steps.length} · ${lesson.steps[i].title}',
            ),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        }
      }
      await tester.ensureVisible(find.byKey(const ValueKey('lesson-enlarge')));
      await tester.tap(find.byKey(const ValueKey('lesson-enlarge')));
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('lesson-close-enlarged')));
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });
  }
}
