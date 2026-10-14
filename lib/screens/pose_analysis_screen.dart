import 'dart:io';
import 'dart:math';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../analysis/pose_angle_utils.dart';
import '../analysis/analysis_quality.dart';
import '../analysis/phase_sampling.dart';
import '../widgets/phase_marker_controls.dart';
import '../analysis/skill_analysis_result.dart';
import '../analysis/skill_analyzer_factory.dart';
import '../services/analysis_service.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../test/test_skill.dart';
import 'login_screen.dart';

class PoseAnalysisScreen extends StatefulWidget {
  final String videoPath;
  final BadmintonSkill skill;

  const PoseAnalysisScreen({
    super.key,
    required this.videoPath,
    required this.skill,
  });

  @override
  State<PoseAnalysisScreen> createState() {
    return _PoseAnalysisScreenState();
  }
}

class _PoseAnalysisScreenState extends State<PoseAnalysisScreen> {
  late final VideoPlayerController _videoController;
  late final PoseDetector _poseDetector;

  bool _videoLoading = true;
  bool _videoError = false;

  bool _isAnalyzingFrame = false;
  bool _isAnalyzingRange = false;

  bool _stopRequested = false;

  File? _analysisFrame;
  Pose? _detectedPose;
  Size? _imageSize;

  double? _elbowAngle;
  double? _kneeAngle;
  double? _shoulderAngle;

  String _detectedSide = '';
  BodySide _racketSide = BodySide.right;
  String? _analysisMessage;
  bool get _busy => _isAnalyzingFrame || _isAnalyzingRange || _isSavingAnalysis;

  double _startSecond = 0;
  double _endSecond = 10;

  double? _phaseMarker;
  String _phaseLabel = '準備／引拍';

  double _analysisProgress = 0;

  int _totalFrames = 0;
  int _processedFrames = 0;
  int _detectedFrames = 0;

  final List<double> _allElbowAngles = [];
  final List<double> _allKneeAngles = [];
  final List<double> _allShoulderAngles = [];

  double? _averageElbowAngle;
  double? _averageShoulderAngle;
  double? _maxShoulderAngle;
  double? _minKneeAngle;

  File? _currentAutoFrame;
  Pose? _currentAutoPose;
  Size? _currentAutoImageSize;

  SkillAnalysisResult? _skillResult;
  SkillAnalysisResult? _bestSkillResult;

  bool _isSavingAnalysis = false;
  bool _analysisSaved = false;

  File? _bestSkillFrame;
  Pose? _bestSkillPose;
  Size? _bestSkillImageSize;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.file(File(widget.videoPath));

    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.single,
        model: PoseDetectionModel.accurate,
      ),
    );

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _videoController.initialize();

      await _videoController.setLooping(true);

      if (!mounted) return;

      final duration = _videoController.value.duration.inMilliseconds / 1000.0;

      setState(() {
        _videoLoading = false;

        if (duration < 10) {
          _endSecond = duration;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _videoLoading = false;
        _videoError = true;
      });
    }
  }

  Future<void> _toggleVideo() async {
    if (!_videoController.value.isInitialized) {
      return;
    }

    if (_videoController.value.isPlaying) {
      await _videoController.pause();
    } else {
      await _videoController.play();
    }
  }

  Future<void> _analyzeCurrentFrame() async {
    if (!_videoController.value.isInitialized) {
      return;
    }

    if (_busy) {
      return;
    }

    setState(() {
      _resetRange();
      _isAnalyzingFrame = true;

      _elbowAngle = null;
      _kneeAngle = null;
      _shoulderAngle = null;

      _skillResult = null;
      _analysisSaved = false;
    });

    try {
      await _videoController.pause();

      final position = _videoController.value.position;

      final sampleTick = PhaseSampling.tick(position.inMilliseconds / 1000.0);
      final seconds = PhaseSampling.second(sampleTick);

      final temp = await getTemporaryDirectory();

      final singleDirectory = await Directory(temp.path)
          .createTemp('pose_single_');
      final framePath = '${singleDirectory.path}/frame.jpg';

      final command =
          '-i "${widget.videoPath}" '
          '-vf "${PhaseSampling.filter(sampleTick)}" '
          '-frames:v 1 '
          '-q:v 2 '
          '-y '
          '"$framePath"';

      final session = await FFmpegKit.execute(command);

      final code = await session.getReturnCode();

      if (!ReturnCode.isSuccess(code)) {
        throw Exception('影片取幀失敗');
      }

      final frame = File(framePath);

      final imageSize = await _getImageSize(frame);
      if (!mounted) return;

      final poses = await _poseDetector.processImage(
        InputImage.fromFilePath(frame.path),
      );

      if (poses.isEmpty) {
        if (!mounted) return;

        setState(() {
          _analysisFrame = frame;
          _imageSize = imageSize;
          _detectedPose = null;
          _analysisMessage = '本畫面沒有偵測到人體，未產生分數。';

          _isAnalyzingFrame = false;
        });

        return;
      }

      final pose = poses.first;

      final side = _racketSide;
      if (!AnalysisQuality.usable(pose, side)) {
        if (!mounted) return;
        setState(() {
          _analysisFrame = frame;
          _imageSize = imageSize;
          _detectedPose = pose;
          _isAnalyzingFrame = false;
          _analysisMessage = '持拍側關節不完整或辨識不足，本次不評分。請讓全身入鏡、減少遮擋，並確認持拍手。';
        });
        return;
      }

      final result = SkillAnalyzerFactory.analyze(
        skillName: widget.skill.name,
        englishName: widget.skill.englishName,
        pose: pose,
        side: side,
      );

      if (!mounted) return;

      setState(() {
        _analysisFrame = frame;
        _imageSize = imageSize;
        _detectedPose = pose;

        _elbowAngle = PoseAngleUtils.elbowAngle(pose, side);

        _kneeAngle = PoseAngleUtils.kneeAngle(pose, side);

        _shoulderAngle = PoseAngleUtils.shoulderAngle(pose, side);

        _detectedSide = side == BodySide.right ? '右側' : '左側';

        _skillResult = result == null
            ? null
            : AnalysisQuality.describe(
                result,
                side: side,
                mode: '單張姿勢',
                second: seconds,
              );

        _isAnalyzingFrame = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isAnalyzingFrame = false;
        _analysisMessage = '本次分析失敗，請重新嘗試；不沿用上次分數。';
      });
    }
  }

  Future<void> _analyzeSelectedRange() async {
    if (!_videoController.value.isInitialized) {
      return;
    }

    if (_busy) {
      return;
    }

    if (_endSecond <= _startSecond) {
      return;
    }
    final sampleTick = _phaseMarker == null
        ? null
        : PhaseSampling.inRange(_phaseMarker!, _startSecond, _endSecond);
    if (sampleTick == null) {
      setState(() => _analysisMessage = '請先在影片中標記要比較的階段；標記時間必須位於所選區間內。');
      return;
    }

    await _videoController.pause();

    _resetRange();

    setState(() {
      _isAnalyzingRange = true;
    });

    try {
      final temp = await getTemporaryDirectory();

      final directory = await Directory(temp.path).createTemp('pose_range_');

      final output = '${directory.path}/frame_%05d.jpg';

      final command =
          '-i "${widget.videoPath}" '
          '-vf "${PhaseSampling.filter(sampleTick)}" '
          '-frames:v 1 '
          '-q:v 4 '
          '-an '
          '-y '
          '"$output"';

      final session = await FFmpegKit.execute(command);

      final code = await session.getReturnCode();

      if (!ReturnCode.isSuccess(code)) {
        throw Exception('影片抽幀失敗');
      }

      final files = directory
          .listSync()
          .whereType<File>()
          .where((e) => e.path.toLowerCase().endsWith('.jpg'))
          .toList();

      files.sort((a, b) => a.path.compareTo(b.path));

      _totalFrames = files.length;
      if (!mounted) return;

      for (int i = 0; i < files.length; i++) {
        if (_stopRequested || !mounted) {
          break;
        }

        final frame = files[i];

        final poses = await _poseDetector.processImage(
          InputImage.fromFilePath(frame.path),
        );
        if (!mounted) return;

        _processedFrames++;

        if (poses.isNotEmpty) {
          final pose = poses.first;

          final side = _racketSide;
          if (!AnalysisQuality.usable(pose, side)) {
            _analysisProgress = _processedFrames / files.length;
            if (mounted) setState(() {});
            continue;
          }

          final elbow = PoseAngleUtils.elbowAngle(pose, side);

          final knee = PoseAngleUtils.kneeAngle(pose, side);

          final shoulder = PoseAngleUtils.shoulderAngle(pose, side);

          if (elbow != null) {
            _allElbowAngles.add(elbow);
          }

          if (knee != null) {
            _allKneeAngles.add(knee);
          }

          if (shoulder != null) {
            _allShoulderAngles.add(shoulder);
          }

          _detectedFrames++;

          final imageSize = await _getImageSize(frame);

          _currentAutoFrame = frame;

          _currentAutoPose = pose;

          _currentAutoImageSize = imageSize;

          final result = SkillAnalyzerFactory.analyze(
            skillName: widget.skill.name,
            englishName: widget.skill.englishName,
            pose: pose,
            side: side,
          );

          if (result != null) {
            _bestSkillResult = AnalysisQuality.describe(
              result,
              side: side,
              mode: '人工標記階段：$_phaseLabel（姿勢參考）',
              second: PhaseSampling.second(sampleTick),
              range:
                  '${_startSecond.toStringAsFixed(3)}–${_endSecond.toStringAsFixed(3)} 秒；固定影片零點 0.1 秒格；人工標記，不取最高分',
            );

            _bestSkillFrame = frame;

            _bestSkillPose = pose;

            _bestSkillImageSize = imageSize;
          }
        }

        _analysisProgress = _processedFrames / files.length;

        _calculateStatistics();

        if (mounted) {
          setState(() {});
        }
      }

      if (!mounted) return;

      setState(() {
        _isAnalyzingRange = false;

        _skillResult = _bestSkillResult;

        if (_bestSkillFrame != null) {
          _analysisFrame = _bestSkillFrame;

          _detectedPose = _bestSkillPose;

          _imageSize = _bestSkillImageSize;
          _elbowAngle = PoseAngleUtils.elbowAngle(_bestSkillPose!, _racketSide);
          _kneeAngle = PoseAngleUtils.kneeAngle(_bestSkillPose!, _racketSide);
          _shoulderAngle = PoseAngleUtils.shoulderAngle(
            _bestSkillPose!,
            _racketSide,
          );
          _detectedSide = _racketSide == BodySide.right ? '右側' : '左側';
        }
        if (_skillResult == null) {
          _analysisMessage = '此區間沒有足夠完整的持拍側關節，無法評分，請調整拍攝或區間。';
        }

        if (!_stopRequested) {
          _analysisProgress = 1;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isAnalyzingRange = false;
        _skillResult = null;
        _bestSkillResult = null;
        _analysisMessage = '區間分析失敗，未產生可儲存的分數。';
      });
    }
  }

  void _resetRange() {
    _skillResult = null;
    _analysisMessage = null;
    _analysisFrame = null;
    _detectedPose = null;
    _imageSize = null;
    _currentAutoFrame = null;
    _currentAutoPose = null;
    _currentAutoImageSize = null;
    _elbowAngle = null;
    _kneeAngle = null;
    _shoulderAngle = null;
    _detectedSide = '';
    _stopRequested = false;

    _analysisProgress = 0;

    _totalFrames = 0;
    _processedFrames = 0;
    _detectedFrames = 0;

    _allElbowAngles.clear();
    _allKneeAngles.clear();
    _allShoulderAngles.clear();

    _averageElbowAngle = null;
    _averageShoulderAngle = null;
    _maxShoulderAngle = null;
    _minKneeAngle = null;

    _bestSkillResult = null;
    _analysisSaved = false;
    _bestSkillFrame = null;
    _bestSkillPose = null;
    _bestSkillImageSize = null;
  }

  void _calculateStatistics() {
    _averageElbowAngle = _average(_allElbowAngles);

    _averageShoulderAngle = _average(_allShoulderAngles);

    if (_allShoulderAngles.isNotEmpty) {
      _maxShoulderAngle = _allShoulderAngles.reduce(max);
    }

    if (_allKneeAngles.isNotEmpty) {
      _minKneeAngle = _allKneeAngles.reduce(min);
    }
  }

  double? _average(List<double> values) {
    if (values.isEmpty) {
      return null;
    }

    return values.reduce((a, b) => a + b) / values.length;
  }

  Future<Size> _getImageSize(File file) async {
    final image = await decodeImageFromList(await file.readAsBytes());

    final size = Size(image.width.toDouble(), image.height.toDouble());
    image.dispose();
    return size;
  }

  String _angle(double? value) {
    if (value == null) return '--°';

    return '${value.toStringAsFixed(1)}°';
  }

  @override
  void dispose() {
    _stopRequested = true;
    _videoController.dispose();
    _poseDetector.close();

    super.dispose();
  }

  Future<void> _saveAnalysis(SkillAnalysisResult result) async {
    if (_busy || _analysisSaved || result != _skillResult) return;
    setState(() => _isSavingAnalysis = true);
    try {
      if (!await AuthService.instance.isLoggedIn) {
        if (!mounted) return;
        final loggedIn = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        if (loggedIn != true || !mounted) return;
      }
      final saved = await AnalysisService().save(result);
      if (mounted) {
        setState(() => _analysisSaved = true);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('分析紀錄已安全儲存（編號 ${saved.id}）')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('無法儲存：$error'),
            action: error is ApiException && error.statusCode == 401
                ? SnackBarAction(
                    label: '重新登入',
                    onPressed: () async {
                      await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                      // Keep the result, but require another explicit save tap.
                    },
                  )
                : null,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingAnalysis = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),

      appBar: AppBar(title: Text('${widget.skill.name} AI 分析')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            _header(),
            const SizedBox(height: 12),
            DropdownButtonFormField<BodySide>(
              initialValue: _racketSide,
              decoration: const InputDecoration(
                labelText: '持拍手（不自動切換左右側）',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: BodySide.right, child: Text('右手')),
                DropdownMenuItem(value: BodySide.left, child: Text('左手')),
              ],
              onChanged: _busy
                  ? null
                  : (side) {
                      if (side != null) {
                        setState(() {
                          _racketSide = side;
                          _resetRange();
                        });
                      }
                    },
            ),
            const SizedBox(height: 12),
            const Text(
              '請固定鏡位、全身入鏡、一次一人。使用同一影片、持拍側及人工標記的階段時間比較；調整區間邊界不會移動取樣。這仍是姿勢參考，不是完整揮拍或擊球品質評分。',
              style: TextStyle(height: 1.6),
            ),
            if (_analysisMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _analysisMessage!,
                  style: const TextStyle(color: Colors.brown),
                ),
              ),

            const SizedBox(height: 20),

            _title('影片預覽'),

            _video(),
            PhaseMarkerControls(
              phase: _phaseLabel,
              second: _phaseMarker,
              busy: _busy,
              onPhase: (phase) => setState(() {
                _phaseLabel = phase;
                _phaseMarker = null;
                _resetRange();
              }),
              onMark: () async {
                if (!_videoController.value.isInitialized || _busy) return;
                await _videoController.pause();
                if (!mounted) return;
                setState(() {
                  _resetRange();
                  _phaseMarker = PhaseSampling.second(
                    PhaseSampling.tick(
                      _videoController.value.position.inMilliseconds / 1000.0,
                    ),
                  );
                });
              },
            ),

            const SizedBox(height: 20),

            _title('單張畫面分析'),

            SizedBox(
              width: double.infinity,

              child: FilledButton(
                onPressed: _busy ? null : _analyzeCurrentFrame,

                child: const Text('分析目前畫面'),
              ),
            ),

            const SizedBox(height: 24),

            _title('限定區間的階段姿勢分析'),

            _rangeSelector(),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,

              child: FilledButton(
                onPressed: _busy ? null : _analyzeSelectedRange,

                child: Text(_isAnalyzingRange ? '分析中...' : '分析標記階段（不取最高分）'),
              ),
            ),

            if (_isAnalyzingRange || _processedFrames > 0) ...[
              const SizedBox(height: 16),

              _progress(),
            ],

            const SizedBox(height: 26),

            _title('骨架預覽'),

            _posePreview(),

            const SizedBox(height: 26),

            _title('目前畫面角度'),

            _angles(),

            const SizedBox(height: 26),

            _title('區間分析統計'),

            _statistics(),

            const SizedBox(height: 28),

            _title('${widget.skill.name}動作評分'),

            _scoreArea(),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF123524),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        '分析技術：${widget.skill.name}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: Text(
        text,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _video() {
    if (_videoLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_videoError) {
      return const SizedBox(height: 300, child: Center(child: Text('影片載入失敗')));
    }

    return Column(
      children: [
        SizedBox(
          height: 300,

          child: Center(
            child: AspectRatio(
              aspectRatio: _videoController.value.aspectRatio,

              child: GestureDetector(
                onTap: _toggleVideo,
                child: VideoPlayer(_videoController),
              ),
            ),
          ),
        ),

        VideoProgressIndicator(_videoController, allowScrubbing: true),
      ],
    );
  }

  Widget _rangeSelector() {
    final maxSeconds = _videoController.value.isInitialized
        ? _videoController.value.duration.inMilliseconds / 1000.0
        : 10.0;

    return Column(
      children: [
        Text('開始：${_startSecond.toStringAsFixed(1)} 秒'),

        Slider(
          min: 0,
          max: maxSeconds,
          value: _startSecond.clamp(0, maxSeconds).toDouble(),

          onChanged: _busy
              ? null
              : (value) {
                  setState(() {
                    _startSecond = value;
                    _resetRange();
                  });
                },
        ),

        Text('結束：${_endSecond.toStringAsFixed(1)} 秒'),

        Slider(
          min: 0,
          max: maxSeconds,
          value: _endSecond.clamp(0, maxSeconds).toDouble(),

          onChanged: _busy
              ? null
              : (value) {
                  setState(() {
                    _endSecond = value;
                    _resetRange();
                  });
                },
        ),
      ],
    );
  }

  Widget _progress() {
    return Column(
      children: [
        LinearProgressIndicator(value: _analysisProgress),

        const SizedBox(height: 8),

        Text('已處理 $_processedFrames / $_totalFrames，通過關節檢查 $_detectedFrames'),
      ],
    );
  }

  Widget _posePreview() {
    final frame = _analysisFrame ?? _currentAutoFrame;

    final pose = _detectedPose ?? _currentAutoPose;

    final size = _imageSize ?? _currentAutoImageSize;

    if (frame == null) {
      return const Text('尚未分析');
    }

    if (pose == null || size == null) {
      return Image.file(frame);
    }

    return AspectRatio(
      aspectRatio: size.width / size.height,

      child: Stack(
        fit: StackFit.expand,

        children: [
          Image.file(frame, fit: BoxFit.fill),

          CustomPaint(
            painter: PosePainter(pose: pose, imageSize: size),
          ),
        ],
      ),
    );
  }

  Widget _angles() {
    return Row(
      children: [
        Expanded(child: _metric('手肘', _angle(_elbowAngle))),

        Expanded(child: _metric('膝蓋', _angle(_kneeAngle))),

        Expanded(child: _metric('肩膀', _angle(_shoulderAngle))),

        Expanded(
          child: _metric('側別', _detectedSide.isEmpty ? '—' : _detectedSide),
        ),
      ],
    );
  }

  Widget _statistics() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _metric('平均手肘', _angle(_averageElbowAngle))),

            Expanded(child: _metric('平均肩膀', _angle(_averageShoulderAngle))),
          ],
        ),

        Row(
          children: [
            Expanded(child: _metric('最大肩膀', _angle(_maxShoulderAngle))),

            Expanded(child: _metric('最低膝蓋', _angle(_minKneeAngle))),
          ],
        ),
      ],
    );
  }

  Widget _metric(String title, String value) {
    return Container(
      margin: const EdgeInsets.all(5),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _scoreArea() {
    final result = _skillResult;

    if (result == null) {
      return Container(
        width: double.infinity,

        padding: const EdgeInsets.all(24),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(20),
        ),

        child: Text(
          '請先分析${widget.skill.name}畫面或區間，才能產生評分。',
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Container(
          width: double.infinity,

          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: const Color(0xFF123524),

            borderRadius: BorderRadius.circular(20),
          ),

          child: Text(
            '${result.skillName}總分：${result.totalScore} / 100',
            style: const TextStyle(
              color: Colors.white,

              fontSize: 26,

              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _busy || _analysisSaved
                ? null
                : () => _saveAnalysis(result),
            icon: Icon(
              _analysisSaved
                  ? Icons.cloud_done_outlined
                  : Icons.cloud_upload_outlined,
            ),
            label: Text(
              _analysisSaved
                  ? '分析紀錄已儲存'
                  : _isSavingAnalysis
                  ? '儲存中…'
                  : '儲存分析紀錄',
            ),
          ),
        ),

        const SizedBox(height: 14),

        ...result.scores.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),

            padding: const EdgeInsets.all(14),

            color: Colors.white,

            child: Row(
              children: [
                Expanded(child: Text(item.name)),

                Text(
                  '${item.score}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }),

        if (result.details.isNotEmpty) ...[
          const SizedBox(height: 12),

          _title('分析細節'),

          ...result.details.entries.map((entry) {
            return ListTile(
              tileColor: Colors.white,

              title: Text(entry.key),

              trailing: Text(entry.value),
            );
          }),
        ],

        const SizedBox(height: 14),

        _feedback('表現良好', result.goodPoints),

        _feedback('需要調整', result.problems),

        _feedback('修正建議', result.suggestions),
      ],
    );
  }

  Widget _feedback(String title, List<String> items) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),

          const SizedBox(height: 8),

          if (items.isEmpty)
            const Text('暫無')
          else
            ...items.map((e) => Text('• $e')),
        ],
      ),
    );
  }
}

class PosePainter extends CustomPainter {
  final Pose pose;
  final Size imageSize;

  PosePainter({required this.pose, required this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3;

    final pointPaint = Paint()..color = Colors.lightGreenAccent;

    Offset? point(PoseLandmarkType type) {
      final landmark = pose.landmarks[type];

      if (landmark == null) {
        return null;
      }

      return Offset(
        landmark.x / imageSize.width * size.width,

        landmark.y / imageSize.height * size.height,
      );
    }

    void bone(PoseLandmarkType a, PoseLandmarkType b) {
      final p1 = point(a);

      final p2 = point(b);

      if (p1 != null && p2 != null) {
        canvas.drawLine(p1, p2, linePaint);
      }
    }

    bone(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);

    bone(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);

    bone(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);

    bone(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);

    bone(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);

    bone(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);

    bone(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);

    bone(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);

    bone(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);

    bone(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);

    bone(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);

    bone(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);

    for (final landmark in pose.landmarks.values) {
      canvas.drawCircle(
        Offset(
          landmark.x / imageSize.width * size.width,

          landmark.y / imageSize.height * size.height,
        ),
        5,
        pointPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return true;
  }
}
