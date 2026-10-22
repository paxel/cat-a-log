import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:catalog_core/catalog_core.dart';
import 'package:catlog/l10n/app_localizations.dart';
import 'package:catlog/src/screens/play_screen.dart';
import 'package:catlog/src/screens/toy_screen.dart';
import 'package:catlog/src/toys/pace.dart';
import 'package:catlog/src/toys/pickup.dart';
import 'package:catlog/src/toys/toy.dart';
import 'package:catlog/src/toys/toy_sounds.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Duration ms(int n) => Duration(milliseconds: n);

void main() {
  group('pickup', () {
    test('a device lifted and held tilted counts after half a second', () {
      final p = PickupDetector();
      for (var i = 0; i < 5; i++) {
        expect(p.add(0, 0, 9.8, ms(i * 20)), isFalse);
      }
      // Tilted by 45 degrees.
      expect(p.add(0, 6.9, 6.9, ms(200)), isFalse);
      expect(p.add(0, 6.9, 6.9, ms(600)), isFalse);
      expect(p.add(0, 6.9, 6.9, ms(700)), isTrue);
    });

    test('a swat that jolts it for a moment is not a pickup', () {
      final p = PickupDetector();
      for (var i = 0; i < 5; i++) {
        p.add(0, 0, 9.8, ms(i * 20));
      }
      expect(p.add(9, 0, 3, ms(200)), isFalse);
      expect(p.add(0, 0, 9.8, ms(300)), isFalse);
      expect(p.add(9, 0, 3, ms(500)), isFalse);
      expect(p.add(9, 0, 3, ms(900)), isFalse, reason: 'tilted only 400 ms');
    });

    test('a device sliding over the floor stays flat', () {
      final p = PickupDetector();
      for (var i = 0; i < 5; i++) {
        p.add(0, 0, 9.8, ms(i * 20));
      }
      // Pushed sideways: a little acceleration in the plane.
      for (var t = 200; t < 3000; t += 50) {
        expect(p.add(2, 1, 9.8, ms(t)), isFalse);
      }
    });

    test('a tablet in a stand is measured against how it stood', () {
      final p = PickupDetector();
      for (var i = 0; i < 5; i++) {
        p.add(0, 8.5, 4.9, ms(i * 20)); // leaning back 60 degrees
      }
      expect(p.add(0, 8.5, 4.9, ms(2000)), isFalse);
      // Lifted out and laid flat in the hand.
      expect(p.add(0, 0, 9.8, ms(2100)), isFalse);
      expect(p.add(0, 0, 9.8, ms(2700)), isTrue);
    });
  });

  group('pace', () {
    test('speeds up with catches and slows down without them', () {
      final pace = Pace();
      pace.caught(ms(1000));
      pace.caught(ms(2000));
      expect(pace.factor, greaterThan(1.3));
      final fast = pace.factor;
      pace.tick(ms(2000) + Pace.patience);
      expect(pace.factor, lessThan(fast));
      for (var i = 2; i < 60; i++) {
        pace.tick(ms(2000) + Pace.patience * i);
      }
      expect(pace.factor, Pace.slowest);
      for (var i = 0; i < 40; i++) {
        pace.caught(ms(i));
      }
      expect(pace.factor, Pace.fastest);
    });
  });

  group('toys', () {
    const size = Size(400, 800);

    test('the dot stays on the screen, chirps on every dart, and flees', () {
      final dot = LaserDot(Random(1));
      var chirps = 0;
      for (var i = 0; i < 2000; i++) {
        if (dot.step(1 / 60, size, 1) == ToySound.chirp) chirps++;
        expect((Offset.zero & size).contains(dot.position), isTrue);
      }
      expect(chirps, greaterThan(5));
      final at = dot.position;
      expect(dot.touch(at + const Offset(10, 10), size), isTrue);
      expect(dot.touch(at + const Offset(200, 200), size), isFalse);
      for (var i = 0; i < 30; i++) {
        dot.step(1 / 60, size, 1);
      }
      expect((dot.position - at).distance, greaterThan(50));
    });

    test('the mouse runs, scurries, hides behind the border and comes back',
        () {
      final mouse = Mouse(Random(2));
      var scurries = 0, hidden = 0, shown = 0;
      for (var i = 0; i < 6000; i++) {
        if (mouse.step(1 / 60, size, 1) == ToySound.scurry) scurries++;
        if (mouse.visible) {
          shown++;
        } else {
          hidden++;
        }
      }
      expect(scurries, greaterThan(5));
      expect(hidden, greaterThan(100));
      expect(shown, greaterThan(hidden));
    });

    test('a caught mouse slips out behind the border', () {
      final mouse = Mouse(Random(3));
      while (!mouse.visible) {
        mouse.step(1 / 60, size, 1);
      }
      for (var i = 0; i < 30; i++) {
        mouse.step(1 / 60, size, 1);
      }
      if (!mouse.visible) return;
      expect(mouse.touch(mouse.position, size), isTrue);
      var gone = false;
      for (var i = 0; i < 60 && !gone; i++) {
        mouse.step(1 / 60, size, 1);
        gone = !mouse.visible;
      }
      expect(gone, isTrue);
    });

    test('the sounds are short mono WAV files', () {
      for (final sound in ToySound.values) {
        final bytes = toySound(sound);
        expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
        expect(String.fromCharCodes(bytes.sublist(8, 12)), 'WAVE');
        final seconds = (bytes.length - 44) / 2 / toySampleRate;
        expect(seconds, inInclusiveRange(0.03, 0.5));
      }
    });
  });

  group('the game', () {
    Future<Future<ToyResult?> Function()> host(
      WidgetTester tester,
      ToyKind kind,
      Stream<Motion> motion,
    ) async {
      late Future<ToyResult?> result;
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => result = Navigator.of(context).push<ToyResult>(
              MaterialPageRoute(
                builder: (_) => ToyScreen(
                  kind: kind,
                  sounds: false,
                  random: Random(4),
                  motion: () => motion,
                ),
              ),
            ),
            child: const Text('start'),
          ),
        ),
      ));
      return () => result;
    }

    testWidgets('picking the device up ends it', (tester) async {
      final motion = StreamController<Motion>();
      addTearDown(motion.close);
      final result = await host(tester, ToyKind.laserDot, motion.stream);
      await tester.tap(find.text('start'));
      await tester.pump();
      await tester.pump(ms(400));
      expect(find.byType(ToyScreen), findsOneWidget);
      for (var i = 0; i < 5; i++) {
        motion.add((x: 0, y: 0, z: 9.8));
        await tester.pump(ms(20));
      }
      motion.add((x: 0, y: 9.8, z: 0));
      await tester.pump(ms(300));
      motion.add((x: 0, y: 9.8, z: 0));
      expect(find.byType(ToyScreen), findsOneWidget);
      await tester.pump(ms(300));
      motion.add((x: 0, y: 9.8, z: 0));
      await tester.pumpAndSettle();
      expect(find.byType(ToyScreen), findsNothing);
      expect((await result())!.catches, 0);
    });

    testWidgets('a paw on the dot counts, the lock held for 3 s ends it',
        (tester) async {
      final result =
          await host(tester, ToyKind.laserDot, const Stream.empty());
      await tester.tap(find.text('start'));
      await tester.pump();
      await tester.pump(ms(300));
      // The dot starts in the middle and waits there a moment.
      await tester.tapAt(const Offset(200, 400));
      await tester.pump(ms(16));
      // Back does nothing, a tap on the lock does nothing.
      await tester.binding.handlePopRoute();
      await tester.pump(ms(16));
      final lock = find.byIcon(Icons.lock_outline);
      await tester.tap(lock);
      await tester.pump(ms(3500));
      expect(find.byType(ToyScreen), findsOneWidget);
      final hold = await tester.startGesture(tester.getCenter(lock));
      await tester.pump(); // the ring starts with the next frame
      await tester.pump(ms(2000));
      expect(find.byType(ToyScreen), findsOneWidget);
      await tester.pump(ms(1100));
      await hold.up();
      await tester.pumpAndSettle();
      expect(find.byType(ToyScreen), findsNothing);
      expect((await result())!.catches, 1);
    });
  });

  group('the Play page', () {
    late Directory dir;
    late CatalogStore store;

    setUpAll(useSystemSqlite);
    setUp(() {
      dir = Directory.systemTemp.createTempSync('catlog-play');
      store = CatalogStore.open('${dir.path}/catlog.db')..author = 'Patrick';
    });
    tearDown(() {
      store.close();
      dir.deleteSync(recursive: true);
    });

    testWidgets('starts a toy and shows how the game went', (tester) async {
      ToyKind? started;
      bool? withSounds;
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PlayScreen(
          store: store,
          open: (context, kind, sounds) async {
            started = kind;
            withSounds = sounds;
            return const ToyResult(14, Duration(minutes: 6, seconds: 20));
          },
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Laser dot'), findsOneWidget);
      await tester.tap(find.text('Toy sounds'));
      await tester.pump();
      await tester.tap(find.text('Mouse'));
      await tester.pumpAndSettle();
      expect(started, ToyKind.mouse);
      expect(withSounds, isFalse);
      expect(find.text('Last game: 14 catches in 6 minutes'), findsOneWidget);
    });
  });
}
