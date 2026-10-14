import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:test_app/analysis/analysis_quality.dart';
import 'package:test_app/analysis/pose_angle_utils.dart';
import 'package:test_app/analysis/skill_analyzer_factory.dart';
import 'package:test_app/data/skill_data.dart';
import 'package:test_app/widgets/progress_explanation.dart';

Pose sample({
  double likelihood = .95,
  bool missing = false,
  bool invalid = false,
}) {
  final points = <PoseLandmarkType, PoseLandmark>{};
  final coords = <PoseLandmarkType, Offset>{
    PoseLandmarkType.rightShoulder: const Offset(100, 100),
    PoseLandmarkType.rightElbow: const Offset(110, 65),
    PoseLandmarkType.rightWrist: const Offset(120, 20),
    PoseLandmarkType.rightHip: const Offset(100, 180),
    PoseLandmarkType.rightKnee: const Offset(115, 250),
    PoseLandmarkType.rightAnkle: const Offset(100, 310),
  };
  for (final entry in coords.entries) {
    if (missing && entry.key == PoseLandmarkType.rightWrist) continue;
    points[entry.key] = PoseLandmark(
      type: entry.key,
      x: invalid ? double.nan : entry.value.dx,
      y: entry.value.dy,
      z: 0,
      likelihood: likelihood,
    );
  }
  return Pose(landmarks: points);
}

void main() {
  test('可見性守門不評缺點、低可見性或非有限座標', () {
    expect(AnalysisQuality.usable(sample(), BodySide.right), isTrue);
    expect(
      AnalysisQuality.usable(sample(missing: true), BodySide.right),
      isFalse,
    );
    expect(
      AnalysisQuality.usable(sample(likelihood: .1), BodySide.right),
      isFalse,
    );
    expect(
      AnalysisQuality.usable(sample(invalid: true), BodySide.right),
      isFalse,
    );
    expect(AnalysisQuality.usable(sample(), BodySide.left), isFalse);
  });
  for (final skill in badmintonSkills) {
    test('${skill.name}同一組骨架及持拍側重複100次結果一致', () {
      final pose = sample();
      final first = SkillAnalyzerFactory.analyze(
        skillName: skill.name,
        englishName: skill.englishName,
        pose: pose,
        side: BodySide.right,
      )!;
      for (var i = 0; i < 100; i++) {
        final result = SkillAnalyzerFactory.analyze(
          skillName: skill.name,
          englishName: skill.englishName,
          pose: pose,
          side: BodySide.right,
        )!;
        expect(result.totalScore, first.totalScore);
        expect(
          result.scores.map((s) => '${s.name}:${s.score}'),
          first.scores.map((s) => '${s.name}:${s.score}'),
        );
        expect(result.problems, first.problems);
        expect(result.details, first.details);
      }
      final annotated = AnalysisQuality.describe(
        first,
        side: BodySide.right,
        mode: '單張姿勢',
        second: 1.25,
      );
      expect(annotated.totalScore, first.totalScore);
      expect(annotated.details['評分版本'], AnalysisQuality.version);
      expect(annotated.details['評分影格秒數'], '1.250');
      expect(first.details.containsKey('評分版本'), isFalse);
    });
  }
  testWidgets('趨勢說明在小螢幕大字體可閱讀', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: const Scaffold(
          body: SingleChildScrollView(child: ProgressExplanation()),
        ),
      ),
    );
    expect(find.text('進步趨勢怎麼看？'), findsOneWidget);
    expect(find.textContaining('最新減上一筆'), findsOneWidget);
    expect(find.textContaining('不是完整揮拍評分'), findsOneWidget);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
