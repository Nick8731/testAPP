import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/analysis/phase_sampling.dart';
import 'package:test_app/analysis/continuous_score.dart';
import 'package:test_app/widgets/phase_marker_controls.dart';

void main() {
  test('nick兩個邊界區間固定同一人工標記，不隨起點移動', () {
    final a = PhaseSampling.inRange(25.61, 20.299, 33.703);
    final b = PhaseSampling.inRange(25.61, 20.101, 33.103);
    expect(a, 256);
    expect(b, a);
    expect(PhaseSampling.second(a!), closeTo(25.6, .000001));
    expect(PhaseSampling.filter(a), PhaseSampling.filter(b!));
    expect(PhaseSampling.filter(a), contains('fps=fps=10:start_time=0'));
    expect(PhaseSampling.filter(a), endsWith('select=eq(n\\,256)'));
  });
  test('標記離開區間不改成邊界或替代最高分', () {
    expect(PhaseSampling.inRange(25.6, 26, 33), isNull);
    expect(PhaseSampling.inRange(25.6, 20, 25.6), isNull);
    expect(PhaseSampling.inRange(double.nan, 0, 10), isNull);
    expect(PhaseSampling.inRange(1, 3, 2), isNull);
    expect(PhaseSampling.tick(0), 0);
    expect(PhaseSampling.tick(25.64), PhaseSampling.tick(25.61));
  });
  test('膝蓋125及165附近微小變化不再跳20分', () {
    expect(ContinuousScore.knee(124.9), 90);
    expect(ContinuousScore.knee(125.1), 90);
    expect(ContinuousScore.knee(164.9), 90);
    expect(ContinuousScore.knee(165.1), 90);
    expect(ContinuousScore.knee(122.5), 80);
    expect(ContinuousScore.knee(167.5), 80);
    expect(ContinuousScore.knee(120), 70);
    expect(ContinuousScore.knee(170), 70);
    expect(ContinuousScore.knee(null), 0);
    expect(ContinuousScore.knee(double.nan), 0);
    for (var angle = 100.0; angle < 180; angle += .1) {
      expect(
        (ContinuousScore.knee(angle) - ContinuousScore.knee(angle + .1)).abs(),
        lessThanOrEqualTo(1),
      );
    }
  });
  testWidgets('人工階段標記可操作，忙碌時不可改動', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var marks = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PhaseMarkerControls(
              phase: PhaseMarkerControls.phases.first,
              second: 25.6,
              busy: false,
              onMark: () => marks++,
              onPhase: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('phase-mark')));
    expect(marks, 1);
    expect(find.textContaining('25.600'), findsOneWidget);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PhaseMarkerControls(
            phase: PhaseMarkerControls.phases.first,
            second: null,
            busy: true,
            onMark: () => marks++,
            onPhase: (_) {},
          ),
        ),
      ),
    );
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(const ValueKey('phase-mark')))
          .onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });
}
