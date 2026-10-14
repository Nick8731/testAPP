import 'package:flutter/material.dart';

import '../models/muscle_phase.dart';

class MuscleBodyView extends StatelessWidget {
  final MusclePhase phase;

  const MuscleBodyView({super.key, required this.phase});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: AspectRatio(
          key: ValueKey(phase.phaseName),
          aspectRatio: 1.55,
          child: CustomPaint(
            painter: _MuscleBodyPainter(
              phase,
              Theme.of(context).textTheme.bodyMedium?.fontFamily,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
      const SizedBox(height: 10),
      const Wrap(
        alignment: WrapAlignment.center,
        spacing: 14,
        runSpacing: 6,
        children: [
          _Legend(color: Color(0xFFE34D59), text: '主要肌群'),
          _Legend(color: Color(0xFFF29E4C), text: '輔助肌群'),
          _Legend(color: Color(0xFF4385C6), text: '穩定肌群'),
        ],
      ),
    ],
  );
}

class _Legend extends StatelessWidget {
  final Color color;
  final String text;

  const _Legend({required this.color, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 5),
      Text(text, style: const TextStyle(fontSize: 12, color: Colors.black54)),
    ],
  );
}

class _MuscleBodyPainter extends CustomPainter {
  final MusclePhase phase;

  final String? fontFamily;
  _MuscleBodyPainter(this.phase, this.fontFamily);

  static const _primary = Color(0xFFE34D59);
  static const _secondary = Color(0xFFF29E4C);
  static const _stabilizing = Color(0xFF4385C6);
  static const _body = Color(0xFFD9E1DB);

  Color? _regionColor(MuscleRegion region) {
    if (phase.primaryRegions.contains(region)) return _primary;
    if (phase.secondaryRegions.contains(region)) return _secondary;
    if (phase.stabilizingRegions.contains(region)) return _stabilizing;
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final panelPaint = Paint()..color = const Color(0xFFF3F7F3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(18)),
      panelPaint,
    );
    final halfWidth = size.width / 2;
    _drawFigure(
      canvas,
      Rect.fromLTWH(0, 0, halfWidth, size.height),
      isBack: false,
    );
    _drawFigure(
      canvas,
      Rect.fromLTWH(halfWidth, 0, halfWidth, size.height),
      isBack: true,
    );
    canvas.drawLine(
      Offset(halfWidth, 18),
      Offset(halfWidth, size.height - 18),
      Paint()..color = const Color(0xFFD7E1D8),
    );
  }

  void _drawFigure(Canvas canvas, Rect area, {required bool isBack}) {
    final center = Offset(area.center.dx, area.top + area.height * 0.47);
    final scale = area.height;
    final base = Paint()
      ..color = _body
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      Offset(center.dx, area.top + scale * 0.13),
      scale * 0.055,
      base,
    );
    final torso = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, area.top + scale * 0.34),
        width: scale * 0.18,
        height: scale * 0.27,
      ),
      const Radius.circular(14),
    );
    canvas.drawRRect(torso, base);
    base.strokeWidth = scale * 0.055;
    canvas.drawLine(
      Offset(center.dx - scale * 0.07, area.top + scale * 0.25),
      Offset(center.dx - scale * 0.15, area.top + scale * 0.55),
      base,
    );
    canvas.drawLine(
      Offset(center.dx + scale * 0.07, area.top + scale * 0.25),
      Offset(center.dx + scale * 0.15, area.top + scale * 0.55),
      base,
    );
    base.strokeWidth = scale * 0.068;
    canvas.drawLine(
      Offset(center.dx - scale * 0.045, area.top + scale * 0.48),
      Offset(center.dx - scale * 0.075, area.top + scale * 0.84),
      base,
    );
    canvas.drawLine(
      Offset(center.dx + scale * 0.045, area.top + scale * 0.48),
      Offset(center.dx + scale * 0.075, area.top + scale * 0.84),
      base,
    );

    _paintRegion(canvas, MuscleRegion.shoulders, [
      Rect.fromCenter(
        center: Offset(center.dx - scale * 0.08, area.top + scale * 0.245),
        width: scale * 0.075,
        height: scale * 0.065,
      ),
      Rect.fromCenter(
        center: Offset(center.dx + scale * 0.08, area.top + scale * 0.245),
        width: scale * 0.075,
        height: scale * 0.065,
      ),
    ]);
    if (!isBack) {
      _paintRegion(canvas, MuscleRegion.chest, [
        Rect.fromCenter(
          center: Offset(center.dx, area.top + scale * 0.31),
          width: scale * 0.145,
          height: scale * 0.075,
        ),
      ]);
      _paintRegion(canvas, MuscleRegion.quadriceps, [
        Rect.fromCenter(
          center: Offset(center.dx - scale * 0.055, area.top + scale * 0.62),
          width: scale * 0.06,
          height: scale * 0.2,
        ),
        Rect.fromCenter(
          center: Offset(center.dx + scale * 0.055, area.top + scale * 0.62),
          width: scale * 0.06,
          height: scale * 0.2,
        ),
      ]);
    } else {
      _paintRegion(canvas, MuscleRegion.upperBack, [
        Rect.fromCenter(
          center: Offset(center.dx, area.top + scale * 0.31),
          width: scale * 0.15,
          height: scale * 0.11,
        ),
      ]);
      _paintRegion(canvas, MuscleRegion.glutes, [
        Rect.fromCenter(
          center: Offset(center.dx, area.top + scale * 0.49),
          width: scale * 0.14,
          height: scale * 0.09,
        ),
      ]);
      _paintRegion(canvas, MuscleRegion.hamstrings, [
        Rect.fromCenter(
          center: Offset(center.dx - scale * 0.055, area.top + scale * 0.62),
          width: scale * 0.06,
          height: scale * 0.2,
        ),
        Rect.fromCenter(
          center: Offset(center.dx + scale * 0.055, area.top + scale * 0.62),
          width: scale * 0.06,
          height: scale * 0.2,
        ),
      ]);
    }
    _paintRegion(canvas, MuscleRegion.core, [
      Rect.fromCenter(
        center: Offset(center.dx, area.top + scale * 0.405),
        width: scale * 0.11,
        height: scale * 0.12,
      ),
    ]);
    _paintLimbRegion(canvas, MuscleRegion.upperArms, area, 0.3, 0.41, 0.052);
    _paintLimbRegion(canvas, MuscleRegion.forearms, area, 0.42, 0.54, 0.042);
    _paintLimbRegion(
      canvas,
      MuscleRegion.calves,
      area,
      0.7,
      0.84,
      0.052,
      legs: true,
    );

    final label = TextPainter(
      text: TextSpan(
        text: isBack ? '背面' : '正面',
        style: TextStyle(
          fontFamily: fontFamily,
          color: Colors.black54,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(
      canvas,
      Offset(area.center.dx - label.width / 2, area.bottom - 22),
    );
  }

  void _paintRegion(Canvas canvas, MuscleRegion region, List<Rect> areas) {
    final color = _regionColor(region);
    if (color == null) return;
    for (final area in areas) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(area, Radius.circular(area.shortestSide / 2)),
        Paint()..color = color.withValues(alpha: 0.9),
      );
    }
  }

  void _paintLimbRegion(
    Canvas canvas,
    MuscleRegion region,
    Rect area,
    double startY,
    double endY,
    double width, {
    bool legs = false,
  }) {
    final color = _regionColor(region);
    if (color == null) return;
    final scale = area.height;
    final centerX = area.center.dx;
    final offset = legs ? scale * 0.058 : scale * 0.11;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..strokeWidth = scale * width
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(centerX - offset, area.top + scale * startY),
      Offset(centerX - offset * (legs ? 1.28 : 1.3), area.top + scale * endY),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + offset, area.top + scale * startY),
      Offset(centerX + offset * (legs ? 1.28 : 1.3), area.top + scale * endY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _MuscleBodyPainter oldDelegate) =>
      oldDelegate.phase != phase;
}
