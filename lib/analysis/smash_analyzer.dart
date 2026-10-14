import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'pose_angle_utils.dart';
import 'skill_analysis_result.dart';

class SmashAnalyzer {
  static SkillAnalysisResult analyze(
    Pose pose,
    BodySide side,
  ) {
    final elbow =
        PoseAngleUtils.elbowAngle(pose, side);

    final knee =
        PoseAngleUtils.kneeAngle(pose, side);

    final shoulder =
        PoseAngleUtils.shoulderAngle(pose, side);

    final wristHigh =
        PoseAngleUtils.wristAboveShoulder(
      pose,
      side,
    );

    final elbowHigh =
        PoseAngleUtils.elbowAboveShoulder(
      pose,
      side,
    );

    final ready =
        elbow == null
            ? 0
            : elbow >= 80 && elbow <= 130
                ? 90
                : 65;

    final arm =
        elbow == null
            ? 0
            : elbow >= 150
                ? 95
                : elbow >= 130
                    ? 80
                    : 60;

    final shoulderScore =
        shoulder == null
            ? 0
            : shoulder >= 130
                ? 90
                : 70;

    final contact =
        wristHigh == true ? 95 : 65;

    final lower =
        knee == null
            ? 0
            : knee >= 115 && knee <= 165
                ? 90
                : 70;

    final backswing =
        ((ready * 0.6) +
                (shoulderScore * 0.4))
            .round();

    final total =
        (
          ready * 0.20 +
          arm * 0.20 +
          shoulderScore * 0.15 +
          contact * 0.20 +
          lower * 0.10 +
          backswing * 0.15
        ).round();

    final good = <String>[];
    final problems = <String>[];
    final suggestions = <String>[];

    if (ready >= 80) {
      good.add('殺球架拍良好');
    } else {
      problems.add('殺球架拍不足');
      suggestions.add(
        '殺球前提高持拍手肘，增加引拍空間。',
      );
    }

    if (contact >= 80) {
      good.add('擊球手高度良好');
    } else {
      problems.add('擊球位置偏低');
      suggestions.add(
        '盡量在身體前上方完成擊球。',
      );
    }

    if (lower < 80) {
      problems.add('下肢準備不足');
      suggestions.add(
        '殺球前保持膝蓋彈性。',
      );
    }

    return SkillAnalysisResult(
      skillName: '殺球',
      totalScore: total.clamp(0, 100),
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
          name: '肩膀上舉',
          score: shoulderScore,
        ),
        SkillScoreItem(
          name: '擊球高度',
          score: contact,
        ),
        SkillScoreItem(
          name: '下肢穩定',
          score: lower,
        ),
        SkillScoreItem(
          name: '引拍完整度',
          score: backswing,
        ),
      ],
      goodPoints: good,
      problems: problems,
      suggestions: suggestions,
      details: {
        '架拍手肘角度':
            elbow == null
                ? '--'
                : '${elbow.toStringAsFixed(1)}°',
        '手肘高於肩膀':
            _yesNo(elbowHigh),
        '手腕高於肩膀':
            _yesNo(wristHigh),
      },
    );
  }

  static String _yesNo(bool? value) {
    if (value == null) return '--';
    return value ? '是' : '否';
  }
}