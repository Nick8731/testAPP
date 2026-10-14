import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'pose_angle_utils.dart';
import 'skill_analysis_result.dart';
import 'continuous_score.dart';

class HighClearAnalyzer {
  static SkillAnalysisResult analyze(Pose pose, BodySide side) {
    final elbow = PoseAngleUtils.elbowAngle(pose, side);

    final knee = PoseAngleUtils.kneeAngle(pose, side);

    final shoulder = PoseAngleUtils.shoulderAngle(pose, side);

    final elbowAbove = PoseAngleUtils.elbowAboveShoulder(pose, side);

    final wristAboveElbow = PoseAngleUtils.wristAboveElbow(pose, side);

    final readyScore = _readyScore(elbow, elbowAbove, wristAboveElbow);

    final armScore = elbow == null
        ? 0
        : elbow >= 150
        ? 95
        : elbow >= 130
        ? 80
        : 60;

    final shoulderScore = shoulder == null
        ? 0
        : shoulder >= 130
        ? 90
        : shoulder >= 105
        ? 75
        : 55;

    final kneeScore = ContinuousScore.knee(knee);

    final backswing = ((readyScore * 0.6) + (shoulderScore * 0.4)).round();

    final total =
        (readyScore * 0.25 +
                armScore * 0.25 +
                shoulderScore * 0.20 +
                kneeScore * 0.15 +
                backswing * 0.15)
            .round();

    final good = <String>[];
    final problems = <String>[];
    final suggestions = <String>[];

    if (readyScore >= 80) {
      good.add('架拍位置良好');
    } else {
      problems.add('架拍位置需要調整');
      suggestions.add('架拍時提高持拍手手肘，並讓手腕保持在手肘上方。');
    }

    if (armScore >= 80) {
      good.add('手臂伸展良好');
    } else {
      problems.add('手臂伸展不足');
      suggestions.add('擊球時讓手肘更充分伸展。');
    }

    if (shoulderScore >= 80) {
      good.add('肩膀上舉良好');
    } else {
      problems.add('肩膀上舉不足');
      suggestions.add('增加肩膀與上臂向上的幅度。');
    }

    return SkillAnalysisResult(
      skillName: '高遠球',
      totalScore: total.clamp(0, 100),
      scores: [
        SkillScoreItem(name: '架拍', score: readyScore),
        SkillScoreItem(name: '手臂伸展', score: armScore),
        SkillScoreItem(name: '肩膀上舉', score: shoulderScore),
        SkillScoreItem(name: '膝蓋穩定', score: kneeScore),
        SkillScoreItem(name: '引拍完整度', score: backswing),
      ],
      goodPoints: good,
      problems: problems,
      suggestions: suggestions,
      details: {
        '膝蓋角度': knee == null ? '--' : '${knee.toStringAsFixed(1)}°',
        '膝蓋評分方式': '舊區間邊界外 5° 線性過渡；工程平滑，非生物力學標準',
        '架拍手肘角度': elbow == null ? '--' : '${elbow.toStringAsFixed(1)}°',
        '手肘高於肩膀': _yesNo(elbowAbove),
        '手腕高於手肘': _yesNo(wristAboveElbow),
      },
    );
  }

  static int _readyScore(double? elbow, bool? elbowAbove, bool? wristAbove) {
    if (elbow == null) {
      return 0;
    }

    int score = 0;

    if (elbow >= 90 && elbow <= 130) {
      score += 40;
    } else if (elbow >= 75 && elbow <= 145) {
      score += 25;
    } else {
      score += 10;
    }

    score += elbowAbove == true ? 30 : 10;
    score += wristAbove == true ? 30 : 10;

    return score.clamp(0, 100);
  }

  static String _yesNo(bool? value) {
    if (value == null) return '--';
    return value ? '是' : '否';
  }
}
