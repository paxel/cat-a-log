import 'dart:math';

/// How fast a toy moves (#172): faster after every catch, slower when
/// the paws have stopped catching for a while, so a kitten and an old
/// cat both get a chase they can win.
class Pace {
  static const slowest = 0.5;
  static const fastest = 2.5;

  /// Catchless time after which the toy slows down a step.
  static const patience = Duration(seconds: 20);

  double factor = 1;
  Duration _since = Duration.zero;

  void caught(Duration at) {
    factor = min(fastest, factor * 1.15);
    _since = at;
  }

  void tick(Duration at) {
    if (at - _since < patience) return;
    factor = max(slowest, factor * 0.85);
    _since = at;
  }
}
