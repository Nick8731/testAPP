import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'pose_angle_utils.dart';
import 'skill_analysis_result.dart';

class DropAnalyzer {
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

    final knee =
        PoseAngleUtils.kneeAngle(pose, side);

    final ready =
        elbow == null ? 0 : elbow >= 90 ? 85 : 70;

    final control =
        elbow == null ? 0 : elbow <= 165 ? 88 : 72;

    final contact =
        wristHigh == true ? 88 : 70;

    final stability =
        knee == null ? 0 : knee >= 120 ? 85 : 70;

    final follow =
        shoulder == null ? 0 : shoulder >= 90 ? 82 : 68;

    final total =
        (ready +
                control +
                contact +
                stability +
                follow) ~/
            5;

    return SkillAnalysisResult(
      skillName: '吊球',
      totalScore: total,
      scores: [
        SkillScoreItem(
          name: '架拍',
          score: ready,
        ),
        SkillScoreItem(
          name: '手臂控制',
          score: control,
        ),
        SkillScoreItem(
          name: '擊球高度',
          score: contact,
        ),
        SkillScoreItem(
          name: '身體穩定',
          score: stability,
        ),
        SkillScoreItem(
          name: '隨揮控制',
          score: follow,
        ),
      ],
      goodPoints: [
        if (control >= 80)
          '手臂控制良好',
      ],
      problems: [
        if (contact < 80)
          '擊球點偏低',
      ],
      suggestions: [
        if (contact < 80)
          '吊球時保持較高擊球點。',
      ],
      details: {},
    );
  }
}