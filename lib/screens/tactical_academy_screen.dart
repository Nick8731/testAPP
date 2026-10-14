import 'package:flutter/material.dart';

import '../data/tactics_data.dart';
import 'tactic_detail_screen.dart';

class TacticalAcademyScreen extends StatefulWidget {
  const TacticalAcademyScreen({super.key});

  @override
  State<TacticalAcademyScreen> createState() => _TacticalAcademyScreenState();
}

class _TacticalAcademyScreenState extends State<TacticalAcademyScreen> {
  TacticMode _mode = TacticMode.singles;

  @override
  Widget build(BuildContext context) {
    final tactics = badmintonTactics
        .where((tactic) => tactic.mode == _mode)
        .toList();
    final isSingles = _mode == TacticMode.singles;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '戰術學院',
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
                Icon(Icons.grid_on_rounded, color: Colors.white, size: 32),
                SizedBox(height: 12),
                Text(
                  '懂得為什麼這樣打，\n才能在場上做出選擇。',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    height: 1.35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '從使用時機、站位到下一拍銜接，建立真正能用在比賽中的戰術思維。',
                  style: TextStyle(color: Colors.white70, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<TacticMode>(
              segments: const [
                ButtonSegment(
                  value: TacticMode.singles,
                  icon: Icon(Icons.person_outline),
                  label: Text('單打戰術'),
                ),
                ButtonSegment(
                  value: TacticMode.doubles,
                  icon: Icon(Icons.groups_outlined),
                  label: Text('雙打戰術'),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (selection) {
                setState(() => _mode = selection.first);
              },
            ),
          ),
          const SizedBox(height: 20),
          _PrincipleCard(
            title: isSingles ? '單打核心：空間與節奏' : '雙打核心：下壓與輪轉',
            points: isSingles
                ? const ['先讓對手移動，再攻擊空檔', '擊球後回到合理基地', '被動先求穩定，主動才加速']
                : const ['進攻前後站，防守左右站', '非擊球者也必須隨球補位', '用簡短口令提早分工'],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Text(
                isSingles ? '單打課程' : '雙打課程',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${tactics.length} 個戰術',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tactics.map(
            (tactic) => _TacticCard(
              tactic: tactic,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TacticDetailScreen(tactic: tactic),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PrincipleCard extends StatelessWidget {
  final String title;
  final List<String> points;

  const _PrincipleCard({required this.title, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(point)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TacticCard extends StatelessWidget {
  final BadmintonTactic tactic;
  final VoidCallback onTap;

  const _TacticCard({required this.tactic, required this.onTap});

  IconData get icon {
    if (tactic.id.contains('defense')) {
      return Icons.shield_outlined;
    }
    if (tactic.id.contains('serve')) {
      return Icons.sports_tennis;
    }
    if (tactic.id.contains('communication')) {
      return Icons.record_voice_over_outlined;
    }
    if (tactic.id.contains('rotation')) {
      return Icons.sync;
    }
    if (tactic.id.contains('net') || tactic.id.contains('front')) {
      return Icons.vertical_align_top;
    }
    return Icons.route_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('tactic-${tactic.id}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: const Color(0xFF1B5E20)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tactic.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F2F0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tactic.level,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      tactic.subtitle,
                      style: const TextStyle(color: Colors.grey, height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
