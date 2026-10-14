import 'package:flutter/material.dart';

import '../data/drive_lesson_data.dart';

const driveCharacterAssets = [
  'assets/images/drive/ready.png',
  'assets/images/drive/backswing-v2.png',
  'assets/images/drive/contact-v2.png',
  'assets/images/drive/recovery.png',
];

/// Static vector artwork: no video, network, ticker, timer or frame extraction.
class DrivePoseDiagram extends StatelessWidget {
  final DrivePose pose;
  final bool largeBackswing;

  const DrivePoseDiagram({
    super.key,
    required this.pose,
    this.largeBackswing = false,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    label: largeBackswing
        ? '錯誤幅度示意：引拍太大，球拍拉到身後'
        : '右手正手平球 ${driveLessonSteps[pose.index].title} 示意',
    image: true,
    child: RepaintBoundary(
      child: AspectRatio(
        aspectRatio: 340 / 230,
        child: largeBackswing
            ? CustomPaint(painter: _DrivePainter(pose, true))
            : LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(
                        painter: _DrivePainter(pose, false, courtOnly: true),
                      ),
                      Positioned(
                        left: constraints.maxWidth * 24 / 340,
                        top: constraints.maxHeight * 45 / 230,
                        width: constraints.maxWidth * 220 / 340,
                        height: constraints.maxHeight * 172 / 230,
                        child: Image.asset(
                          driveCharacterAssets[pose.index],
                          key: ValueKey('drive-character-${pose.index}'),
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomLeft,
                          cacheWidth: 512,
                          gaplessPlayback: true,
                          filterQuality: FilterQuality.medium,
                          errorBuilder: (context, error, stack) => const Center(
                            child: Text(
                              '圖解暫時無法載入，請參考下方文字。',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      if (pose == DrivePose.contact)
                        const IgnorePointer(
                          child: CustomPaint(painter: _DriveDirectionPainter()),
                        ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: IconButton(
                          key: const ValueKey('drive-enlarge'),
                          tooltip: '放大查看動作',
                          icon: const Icon(
                            Icons.zoom_in,
                            color: Color(0xFF496D51),
                          ),
                          onPressed: () => _showEnlarged(context),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    ),
  );

  void _showEnlarged(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                driveLessonSteps[pose.index].title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Flexible(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 3,
                  child: Image.asset(
                    driveCharacterAssets[pose.index],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stack) =>
                        const Text('圖片無法載入'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('可用雙指放大；示意圖仍需教練校正。'),
              const SizedBox(height: 8),
              TextButton(
                key: const ValueKey('drive-close-enlarged'),
                onPressed: () => Navigator.pop(context),
                child: const Text('關閉'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DriveDirectionPainter extends CustomPainter {
  const _DriveDirectionPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 340, size.height / 230);
    final paint = Paint()
      ..color = const Color(0xFFE0A02C)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(198, 73), const Offset(317, 73), paint);
    canvas.drawLine(const Offset(307, 66), const Offset(317, 73), paint);
    canvas.drawLine(const Offset(307, 80), const Offset(317, 73), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DriveDirectionPainter oldDelegate) => false;
}

class _DrivePainter extends CustomPainter {
  final DrivePose pose;
  final bool largeBackswing;
  final bool courtOnly;
  _DrivePainter(this.pose, this.largeBackswing, {this.courtOnly = false});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 340, size.height / 230);
    final ink = Paint()
      ..color = const Color(0xFF184B30)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final court = Paint()
      ..color = const Color(0xFFD6E4D7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 340, 230),
        const Radius.circular(16),
      ),
      Paint()..color = const Color(0xFFF0F5ED),
    );
    final floor = Path()
      ..moveTo(16, 215)
      ..lineTo(62, 149)
      ..lineTo(292, 149)
      ..lineTo(325, 215)
      ..close();
    canvas.drawPath(floor, court);
    canvas.drawLine(const Offset(25, 202), const Offset(318, 202), court);
    canvas.drawLine(const Offset(185, 149), const Offset(182, 215), court);
    // Net is a context marker, not a regulation-scale court drawing.
    canvas.drawLine(const Offset(276, 79), const Offset(276, 182), court);
    canvas.drawLine(const Offset(276, 84), const Offset(334, 92), court);
    canvas.drawLine(const Offset(276, 104), const Offset(334, 112), court);
    canvas.drawLine(const Offset(276, 124), const Offset(334, 132), court);
    canvas.drawLine(const Offset(276, 144), const Offset(334, 152), court);
    for (double x = 286; x < 340; x += 12) {
      canvas.drawLine(
        Offset(x, 85 + (x - 276) / 7),
        Offset(x, 145 + (x - 276) / 7),
        court,
      );
    }
    if (courtOnly) {
      canvas.restore();
      return;
    }
    // Keep the feet on the court but reduce the figure independently of it.
    // This leaves room for the racket, contact point and outgoing shuttle path.
    const figureScale = 0.78;
    const figureOrigin = Offset(23.1, 47.3);
    canvas.save();
    canvas.translate(figureOrigin.dx, figureOrigin.dy);
    canvas.scale(figureScale);
    canvas.drawCircle(
      const Offset(101, 44),
      13,
      Paint()..color = const Color(0xFF184B30),
    );
    canvas.drawLine(
      const Offset(102, 66),
      const Offset(104, 125),
      ink..strokeWidth = 16,
    );
    ink.strokeWidth = 9;
    canvas.drawLine(const Offset(105, 125), const Offset(84, 166), ink);
    canvas.drawLine(const Offset(84, 166), const Offset(69, 210), ink);
    canvas.drawLine(const Offset(105, 125), const Offset(130, 166), ink);
    canvas.drawLine(const Offset(130, 166), const Offset(148, 210), ink);
    canvas.drawLine(const Offset(62, 213), const Offset(80, 213), ink);
    canvas.drawLine(const Offset(141, 213), const Offset(158, 213), ink);
    canvas.drawLine(
      const Offset(98, 79),
      const Offset(75, 103),
      ink..strokeWidth = 7,
    );
    canvas.drawLine(const Offset(75, 103), const Offset(94, 118), ink);
    Offset elbow, hand, racket;
    if (largeBackswing) {
      elbow = const Offset(78, 75);
      hand = const Offset(57, 56);
      racket = const Offset(36, 32);
    } else {
      switch (pose) {
        case DrivePose.ready:
        case DrivePose.recovery:
          elbow = const Offset(131, 101);
          hand = const Offset(161, 94);
          racket = const Offset(194, 65);
        case DrivePose.backswing:
          elbow = const Offset(118, 94);
          hand = const Offset(145, 82);
          racket = const Offset(164, 54);
        case DrivePose.contact:
          elbow = const Offset(149, 90);
          hand = const Offset(191, 100);
          racket = const Offset(236, 102);
      }
    }
    canvas.drawLine(const Offset(110, 78), elbow, ink);
    canvas.drawLine(elbow, hand, ink);
    final activeArm = Paint()
      ..color = const Color(0xFFC98622)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(elbow, hand, activeArm);
    canvas.drawCircle(hand, 5, activeArm);
    final shaft = Paint()
      ..color = const Color(0xFF496D51)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    final direction = racket - hand;
    final nearEdge = racket - direction / direction.distance * 13;
    canvas.drawLine(hand, nearEdge, shaft);
    canvas.save();
    canvas.translate(racket.dx, racket.dy);
    canvas.rotate(direction.direction);
    canvas.drawOval(const Rect.fromLTWH(-17, -11, 34, 22), shaft);
    canvas.drawLine(
      const Offset(-13, 0),
      const Offset(13, 0),
      shaft..strokeWidth = 1,
    );
    canvas.drawLine(const Offset(0, -9), const Offset(0, 9), shaft);
    canvas.restore();
    canvas.restore();
    if (pose == DrivePose.contact && !largeBackswing) {
      final contact = racket * figureScale + figureOrigin;
      final arrow = Paint()
        ..color = const Color(0xFFE0A02C)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      final end = Offset(319, contact.dy);
      canvas.drawLine(contact + const Offset(7, 0), end, arrow);
      canvas.drawLine(end - const Offset(9, 6), end, arrow);
      canvas.drawLine(end - const Offset(9, -6), end, arrow);
      canvas.drawCircle(contact, 5, Paint()..color = const Color(0xFFE0A02C));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DrivePainter oldDelegate) =>
      pose != oldDelegate.pose ||
      largeBackswing != oldDelegate.largeBackswing ||
      courtOnly != oldDelegate.courtOnly;
}
