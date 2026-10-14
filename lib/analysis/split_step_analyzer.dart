import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'pose_angle_utils.dart';
import 'skill_analysis_result.dart';

class SplitStepAnalyzer {
  static SkillAnalysisResult analyze(
    Pose pose,
    BodySide side,
  ) {
    final knee =
        PoseAngleUtils.kneeAngle(pose, side);

    final kneeScore =
        knee == null
            ? 0
            : knee >= 120 && knee <= 165
                ? 90
                : 70;

    final centerScore =
        kneeScore;

    final footStability =
        kneeScore >= 80 ? 88 : 70;

    final balance =
        ((kneeScore + footStability) / 2)
            .round();

    final ready =
        ((centerScore + balance) / 2)
            .round();

    final total =
        (
          kneeScore +
          centerScore +
          footStability +
          balance +
          ready
        ) ~/
        5;

    return SkillAnalysisResult(
      skillName: '啟動步',
      totalScore: total,
      scores: [
        SkillScoreItem(
          name: '膝蓋彎曲',
          score: kneeScore,
        ),
        SkillScoreItem(
          name: '重心高度',
          score: centerScore,
        ),
        SkillScoreItem(
          name: '腳步穩定',
          score: footStability,
        ),
        SkillScoreItem(
          name: '身體平衡',
          score: balance,
        ),
        SkillScoreItem(
          name: '啟動準備',
          score: ready,
        ),
      ],
      goodPoints: [
        if (ready >= 80)
          '啟動準備良好',
      ],
      problems: [
        if (kneeScore < 80)
          '膝蓋彎曲不足',
      ],
      suggestions: [
        if (kneeScore < 80)
          '啟動步時保持膝蓋彈性並降低重心。',
      ],
      details: {},
    );
  }
}