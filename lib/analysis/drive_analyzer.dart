import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'pose_angle_utils.dart';
import 'skill_analysis_result.dart';

class DriveAnalyzer {
  static SkillAnalysisResult analyze(
    Pose pose,
    BodySide side,
  ) {
    final elbow =
        PoseAngleUtils.elbowAngle(pose, side);

    final shoulder =
        PoseAngleUtils.shoulderAngle(pose, side);

    final knee =
        PoseAngleUtils.kneeAngle(pose, side);

    final elbowScore =
        elbow == null ? 0 : elbow >= 100 ? 88 : 70;

    final heightScore =
        shoulder == null
            ? 0
            : shoulder >= 70 && shoulder <= 130
                ? 88
                : 70;

    final controlScore =
        elbow == null ? 0 : elbow <= 160 ? 85 : 70;

    final stabilityScore =
        knee == null ? 0 : knee >= 125 ? 85 : 70;

    final recoveryScore =
        ((elbowScore + stabilityScore) / 2)
            .round();

    final total =
        (
          elbowScore +
          heightScore +
          controlScore +
          stabilityScore +
          recoveryScore
        ) ~/
        5;

    return SkillAnalysisResult(
      skillName: '平球',
      totalScore: total,
      scores: [
        SkillScoreItem(
          name: '手肘位置',
          score: elbowScore,
        ),
        SkillScoreItem(
          name: '擊球高度',
          score: heightScore,
        ),
        SkillScoreItem(
          name: '手臂控制',
          score: controlScore,
        ),
        SkillScoreItem(
          name: '身體穩定',
          score: stabilityScore,
        ),
        SkillScoreItem(
          name: '回拍準備',
          score: recoveryScore,
        ),
      ],
      goodPoints: [
        if (elbowScore >= 80)
          '手肘位置良好',
        if (stabilityScore >= 80)
          '身體穩定度良好',
      ],
      problems: [
        if (elbowScore < 80)
          '手肘位置需要調整',
      ],
      suggestions: [
        if (elbowScore < 80)
          '平球擊球時保持手肘在適當高度。',
      ],
      details: {
        '手肘角度':
            elbow == null
                ? '--'
                : '${elbow.toStringAsFixed(1)}°',
      },
    );
  }
}