# catlog

## Agent skills

### Issue tracker

Issues live as GitHub Issues (`gh` CLI). See `docs/agents/issue-tracker.md`.

### Triage labels

Default five-role vocabulary, label string equals role name. See `docs/agents/triage-labels.md`.

### UI laws

Gestures (tap = primary, long-press = secondary with the cat ear), dialog and page layout, wording. See `docs/agents/ui-laws.md`. Check every screen change against it.

### Store kit

Play and App Store texts, screenshots and paste pages for a release come from the global `store-kit` skill; this repo's ids, paths, locales and glossary are in `docs/agents/store-kit.md`.

### Domain docs

Single-context: `CONTEXT.md` + `docs/adr/` at repo root. See `docs/agents/domain.md`.

### Quality gates

The decisions behind these are in `docs/adr/0011-security-hardening.md` (cat-1025).

- **No panics, no `!`.** The desktop workspace denies `unsafe_code`, `unwrap`, `expect`, `panic!`, `todo!`, `unimplemented!`, `unreachable!` and indexing (`desktop/Cargo.toml`); tests may (`desktop/clippy.toml`, and an allow at the top of each file in `tests/` and `examples/`). The Dart code is analysed strictly (`analysis_options.yaml`) and `packages/catalog_core/tool/no_null_assertions.dart` fails on any `!` outside tests. Handle the `None`, `Err` or `null`; never add an allow to get past a lint.
- **Coverage ratchet.** `tool/coverage.sh` checks each group against `tool/coverage-floors.txt` and raises a floor when coverage rose; commit the raised floor with the change that earned it. Floors are never lowered. Every feature ships with tests that hold or raise coverage.
- **Actions and tokens.** Every action in `.github/workflows/` is pinned to a full commit SHA with its version in a trailing comment. Every workflow starts with `permissions: contents: read`; a job that writes widens it itself.
- **Dependencies.** OSV-Scanner (`tool/osv_gate.py`) and cargo-deny (`desktop/deny.toml`) run on every push and in the release gate. An advisory that cannot be fixed is ignored in `desktop/osv-scanner.toml` (with an `ignoreUntil` date) and in `desktop/deny.toml`, each with its reason. A new licence is added to `deny.toml` only after it has been looked at.
- **Fuzzing.** Every parser that reads untrusted input has a target in `desktop/fuzz/`; a new one gets its own.
- **Branches.** `summer` takes pull requests only; the required checks are the CI jobs, CodeQL, the iOS build and cargo-deny. Work arrives on `release/x.y` and `bugfix/x.y.z` branches.
- **Releases.** The release gate fails on a known vulnerability, an open high or critical CodeQL alert, a missing `CHANGELOG.md` section, unformatted Dart, an untranslated string, a coverage floor, a red Sonar quality gate or a debug-signed Android build. TestFlight, Play, F-Droid and the GitHub release all wait for it.
