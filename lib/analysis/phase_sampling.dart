/// Source-zero time grid. Range bounds validate a marker, never shift it.
class PhaseSampling {
  static const interval = .1;
  static int tick(double second) => (second / interval).round();
  static double second(int tick) => tick * interval;
  static int? inRange(double marker, double start, double end) {
    if (!marker.isFinite ||
        !start.isFinite ||
        !end.isFinite ||
        start < 0 ||
        end <= start) {
      return null;
    }
    final index = tick(marker), time = second(index);
    return time >= start && time < end ? index : null;
  }

  // Run fps BEFORE select, without range-relative input seeking. Same tick
  // uses the same source-zero grid even when range boundaries differ.
  static String filter(int index) =>
      'setpts=PTS-STARTPTS,fps=fps=10:start_time=0:round=near,select=eq(n\\,$index)';
}
