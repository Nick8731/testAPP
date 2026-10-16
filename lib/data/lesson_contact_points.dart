/// Hand-reviewed locations on the *illustration* (not a detected shuttle or
/// prescribed physical angle). Normalized to the padded 512x512 PNG.
const lessonContactPoints = <String, (double, double)>{
  'push': (.900, .245),
  'net_kill': (.882, .182),
  'serve_short': (.780, .549),
  'serve_high': (.720, .620),
  'clear': (.401, .062),
  'drive': (.877, .160),
  'smash': (.756, .123),
  'lift': (.902, .680),
  'drop': (.730, .108),
  'slice': (.770, .113),
  'net': (.903, .430),
  'defence': (.890, .418),
};

/// Short outgoing direction on the illustration, not a measured flight path.
const lessonStrokeDirections = <String, (double, double)>{
  'net_kill': (.025, .14),
};
