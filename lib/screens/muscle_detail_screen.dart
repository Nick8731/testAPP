import 'package:flutter/material.dart';

import '../data/illustrated_lesson_data.dart';
import '../data/lesson_timing_data.dart';
import '../data/lesson_contact_points.dart';
import '../data/muscle_training_data.dart';
import '../data/training_catalog.dart';
import 'skill_detail_screen.dart';
import '../widgets/lesson_character_figure.dart';

import '../models/muscle_phase.dart';
import '../widgets/muscle_body_view.dart';
import '../widgets/muscle_group_chip.dart';

class MuscleDetailScreen extends StatefulWidget {
  final MuscleSkillData skill;

  const MuscleDetailScreen({super.key, required this.skill});

  @override
  State<MuscleDetailScreen> createState() => _MuscleDetailScreenState();
}

class _MuscleDetailScreenState extends State<MuscleDetailScreen> {
  int _phaseIndex = 0;
  MusclePhase get _phase => widget.skill.phases[_phaseIndex];
  void _selectPhase(int index) {
    if (index < 0 ||
        index >= widget.skill.phases.length ||
        index == _phaseIndex) {
      return;
    }
    setState(() => _phaseIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final lesson = lessonFor(widget.skill.skillName);
    final timing = lessonTiming[lesson.key]!;
    return Scaffold(
      appBar: AppBar(title: Text('${widget.skill.skillName}｜肌肉與發力')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
        children: [
          _buildHeader(),
          const SizedBox(height: 18),
          _buildPhaseStatus(),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(
              widget.skill.phases.length,
              (index) => ChoiceChip(
                key: ValueKey('muscle-phase-$index'),
                label: Text(
                  '${index + 1} ${widget.skill.phases[index].phaseName}',
                ),
                showCheckmark: false,
                selected: index == _phaseIndex,
                onSelected: (_) => _selectPhase(index),
              ),
            ),
          ),
          const SizedBox(height: 18),
          LessonCharacterFigure(
            asset: lesson.assetAt(_phaseIndex),
            title: _phase.phaseName,
            contact: _phaseIndex == timing.contactStep,
            contactPoint: lessonContactPoints[lesson.key],
            strokeDirection: lessonStrokeDirections[lesson.key],
          ),
          const SizedBox(height: 18),
          const Text(
            '主要／輔助／穩定是功能性教學分組，不是肌電活化排名。同一粗略區域可包含多種角色，圖色以主要分組優先；不能從顏色判斷肌肉強弱。',
            style: TextStyle(color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 12),
          _Section(
            icon: Icons.accessibility_new,
            title: '人體肌肉示意',
            child: MuscleBodyView(phase: _phase),
          ),
          _MuscleSection(
            title: '主要肌群',
            color: const Color(0xFFE34D59),
            muscles: _phase.primaryMuscles,
          ),
          _MuscleSection(
            title: '輔助肌群',
            color: const Color(0xFFF29E4C),
            muscles: _phase.secondaryMuscles,
          ),
          _MuscleSection(
            title: '穩定肌群',
            color: const Color(0xFF4385C6),
            muscles: _phase.stabilizingMuscles,
          ),
          _Section(
            icon: Icons.bolt,
            title: '發力說明',
            child: Text(
              _phase.forceDescription,
              style: const TextStyle(height: 1.65),
            ),
          ),
          _Section(
            icon: Icons.warning_amber_rounded,
            title: '常見錯誤',
            child: Column(
              children: _phase.mistakes
                  .map(
                    (mistake) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.close,
                            size: 18,
                            color: Color(0xFFB45309),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              mistake,
                              style: const TextStyle(height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          _Section(
            icon: Icons.my_location,
            title: '擊球點與時機',
            child: Text(
              '${timing.contact}\n\n準備放鬆：${timing.relax}\n\n發力：${timing.power}',
              style: const TextStyle(height: 1.6),
            ),
          ),
          _Section(
            icon: Icons.fitness_center_outlined,
            title: '可選基礎強化',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '先選 1–2 項，低負荷、無疼痛地試做；先熱身，組間充分休息。這是一般體能示例，不是針對傷痛的療程，也不保證強化某肌群就改善擊球。',
                  style: TextStyle(height: 1.6),
                ),
                ...muscleExerciseKeys[widget.skill.skillName]!.map((key) {
                  final exercise = muscleExercises[key]!;
                  return ExpansionTile(
                    key: ValueKey('muscle-exercise-$key'),
                    tilePadding: EdgeInsets.zero,
                    title: Text(exercise.title),
                    subtitle: Text(exercise.targets),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          '做法：${exercise.how}\n\n起始量：${exercise.dose}\n\n用途：${exercise.purpose}\n\n注意：${exercise.caution}',
                          style: const TextStyle(height: 1.6),
                        ),
                      ),
                    ],
                  );
                }),
                const Text(
                  '疼痛、麻木、暈眩或持續不適時停止；曾受傷或有疾病、手術後等情況，先由醫療／運動專業人員評估。',
                  style: TextStyle(color: Color(0xFF79552D), height: 1.5),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => SkillDetailScreen(
                  skill: trainingSkills.firstWhere(
                    (s) => s.name == widget.skill.skillName,
                  ),
                ),
              ),
            ),
            icon: const Icon(Icons.menu_book_outlined),
            label: const Text('回看這項動作的完整分解'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _phaseIndex == 0
                    ? null
                    : () => _selectPhase(_phaseIndex - 1),
                icon: const Icon(Icons.arrow_back),
                label: const Text('上一階段'),
              ),
              FilledButton.icon(
                onPressed: _phaseIndex == widget.skill.phases.length - 1
                    ? null
                    : () => _selectPhase(_phaseIndex + 1),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('下一階段'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '動漫圖與肌群標示是教學示意，不是肌電量測、精確握拍模型或醫療診斷。階段由你點選，不再使用影片時間。仍需教練實際校正。',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.all(21),
    decoration: BoxDecoration(
      color: const Color(0xFF123524),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.skill.skillName}  ${widget.skill.englishName}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.skill.overview,
          style: const TextStyle(color: Colors.white70, height: 1.55),
        ),
        const SizedBox(height: 15),
        const Text(
          '協調順序',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 7,
          children: List.generate(
            widget.skill.forceChain.length,
            (index) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    widget.skill.forceChain[index],
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                if (index < widget.skill.forceChain.length - 1)
                  const Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white54,
                      size: 13,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildPhaseStatus() => AnimatedContainer(
    duration: const Duration(milliseconds: 250),
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F5E9),
      borderRadius: BorderRadius.circular(17),
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFF1B5E20),
          foregroundColor: Colors.white,
          child: Text('${_phaseIndex + 1}'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '當前階段',
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
              Text(
                _phase.phaseName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${_phaseIndex + 1}/${widget.skill.phases.length}',
          style: const TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _MuscleSection extends StatelessWidget {
  final String title;
  final Color color;
  final List<String> muscles;

  const _MuscleSection({
    required this.title,
    required this.color,
    required this.muscles,
  });

  @override
  Widget build(BuildContext context) => _Section(
    icon: Icons.circle,
    iconColor: color,
    title: title,
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: muscles
          .map((muscle) => MuscleGroupChip(label: muscle, color: color))
          .toList(),
    ),
  );
}

class _Section extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final Widget child;

  const _Section({
    required this.icon,
    required this.title,
    required this.child,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 14),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 21, color: iconColor ?? const Color(0xFF1B5E20)),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    ),
  );
}
