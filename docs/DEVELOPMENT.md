# Development

One Flutter codebase for Android, iOS, Linux, Windows, and macOS.

## Architecture

- `packages/catalog_core` — pure Dart, no Flutter. The append-only entry
  log over SQLite: every change is an immutable entry
  `(entity, field, value, date, author)`; a device's state is the union of
  all entries it has seen; the newest entry wins the display,
  deterministically on every device. Sync is a delta exchange of missing
  entries plus content-addressed photo blobs, over two transports (LAN
  HTTP, shared folder). Conflicts, merges (alias-based), and reverts are
  all ordinary entries.
- `lib/` — the Flutter app. UI only; all domain logic goes through the
  core's API.
- Decisions: `docs/adr/`. Domain vocabulary: `CONTEXT.md`. Both are kept
  current — read them before changing the model.

## Commands

```sh
# core tests (pure Dart, in-memory SQLite)
cd packages/catalog_core && dart test

# app analysis and widget tests
flutter analyze --fatal-infos && flutter test

# the Rust desktop app (see desktop/README.md for its gates)
cd desktop && cargo run --bin catlog

# regenerate the README screenshots (demo catalog, real fonts)
flutter test test/screenshots --run-skipped
```

## Documentation site

`site/` holds the keeper's documentation as HTML fragments in two trees,
`site/en/` and `site/de/`, page for page; `tool/site/build.js` renders
them into `site-dist/` with the navigation, a search index per language
and the link check (#160).

```sh
# build and preview at http://127.0.0.1:8080/
node tool/site/build.js --serve

# every released minor version under /vX.Y.Z/ plus the working tree at the root
node tool/site/build-all.js

# the build's own tests
node --test "tool/site/*.test.js"
```

The Pages workflow builds the site on every push and deploys it on a
release tag only, after checking the tag against `pubspec.yaml`, so the
site always describes the app the stores have. Every deploy carries every
released minor version, the latest patch of each, under `/vX.Y.Z/`, and
the header's version menu leads between them; an older version's pages
point at the latest.

The site's frames under `site/assets/frames/` are generated, not drawn:
`tool/frames.sh` renders the phone's pages and flow steps (Flutter, both
languages, the clock pinned to the demo's day) and the desk's (the kittest
harness over the same demo catalog). CI regenerates them and fails on a
diff, so a frame never shows an older app than the tag.

The glossary page is built from `CONTEXT.md` and `site/glossary.de.md`,
the fields page from the starter set in the Dart core, and What's new
from `CHANGELOG.md`, `CHANGELOG.de.md` and their `OLDER_CHANGES` files.
A new term, a new starter field or a changelog section without its German
twin fails the build. The privacy policy lives in the site
(`site/en/reference/privacy-policy.html`, served at the root path the
stores link, too).

## Translations

38 ARB files under `lib/l10n/`, machine-translated. `gen_l10n` runs on
build; the untranslated-messages report must stay empty. Starter field
names translate at display time (ADR-0005) — never store translations in
the data.

## Releases

Every changelog entry is written twice: in `CHANGELOG.md` and in
`CHANGELOG.de.md`, same section, same order. A version bump moves the
released section of both to `OLDER_CHANGES.md` and `OLDER_CHANGES.de.md`
with the tag's date.

Tag-driven, mirroring the dedup-rs pipeline: `git tag v2.0.0 && git push
--tags` (or the Actions "Run workflow" button with publish ticked) runs the
full gate, checks the tag against the pubspec and the Cargo versions, builds
signed Android APKs, the Rust desktop for Linux (tar.gz, .deb and AppImage,
x86_64 + arm64), a Windows zip, and unsigned macOS dmgs (both arches),
creates the GitHub Release with the CHANGELOG section as notes, and pushes
the Homebrew cask (macOS app), the Homebrew formula (Linux tarballs) and the
Scoop manifest to `paxel/homebrew-tap` and `paxel/scoop-bucket`. The
templates and packing scripts live under `desktop/packaging/`.

A dry run is the same button with publish left off: every artifact is
built and uploaded to the workflow run, nothing is released or pushed:

```sh
gh workflow run release.yml --ref release/2.0.0 -f tag=v2.0.0 -f publish=false
```

Required repository secrets: `ANDROID_KEYSTORE_BASE64`,
`ANDROID_KEYSTORE_PASSWORD`, `CHANNEL_PAT`, and (for TestFlight) the six
Apple secrets in `docs/ci-ios-signing.md`. Keystore backup notes:
`docs/release-android.md`.
