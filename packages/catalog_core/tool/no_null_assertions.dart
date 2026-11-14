// Fails on any `!` null assertion in the Dart code outside tests (cat-1015):
// the Dart counterpart of the Rust crates' ban on panics. A
// `!` throws when the value is null; the code handles that case instead.
//
// Reads the analyzer's syntax tree, so a `!` in a string, a comment, `!=`
// or a negation `!x` does not count; both the postfix `x!` and the pattern
// `case final x!` do.
//
// One exception: the app's localizations, which `flutter gen-l10n` writes
// anew on every `flutter pub get` ([isGenerated]). Their `of(context)`
// asserts that the app's MaterialApp carries the delegate, which it
// always does; an edit there would not survive the next build.
//
// Usage, from packages/catalog_core:
//   dart run tool/no_null_assertions.dart lib ../../lib
// Prints one line per finding (path:line:column) and exits 1 when there is
// any, 0 when there is none, and 2 on a bad argument.

import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// One `!` null assertion: where it is, 1-based.
class NullAssertion {
  const NullAssertion(this.path, this.line, this.column);

  final String path;
  final int line;
  final int column;

  @override
  String toString() => '$path:$line:$column';
}

/// Every `!` null assertion in [source], in the order they appear.
///
/// The source is parsed even when it has syntax errors: what parses is
/// checked, so a broken file does not hide its `!`.
List<NullAssertion> findNullAssertions(String source, {String path = ''}) {
  final result = parseString(
    content: source,
    path: path.isEmpty ? null : path,
    throwIfDiagnostics: false,
  );
  final visitor = _BangVisitor();
  result.unit.accept(visitor);
  return [
    for (final offset in visitor.offsets)
      if (result.lineInfo.getLocation(offset) case final at)
        NullAssertion(path, at.lineNumber, at.columnNumber),
  ];
}

/// Whether [path] is a file `flutter gen-l10n` writes: the app's
/// `lib/l10n/app_localizations.dart` and one per language beside it.
bool isGenerated(String path) =>
    _generated.hasMatch(path.replaceAll(r'\', '/'));

final _generated = RegExp(r'(^|/)lib/l10n/app_localizations(_[a-z]+)?\.dart$');

/// Every `!` null assertion in the `.dart` files under [roots] (files or
/// directories, walked recursively), sorted by path; the generated ones
/// ([isGenerated]) are not read.
List<NullAssertion> scan(List<String> roots) {
  final files = <File>[];
  for (final root in roots) {
    if (FileSystemEntity.isFileSync(root)) {
      files.add(File(root));
    } else {
      files.addAll(
        Directory(root)
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'))
            .where((file) => !isGenerated(file.path)),
      );
    }
  }
  files.sort((a, b) => a.path.compareTo(b.path));
  return [
    for (final file in files)
      ...findNullAssertions(file.readAsStringSync(), path: file.path),
  ];
}

class _BangVisitor extends RecursiveAstVisitor<void> {
  final offsets = <int>[];

  @override
  void visitPostfixExpression(PostfixExpression node) {
    if (node.operator.type == TokenType.BANG) {
      offsets.add(node.operator.offset);
    }
    super.visitPostfixExpression(node);
  }

  @override
  void visitNullAssertPattern(NullAssertPattern node) {
    offsets.add(node.operator.offset);
    super.visitNullAssertPattern(node);
  }
}

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('usage: dart run tool/no_null_assertions.dart <dir|file>…');
    exitCode = 2;
    return;
  }
  for (final root in args) {
    if (!FileSystemEntity.isFileSync(root) &&
        !FileSystemEntity.isDirectorySync(root)) {
      stderr.writeln('no such file or directory: $root');
      exitCode = 2;
      return;
    }
  }
  final found = scan(args);
  for (final finding in found) {
    stdout.writeln('$finding: `!` null assertion; handle the null instead');
  }
  if (found.isNotEmpty) {
    stderr.writeln('${found.length} null assertion(s) found.');
    exitCode = 1;
  }
}
