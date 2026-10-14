import 'package:flutter/material.dart';

import 'dart:math' as math;

/// Uses decoded-size-limited offline artwork. No player, ticker or network work.
class LessonCharacterFigure extends StatelessWidget {
  final String asset, title;
  final bool contact;
  final (double, double)? contactPoint;
  final (double, double)? strokeDirection;
  const LessonCharacterFigure({
    super.key,
    required this.asset,
    required this.title,
    this.contact = false,
    this.contactPoint,
    this.strokeDirection,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: '右手持拍 $title，動漫動作示意',
    child: RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEDF3EA),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1.25,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        asset,
                        fit: BoxFit.contain,
                        cacheWidth: 512,
                        gaplessPlayback: true,
                        filterQuality: FilterQuality.medium,
                        errorBuilder: (_, _, _) =>
                            const Center(child: Text('圖解無法載入，請參考下方動作說明。')),
                      ),
                    ),
                  ),
                  if (contact && contactPoint != null)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _ContactPointPainter(
                            contactPoint!,
                            strokeDirection,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: IconButton(
                      key: const ValueKey('lesson-enlarge'),
                      tooltip: '放大查看完整動作',
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (context) => Dialog(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  title,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 12),
                                Flexible(
                                  child: InteractiveViewer(
                                    minScale: 1,
                                    maxScale: 3,
                                    child: Image.asset(
                                      asset,
                                      fit: BoxFit.contain,
                                      cacheWidth: 1024,
                                      errorBuilder: (_, _, _) =>
                                          const Text('圖片無法載入'),
                                    ),
                                  ),
                                ),
                                const Text('可雙指放大；握拍細節不能僅憑插圖判定。'),
                                TextButton(
                                  key: const ValueKey('lesson-close-enlarged'),
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('關閉'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.zoom_in),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                contact
                    ? strokeDirection != null
                          ? '橘點：觸球示意｜橘箭頭：短促下壓（非測量）'
                          : '橘點：示意觸球位置（非測量）｜配合下方說明'
                    : '右手持拍示範｜點放大鏡查看完整動作',
                style: const TextStyle(fontSize: 12, color: Color(0xFF48654B)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ContactPointPainter extends CustomPainter {
  final (double, double) point;
  final (double, double)? direction;
  const _ContactPointPainter(this.point, this.direction);
  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width - 24, size.height - 24);
    final center = Offset(
      (size.width - side) / 2 + point.$1 * side,
      (size.height - side) / 2 + point.$2 * side,
    );
    canvas.drawCircle(center, 7, Paint()..color = Colors.white);
    canvas.drawCircle(center, 5, Paint()..color = const Color(0xFFFF8C2A));
    canvas.drawCircle(
      center,
      12,
      Paint()
        ..color = const Color(0xFFFF8C2A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    if (direction case final vector?) {
      final offset = Offset(vector.$1 * side, vector.$2 * side);
      final length = offset.distance;
      if (length > 18) {
        final unit = offset / length;
        final end = center + offset;
        final normal = Offset(-unit.dy, unit.dx);
        final arrow = Paint()
          ..color = const Color(0xFFFF8C2A)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(center + unit * 14, end, arrow);
        canvas.drawLine(end, end - unit * 9 + normal * 5, arrow);
        canvas.drawLine(end, end - unit * 9 - normal * 5, arrow);
      }
    }
  }

  @override
  bool shouldRepaint(_ContactPointPainter old) =>
      old.point != point || old.direction != direction;
}
