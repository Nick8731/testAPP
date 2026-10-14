import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/data/muscle_data.dart';
import 'package:test_app/screens/muscle_detail_screen.dart';
import 'package:test_app/screens/muscle_training_screen.dart';

void main() {
  test('高遠球與殺球具備完整且連續的肌肉階段資料', () {
    final clear = muscleSkills.firstWhere(
      (skill) => skill.englishName == 'Clear',
    );
    final smash = muscleSkills.firstWhere(
      (skill) => skill.englishName == 'Smash',
    );

    expect(clear.phases, hasLength(6));
    expect(smash.phases, hasLength(7));
    expect(muscleSkills, hasLength(12));
    expect(muscleSkills.where((skill) => !skill.isAvailable), isEmpty);
    expect(clear.contactSeconds, isEmpty);
    expect(smash.contactSeconds, isEmpty);
    expect(clear.phaseOffsets, isEmpty);
    expect(smash.phaseOffsets, isEmpty);

    for (final skill in [clear, smash]) {
      expect(skill.videoPath, isEmpty);
      expect(skill.forceChain, isNotEmpty);
      expect(skill.phases.first.startSecond, 0);
      for (var index = 0; index < skill.phases.length; index++) {
        final phase = skill.phases[index];
        expect(phase.endSecond, greaterThan(phase.startSecond));
        expect(phase.primaryMuscles, isNotEmpty);
        expect(phase.secondaryMuscles, isNotEmpty);
        expect(phase.stabilizingMuscles, isNotEmpty);
        expect(phase.forceDescription, isNotEmpty);
        expect(phase.mistakes, isNotEmpty);
        expect(phase.aiIssueTags, isNotEmpty);
        if (index > 0) {
          expect(phase.startSecond, skill.phases[index - 1].endSecond);
        }
      }
    }
  });

  testWidgets('肌肉與發力首頁十一項皆可用', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: MuscleTrainingScreen()));

    expect(find.text('肌肉與發力'), findsOneWidget);
    expect(find.text('6 個動作階段｜Clear'), findsOneWidget);
    expect(find.text('7 個動作階段｜Smash'), findsOneWidget);
    expect(find.text('建置中'), findsNothing);
    await tester.scrollUntilVisible(
      find.textContaining('不屬於醫療建議'),
      300,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 40,
    );
    expect(find.textContaining('不屬於醫療建議'), findsOneWidget);
  });

  testWidgets('高遠球詳情顯示同步教學所需內容', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final clear = muscleSkills.firstWhere(
      (skill) => skill.englishName == 'Clear',
    );

    await tester.pumpWidget(
      MaterialApp(home: MuscleDetailScreen(skill: clear)),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('當前階段'), findsOneWidget);
    expect(find.text('準備'), findsWidgets);
    expect(find.text('人體肌肉示意'), findsOneWidget);
    expect(find.text('主要肌群'), findsWidgets);
    expect(find.text('輔助肌群'), findsWidgets);
    expect(find.text('穩定肌群'), findsWidgets);
    final pageList = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('發力說明'),
      300,
      scrollable: pageList,
    );
    expect(find.text('發力說明'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('常見錯誤'),
      300,
      scrollable: pageList,
    );
    expect(find.text('常見錯誤'), findsOneWidget);
  });
}
