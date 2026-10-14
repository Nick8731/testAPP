import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/shot_route_data.dart';

class ShotRouteCard extends StatelessWidget {
  final ShotRoute route;
  const ShotRouteCard({super.key, required this.route});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '${route.from} → ${route.to}',
        style: const TextStyle(fontWeight: FontWeight.bold, height: 1.5),
      ),
      const SizedBox(height: 12),
      const Center(
        child: Text('對方半場', style: TextStyle(color: Colors.black54)),
      ),
      const SizedBox(height: 4),
      Semantics(
        image: true,
        label: '${route.from}向${route.to}的俯視方向示意',
        child: RepaintBoundary(
          child: SizedBox(
            height: 270,
            width: double.infinity,
            child: CustomPaint(painter: _ShotCourtPainter(route)),
          ),
        ),
      ),
      const SizedBox(height: 4),
      const Center(
        child: Text('我方半場', style: TextStyle(color: Colors.black54)),
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 12,
        runSpacing: 6,
        children: [
          Text(
            '● ${route.trajectory.contains('推地') ? '移動起點' : '示範出球位置'}',
            style: const TextStyle(color: Color(0xFF2784CB)),
          ),
          Text(
            '● ${route.trajectory.contains('推地') ? '移動方向' : '常見目標區'}',
            style: const TextStyle(color: Color(0xFFAD680B)),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Text('球路／動作：${route.trajectory}', style: const TextStyle(height: 1.5)),
      const SizedBox(height: 8),
      Text(route.purpose, style: const TextStyle(height: 1.6)),
      const SizedBox(height: 8),
      Text(route.caution, style: const TextStyle(height: 1.6)),
      const SizedBox(height: 8),
      const Text(
        '俯視圖只表示方向和示例落點，不表示飛行高度、保證落點或唯一打法。白色橫粗線是球網；發球淡色區是此示例的有效接發球區。',
        style: TextStyle(color: Colors.black54, fontSize: 12, height: 1.5),
      ),
    ],
  );
}

class _ShotCourtPainter extends CustomPainter {
  final ShotRoute route;
  const _ShotCourtPainter(this.route);
  @override
  void paint(Canvas canvas, Size size) {
    // 13.4 x 6.1 m regulation court; singles sidelines 0.46 m inward,
    // short service lines 1.98 m from net; doubles rear service 0.76 m inward.
    final scale = math.min((size.width - 16) / 6.1, (size.height - 16) / 13.4);
    final court = Rect.fromLTWH(
      (size.width - 6.1 * scale) / 2,
      8,
      6.1 * scale,
      13.4 * scale,
    );
    Offset at(double x, double y) =>
        Offset(court.left + x * court.width, court.top + y * court.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(court.inflate(4), const Radius.circular(8)),
      Paint()..color = const Color(0xFF126340),
    );
    final line = Paint()
      ..color = Colors.white.withValues(alpha: .8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRect(court, line);
    final single = .46 / 6.1, short = 1.98 / 13.4, rear = .76 / 13.4;
    for (final x in [single, 1 - single]) {
      canvas.drawLine(at(x, 0), at(x, 1), line);
    }
    for (final y in [.5 - short, .5 + short, rear, 1 - rear]) {
      canvas.drawLine(at(0, y), at(1, y), line);
    }
    canvas.drawLine(at(.5, 0), at(.5, .5 - short), line);
    canvas.drawLine(at(.5, .5 + short), at(.5, 1), line);
    if (route.serve) {
      canvas.drawRect(
        Rect.fromPoints(
          at(route.singles ? single : 0, route.singles ? 0 : rear),
          at(.5, .5 - short),
        ),
        Paint()..color = const Color(0xFFFFC56C).withValues(alpha: .22),
      );
    }
    canvas.drawLine(
      at(0, .5),
      at(1, .5),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 3,
    );
    final origin = at(route.origin.$1, route.origin.$2),
        target = at(route.target.$1, route.target.$2);
    final area = Rect.fromCenter(
      center: target,
      width: court.width * .22,
      height: court.height * .08,
    ).intersect(court);
    canvas.drawRRect(
      RRect.fromRectAndRadius(area, const Radius.circular(5)),
      Paint()..color = const Color(0xFFFFC56C).withValues(alpha: .35),
    );
    final arrow = Paint()
      ..color = const Color(0xFFFFC56C)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(origin, target, arrow);
    final direction = target - origin;
    final unit = direction / direction.distance;
    final normal = Offset(-unit.dy, unit.dx);
    canvas.drawLine(target, target - unit * 9 + normal * 5, arrow);
    canvas.drawLine(target, target - unit * 9 - normal * 5, arrow);
    canvas.drawCircle(origin, 5, Paint()..color = const Color(0xFF76CAFF));
    canvas.drawCircle(target, 5, Paint()..color = const Color(0xFFFFC56C));
  }

  @override
  bool shouldRepaint(_ShotCourtPainter old) => old.route != route;
}
