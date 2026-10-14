import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'drop_analyzer.dart';
import 'drive_analyzer.dart';
import 'high_clear_analyzer.dart';
import 'lift_analyzer.dart';
import 'net_shot_analyzer.dart';
import 'pose_angle_utils.dart';
import 'skill_analysis_result.dart';
import 'slice_analyzer.dart';
import 'smash_analyzer.dart';
import 'smash_defence_analyzer.dart';
import 'split_step_analyzer.dart';

class SkillAnalyzerFactory {
  static SkillAnalysisResult? analyze({
    required String skillName,
    required String englishName,
    required Pose pose,
    required BodySide side,
  }) {
    final chinese =
        skillName.replaceAll(' ', '').trim();

    final english =
        englishName
            .replaceAll(' ', '')
            .trim()
            .toLowerCase();

    if (chinese.contains('高遠球') ||
        english.contains('clear')) {
      return HighClearAnalyzer.analyze(
        pose,
        side,
      );
    }

    if (chinese.contains('殺球') ||
        english.contains('smash')) {
      if (chinese.contains('接殺') ||
          english.contains('defence') ||
          english.contains('defense')) {
        return SmashDefenceAnalyzer.analyze(
          pose,
          side,
        );
      }

      return SmashAnalyzer.analyze(
        pose,
        side,
      );
    }

    if (chinese.contains('平球') ||
        english.contains('drive')) {
      return DriveAnalyzer.analyze(
        pose,
        side,
      );
    }

    if (chinese.contains('挑球') ||
        english.contains('lift')) {
      return LiftAnalyzer.analyze(
        pose,
        side,
      );
    }

    if (chinese.contains('切球') ||
        english.contains('slice')) {
      return SliceAnalyzer.analyze(
        pose,
        side,
      );
    }

    if (chinese.contains('吊球') ||
        english.contains('drop')) {
      return DropAnalyzer.analyze(
        pose,
        side,
      );
    }

    if (chinese.contains('放網') ||
        english.contains('netshot')) {
      return NetShotAnalyzer.analyze(
        pose,
        side,
      );
    }

    if (chinese.contains('接殺') ||
        english.contains('smashdefence') ||
        english.contains('smashdefense')) {
      return SmashDefenceAnalyzer.analyze(
        pose,
        side,
      );
    }

    if (chinese.contains('啟動步') ||
        english.contains('splitstep')) {
      return SplitStepAnalyzer.analyze(
        pose,
        side,
      );
    }

    return null;
  }
}