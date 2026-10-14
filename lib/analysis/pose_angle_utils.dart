import 'dart:math';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

enum BodySide {
  left,
  right,
}

class PoseAngleUtils {
  static BodySide chooseBestSide(Pose pose) {
    final rightScore =
        _score(pose, PoseLandmarkType.rightShoulder) +
        _score(pose, PoseLandmarkType.rightElbow) +
        _score(pose, PoseLandmarkType.rightWrist) +
        _score(pose, PoseLandmarkType.rightHip) +
        _score(pose, PoseLandmarkType.rightKnee) +
        _score(pose, PoseLandmarkType.rightAnkle);

    final leftScore =
        _score(pose, PoseLandmarkType.leftShoulder) +
        _score(pose, PoseLandmarkType.leftElbow) +
        _score(pose, PoseLandmarkType.leftWrist) +
        _score(pose, PoseLandmarkType.leftHip) +
        _score(pose, PoseLandmarkType.leftKnee) +
        _score(pose, PoseLandmarkType.leftAnkle);

    return rightScore >= leftScore
        ? BodySide.right
        : BodySide.left;
  }

  static double _score(
    Pose pose,
    PoseLandmarkType type,
  ) {
    return pose.landmarks[type]?.likelihood ?? 0;
  }

  static double? elbowAngle(
    Pose pose,
    BodySide side,
  ) {
    return side == BodySide.right
        ? angleFromLandmarks(
            pose,
            PoseLandmarkType.rightShoulder,
            PoseLandmarkType.rightElbow,
            PoseLandmarkType.rightWrist,
          )
        : angleFromLandmarks(
            pose,
            PoseLandmarkType.leftShoulder,
            PoseLandmarkType.leftElbow,
            PoseLandmarkType.leftWrist,
          );
  }

  static double? kneeAngle(
    Pose pose,
    BodySide side,
  ) {
    return side == BodySide.right
        ? angleFromLandmarks(
            pose,
            PoseLandmarkType.rightHip,
            PoseLandmarkType.rightKnee,
            PoseLandmarkType.rightAnkle,
          )
        : angleFromLandmarks(
            pose,
            PoseLandmarkType.leftHip,
            PoseLandmarkType.leftKnee,
            PoseLandmarkType.leftAnkle,
          );
  }

  static double? shoulderAngle(
    Pose pose,
    BodySide side,
  ) {
    return side == BodySide.right
        ? angleFromLandmarks(
            pose,
            PoseLandmarkType.rightHip,
            PoseLandmarkType.rightShoulder,
            PoseLandmarkType.rightElbow,
          )
        : angleFromLandmarks(
            pose,
            PoseLandmarkType.leftHip,
            PoseLandmarkType.leftShoulder,
            PoseLandmarkType.leftElbow,
          );
  }

  static bool? elbowAboveShoulder(
    Pose pose,
    BodySide side,
  ) {
    final shoulder = pose.landmarks[
        side == BodySide.right
            ? PoseLandmarkType.rightShoulder
            : PoseLandmarkType.leftShoulder];

    final elbow = pose.landmarks[
        side == BodySide.right
            ? PoseLandmarkType.rightElbow
            : PoseLandmarkType.leftElbow];

    if (shoulder == null || elbow == null) {
      return null;
    }

    return elbow.y < shoulder.y;
  }

  static bool? wristAboveElbow(
    Pose pose,
    BodySide side,
  ) {
    final elbow = pose.landmarks[
        side == BodySide.right
            ? PoseLandmarkType.rightElbow
            : PoseLandmarkType.leftElbow];

    final wrist = pose.landmarks[
        side == BodySide.right
            ? PoseLandmarkType.rightWrist
            : PoseLandmarkType.leftWrist];

    if (elbow == null || wrist == null) {
      return null;
    }

    return wrist.y < elbow.y;
  }

  static bool? wristAboveShoulder(
    Pose pose,
    BodySide side,
  ) {
    final shoulder = pose.landmarks[
        side == BodySide.right
            ? PoseLandmarkType.rightShoulder
            : PoseLandmarkType.leftShoulder];

    final wrist = pose.landmarks[
        side == BodySide.right
            ? PoseLandmarkType.rightWrist
            : PoseLandmarkType.leftWrist];

    if (shoulder == null || wrist == null) {
      return null;
    }

    return wrist.y < shoulder.y;
  }

  static double? angleFromLandmarks(
    Pose pose,
    PoseLandmarkType firstType,
    PoseLandmarkType centerType,
    PoseLandmarkType lastType,
  ) {
    final first = pose.landmarks[firstType];
    final center = pose.landmarks[centerType];
    final last = pose.landmarks[lastType];

    if (first == null ||
        center == null ||
        last == null) {
      return null;
    }

    return calculateAngle(
      Point<double>(first.x, first.y),
      Point<double>(center.x, center.y),
      Point<double>(last.x, last.y),
    );
  }

  static double calculateAngle(
    Point<double> a,
    Point<double> b,
    Point<double> c,
  ) {
    final abX = a.x - b.x;
    final abY = a.y - b.y;

    final cbX = c.x - b.x;
    final cbY = c.y - b.y;

    final dot =
        abX * cbX + abY * cbY;

    final abLength =
        sqrt(abX * abX + abY * abY);

    final cbLength =
        sqrt(cbX * cbX + cbY * cbY);

    if (abLength == 0 || cbLength == 0) {
      return 0;
    }

    double cosine =
        dot / (abLength * cbLength);

    cosine = cosine.clamp(-1.0, 1.0);

    return acos(cosine) * 180 / pi;
  }
}