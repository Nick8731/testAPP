import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'pose_angle_utils.dart';
import 'skill_analysis_result.dart';

class SliceAnalyzer {
  static SkillAnalysisResult analyze(
    Pose pose,
    BodySide side,
  ) {
    final elbow =
        PoseAngleUtils.elbowAngle(pose, side);

    final shoulder =
        PoseAngleUtils.shoulderAngle(pose, side);

    final wristHigh =
        PoseAngleUtils.wristAboveShoulder(
      pose,
      side,
    );

    final ready =
        elbow == null ? 0 : elbow >= 90 ? 85 : 68;

    final arm =
        elbow == null ? 0 : elbow >= 130 ? 88 : 70;

    final shoulderScore =
        shoulder == null ? 0 : shoulder >= 100 ? 85 : 70;

    final contact =
        wristHigh == true ? 88 : 68;

    final follow =
        ((arm + shoulderScore) / 2)
            .round();

    final total =
        (ready +
                arm +
                shoulderScore +
                contact +
                follow) ~/
            5;

    return SkillAnalysisResult(
      skillName: '切球',
      totalScore: total,
      scores: [
        SkillScoreItem(
          name: '架拍',
          score: ready,
        ),
        SkillScoreItem(
          name: '手臂伸展',
          score: arm,
        ),
        SkillScoreItem(
          name: '肩膀位置',
          score: shoulderScore,
        ),
        SkillScoreItem(
          name: '擊球點',
          score: contact,
        ),
        SkillScoreItem(
          name: '隨揮控制',
          score: follow,
        ),
      ],
      goodPoints: [
        if (contact >= 80)
          '擊球點高度良好',
      ],
      problems: [
        if (ready < 80)
          '架拍需要調整',
      ],
      suggestions: [
        if (ready < 80)
          '切球前維持完整架拍。',
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