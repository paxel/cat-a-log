import json
import pathlib
import tempfile
import unittest
from contextlib import redirect_stderr, redirect_stdout
from io import StringIO

from coverage_floor import badge, main


def record(path, hits):
    lines = [f"SF:{path}"]
    lines += [f"DA:{n},{h}" for n, h in enumerate(hits, start=1)]
    lines += [f"LF:{len(hits)}", f"LH:{sum(1 for h in hits if h)}", "end_of_record"]
    return "\n".join(lines) + "\n"


FLOORS = "# comment\nrust-core 10\nflutter-app {floor}\ndart-core 30\n"


class CoverageFloorTest(unittest.TestCase):
    def run_floor(self, floor, lcov_text):
        with tempfile.TemporaryDirectory() as tmp:
            floors = pathlib.Path(tmp) / "floors.txt"
            floors.write_text(FLOORS.format(floor=floor), encoding="utf-8")
            lcov = pathlib.Path(tmp) / "lcov.info"
            lcov.write_text(lcov_text, encoding="utf-8")
            with redirect_stdout(StringIO()), redirect_stderr(StringIO()):
                code = main(["flutter-app", str(lcov), str(floors), tmp])
            badge_file = pathlib.Path(tmp) / "coverage-flutter-app.json"
            self.badge = json.loads(badge_file.read_text(encoding="utf-8")) if badge_file.exists() else None
            return code, floors.read_text(encoding="utf-8"), lcov.read_text(encoding="utf-8")

    # 3 of 4 lines: 75 %.
    APP = record("lib/main.dart", [1, 0, 2, 3])

    def test_below_the_floor_fails_and_keeps_the_floor(self):
        code, floors, _ = self.run_floor(76, self.APP)
        self.assertEqual(code, 1)
        self.assertEqual(floors, FLOORS.format(floor=76))

    def test_above_the_floor_raises_it_to_one_point_below_rounded_down(self):
        # 2 of 3 lines: 66.67 % is raised to 65.
        code, floors, _ = self.run_floor(60, record("lib/a.dart", [1, 1, 0]))
        self.assertEqual(code, 0)
        self.assertEqual(floors, FLOORS.format(floor=65))

    def test_two_points_above_the_floor_raises_it_by_one(self):
        # 77 %: the floor trails it at 76.
        hits = [1] * 77 + [0] * 23
        code, floors, _ = self.run_floor(75, record("lib/a.dart", hits))
        self.assertEqual(code, 0)
        self.assertEqual(floors, FLOORS.format(floor=76))

    def test_equal_to_the_floor_leaves_the_file_alone(self):
        # 75 %: the trailing 74 is below the floor, which is never lowered.
        code, floors, _ = self.run_floor(75, self.APP)
        self.assertEqual(code, 0)
        self.assertEqual(floors, FLOORS.format(floor=75))

    def test_a_fraction_above_the_floor_leaves_it_alone(self):
        # 75.5 %: not a whole percent above 75.
        hits = [1] * 151 + [0] * 49
        code, floors, _ = self.run_floor(75, record("lib/a.dart", hits))
        self.assertEqual(code, 0)
        self.assertEqual(floors, FLOORS.format(floor=75))

    def test_one_point_above_the_floor_leaves_it_alone(self):
        # 76.5 %: one point below it, rounded down, is the floor itself.
        hits = [1] * 153 + [0] * 47
        code, floors, _ = self.run_floor(75, record("lib/a.dart", hits))
        self.assertEqual(code, 0)
        self.assertEqual(floors, FLOORS.format(floor=75))

    def test_generated_and_foreign_files_are_dropped_from_measure_and_file(self):
        text = (
            self.APP
            + record("lib/l10n/app_localizations.dart", [0] * 100)
            + record("lib/l10n/app_localizations_de.dart", [0] * 100)
            + record("packages/catalog_core/lib/x.dart", [0] * 100)
        )
        code, floors, lcov = self.run_floor(75, text)
        self.assertEqual(code, 0)
        self.assertEqual(floors, FLOORS.format(floor=75))
        self.assertEqual(lcov, self.APP)

    def test_the_badge_file_holds_the_measured_value(self):
        self.run_floor(76, self.APP)
        self.assertEqual(
            self.badge,
            {
                "schemaVersion": 1,
                "label": "coverage flutter-app",
                "message": "75.0%",
                "color": "yellowgreen",
            },
        )

    def test_the_badge_value_is_rounded_down_to_one_decimal(self):
        self.assertEqual(json.loads(badge("rust-gui", 66.6666))["message"], "66.6%")
        self.assertEqual(json.loads(badge("rust-gui", 99.99))["message"], "99.9%")
        self.assertEqual(json.loads(badge("rust-gui", 70.0))["message"], "70.0%")

    def test_the_badge_colour_by_threshold(self):
        cases = [
            (100, "brightgreen"),
            (90, "brightgreen"),
            (89.99, "green"),
            (80, "green"),
            (79.99, "yellowgreen"),
            (70, "yellowgreen"),
            (69.99, "yellow"),
            (60, "yellow"),
            (59.99, "orange"),
            (50, "orange"),
            (49.99, "red"),
            (0, "red"),
        ]
        for value, colour in cases:
            with self.subTest(value=value):
                self.assertEqual(json.loads(badge("dart-core", value))["color"], colour)

    def test_no_source_file_fails(self):
        code, _, _ = self.run_floor(0, record("lib/l10n/app_localizations.dart", [1]))
        self.assertEqual(code, 1)
        self.assertIsNone(self.badge)


if __name__ == "__main__":
    unittest.main()
