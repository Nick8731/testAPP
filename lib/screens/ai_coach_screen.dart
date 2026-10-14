import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../data/skill_data.dart';
import '../test/test_skill.dart';
import 'pose_analysis_screen.dart';

class AiCoachScreen extends StatefulWidget {
  final BadmintonSkill? initialSkill;
  const AiCoachScreen({super.key, this.initialSkill});
  BadmintonSkill? get initialSupportedSkill =>
      badmintonSkills.contains(initialSkill) ? initialSkill : null;

  @override
  State<AiCoachScreen> createState() {
    return _AiCoachScreenState();
  }
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedVideo;

  VideoPlayerController? _videoController;

  BadmintonSkill? _selectedSkill;

  bool _isLoadingVideo = false;

  @override
  void initState() {
    super.initState();
    _selectedSkill = widget.initialSupportedSkill;
  }

  Future<void> _recordVideo() async {
    try {
      final video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 3),
      );

      if (video == null) {
        return;
      }

      await _loadSelectedVideo(video);
    } catch (error) {
      _showError('無法開啟相機：$error');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final video = await _picker.pickVideo(source: ImageSource.gallery);

      if (video == null) {
        return;
      }

      await _loadSelectedVideo(video);
    } catch (error) {
      _showError('無法選擇影片：$error');
    }
  }

  Future<void> _loadSelectedVideo(XFile video) async {
    setState(() {
      _isLoadingVideo = true;
    });

    await _videoController?.pause();
    await _videoController?.dispose();

    final controller = VideoPlayerController.file(File(video.path));

    try {
      await controller.initialize();

      await controller.setLooping(true);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _selectedVideo = video;
        _videoController = controller;
        _isLoadingVideo = false;
      });
    } catch (error) {
      await controller.dispose();

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingVideo = false;
      });

      _showError('影片載入失敗：$error');
    }
  }

  Future<void> _togglePlay() async {
    final controller = _videoController;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _removeVideo() async {
    await _videoController?.pause();
    await _videoController?.dispose();

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedVideo = null;
      _videoController = null;
      _selectedSkill = null;
    });
  }

  void _startAnalysis() {
    if (_selectedVideo == null) {
      _showError('請先選擇影片');
      return;
    }

    if (_selectedSkill == null) {
      _showError('請先選擇要分析的技術');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return PoseAnalysisScreen(
            videoPath: _selectedVideo!.path,
            skill: _selectedSkill!,
          );
        },
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),

      appBar: AppBar(
        title: const Text(
          'AI 教練',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                color: const Color(0xFF123524),

                borderRadius: BorderRadius.circular(24),
              ),

              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 28),

                      SizedBox(width: 10),

                      Text(
                        'AI 動作分析',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  Text(
                    '拍攝或上傳羽球影片，選擇要分析的技術，'
                    '再進入 AI 骨架與動作分析。',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            if (_selectedVideo == null && !_isLoadingVideo)
              _buildUploadSection(),

            if (_isLoadingVideo) _buildLoadingCard(),

            if (_selectedVideo != null &&
                _videoController != null &&
                !_isLoadingVideo)
              _buildVideoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          '選擇影片來源',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 15),

        _ActionCard(
          icon: Icons.videocam_outlined,
          title: '拍攝影片',
          subtitle: '使用相機錄製你的羽球動作',
          onTap: _recordVideo,
        ),

        const SizedBox(height: 12),

        _ActionCard(
          icon: Icons.video_library_outlined,
          title: '從相簿選擇',
          subtitle: '選擇已經拍攝好的羽球影片',
          onTap: _pickVideo,
        ),

        const SizedBox(height: 30),

        Container(
          width: double.infinity,

          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(20),
          ),

          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Icon(
                    Icons.tips_and_updates_outlined,
                    color: Color(0xFF1B5E20),
                  ),

                  SizedBox(width: 8),

                  Text(
                    '拍攝建議',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              SizedBox(height: 16),

              _TipRow(number: '1', text: '確保全身都出現在畫面中。'),

              _TipRow(number: '2', text: '手機盡量固定，不要大幅晃動。'),

              _TipRow(number: '3', text: '保持場地光線充足。'),

              _TipRow(number: '4', text: '建議從側面或斜側面拍攝。'),

              _TipRow(number: '5', text: '一次影片先分析一種技術動作。'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      height: 220,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            CircularProgressIndicator(),

            SizedBox(height: 15),

            Text('正在載入影片...'),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoSection() {
    final controller = _videoController!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                '影片預覽',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
            ),

            TextButton.icon(
              onPressed: _removeVideo,
              icon: const Icon(Icons.delete_outline),
              label: const Text('移除'),
            ),
          ],
        ),

        const SizedBox(height: 12),

        ClipRRect(
          borderRadius: BorderRadius.circular(20),

          child: Container(
            width: double.infinity,
            color: Colors.black,

            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,

              child: GestureDetector(
                onTap: _togglePlay,

                child: Stack(
                  alignment: Alignment.center,

                  children: [
                    VideoPlayer(controller),

                    if (!controller.value.isPlaying)
                      Container(
                        width: 72,
                        height: 72,

                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        VideoProgressIndicator(
          controller,
          allowScrubbing: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),

        const SizedBox(height: 24),

        const Text(
          '選擇分析技術',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        DropdownButtonFormField<BadmintonSkill>(
          initialValue: _selectedSkill,

          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),

          hint: const Text('請選擇技術'),

          items: badmintonSkills.map((skill) {
            return DropdownMenuItem<BadmintonSkill>(
              value: skill,

              child: Text('${skill.name} · ${skill.englishName}'),
            );
          }).toList(),

          onChanged: (skill) {
            setState(() {
              _selectedSkill = skill;
            });
          },
        ),

        const SizedBox(height: 20),

        Container(
          width: double.infinity,

          padding: const EdgeInsets.all(18),

          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),

            borderRadius: BorderRadius.circular(18),
          ),

          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF1B5E20)),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  _selectedSkill == null
                      ? '影片已準備完成，請再選擇分析技術。'
                      : '已選擇：${_selectedSkill!.name}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickVideo,

                icon: const Icon(Icons.video_library_outlined),

                label: const Text('重新選擇'),

                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 54)),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: FilledButton.icon(
                onPressed: _selectedSkill == null ? null : _startAnalysis,

                icon: const Icon(Icons.auto_awesome),

                label: const Text('開始分析'),

                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),

                  minimumSize: const Size(0, 54),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,

      borderRadius: BorderRadius.circular(20),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(20),

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,

                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),

                  borderRadius: BorderRadius.circular(17),
                ),

                child: Icon(icon, size: 29, color: const Color(0xFF1B5E20)),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String number;
  final String text;

  const _TipRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            width: 26,
            height: 26,

            alignment: Alignment.center,

            decoration: const BoxDecoration(
              color: Color(0xFF1B5E20),
              shape: BoxShape.circle,
            ),

            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),

              child: Text(
                text,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
