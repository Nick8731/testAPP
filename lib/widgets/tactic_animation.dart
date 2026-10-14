import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/tactic_sequences.dart';

class TacticAnimation extends StatefulWidget {
  final TacticSequence sequence;
  const TacticAnimation({super.key, required this.sequence});
  @override
  State<TacticAnimation> createState() => _TacticAnimationState();
}

class _TacticAnimationState extends State<TacticAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _beat = 0;
  bool _playing = false;
  TacticBeat get current => widget.sequence.beats[_beat];
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: current.milliseconds),
    )..addStatusListener(_status);
  }

  void _status(AnimationStatus status) {
    if (status != AnimationStatus.completed || !_playing || !mounted) return;
    if (_beat == widget.sequence.beats.length - 1) {
      setState(() => _playing = false);
    } else {
      setState(() => _beat++);
      _controller.duration = Duration(milliseconds: current.milliseconds);
      _controller.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(covariant TacticAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sequence != widget.sequence) {
      _playing = false;
      _beat = 0;
      _controller.stop();
      _controller.value = 0;
      _controller.duration = Duration(milliseconds: current.milliseconds);
    }
  }

  void _select(int i) {
    if (i < 0 || i >= widget.sequence.beats.length) return;
    _controller.stop();
    setState(() {
      _playing = false;
      _beat = i;
    });
    _controller.duration = Duration(milliseconds: current.milliseconds);
    _controller.value = 1;
  }

  void _toggle() {
    if (_playing) {
      _controller.stop();
      setState(() => _playing = false);
    } else {
      setState(() => _playing = true);
      if (_controller.value == 1) {
        _controller.forward(from: 0);
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_status);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('戰術動畫｜一拍一段', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Row(
        children: [
          Expanded(
            child: Text('我方（1、2）', style: TextStyle(color: Color(0xFF886000))),
          ),
          Text('對方（A、B）', style: TextStyle(color: Color(0xFFAC4545))),
        ],
      ),
      const SizedBox(height: 4),
      Semantics(
        image: true,
        label: current.caption,
        child: RepaintBoundary(
          child: AspectRatio(
            aspectRatio: 2.05,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: _TacticPainter(
                  current,
                  _controller.value,
                  widget.sequence.id,
                  Theme.of(context).textTheme.bodyMedium?.fontFamily,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      const Wrap(
        spacing: 12,
        runSpacing: 6,
        children: [
          Text(
            '藍色：球員移動',
            style: TextStyle(color: Color(0xFF2784CB), fontSize: 12),
          ),
          Text(
            '白色：球路與羽球',
            style: TextStyle(color: Color(0xFF48654B), fontSize: 12),
          ),
          Text(
            '淡橘：目標區',
            style: TextStyle(color: Color(0xFF9D6C14), fontSize: 12),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Text(
        '${_beat + 1}/${widget.sequence.beats.length} · ${current.caption}',
        key: const ValueKey('tactic-step-current'),
        style: const TextStyle(height: 1.6, fontWeight: FontWeight.w600),
      ),
      AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Slider(
          key: const ValueKey('tactic-scrub'),
          value: _controller.value,
          label: '本拍示意進度',
          onChanged: (v) {
            _controller.stop();
            setState(() => _playing = false);
            _controller.value = v;
          },
        ),
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            key: const ValueKey('tactic-previous'),
            onPressed: _beat == 0 ? null : () => _select(_beat - 1),
            icon: const Icon(Icons.chevron_left),
            label: const Text('上一步'),
          ),
          FilledButton.icon(
            key: const ValueKey('tactic-play'),
            onPressed: _toggle,
            icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
            label: Text(_playing ? '暫停' : '播放'),
          ),
          OutlinedButton.icon(
            key: const ValueKey('tactic-next'),
            onPressed: _beat == widget.sequence.beats.length - 1
                ? null
                : () => _select(_beat + 1),
            icon: const Icon(Icons.chevron_right),
            label: const Text('下一步'),
          ),
          TextButton.icon(
            onPressed: () {
              _controller.stop();
              setState(() {
                _beat = 0;
                _playing = true;
              });
              _controller.duration = Duration(
                milliseconds: current.milliseconds,
              );
              _controller.forward(from: 0);
            },
            icon: const Icon(Icons.replay),
            label: const Text('從頭播放'),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(widget.sequence.note, style: const TextStyle(height: 1.5)),
      const SizedBox(height: 8),
      const Text(
        '俯視路線只表示方向與責任；不表示球的飛行高度或實際比賽速度。每段播完會停，不自動無限循環。',
        style: TextStyle(color: Colors.black54, fontSize: 12, height: 1.5),
      ),
    ],
  );
}

class _TacticPainter extends CustomPainter {
  final TacticBeat beat;
  final double progress;
  final String id;
  final String? fontFamily;
  const _TacticPainter(this.beat, this.progress, this.id, this.fontFamily);
  void _arrow(Canvas canvas, Offset a, Offset b, Color color, double width) {
    if ((b - a).distance < 1) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;
    canvas.drawLine(a, b, paint);
    final unit = (b - a) / (b - a).distance, normal = Offset(-unit.dy, unit.dx);
    canvas.drawLine(b, b - unit * 6 + normal * 3, paint);
    canvas.drawLine(b, b - unit * 6 - normal * 3, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width - 16,
        height = math.min(size.height - 16, width * 6.1 / 13.4);
    final field = Rect.fromLTWH(8, (size.height - height) / 2, width, height);
    Offset at(Offset p) => Offset(
      field.left + p.dx * field.width,
      field.top + p.dy * field.height,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(field.inflate(5), const Radius.circular(8)),
      Paint()..color = const Color(0xFF08743E),
    );
    final line = Paint()
      ..color = Colors.white.withValues(alpha: .85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawRect(field, line);
    final side = .46 / 6.1, short = 1.98 / 13.4, rear = .76 / 13.4;
    for (final y in [side, 1 - side]) {
      canvas.drawLine(at(Offset(0, y)), at(Offset(1, y)), line);
    }
    for (final x in [rear, 1 - rear, .5 - short, .5 + short]) {
      canvas.drawLine(at(Offset(x, 0)), at(Offset(x, 1)), line);
    }
    canvas.drawLine(at(const Offset(0, .5)), at(Offset(.5 - short, .5)), line);
    canvas.drawLine(at(Offset(.5 + short, .5)), at(const Offset(1, .5)), line);
    canvas.drawLine(
      at(const Offset(.5, 0)),
      at(const Offset(.5, 1)),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 3,
    );
    if (id == 'doubles-serve-third-shot' &&
        beat.hitter == 0 &&
        beat.receiver == 2) {
      canvas.drawRect(
        Rect.fromPoints(at(Offset(.5 + short, 0)), at(Offset(1 - rear, .5))),
        Paint()..color = const Color(0xFFFFD166).withValues(alpha: .15),
      );
    }
    final target = at(beat.shuttleEnd);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: target, width: 24, height: 20).intersect(field),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFFFD166).withValues(alpha: .28),
    );
    for (var i = 0; i < beat.start.length; i++) {
      _arrow(
        canvas,
        at(beat.start[i]),
        at(beat.end[i]),
        const Color(0xFF8FD3FF).withValues(alpha: .75),
        1.6,
      );
    }
    _arrow(
      canvas,
      at(beat.shuttleStart),
      target,
      Colors.white.withValues(alpha: .65),
      1.5,
    );
    final t = Curves.easeInOut.transform(progress.clamp(0, 1));
    for (var i = 0; i < beat.start.length; i++) {
      final p = at(Offset.lerp(beat.start[i], beat.end[i], t)!);
      final ours = i < (beat.start.length == 4 ? 2 : 1);
      canvas.drawCircle(
        p,
        9,
        Paint()
          ..color = ours ? const Color(0xFFFFD166) : const Color(0xFFFF7B7B),
      );
      final label = ours
          ? '${i + 1}'
          : String.fromCharCode(65 + i - (beat.start.length == 4 ? 2 : 1));
      final text = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontFamily: fontFamily,
            color: Color(0xFF123524),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, p - Offset(text.width / 2, text.height / 2));
    }
    final shuttle = at(Offset.lerp(beat.shuttleStart, beat.shuttleEnd, t)!);
    canvas.drawCircle(shuttle, 3.3, Paint()..color = Colors.white);
    canvas.drawCircle(
      shuttle,
      3.3,
      Paint()
        ..color = const Color(0xFF123524)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .7,
    );
  }

  @override
  bool shouldRepaint(_TacticPainter old) =>
      old.beat != beat || old.progress != progress || old.id != id;
}
