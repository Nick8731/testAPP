import 'package:flutter/material.dart';

import '../data/muscle_data.dart';
import '../models/muscle_phase.dart';
import 'muscle_detail_screen.dart';

class MuscleTrainingScreen extends StatelessWidget {
  const MuscleTrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final available = muscleSkills.where((skill) => skill.isAvailable).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '肌肉與發力',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF123524),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.fitness_center, color: Colors.white, size: 34),
                SizedBox(height: 14),
                Text(
                  '看懂肌群分工，\n不是只靠手臂。',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    height: 1.3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 9),
                Text(
                  '點選動漫分解圖，理解每個動作階段的肌群分工、動力鏈與常見錯誤。',
                  style: TextStyle(color: Colors.white70, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.accessibility_new, color: Color(0xFF1B5E20)),
                const SizedBox(width: 10),
                Expanded(child: Text('對應技術訓練全部 $available 項課程，以同一組分解圖逐步查看')),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '選擇技術',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...muscleSkills.map((skill) => _MuscleSkillCard(skill: skill)),
          const SizedBox(height: 8),
          const Text(
            '此模組為第一版教學內容，不屬於醫療建議或正式運動生物力學診斷。',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _MuscleSkillCard extends StatelessWidget {
  final MuscleSkillData skill;

  const _MuscleSkillCard({required this.skill});

  @override
  Widget build(BuildContext context) {
    final available = skill.isAvailable;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('muscle-${skill.englishName}'),
        onTap: available
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MuscleDetailScreen(skill: skill),
                  ),
                );
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: available
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFF0F1F0),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  available ? Icons.accessibility_new : Icons.construction,
                  color: available ? const Color(0xFF1B5E20) : Colors.grey,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.skillName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      available
                          ? '${skill.phases.length} 個動作階段｜${skill.englishName}'
                          : '${skill.englishName}｜內容建置中',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (available)
                const Icon(Icons.chevron_right, color: Colors.grey)
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F1F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '建置中',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
