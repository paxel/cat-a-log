#!/usr/bin/env bash
# Coverage floors (cat-1016): runs the tests with coverage, writes the LCOV
# files SonarQube Cloud imports (sonar-project.properties), and checks each
# group's line coverage against tool/coverage-floors.txt with
# tool/coverage_floor.py. Below a floor fails; a floor that rose is raised
# in that file, for the user to commit.
#
#   tool/coverage.sh [rust-core] [rust-gui] [rust-l10n] [dart-core] [flutter-app]
#
# No group named runs all five. A failing test stops the script; a group
# below its floor does not stop the others, so every LCOV file is written.
#
#   rust-core    cargo llvm-cov, catlog-core's own tests, its src/ only
#   rust-gui     cargo llvm-cov, catlog-gui's own tests, its src/ without the
#                binary entry point; needs the GUI test libraries (ALSA)
#   rust-l10n    cargo llvm-cov, catlog-l10n's own tests, its src/ only
#   dart-core    dart test --coverage, format_coverage to LCOV with paths
#                from the repository root (packages/catalog_core/lib/…)
#   flutter-app  flutter test --coverage, lib/ without the generated
#                lib/l10n/app_localizations*.dart
#
# Output: desktop/coverage/lcov.info (the Rust groups),
# packages/catalog_core/coverage/lcov.info and coverage/lcov.info.
#
# Needs cargo-llvm-cov and the llvm-tools-preview rustup component for the
# Rust groups. COVERAGE_JOBS=N limits the test and build parallelism (for a
# shared machine); unset leaves each tool's default.
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"

groups=("$@")
[ ${#groups[@]} -gt 0 ] || groups=(rust-core rust-gui rust-l10n dart-core flutter-app)

jobs=${COVERAGE_JOBS:-}
failed=()

floor() {
  python3 tool/coverage_floor.py "$1" "$2" || failed+=("$1")
}

rust() {
  local group=$1 crate=$2
  # Each crate's number comes from its own unit and integration tests; the
  # floor tool keeps its src/ only (generated code is in target/). The
  # render and snapshot tests are ignored by default and do not count.
  (cd desktop && cargo llvm-cov --locked ${jobs:+-j "$jobs"} -p "$crate" --lib --tests \
    --lcov --output-path "coverage/$group.lcov")
  floor "$group" "desktop/coverage/$group.lcov"
}

mkdir -p desktop/coverage
# Profiles of an earlier run (an example, a render test) would count as
# uncovered copies of the same code.
case " ${groups[*]} " in
  *" rust-"*) (cd desktop && cargo llvm-cov clean --workspace) ;;
esac
for group in "${groups[@]}"; do
  case $group in
    rust-core) rust rust-core catlog-core ;;
    rust-gui) rust rust-gui catlog-gui ;;
    rust-l10n) rust rust-l10n catlog-l10n ;;
    dart-core)
      (
        cd packages/catalog_core
        rm -rf coverage
        dart test ${jobs:+-j "$jobs"} --coverage=coverage
        dart run coverage:format_coverage --lcov \
          --in=coverage --out=coverage/lcov.info \
          --report-on=lib --base-directory=../..
      )
      floor dart-core packages/catalog_core/coverage/lcov.info
      ;;
    flutter-app)
      rm -rf coverage
      flutter test ${jobs:+--concurrency="$jobs"} --coverage
      floor flutter-app coverage/lcov.info
      ;;
    *)
      echo "unknown group: $group" >&2
      exit 2
      ;;
  esac
done

# SonarQube Cloud reads one Rust LCOV file.
if ls desktop/coverage/*.lcov > /dev/null 2>&1; then
  cat desktop/coverage/*.lcov > desktop/coverage/lcov.info
fi

if [ ${#failed[@]} -gt 0 ]; then
  echo "below its coverage floor: ${failed[*]}" >&2
  exit 1
fi
