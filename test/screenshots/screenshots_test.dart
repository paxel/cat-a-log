// Screenshot generator, not a test suite: renders key screens with a
// demo catalog and real fonts, writing PNGs to docs/screenshots/.
//
// Regenerate with:
//   flutter test test/screenshots --run-skipped
@Tags(['screenshots'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:catalog_core/catalog_core.dart';
import 'package:catlog/l10n/app_localizations.dart';
import 'package:catlog/src/achievements.dart';
import 'package:catlog/src/screens/card_screen.dart';
import 'package:catlog/src/screens/cat_detail_screen.dart';
import 'package:catlog/src/screens/clowder_detail_screen.dart';
import 'package:catlog/src/screens/clowder_list_screen.dart';
import 'package:catlog/src/map/cached_tiles.dart';
import 'package:catlog/src/screens/map_screen.dart';
import 'package:catlog/src/screens/strays_screen.dart';
import 'package:catlog/src/screens/timeline_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:catlog/src/screens/field_graph_screen.dart';
import 'package:catlog/src/screens/agenda_screen.dart';
import 'package:catlog/src/fur_background.dart';
import 'package:catlog/src/pet_mode.dart';
import 'package:catlog/src/cover_picture.dart';
import 'package:catlog/src/screens/missing_poster_screen.dart';
import 'package:catlog/src/screens/vet_report_screen.dart';
import 'package:catlog/src/notes.dart';
import 'package:catlog/src/sync/sync_watch.dart';
import 'package:flutter/foundation.dart';

import 'demo.dart';

void main() {
  setUpAll(() async {
    useSystemSqlite();
    pinClock();
    await loadRealFonts();
  });

  // The coat under each page — pinned, so the shots are reproducible.
  const coats = {
    '01-home': FurPattern.tabby,
    '02-clowder': FurPattern.cheetah,
    '03-cat': FurPattern.rosettes,
    '04-card': FurPattern.paws,
    '05-timeline': FurPattern.tiger,
    '06-map': FurPattern.tabby,
    '07-graph': FurPattern.cheetah,
    '08-agenda': FurPattern.zebra,
    '09-poster': FurPattern.paws,
    '10-report': FurPattern.rosettes,
    '11-sync': FurPattern.tabby,
    '12-strays': FurPattern.zebra,
  };

  Future<void> shoot(
    WidgetTester tester,
    Widget home,
    String name, {
    Size physical = const Size(820, 1660),
    double dpr = 2,
  }) async {
    tester.view.physicalSize = physical;
    tester.view.devicePixelRatio = dpr;
    addTearDown(tester.view.reset);
    // The shot's own key is the tail: `12-achievements`, whatever the
    // store prefix (`tablet10-` carries digits of its own).
    activeFur = coats[RegExp(r'\d\d-[a-z]+$').firstMatch(name)!.group(0)!]!;
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
            scaffoldBackgroundColor: Colors.transparent,
          ),
          home: FurBackground(child: home),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    // Real time so Image.memory decoding and tile loading complete.
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 400)),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: dpr);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      // Flutter writes RGBA; App Store Connect refuses a screenshot with
      // an alpha channel. Three channels, nothing else changes.
      final rgb = img
          .decodePng(data!.buffer.asUint8List())!
          .convert(numChannels: 3);
      File('docs/screenshots/$name.png').writeAsBytesSync(img.encodePng(rgb));
    });
  }

  testWidgets('generate', (tester) async {
    // The home would open the agenda by itself (something is due): the
    // shot wants the home.
    agendaAutoOpened = true;
    final store = demoStore();
    addTearDown(store.close);
    final miezi = store.searchCats('Herr Sonnenschein').single.id;
    final home = store
        .clowders()
        .firstWhere((c) => c.name == 'Foster Home South')
        .id;
    // Achievements live in the app database: a manager on a temp dir,
    // fed from the demo's ticks.
    final root = Directory.systemTemp.createTempSync('catlog-shots');
    addTearDown(() => root.deleteSync(recursive: true));
    final manager = CatalogManager.open(root.path, defaultName: 'Demo');
    addTearDown(manager.close);
    recordLadders(manager, ladders(gatherStats([store], demoToday)), ago(1));

    final weight = store.fieldDefs().firstWhere((d) => d.slug == 'weight');
    // 1.3.x on the pages: a cover picture and a star on the home, the
    // strays' place, the smoothed line with its trend on the graph.
    await tester.runAsync(() async {
      await setCover(store, home, photo(4));
      await setCover(store, straysEntity, photo(5));
    });
    store.setLocalSetting('fav:$home', 'yes');
    store.setLocalSetting(graphSmoothKey, 'yes');
    store.setLocalSetting(graphTrendKey, 'yes');
    store.setLocalSetting(catalogNameKey, 'Foster homes');
    // The waiting note, as it looks when Marta's changes wait.
    final notes = NoteQueue();
    final watcher = SyncWatcher(
      store,
      folderOf: (_) => MemorySyncFolder(),
      notes: notes,
    )..announce(const UnseenChanges(3, {'Marta'}));
    addTearDown(watcher.dispose);
    // The poster's preview: the printing plugin is not there in a test,
    // pdftoppm is.
    Future<Uint8List?> preview(Uint8List pdf) async {
      final dir = Directory.systemTemp.createTempSync('poster');
      try {
        final file = File('${dir.path}/poster.pdf')..writeAsBytesSync(pdf);
        await Process.run('pdftoppm', [
          '-png',
          '-r',
          '150',
          '-singlefile',
          file.path,
          '${dir.path}/poster',
        ]);
        final png = File('${dir.path}/poster.png');
        return png.existsSync() ? png.readAsBytesSync() : null;
      } finally {
        dir.deleteSync(recursive: true);
      }
    }

    // Map with REAL pre-downloaded OSM tiles (test/screenshots/tiles,
    // fetched once by the tile script) — no network in tests.
    final tiles = DiskCachingTileProvider(Directory('test/screenshots/tiles'));

    final shots = <String, Widget Function()>{
      '01-home': () => ClowderListScreen(store: store),
      '02-clowder': () => ClowderDetailScreen(store: store, clowderId: home),
      '03-cat': () => CatDetailScreen(store: store, catId: miezi),
      '04-card': () => CardScreen(store: store, catId: miezi),
      '05-timeline': () => TimelineScreen(store: store, entityId: miezi),
      '06-map': () => MapScreen(store: store, tileProvider: tiles),
      '07-graph': () =>
          FieldGraphScreen(store: store, entityId: miezi, def: weight),
      '08-agenda': () => AgendaScreen(store: store, manager: manager),
      '09-poster': () =>
          MissingPosterScreen(store: store, catId: miezi, preview: preview),
      // The report previews like the poster; the shot is taken before
      // the preview has drawn, so the frame shows the page without it.
      '10-report': () =>
          VetReportScreen(store: store, catId: miezi, preview: preview),
      '11-sync': () => NoteStrip(
        queue: notes,
        busy: ValueNotifier(const {}),
        child: ClowderListScreen(store: store),
      ),
      '12-strays': () => StraysScreen(store: store),
    };

    // The docs set, then the store sets: Apple 6.9" iPhone (1320×2868
    // @3x) and 13" iPad (2064×2752 @2x); Google Play phone (9:16) and
    // 10-inch tablet.
    Directory('docs/screenshots/appstore').createSync(recursive: true);
    Directory('docs/screenshots/play').createSync(recursive: true);
    Directory('docs/screenshots/tablet').createSync(recursive: true);
    const phone = Size(1320, 2868);
    const pad = Size(2064, 2752);
    const play = Size(1080, 1920);
    const tablet = Size(1440, 2560);
    for (final entry in shots.entries) {
      await shoot(tester, entry.value(), entry.key);
      await shoot(
        tester,
        entry.value(),
        'appstore/iphone-${entry.key}',
        physical: phone,
        dpr: 3,
      );
      await shoot(
        tester,
        entry.value(),
        'appstore/ipad-${entry.key}',
        physical: pad,
        dpr: 2,
      );
      await shoot(
        tester,
        entry.value(),
        'play/play-${entry.key}',
        physical: play,
        dpr: 3,
      );
      await shoot(
        tester,
        entry.value(),
        'tablet/tablet10-${entry.key}',
        physical: tablet,
        dpr: 2,
      );
    }
    petMode.value = false;
  });
}
