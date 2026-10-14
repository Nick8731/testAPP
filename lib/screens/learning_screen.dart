import 'package:flutter/material.dart';

import '../data/training_catalog.dart';
import '../services/progress_service.dart';
import '../test/test_skill.dart';
import 'skill_detail_screen.dart';
import '../data/beginner_course_data.dart';
import '../widgets/beginner_course_tile.dart';
import 'beginner_grip_screen.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() {
    return _LearningScreenState();
  }
}

class _LearningScreenState extends State<LearningScreen> {
  Map<String, int> progressMap = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadProgress();
  }

  // ============================================================
  // 讀取所有課程進度
  // ============================================================

  Future<void> _loadProgress() async {
    final Map<String, int> result = {};

    for (final skill in trainingSkills) {
      final progress = await ProgressService.getProgress(skill.name);

      result[skill.name] = progress;
    }

    result[beginnerCourseName] = await ProgressService.getProgress(
      beginnerCourseName,
    );
    if (!mounted) return;

    setState(() {
      progressMap = result;
      isLoading = false;
    });
  }

  // ============================================================
  // 教材已讀課程
  // ============================================================

  List<BadmintonSkill> get completedSkills {
    return trainingSkills.where((skill) {
      return (progressMap[skill.name] ?? 0) == 100;
    }).toList();
  }

  // ============================================================
  // 學習中的課程
  // ============================================================

  List<BadmintonSkill> get learningSkills {
    return trainingSkills.where((skill) {
      final progress = progressMap[skill.name] ?? 0;

      return progress > 0 && progress < 100;
    }).toList();
  }

  // ============================================================
  // 尚未開始
  // ============================================================

  List<BadmintonSkill> get notStartedSkills {
    return trainingSkills.where((skill) {
      return (progressMap[skill.name] ?? 0) == 0;
    }).toList();
  }

  // ============================================================
  // 整體平均進度
  // ============================================================

  int get overallProgress {
    if (trainingSkills.isEmpty) {
      return 0;
    }

    int total = 0;

    for (final skill in trainingSkills) {
      total += progressMap[skill.name] ?? 0;
    }

    total += progressMap[beginnerCourseName] ?? 0;
    return (total / (trainingSkills.length + 1)).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),

      appBar: AppBar(
        title: const Text(
          '我的學習',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProgress,

              child: ListView(
                padding: const EdgeInsets.all(20),

                children: [
                  // ==============================================
                  // 標題
                  // ==============================================

                  const Text(
                    '教材閱讀進度',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    '先看懂再練習。此處是本機教材閱讀紀錄，不是動作能力評分。',
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),

                  const SizedBox(height: 24),

                  // ==============================================
                  // 整體完成度
                  // ==============================================
                  _buildOverallCard(),
                  const SizedBox(height: 20),
                  const Text(
                    '入門教材',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  BeginnerCourseTile(
                    read: progressMap[beginnerCourseName] == 100,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const BeginnerGripScreen(),
                        ),
                      );
                      if (mounted) await _loadProgress();
                    },
                  ),

                  const SizedBox(height: 28),

                  // ==============================================
                  // 學習中的課程
                  // ==============================================
                  _SectionHeader(
                    title: '學習中',
                    count: learningSkills.length,
                    icon: Icons.play_circle_outline,
                  ),

                  const SizedBox(height: 12),

                  if (learningSkills.isEmpty)
                    const _EmptyCard(text: '目前沒有進行中的課程'),

                  ...learningSkills.map((skill) {
                    return _LearningCourseCard(
                      skill: skill,

                      progress: progressMap[skill.name] ?? 0,

                      onTap: () async {
                        await Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (context) {
                              return SkillDetailScreen(skill: skill);
                            },
                          ),
                        );

                        await _loadProgress();
                      },
                    );
                  }),

                  const SizedBox(height: 28),

                  // ==============================================
                  // 教材已讀
                  // ==============================================
                  _SectionHeader(
                    title: '教材已讀',
                    count: completedSkills.length,
                    icon: Icons.check_circle_outline,
                  ),

                  const SizedBox(height: 12),

                  if (completedSkills.isEmpty)
                    const _EmptyCard(text: '還沒有完成任何課程'),

                  ...completedSkills.map((skill) {
                    return _LearningCourseCard(
                      skill: skill,
                      progress: 100,

                      onTap: () async {
                        await Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (context) {
                              return SkillDetailScreen(skill: skill);
                            },
                          ),
                        );

                        await _loadProgress();
                      },
                    );
                  }),

                  const SizedBox(height: 28),

                  // ==============================================
                  // 尚未開始
                  // ==============================================
                  _SectionHeader(
                    title: '尚未開始',
                    count: notStartedSkills.length,
                    icon: Icons.school_outlined,
                  ),

                  const SizedBox(height: 12),

                  ...notStartedSkills.map((skill) {
                    return _LearningCourseCard(
                      skill: skill,
                      progress: 0,

                      onTap: () async {
                        await Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (context) {
                              return SkillDetailScreen(skill: skill);
                            },
                          ),
                        );

                        await _loadProgress();
                      },
                    );
                  }),

                  const SizedBox(height: 50),
                ],
              ),
            ),
    );
  }

  // ============================================================
  // 整體完成度卡
  // ============================================================

  Widget _buildOverallCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: const Color(0xFF123524),

        borderRadius: BorderRadius.circular(22),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            '總學習完成度',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),

          const SizedBox(height: 8),

          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 20,
            runSpacing: 8,

            children: [
              Text(
                '$overallProgress%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                '${completedSkills.length + (progressMap[beginnerCourseName] == 100 ? 1 : 0)} / ${trainingSkills.length + 1} 教材已讀',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),

          const SizedBox(height: 18),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),

            child: LinearProgressIndicator(
              value: overallProgress / 100,

              minHeight: 10,

              backgroundColor: Colors.white24,

              color: const Color(0xFF81C784),
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              _StatBox(number: '${learningSkills.length}', label: '學習中'),

              const SizedBox(width: 10),

              _StatBox(
                number:
                    '${completedSkills.length + (progressMap[beginnerCourseName] == 100 ? 1 : 0)}',
                label: '教材已讀',
              ),

              const SizedBox(width: 10),

              _StatBox(
                number:
                    '${notStartedSkills.length + (progressMap[beginnerCourseName] == 100 ? 0 : 1)}',
                label: '未開始',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Section Header
// ============================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1B5E20)),

        const SizedBox(width: 8),

        Text(
          title,
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),

        const SizedBox(width: 8),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),

          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),

            borderRadius: BorderRadius.circular(20),
          ),

          child: Text(
            '$count',
            style: const TextStyle(
              color: Color(0xFF1B5E20),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Course Card
// ============================================================

class _LearningCourseCard extends StatelessWidget {
  final BadmintonSkill skill;
  final int progress;
  final VoidCallback onTap;

  const _LearningCourseCard({
    required this.skill,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final completed = progress == 100;

    return Card(
      elevation: 0,

      margin: const EdgeInsets.only(bottom: 12),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(18),

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,

                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),

                  borderRadius: BorderRadius.circular(14),
                ),

                child: Icon(
                  completed ? Icons.check : Icons.sports_tennis,

                  color: const Color(0xFF1B5E20),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      skill.name,

                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      '${skill.englishName} · 動漫分解圖',

                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),

                    const SizedBox(height: 9),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),

                      child: LinearProgressIndicator(
                        value: progress / 100,

                        minHeight: 5,

                        backgroundColor: const Color(0xFFE0E0E0),

                        color: const Color(0xFF1B5E20),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Text(
                '$progress%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,

                  color: completed ? const Color(0xFF1B5E20) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Empty Card
// ============================================================

class _EmptyCard extends StatelessWidget {
  final String text;

  const _EmptyCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 10),

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),
      ),

      child: Center(
        child: Text(text, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}

// ============================================================
// Stat Box
// ============================================================

class _StatBox extends StatelessWidget {
  final String number;
  final String label;

  const _StatBox({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),

        decoration: BoxDecoration(
          color: Colors.white10,

          borderRadius: BorderRadius.circular(14),
        ),

        child: Column(
          children: [
            Text(
              number,

              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              label,

              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
