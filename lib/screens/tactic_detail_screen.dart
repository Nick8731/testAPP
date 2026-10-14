import '../data/tactic_sequences.dart';
import '../widgets/tactic_animation.dart';

import 'package:flutter/material.dart';

import '../data/tactics_data.dart';

class TacticDetailScreen extends StatelessWidget {
  final BadmintonTactic tactic;

  const TacticDetailScreen({super.key, required this.tactic});

  @override
  Widget build(BuildContext context) {
    final isSingles = tactic.mode == TacticMode.singles;
    return Scaffold(
      appBar: AppBar(title: Text(tactic.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF123524),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Tag(text: isSingles ? '單打' : '雙打'),
                    const SizedBox(width: 8),
                    _Tag(text: tactic.level),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  tactic.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tactic.subtitle,
                  style: const TextStyle(color: Colors.white70, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _TextSection(
            icon: Icons.flag_outlined,
            title: '戰術目的',
            child: Text(tactic.objective, style: const TextStyle(height: 1.65)),
          ),
          _TextSection(
            icon: Icons.grid_on_outlined,
            title: '場上站位',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TacticAnimation(sequence: tacticSequences[tactic.id]!),
                const SizedBox(height: 14),
                Text(tactic.formation, style: const TextStyle(height: 1.65)),
              ],
            ),
          ),
          _ListSection(
            icon: Icons.schedule_outlined,
            title: '什麼時候使用',
            items: tactic.situations,
          ),
          _StepSection(
            steps: tacticSequences[tactic.id]!.beats
                .map((b) => b.caption)
                .toList(),
          ),
          _ListSection(
            icon: Icons.visibility_outlined,
            title: '場上觀察重點',
            items: tactic.keyPoints,
            color: const Color(0xFF1B5E20),
          ),
          _ListSection(
            icon: Icons.warning_amber_rounded,
            title: '常見失誤',
            items: tactic.mistakes,
            color: const Color(0xFFB45309),
          ),
          _ListSection(
            icon: Icons.fitness_center_outlined,
            title: '練習方式',
            items: [
              '準備：${tacticSequences[tactic.id]!.setup}',
              '怎麼練：${tacticSequences[tactic.id]!.practice}',
              '檢查：${tacticSequences[tactic.id]!.check}',
              '進階：${tacticSequences[tactic.id]!.progression}',
              '先熱身、確認止滑與搭檔空間。先慢速定式，再隨機；有疼痛或失衡就停。',
            ],
            color: const Color(0xFF315CA8),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: Color(0xFF1B5E20)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '先把一個戰術練到能穩定執行，再加入第二種變化。比賽中簡單、清楚的選擇通常最有效。',
                    style: TextStyle(height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;

  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 12),
    ),
  );
}

class _TextSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _TextSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) =>
      _SectionShell(icon: icon, title: title, child: child);
}

class _ListSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;
  final Color color;

  const _ListSection({
    required this.icon,
    required this.title,
    required this.items,
    this.color = const Color(0xFF1B5E20),
  });

  @override
  Widget build(BuildContext context) => _SectionShell(
    icon: icon,
    title: title,
    child: Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item, style: const TextStyle(height: 1.5)),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    ),
  );
}

class _StepSection extends StatelessWidget {
  final List<String> steps;

  const _StepSection({required this.steps});

  @override
  Widget build(BuildContext context) => _SectionShell(
    icon: Icons.route_outlined,
    title: '場上執行順序',
    child: Column(
      children: List.generate(
        steps.length,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index == steps.length - 1 ? 0 : 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(steps[index], style: const TextStyle(height: 1.55)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SectionShell extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionShell({
    required this.icon,
    required this.title,
    required this.child,
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
              Icon(icon, color: const Color(0xFF1B5E20)),
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
