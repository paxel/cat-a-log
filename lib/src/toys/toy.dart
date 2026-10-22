import 'dart:math';
import 'dart:ui';

/// The two toys of the Play page (#172).
enum ToyKind { laserDot, mouse }

/// What a toy says while it moves; the screen turns it into a sound.
enum ToySound { squeak, chirp, scurry }

/// A toy on the screen: it moves by itself and runs away when a paw
/// catches it. [step] and [touch] are all the game asks of it, so the
/// screen draws and counts the same way for both.
abstract class Toy {
  /// Where its middle is, in logical pixels of the screen.
  Offset get position;

  /// How big it is drawn; a paw within twice this catches it.
  double get radius;

  /// The way it faces, in radians; the mouse is drawn along it.
  double get heading;

  /// False while it hides behind the screen's border.
  bool get visible;

  /// Moves on by [dt] seconds at [speed] (1 is the calm pace) inside a
  /// screen of [size]; the sound to make, if any.
  ToySound? step(double dt, Size size, double speed);

  /// A paw at [point]: true when that caught the toy, which then runs.
  bool touch(Offset point, Size size);

  factory Toy(ToyKind kind, Random random) => switch (kind) {
    ToyKind.laserDot => LaserDot(random),
    ToyKind.mouse => Mouse(random),
  };
}

/// A red dot that darts to a spot, waits there, and darts on.
class LaserDot implements Toy {
  final Random random;
  LaserDot(this.random);

  static const _speed = 700.0;

  Offset? _at;
  Offset _target = Offset.zero;
  double _wait = 0.4;

  @override
  Offset get position => _at ?? Offset.zero;

  @override
  double get radius => 14;

  @override
  double get heading => 0;

  @override
  bool get visible => _at != null;

  Offset _spot(Size size) {
    final margin = radius * 3;
    return Offset(
      margin + random.nextDouble() * max(1, size.width - 2 * margin),
      margin + random.nextDouble() * max(1, size.height - 2 * margin),
    );
  }

  @override
  ToySound? step(double dt, Size size, double speed) {
    final at = _at ??= size.center(Offset.zero);
    if (_wait > 0) {
      _wait -= dt;
      if (_wait > 0) return null;
      _target = _spot(size);
      return ToySound.chirp;
    }
    final way = _target - at;
    final reach = _speed * speed * dt;
    if (way.distance <= reach) {
      _at = _target;
      _wait = (0.2 + random.nextDouble() * 1.3) / speed;
    } else {
      _at = at + way / way.distance * reach;
    }
    return null;
  }

  @override
  bool touch(Offset point, Size size) {
    if (_at == null || (point - position).distance > radius * 2.5) {
      return false;
    }
    // Caught: off to the farthest of a few spots, at once.
    _target = List.generate(4, (_) => _spot(size)).reduce(
      (a, b) => (a - point).distance > (b - point).distance ? a : b,
    );
    _wait = 0;
    return true;
  }
}

enum _Phase { run, leave, hidden, enter }

/// A mouse that runs along the edges of the screen, slips out behind
/// the border, and peeks back in somewhere else.
class Mouse implements Toy {
  final Random random;
  Mouse(this.random);

  static const _speed = 320.0;
  static const _inset = 44.0;
  static const _slip = 0.35;

  _Phase _phase = _Phase.enter;
  double _left = _slip;
  double _along = 0;
  double _direction = 1;
  double _out = 1;
  double _length = _slip;
  bool _placed = false;

  @override
  double get radius => 22;

  Size _size = Size.zero;

  @override
  Offset get position => _track(_along).$1 + _track(_along).$2 * _outset;

  @override
  double get heading {
    final tangent = _track(_along).$3 * _direction;
    return atan2(tangent.dy, tangent.dx);
  }

  @override
  bool get visible => _phase != _Phase.hidden;

  double get _outset => _out * (_inset + radius * 2);

  double get _perimeter =>
      2 * (max(1, _size.width - 2 * _inset) + max(1, _size.height - 2 * _inset));

  /// The point of the track [s] along it, the outward normal there and
  /// the way forward.
  (Offset, Offset, Offset) _track(double s) {
    final w = max(1.0, _size.width - 2 * _inset);
    final h = max(1.0, _size.height - 2 * _inset);
    var d = s % (2 * (w + h));
    if (d < w) {
      return (Offset(_inset + d, _inset), const Offset(0, -1), const Offset(1, 0));
    }
    d -= w;
    if (d < h) {
      return (Offset(_inset + w, _inset + d), const Offset(1, 0), const Offset(0, 1));
    }
    d -= h;
    if (d < w) {
      return (Offset(_inset + w - d, _inset + h), const Offset(0, 1), const Offset(-1, 0));
    }
    d -= w;
    return (Offset(_inset, _inset + h - d), const Offset(-1, 0), const Offset(0, -1));
  }

  void _somewhereElse() {
    _along = random.nextDouble() * _perimeter;
    _direction = random.nextBool() ? 1 : -1;
  }

  @override
  ToySound? step(double dt, Size size, double speed) {
    _size = size;
    if (!_placed) {
      _placed = true;
      _somewhereElse();
    }
    _left -= dt * speed;
    switch (_phase) {
      case _Phase.run:
        _along += _direction * _speed * speed * dt;
        if (_left <= 0) {
          if (random.nextDouble() < 0.4) {
            _phase = _Phase.leave;
            _left = _length = _slip;
          } else {
            // A stop and a turn now and then, then off again.
            if (random.nextDouble() < 0.5) _direction = -_direction;
            _left = 1 + random.nextDouble() * 2.5;
            return ToySound.scurry;
          }
        }
      case _Phase.leave:
        _out = 1 - max(0.0, _left) / _length;
        if (_left <= 0) {
          _phase = _Phase.hidden;
          _left = 1 + random.nextDouble() * 2;
        }
      case _Phase.hidden:
        if (_left <= 0) {
          _somewhereElse();
          _phase = _Phase.enter;
          _left = _slip;
        }
      case _Phase.enter:
        _out = max(0.0, _left) / _slip;
        if (_left <= 0) {
          _out = 0;
          _phase = _Phase.run;
          _left = 1 + random.nextDouble() * 2.5;
          return ToySound.scurry;
        }
    }
    return null;
  }

  @override
  bool touch(Offset point, Size size) {
    if (!visible || (point - position).distance > radius * 2) return false;
    // Caught: it turns and slips away behind the nearest border.
    _direction = -_direction;
    _phase = _Phase.leave;
    _left = _length = _slip / 2;
    return true;
  }
}
