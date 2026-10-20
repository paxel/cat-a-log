#!/usr/bin/env sh
# Regenerates the documentation site's frames (#161, #162): the phone's
# pages and flow steps in English and German, then the desk's. Run before
# a release; CI runs the same and fails when a committed frame differs.
set -eu
cd "$(dirname "$0")/.."
echo "phone frames (en, de)…"
flutter test test/screenshots/site_frames_test.dart --run-skipped --concurrency=1
if [ -d desktop/crates/catlog-gui/tests ] && grep -q site_frames desktop/crates/catlog-gui/tests/*.rs 2>/dev/null; then
  echo "desk frames (en, de)…"
  (cd desktop && nice -n 19 env CARGO_BUILD_JOBS=2 cargo test -j 2 -p catlog-gui --test site_frames -- --ignored)
fi
echo "done: site/assets/frames"
