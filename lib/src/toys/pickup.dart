import 'dart:math';

/// Tells a device that was picked up from one a cat is batting about
/// (#172). The first readings of gravity are where the device rests;
/// once it stays tilted away from that by more than [threshold] degrees
/// for [hold], it has been picked up. A swat that slides the device over
/// the floor keeps it flat, and a knock that jolts it is over before
/// [hold] runs out. Measured against the resting position, not against
/// flat, so a tablet in a stand works too.
class PickupDetector {
  final double threshold;
  final Duration hold;
  final int settle;

  PickupDetector({
    this.threshold = 30,
    this.hold = const Duration(milliseconds: 500),
    this.settle = 5,
  });

  final List<List<double>> _first = [];
  List<double>? _rest;
  Duration? _tiltedSince;

  /// One reading of the accelerometer, gravity included, at [at];
  /// true once the device counts as picked up.
  bool add(double x, double y, double z, Duration at) {
    final v = _unit(x, y, z);
    if (v == null) return false;
    final rest = _rest;
    if (rest == null) {
      _first.add(v);
      if (_first.length >= settle) {
        _rest = _unit(
          _first.fold(0.0, (s, e) => s + e[0]),
          _first.fold(0.0, (s, e) => s + e[1]),
          _first.fold(0.0, (s, e) => s + e[2]),
        );
      }
      return false;
    }
    final cos = (v[0] * rest[0] + v[1] * rest[1] + v[2] * rest[2])
        .clamp(-1.0, 1.0);
    final degrees = acos(cos) * 180 / pi;
    if (degrees < threshold) {
      _tiltedSince = null;
      return false;
    }
    final since = _tiltedSince ??= at;
    return at - since >= hold;
  }

  static List<double>? _unit(double x, double y, double z) {
    final length = sqrt(x * x + y * y + z * z);
    if (length < 1e-6) return null;
    return [x / length, y / length, z / length];
  }
}
