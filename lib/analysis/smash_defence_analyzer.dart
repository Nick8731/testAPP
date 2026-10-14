import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'pose_angle_utils.dart';
import 'skill_analysis_result.dart';

class SmashDefenceAnalyzer {
  static SkillAnalysisResult analyze(
    Pose pose,
    BodySide side,
  ) {
    final knee =
        PoseAngleUtils.kneeAngle(pose, side);

    final elbow =
        PoseAngleUtils.elbowAngle(pose, side);

    final lowCenter =
        knee == null ? 0 : knee <= 160 ? 90 : 70;

    final kneeScore =
        knee == null ? 0 : knee >= 110 && knee <= 165 ? 90 : 70;

    final elbowScore =
        elbow == null ? 0 : elbow >= 80 && elbow <= 150 ? 85 : 70;

    final handScore =
        PoseAngleUtils.wristAboveElbow(
          pose,
          side,
        ) ==
        true
        ? 82
        : 72;

    final ready =
        ((lowCenter +
                kneeScore +
                elbowScore) /
            3)
            .round();

    final total =
        (lowCenter +
                kneeScore +
                elbowScore +
                handScore +
                ready) ~/
            5;

    return SkillAnalysisResult(
      skillName: '接殺',
      totalScore: total,
      scores: [
        SkillScoreItem(
          name: '重心',
          score: lowCenter,
        ),
        SkillScoreItem(
          name: '膝蓋彎曲',
          score: kneeScore,
        ),
        SkillScoreItem(
          name: '手肘位置',
          score: elbowScore,
        ),
        SkillScoreItem(
          name: '擊球手位置',
          score: handScore,
        ),
        SkillScoreItem(
          name: '防守準備',
          score: ready,
        ),
      ],
      goodPoints: [
        if (ready >= 80)
          '防守準備姿勢良好',
      ],
      problems: [
        if (lowCenter < 80)
          '重心偏高',
      ],
      suggestions: [
        if (lowCenter < 80)
          '接殺時降低重心並保持膝蓋彈性。',
      ],
      details: {},
    );
  }
}