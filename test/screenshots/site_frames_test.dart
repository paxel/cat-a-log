// The phone frames of the documentation site (#161), not a test suite:
// every page of the Phone and Start tracks and every step of every phone
// flow, in English and German, written to site/assets/frames/phone/<lang>/.
// Deterministic: the demo's day is pinned, the fonts are real, the tiles
// come from disk; CI regenerates them and fails on a diff.
//
// Regenerate with:
//   flutter test test/screenshots/site_frames_test.dart --run-skipped --concurrency=1
@Tags(['screenshots'])
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:catalog_core/catalog_core.dart';
import 'package:catlog/src/achievements.dart';
import 'package:catlog/src/cover_picture.dart';
import 'package:catlog/src/field_labels.dart';
import 'package:catlog/src/flier_capture.dart';
import 'package:catlog/src/flier_ocr.dart';
import 'package:catlog/src/flier_template.dart';
import 'package:catlog/src/fur_background.dart';
import 'package:catlog/src/geocode.dart';
import 'package:catlog/src/map/cached_tiles.dart';
import 'package:catlog/src/notes.dart';
import 'package:catlog/src/pet_mode.dart';
import 'package:catlog/src/screens/achievements_screen.dart';
import 'package:catlog/src/screens/agenda_screen.dart';
import 'package:catlog/src/screens/archive_screen.dart';
import 'package:catlog/src/screens/backups_screen.dart';
import 'package:catlog/src/screens/card_screen.dart';
import 'package:catlog/src/screens/cat_detail_screen.dart';
import 'package:catlog/src/screens/clowder_detail_screen.dart';
import 'package:catlog/src/screens/clowder_list_screen.dart';
import 'package:catlog/src/screens/conflicts_screen.dart';
import 'package:catlog/src/screens/duplicates_screen.dart';
import 'package:catlog/src/screens/field_graph_screen.dart';
import 'package:catlog/src/screens/field_history_screen.dart';
import 'package:catlog/src/screens/fields_screen.dart';
import 'package:catlog/src/screens/go_back_screen.dart';
import 'package:catlog/src/screens/map_screen.dart';
import 'package:catlog/src/screens/messenger_screen.dart';
import 'package:catlog/src/screens/missing_poster_screen.dart';
import 'package:catlog/src/screens/moderation_screen.dart';
import 'package:catlog/src/screens/photo_viewer_screen.dart';
import 'package:catlog/src/screens/remote_screen.dart';
import 'package:catlog/src/screens/settings_screen.dart';
import 'package:catlog/src/screens/strays_screen.dart';
import 'package:catlog/src/screens/sync_screen.dart';
import 'package:catlog/src/screens/timeline_screen.dart';
import 'package:catlog/src/screens/vet_report_screen.dart';
import 'package:catlog/src/sync/sync_watch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../flier_fixtures.dart';
import 'demo.dart';

/// `--dart-define=SITE_LANGS=en` frames one language while iterating.
const _langs = String.fromEnvironment('SITE_LANGS', defaultValue: 'en,de');

/// The poster's and the report's preview: pdftoppm stands in for the
/// printing plugin, which is not there in a test.
Future<Uint8List?> _preview(Uint8List pdf) async {
  final dir = Directory.systemTemp.createTempSync('poster');
  try {
    final file = File('${dir.path}/doc.pdf')..writeAsBytesSync(pdf);
    await Process.run('pdftoppm', [
      '-png', '-r', '150', '-singlefile', file.path, '${dir.path}/doc',
    ]);
    final png = File('${dir.path}/doc.png');
    return png.existsSync() ? png.readAsBytesSync() : null;
  } finally {
    dir.deleteSync(recursive: true);
  }
}

void main() {
  setUpAll(() async {
    useSystemSqlite();
    pinClock();
    await loadRealFonts();
  });

  for (final lang in _langs.split(',')) {
    testWidgets('phone frames $lang', (tester) async {
      agendaAutoOpened = true;
      final s = Shooter(tester, lang, 'site/assets/frames/phone/$lang');
      addTearDown(tester.view.reset);
      final t = s.t;
      final store = demoStore();
      addTearDown(store.close);
      String cat(String name) => store.cats().firstWhere((c) => c.name == name).id;
      final miezi = cat('Herr Sonnenschein');
      final luna = cat('Luna');
      final pumpkin = cat('Pumpkin');
      final home = store.clowders().firstWhere((c) => c.name == 'Foster Home South').id;
      final weight = store.fieldDefs().firstWhere((d) => d.slug == 'weight');
      final root = Directory.systemTemp.createTempSync('catlog-frames');
      addTearDown(() => root.deleteSync(recursive: true));
      final manager = CatalogManager.open(root.path, defaultName: 'Demo');
      addTearDown(manager.close);
      recordLadders(manager, ladders(gatherStats([store], demoToday)), ago(1));
      await tester.runAsync(() async {
        await setCover(store, home, photo(4));
        await setCover(store, straysEntity, photo(5));
      });
      store.setLocalSetting('fav:$home', 'yes');
      store.setLocalSetting(graphSmoothKey, 'yes');
      store.setLocalSetting(graphTrendKey, 'yes');
      store.setLocalSetting(catalogNameKey, lang == 'de' ? 'Pflegestellen' : 'Foster homes');
      // A second Findus, so the duplicates page has something to show,
      // and a value two people changed at once for the conflicts page.
      final findus2 = store.createCat('Findus', date: ago(5));
      store.append(findus2, 'f:color', 'ginger & white', date: ago(5), as: 'Marta');
      store.recordPosition(findus2, 52.5170, 13.4040, date: ago(5));
      final other = CatalogStore.inMemory()..author = 'Marta';
      addTearDown(other.close);
      other.applyEntries(store.entriesSince(const {}), senderVector: store.versionVector());
      store.append(miezi, 'f:remarks', 'Eats only in the morning now', date: ago(1));
      other.append(miezi, 'f:remarks', 'Needs the diet food', date: ago(1, hour: 11));
      store.applyEntries(other.entriesSince(store.versionVector()), senderVector: other.versionVector());
      // A moment to go back to.
      store.addMoment(cause: MomentCause.sync, label: 'Marta', seq: store.currentSeq() - 3);
      final notes = NoteQueue();
      final watcher = SyncWatcher(store, folderOf: (_) => MemorySyncFolder(), notes: notes)
        ..announce(const UnseenChanges(3, {'Marta'}));
      addTearDown(watcher.dispose);
      final tiles = DiskCachingTileProvider(Directory('test/screenshots/tiles'));

      // ---- the pages, one frame each, named like the site's pages
      final pages = <String, Widget Function()>{
        'home': () => ClowderListScreen(store: store),
        'notes': () => NoteStrip(queue: notes, busy: ValueNotifier(const {}), child: ClowderListScreen(store: store)),
        'clowder': () => ClowderDetailScreen(store: store, clowderId: home),
        'cat': () => CatDetailScreen(store: store, catId: miezi),
        'cat-edit': () => CatDetailScreen(store: store, catId: miezi, startEditing: true),
        'strays': () => StraysScreen(store: store),
        'map': () => MapScreen(store: store, tileProvider: tiles),
        'timeline': () => TimelineScreen(store: store, entityId: miezi),
        'history': () => FieldHistoryScreen(store: store, entityId: miezi, def: weight),
        'graph': () => FieldGraphScreen(store: store, entityId: miezi, def: weight),
        'photos': () => PhotoViewerScreen(store: store, hashes: store.images(miezi), initialIndex: 0, name: 'Herr Sonnenschein'),
        'agenda': () => AgendaScreen(store: store, manager: manager),
        'card': () => CardScreen(store: store, catId: miezi),
        'poster': () => MissingPosterScreen(store: store, catId: pumpkin, preview: _preview),
        'report': () => VetReportScreen(store: store, catId: miezi, preview: _preview),
        'sync': () => SyncScreen(store: store),
        'shared-folder': () => RemoteScreen(store: store),
        'bundles': () => MessengerScreen(store: store),
        'conflicts': () => ConflictsScreen(store: store),
        'duplicates': () => DuplicatesScreen(store: store),
        'moments': () => GoBackScreen(store: store),
        'backups': () => BackupsScreen(store: store),
        'archive': () => ArchiveScreen(store: store),
        'authors': () => ModerationScreen(store: store),
        'fields': () => FieldsScreen(store: store),
        'achievements': () => AchievementsScreen(manager: manager, stores: [store]),
        'settings': () => SettingsScreen(store: store),
      };
      final coats = {
        'home': FurPattern.tabby, 'clowder': FurPattern.cheetah, 'cat': FurPattern.rosettes,
        'card': FurPattern.paws, 'timeline': FurPattern.tiger, 'map': FurPattern.tabby,
        'graph': FurPattern.cheetah, 'agenda': FurPattern.zebra, 'poster': FurPattern.paws,
        'report': FurPattern.rosettes, 'strays': FurPattern.zebra,
      };
      for (final entry in pages.entries) {
        await s.pump(entry.value(), fur: coats[entry.key] ?? FurPattern.tabby);
        await s.capture(entry.key);
      }
      petMode.value = true;
      await s.pump(ClowderListScreen(store: store));
      await s.capture('pet-mode');
      petMode.value = false;

      // ---- the flows: a frame per step, driven on the page
      // Add a home and a cat.
      await s.pump(ClowderListScreen(store: store), fur: FurPattern.tabby);
      await s.capture('add-home-and-cat/01');
      await s.tap(find.byType(FloatingActionButton));
      await s.capture('add-home-and-cat/02');
      await tester.enterText(find.byType(TextField).first, lang == 'de' ? 'Gartenschuppen' : 'Garden Shed');
      await s.settle(rounds: 1);
      await s.tapText(t.create);
      await s.capture('add-home-and-cat/03');
      await s.tapTooltip(t.addCat);
      await s.capture('add-home-and-cat/04');
      await s.tapText(t.addCat);
      await s.capture('add-home-and-cat/05');
      await tester.enterText(find.byType(TextField).first, 'Mimi');
      await s.settle(rounds: 1);
      await s.tapText(t.create);
      await s.capture('add-home-and-cat/06');

      // Weigh a cat and read the graph.
      await s.pump(CatDetailScreen(store: store, catId: miezi), fur: FurPattern.rosettes);
      await s.capture('weigh-a-cat/01');
      await s.tapTooltip(t.editLabel);
      await s.capture('weigh-a-cat/02');
      await tester.dragUntilVisible(find.text(fieldDefName(t, weight)),
          find.byType(ListView).first, const Offset(0, -300));
      await s.settle(rounds: 1);
      await s.tapText(fieldDefName(t, weight));
      await s.capture('weigh-a-cat/03');
      await s.tapText(t.cancel);
      await s.pump(FieldGraphScreen(store: store, entityId: miezi, def: weight), fur: FurPattern.cheetah);
      await s.capture('weigh-a-cat/04');

      // Add a chore and tick it.
      await s.pump(AgendaScreen(store: store, manager: manager), fur: FurPattern.zebra);
      await s.capture('add-a-chore/01');
      await s.tapTooltip(t.addAppointment);
      await s.capture('add-a-chore/02');
      await s.tapText(t.choreLabel);
      await s.capture('add-a-chore/03');
      await s.back();
      await s.tap(find.byType(Checkbox).first);
      await s.capture('add-a-chore/04');

      // Plan a vet visit.
      await s.pump(AgendaScreen(store: store, manager: manager), fur: FurPattern.zebra);
      await s.tapTooltip(t.addAppointment);
      await s.tapText(t.appointmentLabel);
      await s.capture('plan-a-vet-visit/01');
      await s.back();
      await s.pump(VetReportScreen(store: store, catId: miezi, preview: _preview), fur: FurPattern.rosettes);
      await s.capture('plan-a-vet-visit/02');

      // Share the card, print the poster.
      await s.pump(CardScreen(store: store, catId: miezi), fur: FurPattern.paws);
      await s.capture('share-the-card/01');
      await s.pump(MissingPosterScreen(store: store, catId: pumpkin, preview: _preview), fur: FurPattern.paws);
      await s.capture('print-the-poster/01');

      // Capture a flier: the wizard, step by step.
      final templates = FlierTemplateSet.fromJson(File('assets/fliers/templates.json').readAsStringSync());
      final flierPhoto = File('test/screenshots/demo/cat3.jpg').readAsBytesSync();
      final lines = hugoLines();
      await s.pump(
        FlierCaptureScreen(
          store: store,
          pickPhoto: (_) async => flierPhoto,
          locate: () async => (pos: (52.52, 13.405), failure: null),
          scan: (_) async => null,
          ocr: (_) async => FlierText(lines.map((l) => l.text).join('\n'), lines),
          codes: (_) async => const FlierCodes(['https://www.tasso.net/Tierregister/Suchmeldungen?lang=de-DE&snr=S3101849&lp=0']),
          geocode: (q) async => [GeoHit('Berlin, Mitte', 52.52, 13.405)],
          templates: () async => templates,
        ),
        fur: FurPattern.paws,
      );
      await s.capture('capture-a-flier/01');
      Future<void> next() async {
        await tester.drag(find.byType(ListView).first, const Offset(0, 4000));
        await s.tapText(t.introNext);
      }
      await next();
      await s.capture('capture-a-flier/02');
      await next();
      await s.capture('capture-a-flier/03');
      await next();
      await s.capture('capture-a-flier/04');
      await next();
      await s.capture('capture-a-flier/05');
      await next();
      await s.capture('capture-a-flier/06');

      // Sync with a partner through a shared folder; in person; a bundle.
      await s.pump(SyncScreen(store: store), fur: FurPattern.tabby);
      await s.capture('shared-folder/01');
      await s.tapText(t.syncChooserRemote);
      await s.capture('shared-folder/02');
      await s.pump(SyncScreen(store: store), fur: FurPattern.tabby);
      await s.tapText(t.syncChooserMessenger);
      await s.capture('send-a-bundle/01');

      // Decide a conflict.
      await s.pump(ConflictsScreen(store: store), fur: FurPattern.tiger);
      await s.capture('decide-a-conflict/01');
      await s.tapText('Needs the diet food');
      await s.pump(TimelineScreen(store: store, entityId: miezi), fur: FurPattern.tiger);
      await s.capture('decide-a-conflict/02');

      // Merge two cats.
      await s.pump(CatDetailScreen(store: store, catId: findus2), fur: FurPattern.rosettes);
      await s.capture('merge-two-cats/01');
      // Merge sits in the menu on a phone: the bar is full before it.
      await s.tap(find.byIcon(Icons.more_vert));
      await s.capture('merge-two-cats/02');
      await s.tapText(t.mergeInto);
      await s.capture('merge-two-cats/03');
      // The page's own title is "Findus" too: the row is the last match.
      await s.tap(find.text('Findus').last);
      await s.capture('merge-two-cats/04');
      await s.tapText(t.cancel);

      // Go back to a moment.
      await s.pump(GoBackScreen(store: store), fur: FurPattern.tiger);
      await s.capture('go-back/01');
      await s.tap(find.byType(ListTile).first);
      await s.capture('go-back/02');

      // Luna's eye drops: the chore page of one cat, for the chores page.
      await s.pump(CatDetailScreen(store: store, catId: luna), fur: FurPattern.rosettes);
      await s.capture('chores');
    }, skip: true);
  }
}
