import 'package:catalog_core/catalog_core.dart';
import 'package:catlog/l10n/app_localizations.dart';
import 'package:catlog/src/screens/cat_detail_screen.dart';
import 'package:catlog/src/screens/clowder_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The bar shows a page's actions as far as they fit and puts the rest
/// into a ⋮ that exists only when something is in it (#171).
void main() {
  setUpAll(useSystemSqlite);

  late CatalogStore store;
  late String cat, clowder;

  setUp(() {
    store = CatalogStore.inMemory();
    store.author = 'test';
    clowder = store.createClowder('Hinterhof');
    cat = store.createCat('Miezi');
  });

  tearDown(() => store.close());

  Future<void> pump(WidgetTester tester, Widget screen, double width) async {
    tester.view.physicalSize = Size(width, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: screen,
    ));
    await tester.pumpAndSettle();
  }

  Finder barButtons() => find.descendant(
      of: find.byType(AppBar), matching: find.byType(IconButton));

  testWidgets('the cat page overflows its last actions on a phone',
      (tester) async {
    await pump(tester, CatDetailScreen(store: store, catId: cat), 360);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
    expect(find.byTooltip('Delete cat'), findsNothing);
    // The first ones are on the bar, in their order.
    expect(find.byTooltip('Card'), findsOneWidget);
    expect(find.byTooltip('Edit'), findsOneWidget);
    // The overflowed ones are in the menu, icon beside the words.
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.text('Delete cat'), findsOneWidget);
    expect(find.text('Merge into…'), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(PopupMenuItem<int>),
            matching: find.byIcon(Icons.delete_outline)),
        findsOneWidget);
  });

  testWidgets('a wide screen empties the cat page menu', (tester) async {
    await pump(tester, CatDetailScreen(store: store, catId: cat), 800);
    expect(find.byIcon(Icons.more_vert), findsNothing);
    expect(find.byTooltip('Delete cat'), findsOneWidget);
    expect(find.byTooltip('Merge into…'), findsOneWidget);
  });

  testWidgets('the clowder page shows all of its actions on a phone',
      (tester) async {
    await pump(
        tester, ClowderDetailScreen(store: store, clowderId: clowder), 360);
    expect(find.byIcon(Icons.more_vert), findsNothing);
    expect(find.byTooltip('Delete clowder'), findsOneWidget);
    expect(find.byTooltip('Merge into…'), findsOneWidget);
  });

  testWidgets('help is the first button on the bar', (tester) async {
    for (final screen in [
      CatDetailScreen(store: store, catId: cat),
      ClowderDetailScreen(store: store, clowderId: clowder),
    ]) {
      await pump(tester, screen, 360);
      final help = tester.getRect(find.ancestor(
          of: find.byIcon(Icons.help_outline),
          matching: find.byType(IconButton)));
      for (final e in barButtons().evaluate()) {
        expect(tester.getRect(find.byWidget(e.widget)).left,
            greaterThanOrEqualTo(help.left));
      }
    }
  });

  testWidgets('the cat page offers Flier hangs here beside Seen here now (#85)',
      (tester) async {
    await pump(tester, CatDetailScreen(store: store, catId: cat), 800);
    final seen = tester.getRect(find.byTooltip('Seen here now'));
    final flier = tester.getRect(find.byTooltip('Flier hangs here'));
    expect(flier.left, greaterThan(seen.left));
  });

  testWidgets('a delete on the bar still asks first', (tester) async {
    await pump(tester, CatDetailScreen(store: store, catId: cat), 800);
    await tester.tap(find.byTooltip('Delete cat'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(store.isDeleted(cat), isFalse);
  });
}
