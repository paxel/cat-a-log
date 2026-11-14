import 'dart:io';

import 'package:test/test.dart';

import '../tool/no_null_assertions.dart';

void main() {
  List<String> found(String source) => [
        for (final f in findNullAssertions(source, path: 'a.dart')) '$f',
      ];

  group('findNullAssertions', () {
    test('finds a postfix `!`, where it is', () {
      expect(found('int f(int? x) => x!;\n'), ['a.dart:1:19']);
      expect(found('void f(Map<String, int> m) {\n  m["a"]!.isEven;\n}\n'), [
        'a.dart:2:9',
      ]);
    });

    test('finds a `!` null-assert pattern', () {
      expect(found('void f(int? x) {\n  if (x case final y!) print(y);\n}\n'), [
        'a.dart:2:21',
      ]);
    });

    test('finds each of several, in order', () {
      expect(found('int f(int? a, int? b) => a! + b!;\n'), [
        'a.dart:1:27',
        'a.dart:1:32',
      ]);
    });

    test('a negation, `!=`, a string or a comment holds none', () {
      expect(
        found('''
// x! in a comment
/// and x! in a doc comment
bool f(bool a, int? b) => !a && b != null && 'x!' != "y!";
'''),
        isEmpty,
      );
    });

    test('reads what parses of a file with a syntax error', () {
      expect(found('int f(int? x) => x!;\nvoid g( {\n'), ['a.dart:1:19']);
    });
  });

  group('isGenerated', () {
    test('names the localizations flutter gen-l10n writes', () {
      expect(isGenerated('lib/l10n/app_localizations.dart'), isTrue);
      expect(isGenerated('../../lib/l10n/app_localizations_de.dart'), isTrue);
      expect(isGenerated('/x/lib/l10n/app_localizations_en.dart'), isTrue);
    });

    test('names nothing else', () {
      expect(isGenerated('lib/l10n/strings.dart'), isFalse);
      expect(isGenerated('lib/src/app_localizations.dart'), isFalse);
      expect(isGenerated('lib/l10n/app_localizations.dart.bak'), isFalse);
    });
  });

  group('scan', () {
    late Directory dir;

    setUp(() => dir = Directory.systemTemp.createTempSync('no_bang_'));
    tearDown(() => dir.deleteSync(recursive: true));

    void write(String path, String text) => File('${dir.path}/$path')
      ..createSync(recursive: true)
      ..writeAsStringSync(text);

    test('walks a directory, only its .dart files, by path', () {
      write('lib/b.dart', 'int f(int? x) => x!;\n');
      write('lib/src/a.dart', 'int g(int? x) => x!;\n');
      write('lib/clean.dart', 'int h(int? x) => x ?? 0;\n');
      write('lib/notes.txt', 'x!\n');
      expect(
        [
          for (final f in scan(['${dir.path}/lib'])) f.path,
        ],
        ['${dir.path}/lib/b.dart', '${dir.path}/lib/src/a.dart'],
      );
    });

    test('skips the generated localizations in a directory', () {
      write('lib/l10n/app_localizations.dart', 'int f(int? x) => x!;\n');
      write('lib/l10n/app_localizations_en.dart', 'int f(int? x) => x!;\n');
      write('lib/main.dart', 'int f(int? x) => x!;\n');
      expect(
        [
          for (final f in scan(['${dir.path}/lib'])) f.path,
        ],
        ['${dir.path}/lib/main.dart'],
      );
    });

    test('reads a file given by name', () {
      write('one.dart', 'int f(int? x) => x!;\n');
      expect(scan(['${dir.path}/one.dart']), hasLength(1));
    });

    test('finds none in a clean tree', () {
      write('lib/a.dart', 'int f(int? x) => x ?? 0;\n');
      expect(scan(['${dir.path}/lib']), isEmpty);
    });

    // The check as CI runs it: its exit code fails the job.
    ProcessResult run(List<String> args) => Process.runSync(
          Platform.resolvedExecutable,
          ['tool/no_null_assertions.dart', ...args],
        );

    test('as a command: 1 and the place for a `!`, 0 for none', () {
      write('bad/a.dart', 'int f(int? x) => x!;\n');
      write('good/a.dart', 'int f(int? x) => x ?? 0;\n');
      final bad = run(['${dir.path}/bad']);
      expect(bad.exitCode, 1);
      expect(bad.stdout, contains('${dir.path}/bad/a.dart:1:19'));
      expect(run(['${dir.path}/good']).exitCode, 0);
    });

    test('as a command: 2 without a place or for one that is not there', () {
      expect(run([]).exitCode, 2);
      expect(run(['${dir.path}/missing']).exitCode, 2);
    });
  });
}
