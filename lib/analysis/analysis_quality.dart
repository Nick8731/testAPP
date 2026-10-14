import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'pose_angle_utils.dart';
import 'skill_analysis_result.dart';

class AnalysisQuality {
  static const version = 'pose-phase-v3';
  // An engineering visibility guard, not a validated accuracy percentage.
  static bool usable(Pose pose, BodySide side) {
    final types = side == BodySide.right
        ? [
            PoseLandmarkType.rightShoulder,
            PoseLandmarkType.rightElbow,
            PoseLandmarkType.rightWrist,
            PoseLandmarkType.rightHip,
            PoseLandmarkType.rightKnee,
            PoseLandmarkType.rightAnkle,
          ]
        : [
            PoseLandmarkType.leftShoulder,
            PoseLandmarkType.leftElbow,
            PoseLandmarkType.leftWrist,
            PoseLandmarkType.leftHip,
            PoseLandmarkType.leftKnee,
            PoseLandmarkType.leftAnkle,
          ];
    for (final type in types) {
      final p = pose.landmarks[type];
      if (p == null ||
          !p.likelihood.isFinite ||
          p.likelihood < .5 ||
          !p.x.isFinite ||
          !p.y.isFinite) {
        return false;
      }
    }
    for (final angle in [
      PoseAngleUtils.elbowAngle(pose, side),
      PoseAngleUtils.kneeAngle(pose, side),
      PoseAngleUtils.shoulderAngle(pose, side),
    ]) {
      if (angle == null || !angle.isFinite || angle <= 0) return false;
    }
    return true;
  }

  static SkillAnalysisResult describe(
    SkillAnalysisResult result, {
    required BodySide side,
    required String mode,
    required double second,
    String? range,
  }) => SkillAnalysisResult(
    skillName: result.skillName,
    totalScore: result.totalScore,
    scores: result.scores,
    goodPoints: result.goodPoints,
    problems: result.problems,
    suggestions: result.suggestions,
    details: {
      ...result.details,
      '評分版本': version,
      '分析方式': mode,
      '持拍側': side == BodySide.right ? '右手' : '左手',
      '評分影格秒數': second.toStringAsFixed(3),
      '分析區間': ?range,
    },
  );
}
