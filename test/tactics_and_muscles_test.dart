import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/data/tactics_data.dart';
import 'package:test_app/data/tactic_sequences.dart';
import 'package:test_app/data/muscle_data.dart';
import 'package:test_app/data/illustrated_lesson_data.dart';
import 'package:test_app/data/muscle_training_data.dart';
import 'package:test_app/screens/muscle_detail_screen.dart';
import 'package:test_app/widgets/tactic_animation.dart';
import 'package:test_app/widgets/lesson_muscle_link.dart';
import 'package:test_app/data/training_catalog.dart';

void main() {
  testWidgets('技術課程入口逐項開啟同名肌肉教材', (tester) async {
    for (final skill in trainingSkills) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LessonMuscleLink(skillName: skill.name)),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('lesson-open-muscles')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<MuscleDetailScreen>(find.byType(MuscleDetailScreen))
            .skill
            .skillName,
        skill.name,
      );
      expect(find.textContaining('建置中'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    }
  });
  test('全部13戰術有不同的逐拍資料，接觸點與下一拍銜接一致', () {
    expect(
      tacticSequences.keys.toSet(),
      badmintonTactics.map((t) => t.id).toSet(),
    );
    for (final tactic in badmintonTactics) {
      final plan = tacticSequences[tactic.id]!;
      expect(plan.beats.length, greaterThanOrEqualTo(3));
      expect(plan.setup, isNotEmpty);
      expect(plan.practice, isNotEmpty);
      expect(plan.check, isNotEmpty);
      expect(plan.progression, isNotEmpty);
      for (var i = 0; i < plan.beats.length; i++) {
        final beat = plan.beats[i], count = beat.start.length;
        expect(count, tactic.mode == TacticMode.singles ? 2 : 4);
        expect(beat.end.length, count);
        expect(beat.shuttleStart, beat.start[beat.hitter]);
        expect(beat.shuttleEnd, beat.end[beat.receiver]);
        expect(beat.shuttleStart.dx < .5, beat.shuttleEnd.dx > .5);
        for (final positions in [beat.start, beat.end]) {
          for (var p = 0; p < count; p++) {
            expect(positions[p].dx, greaterThan(0));
            expect(positions[p].dx, lessThan(1));
            expect(positions[p].dy, greaterThan(0));
            expect(positions[p].dy, lessThan(1));
            expect(positions[p].dx < .5, p < (count == 4 ? 2 : 1));
          }
        }
        if (i > 0) {
          expect(beat.start, plan.beats[i - 1].end);
          expect(beat.hitter, plan.beats[i - 1].receiver);
          expect(beat.shuttleStart, plan.beats[i - 1].shuttleEnd);
        }
        if (count == 4) {
          for (var sample = 0; sample <= 20; sample++) {
            for (final team in [0, 2]) {
              final a = Offset.lerp(
                beat.start[team],
                beat.end[team],
                sample / 20,
              )!;
              final b = Offset.lerp(
                beat.start[team + 1],
                beat.end[team + 1],
                sample / 20,
              )!;
              final separation = Offset(
                (a.dx - b.dx) * 13.4,
                (a.dy - b.dy) * 6.1,
              ).distance;
              expect(
                separation,
                greaterThan(.55),
                reason: '${tactic.id} beat $i paths overlap',
              );
            }
          }
        }
      }
    }
    final serve = tacticSequences['doubles-serve-third-shot']!.beats.first;
    expect(serve.shuttleStart.dx, lessThan(.5 - 1.98 / 13.4));
    expect(serve.shuttleStart.dy, greaterThan(.5));
    expect(serve.shuttleEnd.dx, greaterThan(.5 + 1.98 / 13.4));
    expect(serve.shuttleEnd.dx, lessThan(1 - .76 / 13.4));
    expect(serve.shuttleEnd.dy, lessThan(.5));
    expect(
      tacticSequences['singles-backhand-pressure']!.beats[2].shuttleEnd.dy,
      greaterThan(.5),
    );
  });

  for (final tactic in badmintonTactics) {
    testWidgets('${tactic.title}可逐拍、暫停、拖曳，播完與離開不留下背景動畫', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final plan = tacticSequences[tactic.id]!;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TacticAnimation(sequence: plan),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      for (var i = 1; i < plan.beats.length; i++) {
        await tester.tap(find.byKey(const ValueKey('tactic-next')));
        await tester.pumpAndSettle();
        expect(
          find.text('${i + 1}/${plan.beats.length} · ${plan.beats[i].caption}'),
          findsOneWidget,
        );
      }
      expect(
        tester
            .widget<OutlinedButton>(find.byKey(const ValueKey('tactic-next')))
            .onPressed,
        isNull,
      );
      await tester.tap(find.text('從頭播放'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.byKey(const ValueKey('tactic-play')));
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      final scrub = tester.widget<Slider>(
        find.byKey(const ValueKey('tactic-scrub')),
      );
      scrub.onChanged!(.5);
      await tester.pumpAndSettle();
      expect(
        tester.widget<Slider>(find.byKey(const ValueKey('tactic-scrub'))).value,
        .5,
      );
      await tester.tap(find.text('從頭播放'));
      await tester.pump();
      for (var i = 0; i < plan.beats.length + 1; i++) {
        await tester.pump(const Duration(milliseconds: 2500));
      }
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(
        find.text(
          '${plan.beats.length}/${plan.beats.length} · ${plan.beats.last.caption}',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
    });
  }
  test('13項肌群教材精確對應57張分解圖，全部含功能角色與可選強化', () {
    expect(muscleSkills, hasLength(13));
    var phases = 0;
    for (final skill in muscleSkills) {
      final lesson = lessonFor(skill.skillName);
      expect(skill.isAvailable, isTrue);
      expect(skill.videoPath, isEmpty);
      expect(skill.contactSeconds, isEmpty);
      expect(skill.phaseOffsets, isEmpty);
      expect(skill.phases.length, lesson.steps.length);
      for (var i = 0; i < skill.phases.length; i++) {
        final phase = skill.phases[i];
        phases++;
        expect(File(lesson.assetAt(i)).existsSync(), isTrue);
        expect(phase.primaryMuscles, isNotEmpty);
        expect(phase.secondaryMuscles, isNotEmpty);
        expect(phase.stabilizingMuscles, isNotEmpty);
        expect(phase.forceDescription, contains('肌群角色'));
        expect(phase.mistakes, isNotEmpty);
      }
      for (final key in muscleExerciseKeys[skill.skillName]!) {
        final exercise = muscleExercises[key]!;
        expect(exercise.how, isNotEmpty);
        expect(exercise.dose, isNotEmpty);
        expect(exercise.caution, isNotEmpty);
        expect(exercise.purpose, isNotEmpty);
      }
    }
    expect(phases, 57);
  });
  for (final skill in muscleSkills) {
    testWidgets('${skill.skillName}肌肉頁320寬大字體切換全部階段與強化說明', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: MuscleDetailScreen(skill: skill),
        ),
      );
      await tester.pumpAndSettle();
      for (var i = 0; i < skill.phases.length; i++) {
        final target = find.byKey(ValueKey('muscle-phase-$i'));
        tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .jumpTo(0);
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          target,
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await Scrollable.ensureVisible(tester.element(target), alignment: .25);
        await tester.pumpAndSettle();
        await tester.tap(target);
        await tester.pumpAndSettle();
        expect(tester.widget<ChoiceChip>(target).selected, isTrue);
        expect(tester.takeException(), isNull);
      }
      final key = muscleExerciseKeys[skill.skillName]!.first;
      final exerciseTitle = find.text(muscleExercises[key]!.title);
      await tester.scrollUntilVisible(
        exerciseTitle,
        300,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 80,
      );
      await tester.pumpAndSettle();
      await Scrollable.ensureVisible(
        tester.element(exerciseTitle),
        alignment: .25,
      );
      await tester.pumpAndSettle();
      await tester.tap(exerciseTitle);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
    });
  }
}
