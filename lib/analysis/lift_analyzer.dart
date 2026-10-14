import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'pose_angle_utils.dart';
import 'skill_analysis_result.dart';

class LiftAnalyzer {
  static SkillAnalysisResult analyze(
    Pose pose,
    BodySide side,
  ) {
    final elbow =
        PoseAngleUtils.elbowAngle(pose, side);

    final knee =
        PoseAngleUtils.kneeAngle(pose, side);

    final wristHigh =
        PoseAngleUtils.wristAboveElbow(
      pose,
      side,
    );

    final kneeScore =
        knee == null
            ? 0
            : knee <= 160
                ? 90
                : 70;

    final armScore =
        elbow == null
            ? 0
            : elbow >= 130
                ? 90
                : 70;

    final handScore =
        wristHigh == true ? 85 : 70;

    final balanceScore =
        kneeScore >= 80 ? 88 : 72;

    final followScore =
        ((armScore + handScore) / 2)
            .round();

    final total =
        (
          kneeScore +
          armScore +
          handScore +
          balanceScore +
          followScore
        ) ~/
        5;

    return SkillAnalysisResult(
      skillName: '挑球',
      totalScore: total,
      scores: [
        SkillScoreItem(
          name: '膝蓋下沉',
          score: kneeScore,
        ),
        SkillScoreItem(
          name: '手臂伸展',
          score: armScore,
        ),
        SkillScoreItem(
          name: '擊球手位置',
          score: handScore,
        ),
        SkillScoreItem(
          name: '重心穩定',
          score: balanceScore,
        ),
        SkillScoreItem(
          name: '隨揮',
          score: followScore,
        ),
      ],
      goodPoints: [
        if (kneeScore >= 80)
          '下肢準備良好',
      ],
      problems: [
        if (kneeScore < 80)
          '膝蓋下沉不足',
      ],
      suggestions: [
        if (kneeScore < 80)
          '挑球時適度降低重心。',
      ],
      details: {
        '膝蓋角度':
            knee == null
                ? '--'
                : '${knee.toStringAsFixed(1)}°',
      },
    );
  }
}