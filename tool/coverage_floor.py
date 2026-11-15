"""Coverage floors that may only rise (cat-1016).

    python3 tool/coverage_floor.py <group> <lcov file> [floors file [badge dir]]

Keeps only the group's own source files in the LCOV file (rewritten in
place, so SonarQube Cloud imports what the floor measured), computes the
line coverage, and compares it with the group's floor in the floors file
(default: tool/coverage-floors.txt):

- below the floor: exit 1;
- the measured value rounded down, less one point, above the floor: the
  floor is raised to that in the file, for the user to commit;
- otherwise the file is left alone. A floor is never lowered.

Floors are whole percents and trail the measured value by one point (see
the floors file).

It also writes the group's README badge, a shields.io endpoint file
(default: .github/badges/coverage-<group>.json), with the measured value
rounded down to one decimal, committed with the floors.
"""

import json
import math
import pathlib
import re
import sys

FLOORS = pathlib.Path(__file__).with_name("coverage-floors.txt")
BADGES = pathlib.Path(__file__).resolve().parent.parent / ".github" / "badges"

# Badge colour by line coverage: the first threshold reached.
COLOURS = (
    (90, "brightgreen"),
    (80, "green"),
    (70, "yellowgreen"),
    (60, "yellow"),
    (50, "orange"),
    (0, "red"),
)

# Per group: which source files count (matched against the SF: path,
# with forward slashes), and which of those are generated and do not.
GROUPS = {
    "rust-core": (r"(^|/)crates/catlog-core/src/", r"(^|/)target/"),
    "rust-gui": (r"(^|/)crates/catlog-gui/src/", r"(^|/)target/|/src/bin/"),
    "rust-l10n": (r"(^|/)crates/catlog-l10n/src/", r"(^|/)target/"),
    "dart-core": (r"^packages/catalog_core/lib/", r"(^|/)build/"),
    "flutter-app": (
        r"^lib/",
        r"^lib/l10n/app_localizations[^/]*\.dart$|(^|/)build/",
    ),
}


def records(text):
    """The LCOV text split into records, each a list of lines ending at
    end_of_record."""
    out, current = [], []
    for line in text.splitlines():
        if not line.strip():
            continue
        current.append(line)
        if line == "end_of_record":
            out.append(current)
            current = []
    if current:
        out.append(current)
    return out


def source(record):
    for line in record:
        if line.startswith("SF:"):
            return line[3:].replace("\\", "/")
    return ""


def keep(group, text):
    """Only the records of the group's own, non-generated source files."""
    include, exclude = (re.compile(p) for p in GROUPS[group])
    return [
        r
        for r in records(text)
        if include.search(source(r)) and not exclude.search(source(r))
    ]


def line_coverage(kept):
    """Percent of instrumented lines hit, from the DA: lines."""
    found = hit = 0
    for record in kept:
        for line in record:
            if line.startswith("DA:"):
                found += 1
                if int(line[3:].split(",")[1]) > 0:
                    hit += 1
    return 100.0 * hit / found if found else 0.0


def read_floors(path):
    floors = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.split("#", 1)[0].strip()
        if line:
            name, value = line.split()
            floors[name] = int(value)
    return floors


def write_floor(path, group, value):
    lines = path.read_text(encoding="utf-8").splitlines(keepends=True)
    for i, line in enumerate(lines):
        if line.split("#", 1)[0].split()[:1] == [group]:
            lines[i] = f"{group} {value}\n"
    path.write_text("".join(lines), encoding="utf-8")


def badge(group, measured):
    """The shields.io endpoint JSON for the group's README badge."""
    tenths = math.floor(round(measured * 10, 6)) / 10
    colour = next(c for threshold, c in COLOURS if measured >= threshold)
    return (
        json.dumps(
            {
                "schemaVersion": 1,
                "label": f"coverage {group}",
                "message": f"{tenths:.1f}%",
                "color": colour,
            },
            indent=2,
        )
        + "\n"
    )


def main(argv):
    if not 2 <= len(argv) <= 4 or argv[0] not in GROUPS:
        print(__doc__, file=sys.stderr)
        return 2
    group, lcov = argv[0], pathlib.Path(argv[1])
    floors_path = pathlib.Path(argv[2]) if len(argv) >= 3 else FLOORS
    badges = pathlib.Path(argv[3]) if len(argv) == 4 else BADGES
    kept = keep(group, lcov.read_text(encoding="utf-8"))
    if not kept:
        print(f"{group}: no source files in {lcov}", file=sys.stderr)
        return 1
    lcov.write_text("".join("\n".join(r) + "\n" for r in kept), encoding="utf-8")
    measured = line_coverage(kept)
    badges.mkdir(parents=True, exist_ok=True)
    (badges / f"coverage-{group}.json").write_text(
        badge(group, measured), encoding="utf-8"
    )
    floor = read_floors(floors_path)[group]
    # One point below the measured value, rounded down: the margin that
    # keeps a CI run measuring a fraction lower from stopping a release.
    target = math.floor(measured) - 1
    print(f"{group}: {measured:.2f}% of lines covered, floor {floor}%")
    if measured < floor:
        print(f"{group}: below its floor of {floor}%", file=sys.stderr)
        return 1
    if target > floor:
        write_floor(floors_path, group, target)
        print(f"{group}: floor raised to {target}% in {floors_path}; commit it")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
