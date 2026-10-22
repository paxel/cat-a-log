import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart' show BytesSource;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../l10n.dart';
import '../sounds.dart';
import '../toys/pace.dart';
import '../toys/pickup.dart';
import '../toys/toy.dart';
import '../toys/toy_sounds.dart';

/// How a game went, for the Play page to show once it is over.
class ToyResult {
  final int catches;
  final Duration played;
  const ToyResult(this.catches, this.played);
}

/// One reading of the accelerometer, gravity included.
typedef Motion = ({double x, double y, double z});

Stream<Motion> deviceMotion() => accelerometerEventStream()
    .map((e) => (x: e.x, y: e.y, z: e.z));

/// A toy for the cat (#172): the whole screen, dark, one toy moving on
/// it. Paws catch it; the game ends when the device is picked up or the
/// lock in the corner is held for three seconds, and never by back, a
/// swipe or a tap. The screen stays on until then.
class ToyScreen extends StatefulWidget {
  final ToyKind kind;
  final bool sounds;
  final Random? random;

  /// The accelerometer; a test passes its own.
  final Stream<Motion> Function() motion;

  const ToyScreen({
    super.key,
    required this.kind,
    this.sounds = true,
    this.random,
    this.motion = deviceMotion,
  });

  @override
  State<ToyScreen> createState() => _ToyScreenState();
}

class _ToyScreenState extends State<ToyScreen>
    with SingleTickerProviderStateMixin {
  late final Toy _toy = Toy(widget.kind, widget.random ?? Random());
  final _pace = Pace();
  final _pickup = PickupDetector();
  late final Ticker _ticker = createTicker(_frame);
  StreamSubscription<Motion>? _motion;
  Duration _now = Duration.zero;
  Duration _last = Duration.zero;
  Size _size = Size.zero;
  int _catches = 0;
  bool _over = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _quietly(WakelockPlus.enable);
    _motion = widget.motion().listen(
      (m) {
        if (_pickup.add(m.x, m.y, m.z, _now)) _end();
      },
      // No sensor: the lock is the way out.
      onError: (Object _) {},
      cancelOnError: true,
    );
    _ticker.start();
  }

  static void _quietly(Future<void> Function() call) {
    try {
      call().catchError((Object _) {});
    } catch (_) {
      // No wake lock on this device: the screen sleeps as it is set to.
    }
  }

  void _frame(Duration elapsed) {
    final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.1);
    _last = elapsed;
    _now = elapsed;
    if (_size.isEmpty) return;
    _pace.tick(elapsed);
    final sound = _toy.step(dt, _size, _pace.factor);
    if (sound != null) _play(sound);
    setState(() {});
  }

  void _play(ToySound sound) {
    if (!widget.sounds) return;
    playSource(BytesSource(toySound(sound), mimeType: 'audio/wav'));
  }

  void _paw(PointerDownEvent event) {
    if (_over || !_toy.touch(event.localPosition, _size)) return;
    _catches++;
    _pace.caught(_now);
    _play(ToySound.squeak);
  }

  void _end() {
    if (_over) return;
    _over = true;
    Navigator.of(context).pop(ToyResult(_catches, _now));
  }

  @override
  void dispose() {
    _ticker.dispose();
    _motion?.cancel();
    _quietly(WakelockPlus.disable);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: LayoutBuilder(builder: (context, box) {
          _size = box.biggest;
          return Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: _paw,
            child: Stack(children: [
              Positioned.fill(
                child: CustomPaint(painter: _ToyPainter(_toy, _now)),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: HoldLock(onHeld: _end, label: context.t.toyHoldToStop),
              ),
            ]),
          );
        }),
      ),
    );
  }
}

/// The way out a paw does not find: a small lock that has to be held
/// for [hold]. A ring fills while it is held; letting go empties it.
class HoldLock extends StatefulWidget {
  final VoidCallback onHeld;
  final String label;
  final Duration hold;

  const HoldLock({
    super.key,
    required this.onHeld,
    required this.label,
    this.hold = const Duration(seconds: 3),
  });

  @override
  State<HoldLock> createState() => _HoldLockState();
}

class _HoldLockState extends State<HoldLock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _held =
      AnimationController(vsync: this, duration: widget.hold)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) widget.onHeld();
        });

  @override
  void dispose() {
    _held.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      button: true,
      child: Listener(
        onPointerDown: (_) => _held.forward(from: 0),
        onPointerUp: (_) => _held.reset(),
        onPointerCancel: (_) => _held.reset(),
        child: SizedBox.square(
          dimension: 44,
          child: AnimatedBuilder(
            animation: _held,
            builder: (context, _) => Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(
                value: _held.value,
                strokeWidth: 3,
                color: Colors.white54,
                backgroundColor: Colors.white12,
              ),
              const Icon(Icons.lock_outline, size: 20, color: Colors.white38),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ToyPainter extends CustomPainter {
  final Toy toy;
  final Duration at;
  _ToyPainter(this.toy, this.at);

  @override
  void paint(Canvas canvas, Size size) {
    if (!toy.visible) return;
    switch (toy) {
      case LaserDot():
        _dot(canvas, toy.position, toy.radius);
      case Mouse():
        _mouse(canvas, toy.position, toy.radius, toy.heading);
    }
  }

  void _dot(Canvas canvas, Offset at, double r) {
    canvas.drawCircle(
      at,
      r * 2.6,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0x66FF1A1A),
          const Color(0x00FF1A1A),
        ]).createShader(Rect.fromCircle(center: at, radius: r * 2.6)),
    );
    canvas.drawCircle(at, r, Paint()..color = const Color(0xFFFF2020));
    canvas.drawCircle(at, r * 0.45, Paint()..color = const Color(0xFFFFB0B0));
  }

  void _mouse(Canvas canvas, Offset at, double r, double heading) {
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.rotate(heading);
    final fur = Paint()..color = const Color(0xFFB8B0A8);
    final pink = Paint()..color = const Color(0xFFE8A0A8);
    // The tail wags as it runs.
    final wag = sin(at.dx / 9 + at.dy / 9) * r * 0.5;
    canvas.drawPath(
      Path()
        ..moveTo(-r * 1.1, 0)
        ..quadraticBezierTo(-r * 2, wag, -r * 2.8, -wag),
      Paint()
        ..color = pink.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: r * 2.4, height: r * 1.5),
      fur,
    );
    canvas.drawCircle(Offset(r * 0.95, 0), r * 0.55, fur);
    canvas.drawCircle(Offset(r * 0.6, -r * 0.55), r * 0.32, pink);
    canvas.drawCircle(Offset(r * 0.6, r * 0.55), r * 0.32, pink);
    canvas.drawCircle(Offset(r * 1.45, 0), r * 0.12, pink);
    canvas.drawCircle(
      Offset(r * 1.1, -r * 0.2),
      r * 0.08,
      Paint()..color = Colors.black,
    );
    canvas.drawCircle(
      Offset(r * 1.1, r * 0.2),
      r * 0.08,
      Paint()..color = Colors.black,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ToyPainter old) => true;
}
