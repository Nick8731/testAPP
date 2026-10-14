// Optional Android-only diagnostic. Does not log in or write analysis records.
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test_app/analysis/phase_sampling.dart';
import 'package:test_app/analysis/pose_angle_utils.dart';
import 'package:test_app/analysis/analysis_quality.dart';
import 'package:test_app/analysis/high_clear_analyzer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      home: Scaffold(body: Center(child: Text('固定階段取樣驗證中；不儲存會員紀錄'))),
    ),
  );
  check();
}

Future<void> check() async {
  final detector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.single,
      model: PoseDetectionModel.accurate,
    ),
  );
  try {
    final cache = await getTemporaryDirectory();
    final folder = await Directory(cache.path).createTemp('phase_native_');
    List<int>? previousBytes;
    int? previousScore;
    for (var attempt = 0; attempt < 2; attempt++) {
      final tick = PhaseSampling.inRange(
        25.61,
        attempt == 0 ? 20.299 : 20.101,
        attempt == 0 ? 33.703 : 33.103,
      )!;
      final output = '${folder.path}/check-$attempt.jpg';
      final command =
          '-i "${cache.path}/phase-check-clear.mp4" -vf "${PhaseSampling.filter(tick)}" -frames:v 1 -q:v 4 -an -y "$output"';
      final session = await FFmpegKit.execute(command);
      if (!ReturnCode.isSuccess(await session.getReturnCode())) {
        throw StateError('FFmpeg failed');
      }
      final bytes = await File(output).readAsBytes();
      if (previousBytes != null && !listEquals(previousBytes, bytes)) {
        throw StateError('frame bytes differ');
      }
      previousBytes = bytes;
      final poses = await detector.processImage(
        InputImage.fromFilePath(output),
      );
      if (poses.isEmpty ||
          !AnalysisQuality.usable(poses.first, BodySide.right)) {
        throw StateError('pose visibility guard rejected test frame');
      }
      final result = HighClearAnalyzer.analyze(poses.first, BodySide.right);
      if (previousScore != null && previousScore != result.totalScore) {
        throw StateError(
          'native repeat scores differ $previousScore / ${result.totalScore}',
        );
      }
      previousScore = result.totalScore;
      debugPrint(
        'PHASE_CHECK attempt=$attempt tick=$tick jpegBytes=${bytes.length} score=${result.totalScore} knee=${PoseAngleUtils.kneeAngle(poses.first, BodySide.right)}',
      );
    }
    debugPrint(
      'PHASE_CHECK PASS same source frame bytes and native scores across both ranges',
    );
  } catch (error) {
    debugPrint('PHASE_CHECK FAIL $error');
  } finally {
    await detector.close();
  }
}
