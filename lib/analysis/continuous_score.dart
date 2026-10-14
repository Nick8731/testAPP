class ContinuousScore {
  /// Smooth engineering transition around the legacy knee window, not a
  /// validated biomechanical prescription. Legacy plateau and weights remain.
  static int knee(double? angle) {
    if (angle == null || !angle.isFinite) return 0;
    final distance = angle < 125
        ? 125 - angle
        : angle > 165
        ? angle - 165
        : 0.0;
    return (90 - 20 * (distance / 5).clamp(0.0, 1.0)).round();
  }
}
