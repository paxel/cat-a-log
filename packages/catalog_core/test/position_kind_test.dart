import 'package:catalog_core/catalog_core.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(useSystemSqlite);

  late CatalogStore store;
  late String cat;

  setUp(() {
    store = CatalogStore.inMemory();
    store.author = 'test';
    cat = store.createCat('Sissi');
  });

  tearDown(() => store.close());

  test('plain values are sightings; flier values carry the marker', () {
    expect(CatalogStore.parsePositionKind('48.1,11.5'),
        PositionKind.sighting);
    expect(CatalogStore.parsePositionKind('48.1,11.5@flier'),
        PositionKind.flier);
    // Coordinates parse for both kinds.
    expect(CatalogStore.parsePosition('48.1,11.5@flier'), (48.1, 11.5));
  });

  test('sighting position skips flier entries', () {
    store.recordPosition(cat, 48.1, 11.5);
    store.recordPosition(cat, 50.0, 8.0, kind: PositionKind.flier);
    // Latest overall is the flier, latest sighting is the older entry.
    expect(store.positionOf(cat), (50.0, 8.0));
    expect(store.sightingPositionOf(cat), (48.1, 11.5));
    expect(store.flierPositions(cat), [(50.0, 8.0)]);
  });

  test('a poster taken down is its entry removed; the history keeps it (#85)',
      () {
    store.recordPosition(cat, 50.0, 8.0, kind: PositionKind.flier);
    store.recordPosition(cat, 50.1, 8.1, kind: PositionKind.flier);
    final hanging = store.flierPositionEntries(cat);
    expect(hanging.map((e) => CatalogStore.parsePosition(e.value)),
        [(50.1, 8.1), (50.0, 8.0)]);
    store.removeEntry(hanging.first.seq);
    expect(store.flierPositions(cat), [(50.0, 8.0)]);
    expect(store.flierPositionEntries(cat).single.seq, hanging.last.seq);
    // The history shows the row marked, not gone.
    final rows = store.fieldHistory(cat, CatalogStore.positionKey,
        includeVoided: true);
    expect(rows.where((e) => e.voided).single.seq, hanging.first.seq);
  });

  test('a flier-only stray has no sighting position but is valid', () {
    store.recordPosition(cat, 50.0, 8.0, kind: PositionKind.flier);
    expect(store.sightingPositionOf(cat), isNull);
    expect(store.strays().single.id, cat);
    expect(store.searchCats('sissi').single.id, cat);
  });
}
