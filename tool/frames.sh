#!/usr/bin/env sh
# Renders the documentation site's frames (#161, #162): the phone's pages
# and flow steps in English and German, then the desk's. The frames are not
# committed: the Pages workflow runs this on the runner before every site
# build, and a local site build needs it once. FRAMES_JOBS caps the Rust
# build (2 at home, where a wide build has taken the machine down).
set -eu
jobs="${FRAMES_JOBS:-2}"
cd "$(dirname "$0")/.."
echo "the demo catalog as a folder for the desk…"
flutter test test/screenshots/demo_fixture_test.dart --run-skipped --concurrency=1
echo "phone frames (en, de)…"
flutter test test/screenshots/site_frames_test.dart --run-skipped --concurrency=1
if [ -d desktop/crates/catlog-gui/tests ] && grep -q site_frames desktop/crates/catlog-gui/tests/*.rs 2>/dev/null; then
  echo "desk frames (en, de)…"
  (cd desktop && nice -n 19 env CARGO_BUILD_JOBS="$jobs" UPDATE_SNAPSHOTS=force cargo test -j "$jobs" -p catlog-gui --test site_frames --locked -- --ignored)
fi
echo "done: site/assets/frames"
