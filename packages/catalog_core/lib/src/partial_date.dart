/// A date known to the day, the month, or only the year (#76).
///
/// Stored as `YYYY`, `YYYY-MM` or `YYYY-MM-DD` — exactly what is known,
/// never padded to the first of a period: padding would invent a
/// precision that makes ages and orderings wrong. The three forms sort
/// correctly as plain strings.
class PartialDate implements Comparable<PartialDate> {
  final int year;
  final int? month;
  final int? day;

  const PartialDate(this.year, [this.month, this.day]);

  /// Day precision — the only form a scheduled thing (reminder,
  /// appointment) accepts.
  bool get isFull => day != null;

  /// The stored form.
  String get iso {
    final b = StringBuffer(year.toString().padLeft(4, '0'));
    if (month != null) b.write('-${month.toString().padLeft(2, '0')}');
    if (day != null) b.write('-${day.toString().padLeft(2, '0')}');
    return b.toString();
  }

  /// First instant of the period — a timestamp for what needs one.
  DateTime get earliest => DateTime(year, month ?? 1, day ?? 1);

  /// Last day of the period.
  DateTime get latest => switch ((month, day)) {
        (final m?, final d?) => DateTime(year, m, d),
        (final m?, null) => DateTime(year, m + 1, 0),
        _ => DateTime(year, 12, 31),
      };

  /// The stored form parsed back; null for anything else.
  static PartialDate? parse(String? value) {
    if (value == null) return null;
    final m =
        RegExp(r'^(\d{4})(?:-(\d{2})(?:-(\d{2}))?)?$').firstMatch(value.trim());
    if (m == null) return null;
    final y = _number(m, 1);
    if (y == null) return null;
    return _checked(y, _number(m, 2), _number(m, 3));
  }

  /// A date as people type or posters print it: `2021`, `5/2021`,
  /// `05.2021`, `2021-05`, `14.05.2021`, `5.6.2025`, `14/05/2021`,
  /// `2021-05-14`. Day-month order is day first, as in German and most
  /// of Europe. Null for anything else or an impossible day.
  static PartialDate? parseLoose(String text) {
    final s = text.trim();
    final iso = PartialDate.parse(s);
    if (iso != null) return iso;
    final dmy = RegExp(r'^(\d{1,2})[./](\d{1,2})[./](\d{4})$').firstMatch(s);
    if (dmy != null) {
      return switch ((_number(dmy, 3), _number(dmy, 2), _number(dmy, 1))) {
        (final y?, final mo?, final d?) => _checked(y, mo, d),
        _ => null,
      };
    }
    final my = RegExp(r'^(\d{1,2})[./](\d{4})$').firstMatch(s);
    if (my != null) {
      return switch ((_number(my, 2), _number(my, 1))) {
        (final y?, final mo?) => _checked(y, mo, null),
        _ => null,
      };
    }
    final ym = RegExp(r'^(\d{4})[./](\d{1,2})$').firstMatch(s);
    if (ym != null) {
      return switch ((_number(ym, 1), _number(ym, 2))) {
        (final y?, final mo?) => _checked(y, mo, null),
        _ => null,
      };
    }
    return null;
  }

  /// Group [i] of [m] as a number; null when the group did not take
  /// part in the match.
  static int? _number(RegExpMatch m, int i) => switch (m.group(i)) {
        final g? => int.parse(g),
        null => null,
      };

  /// The first date found inside free text (a poster line), by the same
  /// spellings as [parseLoose]; null when there is none.
  static PartialDate? find(String text) {
    for (final re in [
      RegExp(r'(\d{1,2})[./](\d{1,2})[./](\d{4})'),
      RegExp(r'(\d{4})-(\d{2})-(\d{2})'),
      RegExp(r'(\d{1,2})[./](\d{4})'),
      RegExp(r'(\d{4})-(\d{2})'),
      RegExp(r'(?<!\d)(\d{4})(?!\d)'),
    ]) {
      final m = re.firstMatch(text);
      // The fullest spelling present decides; an impossible day is no
      // date, not a month plucked from its tail.
      if (m != null) return parseLoose(text.substring(m.start, m.end));
    }
    return null;
  }

  static PartialDate? _checked(int y, int? m, int? d) {
    if (y < 1000 || y > 9999) return null;
    if (m != null && (m < 1 || m > 12)) return null;
    if (d != null) {
      if (m == null || d < 1 || d > 31) return null;
      if (DateTime(y, m, d).month != m) return null;
    }
    return PartialDate(y, m, d);
  }

  /// Full years and months elapsed at [today], as far as the precision
  /// allows: a year-only date yields months null. Null before the date.
  ({int years, int? months})? ageAt(DateTime today) {
    var years = today.year - year;
    final month = this.month;
    if (month == null) {
      return years < 0 ? null : (years: years, months: null);
    }
    var months = today.month - month;
    final day = this.day;
    if (day != null && today.day < day) months -= 1;
    if (months < 0) {
      years -= 1;
      months += 12;
    }
    return years < 0 ? null : (years: years, months: months);
  }

  @override
  int compareTo(PartialDate other) => iso.compareTo(other.iso);

  @override
  bool operator ==(Object other) => other is PartialDate && other.iso == iso;

  @override
  int get hashCode => iso.hashCode;

  @override
  String toString() => iso;
}
