import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'pose_angle_utils.dart';
import 'skill_analysis_result.dart';

class NetShotAnalyzer {
  static SkillAnalysisResult analyze(
    Pose pose,
    BodySide side,
  ) {
    final knee =
        PoseAngleUtils.kneeAngle(pose, side);

    final elbow =
        PoseAngleUtils.elbowAngle(pose, side);

    final lowCenter =
        knee == null ? 0 : knee <= 155 ? 90 : 70;

    final arm =
        elbow == null ? 0 : elbow >= 120 ? 88 : 70;

    final hand =
        PoseAngleUtils.wristAboveElbow(
          pose,
          side,
        ) ==
        true
        ? 85
        : 70;

    final kneeScore =
        knee == null ? 0 : knee <= 160 ? 88 : 70;

    final stability =
        ((lowCenter + kneeScore) / 2)
            .round();

    final total =
        (lowCenter +
                arm +
                hand +
                kneeScore +
                stability) ~/
            5;

    return SkillAnalysisResult(
      skillName: '放網',
      totalScore: total,
      scores: [
        SkillScoreItem(
          name: '重心降低',
          score: lowCenter,
        ),
        SkillScoreItem(
          name: '手臂伸展',
          score: arm,
        ),
        SkillScoreItem(
          name: '擊球手位置',
          score: hand,
        ),
        SkillScoreItem(
          name: '膝蓋彎曲',
          score: kneeScore,
        ),
        SkillScoreItem(
          name: '身體穩定',
          score: stability,
        ),
      ],
      goodPoints: [
        if (lowCenter >= 80)
          '重心控制良好',
      ],
      problems: [
        if (lowCenter < 80)
          '重心偏高',
      ],
      suggestions: [
        if (lowCenter < 80)
          '放網時降低重心並保持前腳穩定。',
      ],
      details: {},
    );
  }
}