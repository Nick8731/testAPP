import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'ai_coach_screen.dart';
import 'muscle_training_screen.dart';
import 'skills_screen.dart';
import 'tactical_academy_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _open(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'SmashCoach',
        style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -.5),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 20),
          child: Icon(Icons.sports_tennis, size: 23),
        ),
      ],
    ),
    body: SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '把每一拍，打得更明白。',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '看懂動作・找到問題・帶上球場',
                  style: TextStyle(color: AppPalette.muted, height: 1.5),
                ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppPalette.ink,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '從這裡開始',
                        style: TextStyle(
                          color: AppPalette.lime,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '先看懂，再練好每一拍',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '從握拍到發力，用分解圖片一步步學習。',
                        style: TextStyle(color: Color(0xFFD3DFD8), height: 1.6),
                      ),
                      const SizedBox(height: 18),
                      const ExcludeSemantics(
                        child: SizedBox(
                          height: 42,
                          width: double.infinity,
                          child: CustomPaint(painter: _CourtPainter()),
                        ),
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        key: const ValueKey('home-start-learning'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppPalette.lime,
                          foregroundColor: AppPalette.ink,
                        ),
                        onPressed: () => _open(context, const SkillsScreen()),
                        icon: const Icon(Icons.arrow_forward, size: 20),
                        label: const Text(
                          '開始技術訓練',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                const Text(
                  '今天想練什麼？',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text(
                  '依照你的目標選擇，不必照順序。',
                  style: TextStyle(color: AppPalette.muted),
                ),
                const SizedBox(height: 14),
                _FeatureEntries(
                  children: [
                    _Entry(
                      icon: Icons.sports_tennis,
                      title: '技術訓練',
                      tag: '動作分解',
                      hint: '從握拍到擊球，找到想改善的技術',
                      onTap: () => _open(context, const SkillsScreen()),
                    ),
                    _Entry(
                      icon: Icons.center_focus_strong_outlined,
                      title: 'AI 動作分析',
                      tag: '影片觀察',
                      hint: '上傳練習影片，檢查姿勢與動作階段',
                      onTap: () => _open(context, const AiCoachScreen()),
                    ),
                    _Entry(
                      icon: Icons.grid_on_outlined,
                      title: '戰術學院',
                      tag: '場上應用',
                      hint: '單打與雙打的站位、落點及練習',
                      onTap: () =>
                          _open(context, const TacticalAcademyScreen()),
                    ),
                    _Entry(
                      icon: Icons.fitness_center,
                      title: '肌肉與發力',
                      tag: '發力原理',
                      hint: '對照技術，理解肌群與發力順序',
                      onTap: () => _open(context, const MuscleTrainingScreen()),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  '教材可直接閱讀；登入後可儲存 AI 分析紀錄。',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: AppPalette.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _FeatureEntries extends StatelessWidget {
  final List<Widget> children;
  const _FeatureEntries({required this.children});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 310 ||
          MediaQuery.textScalerOf(context).scale(14) > 17) {
        return Column(children: children);
      }
      return Column(
        children: [
          for (var index = 0; index < children.length; index += 2)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: children[index]),
                  const SizedBox(width: 12),
                  Expanded(child: children[index + 1]),
                ],
              ),
            ),
        ],
      );
    },
  );
}

class _Entry extends StatelessWidget {
  final IconData icon;
  final String title, tag, hint;
  final VoidCallback onTap;
  const _Entry({
    required this.icon,
    required this.title,
    required this.tag,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final compact =
        MediaQuery.sizeOf(context).width >= 350 &&
        MediaQuery.textScalerOf(context).scale(14) <= 17;
    if (compact) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          key: ValueKey('home-$title'),
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 24, color: AppPalette.ink),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: AppPalette.muted,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  tag,
                  style: const TextStyle(fontSize: 12, color: AppPalette.muted),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        key: ValueKey('home-$title'),
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF3E9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppPalette.ink),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppPalette.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      hint,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppPalette.muted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 19, color: AppPalette.ink),
            ],
          ),
        ),
      ),
    );
  }
}

// Decorative court motif only; no teaching positions or simulated scores.
class _CourtPainter extends CustomPainter {
  const _CourtPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(1, 1, size.width - 2, size.height - 2);
    final paint = Paint()
      ..color = const Color(0xFF729685)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(rect, paint);
    for (final x in [.06, .35, .5, .65, .94]) {
      canvas.drawLine(
        Offset(size.width * x, 1),
        Offset(size.width * x, size.height - 1),
        paint,
      );
    }
    for (final y in [.12, .88]) {
      canvas.drawLine(
        Offset(1, size.height * y),
        Offset(size.width - 1, size.height * y),
        paint,
      );
    }
    canvas.drawLine(
      Offset(1, size.height / 2),
      Offset(size.width * .35, size.height / 2),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * .65, size.height / 2),
      Offset(size.width - 1, size.height / 2),
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * .77, size.height * .38),
      5,
      Paint()..color = AppPalette.lime,
    );
  }

  @override
  bool shouldRepaint(covariant _CourtPainter oldDelegate) => false;
}
