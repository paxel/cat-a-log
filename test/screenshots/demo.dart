// The demo catalog the screenshots and the site's frames are made of
// (#161): five homes and colonies, ten cats with portraits, fields,
// history, chores and appointments, written by three people, dated
// relative to [demoToday], which the app's clock is pinned to so every
// run draws the same pictures.
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:catalog_core/catalog_core.dart';
import 'package:catlog/l10n/app_localizations.dart';
import 'package:catlog/src/fur_background.dart';
import 'package:catlog/src/name_proposals.dart';
import 'package:catlog/src/screens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

Future<void> loadRealFonts() async {
  final root = Platform.environment['FLUTTER_ROOT']!;
  final fonts = '$root/bin/cache/artifacts/material_fonts';
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      final bytes = File('$fonts/$f').readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  }

  await load('Roboto', [
    'Roboto-Regular.ttf',
    'Roboto-Medium.ttf',
    'Roboto-Bold.ttf',
  ]);
  await load('MaterialIcons', ['MaterialIcons-Regular.otf']);
}

/// The demo's day: a Tuesday in autumn. The demo is dated relative to
/// it, so chores are due, appointments lie ahead and streaks end
/// yesterday; [pinClock] makes the app see the same day.
final DateTime demoToday = DateTime(2026, 10, 20);

/// The moment the store's clock stands at while the demo is written:
/// [ago] moves it to the day it names, so an entry is recorded on the
/// day it is dated and the desk's "recent changes" read as a history.
DateTime _writingAt = DateTime(2026, 10, 20, 9);

DateTime ago(int days, {int hour = 10}) {
  final at = DateTime(demoToday.year, demoToday.month, demoToday.day - days, hour);
  if (days >= 0) _writingAt = at;
  return at;
}

DateTime ahead(int days, {int hour = 10}) => ago(-days, hour: hour);

/// Pins the app's clock to nine in the morning of [demoToday], and the
/// two dice the pages roll: a new store's signing key, whose code the
/// authors page shows, and the name a new cat is proposed.
void pinClock() {
  nowProvider = () => DateTime(demoToday.year, demoToday.month, demoToday.day, 9);
  CatalogStore.clock = () => _writingAt;
  var seed = 7;
  CatalogStore.newKey = () => SigningKey.fromSeed(
        Uint8List.fromList(List<int>.generate(32, (i) => (i * 37 + seed++) & 0xff)),
      );
  proposalDice = Random(7);
}

/// Thirteen portraits in test/screenshots/demo, one per cat.
Uint8List photo(int n) => CatalogStore.compressImage(
  File('test/screenshots/demo/cat$n.jpg').readAsBytesSync(),
);

/// Demo catalog: five homes and colonies, ten cats with portraits,
/// fields, history, chores and appointments, written by three people.
CatalogStore demoStore() {
  final store = CatalogStore.inMemory();
  store.author = 'Alex';
  void put(
    String entity,
    String field,
    String value, {
    DateTime? date,
    String as = 'Alex',
  }) => store.append(entity, field, value, date: date ?? ago(60), as: as);

  // ---- homes and colonies
  final home = store.createClowder('Foster Home South', date: ago(130));
  put(home, 'f:address', 'Main Street 7, 10178 Berlin', date: ago(130));
  put(home, 'f:responsible', 'Marta', date: ago(130));
  put(home, 'f:phone', '+49 30 1234567', date: ago(130));
  put(home, 'f:status', 'foster', date: ago(130));
  store.recordPosition(home, 52.5168, 13.4008, date: ago(130));

  final barn = store.createClowder('Old Barn', date: ago(110));
  put(barn, 'f:address', 'Field Road 2', date: ago(110), as: 'Marta');
  put(barn, 'f:status', 'barn', date: ago(110), as: 'Marta');
  put(
    barn,
    'f:remarks',
    'Feeding station behind the tractor shed',
    date: ago(100),
    as: 'Marta',
  );
  store.recordPosition(barn, 52.5236, 13.4125, date: ago(110));

  final riverside = store.createClowder('Riverside Colony', date: ago(95));
  put(riverside, 'f:responsible', 'Jonas', date: ago(95), as: 'Jonas');
  put(
    riverside,
    'f:remarks',
    'Seven cats seen at once in June',
    date: ago(80),
    as: 'Jonas',
  );
  store.recordPosition(riverside, 52.5212, 13.4098, date: ago(95));

  final clinic = store.createClowder('Vet Clinic Dr. Koch', date: ago(90));
  put(clinic, 'f:status', 'clinic', date: ago(90));
  put(clinic, 'f:address', 'Park Avenue 12', date: ago(90));
  put(clinic, 'f:phone', '+49 30 7654321', date: ago(90));

  final millers = store.createClowder('The Millers', date: ago(40));
  put(millers, 'f:status', 'forever-home', date: ago(40), as: 'Marta');
  put(millers, 'f:responsible', 'Anne Miller', date: ago(40), as: 'Marta');
  put(millers, 'f:email', 'anne@example.org', date: ago(40), as: 'Marta');
  store.recordPosition(millers, 52.5138, 13.4021, date: ago(40));

  // ---- cats at the foster home
  final miezi = store.createCat(
    'Herr Sonnenschein',
    clowderId: home,
    date: ago(128),
  );
  store.addImage(miezi, photo(1), date: ago(128));
  put(miezi, 'f:gender', 'male', date: ago(128));
  put(miezi, 'f:color', 'white & ginger', date: ago(128));
  put(miezi, 'f:breed', 'European Shorthair', date: ago(128));
  put(miezi, 'f:chipid', '276 0981 0234 5678', date: ago(120), as: 'Marta');
  put(miezi, 'f:neutered', 'yes', date: ago(85), as: 'Marta');
  put(miezi, 'f:birthdate', '2010-12-27', date: ago(128));
  put(
    miezi,
    'f:looks',
    'size=medium; colours=ginger,white; pattern=bicolour; fur=short; tail=long; ears=upright',
    date: ago(128),
  );
  put(
    miezi,
    'f:remarks',
    'Shy at first, purrs within a minute',
    date: ago(120),
  );
  put(
    miezi,
    'f:remarks',
    'Sneezing for two days, vet said harmless',
    date: ago(44),
    as: 'Marta',
  );
  put(miezi, 'f:remarks', 'Loves the window seat', date: ago(9), as: 'Jonas');
  // A grown tom of six kilos, weighed every fortnight: the curve of an
  // adult, not of a kitten.
  for (final (i, grams) in [
    5620,
    5700,
    5760,
    5810,
    5880,
    5920,
    5950,
    5980,
    6000,
  ].indexed) {
    put(
      miezi,
      'f:weight',
      '$grams',
      date: ago(128 - 14 * i),
      as: i.isEven ? 'Alex' : 'Marta',
    );
  }

  final balu = store.createCat('Hoernchen', clowderId: home, date: ago(128));
  store.addImage(balu, photo(13), date: ago(128));
  put(balu, 'f:gender', 'male', date: ago(128));
  put(balu, 'f:color', 'black', date: ago(128));
  put(balu, 'f:breed', 'mixed', date: ago(128));
  put(balu, 'f:neutered', 'yes', date: ago(70), as: 'Marta');
  put(balu, 'f:birthdate', '2025-11', date: ago(128));
  put(
    balu,
    'f:looks',
    'size=large; colours=black; pattern=solid; fur=short; tail=long; ears=upright; marks=white bib',
    date: ago(128),
  );
  for (final (i, grams) in [3100, 3350, 3600, 3900, 4150, 4300].indexed) {
    put(balu, 'f:weight', '$grams', date: ago(120 - 20 * i));
  }

  final nala = store.createCat('Socke', clowderId: home, date: ago(60));
  store.addImage(nala, photo(5), date: ago(60));
  put(nala, 'f:gender', 'male', date: ago(60), as: 'Marta');
  put(nala, 'f:color', 'black & white', date: ago(60), as: 'Marta');
  put(nala, 'f:birthdate', '2026-06-15', date: ago(60), as: 'Marta');
  put(
    nala,
    'f:looks',
    'size=small; colours=black,white; pattern=bicolour; fur=short',
    date: ago(60),
    as: 'Marta',
  );
  put(
    nala,
    'f:remarks',
    'Kitten of Luna, bottle-fed the first week',
    date: ago(58),
    as: 'Marta',
  );

  final simba = store.createCat('Simba', clowderId: home, date: ago(60));
  store.addImage(simba, photo(6), date: ago(60));
  put(simba, 'f:gender', 'male', date: ago(60), as: 'Marta');
  put(simba, 'f:color', 'ginger tabby', date: ago(60), as: 'Marta');
  put(simba, 'f:birthdate', '2026-06-15', date: ago(60), as: 'Marta');
  put(
    simba,
    'f:looks',
    'size=small; colours=ginger; pattern=tabby; fur=short',
    date: ago(60),
    as: 'Marta',
  );

  // ---- the barn
  final luna = store.createCat('Luna', clowderId: home, date: ago(121));
  store.addImage(luna, photo(11), date: ago(121));
  put(luna, 'f:gender', 'female', date: ago(121));
  put(luna, 'f:color', 'grey', date: ago(121));
  put(luna, 'f:pregnant', 'yes', date: ago(99), as: 'Marta');
  put(luna, 'f:pregnant', 'no', date: ago(60), as: 'Marta');
  put(
    luna,
    'f:looks',
    'size=medium; colours=grey; pattern=solid; fur=long; ears=upright',
    date: ago(121),
  );
  store.moveCat(luna, barn, date: ago(30));
  put(nala, 'f:mother', luna, date: ago(60), as: 'Marta');
  put(simba, 'f:mother', luna, date: ago(60), as: 'Marta');

  final smokey = store.createCat('Smokey', clowderId: barn, date: ago(100));
  store.addImage(smokey, photo(12), date: ago(100));
  put(smokey, 'f:gender', 'male', date: ago(100), as: 'Marta');
  put(smokey, 'f:color', 'blue grey', date: ago(100), as: 'Marta');
  put(smokey, 'f:neutered', 'no', date: ago(100), as: 'Marta');
  put(
    smokey,
    'f:looks',
    'size=large; colours=grey; pattern=solid; fur=medium; marks=notched ear',
    date: ago(100),
    as: 'Marta',
  );
  put(
    smokey,
    'f:remarks',
    'Left ear notched: neutered before we met him?',
    date: ago(98),
    as: 'Marta',
  );

  // ---- clinic and forever home
  final cleo = store.createCat('Cleo', clowderId: clinic, date: ago(50));
  store.addImage(cleo, photo(8), date: ago(50));
  put(cleo, 'f:gender', 'female', date: ago(50));
  put(cleo, 'f:color', 'calico', date: ago(50));
  put(cleo, 'f:chipid', '276 0981 0234 9911', date: ago(50));
  put(cleo, 'f:remarks', 'Broken leg, cast until end of month', date: ago(50));
  put(
    cleo,
    'f:looks',
    'size=medium; colours=white,black,ginger; pattern=calico; fur=short',
    date: ago(50),
  );
  store.moveCat(cleo, millers, date: ago(12));

  final pumpkin = store.createCat(
    'Pumpkin',
    clowderId: millers,
    date: ago(38),
  );
  store.addImage(pumpkin, photo(9), date: ago(38));
  put(pumpkin, 'f:gender', 'male', date: ago(38), as: 'Marta');
  put(pumpkin, 'f:color', 'ginger & white', date: ago(38), as: 'Marta');
  put(pumpkin, 'f:chipid', '276 0981 0234 4433', date: ago(38), as: 'Marta');
  put(
    pumpkin,
    'f:looks',
    'size=medium; colours=ginger,white; pattern=bicolour; fur=short; tail=long; marks=white paws',
    date: ago(38),
    as: 'Marta',
  );
  // Missing since a week: a flier hangs where he was last seen.
  store.moveCat(pumpkin, null, date: ago(7));
  store.recordPosition(
    pumpkin,
    52.5152,
    13.4082,
    date: ago(6),
    kind: PositionKind.flier,
  );

  // ---- strays
  final findus = store.createCat('Findus', date: ago(48));
  store.addImage(findus, photo(4), date: ago(48));
  put(findus, 'f:gender', 'male', date: ago(48), as: 'Jonas');
  put(findus, 'f:color', 'ginger & white', date: ago(48), as: 'Jonas');
  put(
    findus,
    'f:looks',
    'size=medium; colours=ginger,white; fur=short; tail=long; marks=white paws',
    date: ago(48),
    as: 'Jonas',
  );
  put(
    findus,
    'f:remarks',
    'Comes for food at dusk, keeps two metres away',
    date: ago(47),
    as: 'Jonas',
  );
  store.recordPosition(findus, 52.5205, 13.4049, date: ago(48));
  store.recordPosition(findus, 52.5228, 13.4102, date: ago(36));
  store.recordPosition(findus, 52.5241, 13.4021, date: ago(26));
  store.recordPosition(findus, 52.5168, 13.4045, date: ago(3));

  final oskar = store.createCat('Oskar', date: ago(20));
  store.addImage(oskar, photo(10), date: ago(20));
  put(oskar, 'f:gender', 'unknown', date: ago(20), as: 'Jonas');
  put(oskar, 'f:color', 'brown tabby', date: ago(20), as: 'Jonas');
  put(
    oskar,
    'f:looks',
    'size=large; colours=brown; pattern=tabby; fur=short; marks=scar',
    date: ago(20),
    as: 'Jonas',
  );
  store.recordPosition(oskar, 52.5232, 13.4052, date: ago(20));
  store.recordPosition(oskar, 52.5226, 13.4068, date: ago(5));

  // ---- appointments ahead
  store.createAppointment(
    Appointment(
      id: '',
      entity: miezi,
      date: ahead(3),
      time: (hour: 10, minute: 30),
      title: 'Vaccination booster',
      notes: 'Bring the blue booklet',
      alert: AppointmentAlert.dayBefore,
    ),
  );
  store.createAppointment(
    Appointment(
      id: '',
      entity: balu,
      date: ahead(10),
      time: null,
      title: 'Deworming',
      notes: '',
      alert: AppointmentAlert.none,
    ),
  );
  store.createAppointment(
    Appointment(
      id: '',
      entity: cleo,
      date: ahead(18),
      time: (hour: 9, minute: 0),
      title: 'Cast comes off',
      notes: 'Dr. Koch, bring the X-ray',
      alert: AppointmentAlert.dayBefore,
    ),
  );

  // ---- chores: a routine with streaks, one due today undone
  final feed = store.createChore(
    Chore(
      id: '',
      entity: home,
      title: 'Feed',
      schedule: const ChoreSchedule.daily(),
      time: (hour: 8, minute: 0),
      start: ago(40),
      remind: true,
      remindAt: (hour: 8, minute: 0),
    ),
  );
  for (var d = 12; d >= 0; d--) {
    store.tickChore(feed, ago(d), doneOn: ago(d));
  }
  final litter = store.createChore(
    Chore(
      id: '',
      entity: home,
      title: 'Litter boxes',
      schedule: const ChoreSchedule.daily(),
      time: (hour: 18, minute: 0),
      start: ago(40),
    ),
  );
  for (var d = 6; d >= 1; d--) {
    if (d != 3) store.tickChore(litter, ago(d), doneOn: ago(d));
  }
  final drops = store.createChore(
    Chore(
      id: '',
      entity: luna,
      title: 'Eye drops',
      schedule: const ChoreSchedule.every(2, ChoreUnit.days),
      time: (hour: 20, minute: 0),
      start: ago(8),
      remind: true,
      remindAt: (hour: 20, minute: 0),
    ),
  );
  store.tickChore(drops, ago(8), doneOn: ago(8));
  store.tickChore(drops, ago(6), doneOn: ago(6));
  store.tickChore(drops, ago(4), doneOn: ago(4));
  store.tickChore(drops, ago(2), doneOn: ago(2));
  store.createChore(
    Chore(
      id: '',
      entity: cleo,
      title: 'Check the cast',
      schedule: ChoreSchedule.weekdays({DateTime.monday, DateTime.thursday}),
      start: ago(12),
    ),
  );
  store.createChore(
    Chore(
      id: '',
      entity: nala,
      title: 'Weigh the kittens',
      schedule: const ChoreSchedule.every(1, ChoreUnit.weeks),
      time: (hour: 9, minute: 0),
      start: ago(2),
    ),
  );
  store.createChore(
    Chore(
      id: '',
      entity: miezi,
      title: 'Vaccination',
      schedule: const ChoreSchedule.every(1, ChoreUnit.years),
      start: ahead(3),
    ),
  );
  store.setLocalSetting('fold:agenda-upcoming', 'open');
  // The map opens on the demo's quarter at street zoom: pins apart.
  store.setLocalSetting(mapViewportKey, '52.5190,13.4065,15');
  return store;
}


/// Shoots phone pages at the README size: 820 × 1660 at 2×, in [lang].
/// [pump] puts a page up, [capture] writes what is on screen, so a flow
/// can drive the page between frames.
class Shooter {
  final WidgetTester tester;
  final String lang;
  final String dir;
  final GlobalKey _key = GlobalKey();

  Shooter(this.tester, this.lang, this.dir) {
    // A caret that blinks is a frame that differs run to run.
    EditableText.debugDeterministicCursor = true;
    tester.view.physicalSize = const Size(820, 1660);
    tester.view.devicePixelRatio = 2;
    Directory(dir).createSync(recursive: true);
  }

  AppLocalizations get t => lookupAppLocalizations(Locale(lang));

  Future<void> pump(Widget home, {FurPattern fur = FurPattern.tabby}) async {
    activeFur = fur;
    await tester.pumpWidget(
      RepaintBoundary(
        key: _key,
        child: MaterialApp(
          // A fresh app per page, so the routes a flow pushed are gone.
          key: UniqueKey(),
          debugShowCheckedModeBanner: false,
          locale: Locale(lang),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
            scaffoldBackgroundColor: Colors.transparent,
          ),
          // Every route gets the coat, pushed pages included.
          builder: (context, child) => FurBackground(child: child!),
          home: home,
        ),
      ),
    );
    await settle();
  }

  /// Real time, so Image.memory decoding and tile loading complete.
  Future<void> settle({int rounds = 4}) async {
    await tester.pump(const Duration(milliseconds: 300));
    for (var i = 0; i < rounds; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 350)),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  Future<void> capture(String name) async {
    await settle(rounds: 2);
    await tester.runAsync(() async {
      final boundary =
          _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      final rgb = img
          .decodePng(data!.buffer.asUint8List())!
          .convert(numChannels: 3);
      final file = File('$dir/$name.png');
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(img.encodePng(rgb));
    });
  }

  /// A tap that waits for the page to settle, by finder or by text.
  Future<void> tap(Finder finder) async {
    await tester.tap(finder);
    await settle(rounds: 2);
  }

  Future<void> tapText(String text) => tap(find.text(text).first);

  /// Leaves the page on top, as the back arrow would.
  Future<void> back() async {
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await settle(rounds: 2);
  }
  Future<void> tapTooltip(String text) => tap(find.byTooltip(text).first);
}
