import 'package:flutter/material.dart';

/// Handle-shape concept only; no hand anatomy or bevel numbering inferred.
class GripHandleGuide extends StatelessWidget {
  const GripHandleGuide({super.key});
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '先摸出拍柄的平面與斜面',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 2,
            child: CustomPaint(
              painter: _HandlePainter(
                Theme.of(context).textTheme.bodyMedium?.fontFamily,
              ),
            ),
          ),
          const Text(
            '這是拍柄橫切面的概念示意，不是固定握拍角度或手指壓力圖。實際拍柄尺寸、拍面方向與手型需配合確認。',
            style: TextStyle(color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    ),
  );
}

class _HandlePainter extends CustomPainter {
  final String? font;
  const _HandlePainter(this.font);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 320, size.height / 160);
    const points = [
      Offset(94, 30),
      Offset(146, 30),
      Offset(158, 43),
      Offset(158, 107),
      Offset(146, 120),
      Offset(94, 120),
      Offset(82, 107),
      Offset(82, 43),
    ];
    final path = Path()..addPolygon(points, true);
    canvas.drawPath(path, Paint()..color = const Color(0xFF344B3B));
    final green = Paint()
      ..color = const Color(0xFF70AA70)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final orange = Paint()
      ..color = const Color(0xFFE5A347)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(points[2], points[3], green);
    canvas.drawLine(points[7], points[0], orange);
    canvas.drawLine(
      const Offset(158, 72),
      const Offset(198, 72),
      green..strokeWidth = 1.5,
    );
    canvas.drawLine(
      const Offset(88, 35),
      const Offset(62, 21),
      orange..strokeWidth = 1.5,
    );
    void label(String text, Offset offset) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: font,
            fontSize: 14,
            color: const Color(0xFF344B3B),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, offset);
    }

    label('斜面', const Offset(22, 5));
    label('較寬平面', const Offset(205, 59));
    label('八面拍柄：形狀示意', const Offset(68, 132));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HandlePainter old) => old.font != font;
}
