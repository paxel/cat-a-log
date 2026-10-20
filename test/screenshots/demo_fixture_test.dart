// Writes the demo catalog as a shared folder the desk imports for its
// site frames (#162), so phone and desk pages show the same cats. Not a
// test; skipped in the suite, run by tool/frames.sh:
//   flutter test test/screenshots/demo_fixture_test.dart --run-skipped
@Tags(['screenshots'])
library;

import 'dart:io';

import 'package:catalog_core/catalog_core.dart';
import 'package:catlog/src/cover_picture.dart';
import 'package:flutter_test/flutter_test.dart';

import 'demo.dart';

void main() {
  setUpAll(() {
    useSystemSqlite();
    pinClock();
  });

  test('the demo catalog as a folder for the desk', () async {
    final store = demoStore();
    addTearDown(store.close);
    final home = store.clowders().firstWhere((c) => c.name == 'Foster Home South').id;
    await setCover(store, home, photo(4));
    await setCover(store, straysEntity, photo(5));
    final out = Directory('desktop/crates/catlog-gui/tests/demo/folder');
    if (out.existsSync()) out.deleteSync(recursive: true);
    out.createSync(recursive: true);
    await folderSync(store, out.path);
    expect(Directory('${out.path}/catlog-sync').existsSync(), isTrue);
  }, skip: true);
}
