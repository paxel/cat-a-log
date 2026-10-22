import 'dart:math';
import 'dart:typed_data';

import 'toy.dart';

/// The toys' sounds, made here rather than shipped (#172): a squeak, a
/// chirp and a scurry, each a few hundredths of a second of 16-bit mono
/// WAV. Made once and kept.
const toySampleRate = 22050;

final Map<ToySound, Uint8List> _made = {};

Uint8List toySound(ToySound sound) => _made[sound] ??= wav(switch (sound) {
  ToySound.squeak => _sweep(0.13, 2200, 3900),
  ToySound.chirp => _sweep(0.06, 3300, 2500),
  ToySound.scurry => _scurry(),
});

/// A tone gliding from [from] to [to] hertz, faded in and out.
List<double> _sweep(double seconds, double from, double to) {
  final n = (seconds * toySampleRate).round();
  var phase = 0.0;
  return List.generate(n, (i) {
    final t = i / n;
    phase += 2 * pi * (from + (to - from) * t) / toySampleRate;
    return sin(pi * t) * sin(phase) * 0.6;
  });
}

/// Little feet on a floor: short bursts of rustling noise.
List<double> _scurry() {
  final random = Random(5);
  final n = (0.36 * toySampleRate).round();
  final burst = (0.022 * toySampleRate).round();
  final gap = (0.05 * toySampleRate).round();
  var last = 0.0;
  return List.generate(n, (i) {
    final into = i % gap;
    final noise = random.nextDouble() * 2 - 1;
    // The difference of two samples keeps the hiss and drops the rumble.
    final hiss = noise - last;
    last = noise;
    return into < burst ? sin(pi * into / burst) * hiss * 0.35 : 0.0;
  });
}

/// Samples between -1 and 1 as a WAV file.
Uint8List wav(List<double> samples, {int rate = toySampleRate}) {
  final data = ByteData(44 + samples.length * 2);
  void text(int at, String s) {
    for (var i = 0; i < s.length; i++) {
      data.setUint8(at + i, s.codeUnitAt(i));
    }
  }

  text(0, 'RIFF');
  data.setUint32(4, 36 + samples.length * 2, Endian.little);
  text(8, 'WAVE');
  text(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little); // PCM
  data.setUint16(22, 1, Endian.little); // mono
  data.setUint32(24, rate, Endian.little);
  data.setUint32(28, rate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  text(36, 'data');
  data.setUint32(40, samples.length * 2, Endian.little);
  for (var i = 0; i < samples.length; i++) {
    final v = (samples[i].clamp(-1.0, 1.0) * 32767).round();
    data.setInt16(44 + i * 2, v, Endian.little);
  }
  return data.buffer.asUint8List();
}
