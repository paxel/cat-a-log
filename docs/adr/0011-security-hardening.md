# ADR-0011: Security and quality hardening

## Status

Accepted. Implemented by the tickets [cat-1000](https://github.com/paxel/cat-a-log/issues/173) to [cat-1027](https://github.com/paxel/cat-a-log/issues/200), milestone 2.6.0.

## Context

By November 2026 the user's sibling repositories (oldbrainfix, chaos-alert,
pixpixpix, dedup-rs, focus, multigit) had been hardened: pinned workflow
actions, read-only tokens, CodeQL, SonarQube Cloud, coverage ratchets, strict
lints, release gates and a protected default branch. cat(a)log, whose release
pipeline oldbrainfix's was copied from, had none of it: actions by tag, OSV
weekly only, a fixed 80% coverage floor in CI, `unwrap` and `!` allowed, a
TestFlight upload outside the gate, and a `summer` branch anyone with push
access could rewrite.

cat(a)log reads input from outside: bundle files and backups, what a peer
sends in an in-person session, sync folders, pair codes, share QR codes. It
ships to Google Play, the App Store, F-Droid, Homebrew, Scoop and GitHub
releases.

## Decision

Everything below was decided in the 2.6.0 grilling, one question at a time.

- **Baseline:** parity with oldbrainfix, the closest sibling (Flutter, Dart
  core, Rust desktop, iOS), plus what only the Rust siblings have: OpenSSF
  Scorecard, SLSA build provenance, cargo-deny and fuzzing.
- **Lints, strict at once:** the desktop workspace denies `unsafe_code`,
  `unwrap_used`, `expect_used`, `panic`, `todo`, `unimplemented`,
  `unreachable` and `indexing_slicing`; tests may (clippy.toml, and an allow
  at the top of each file in tests/ and examples/). The Dart code is analysed
  with `strict-casts`, `strict-raw-types` and `strict-inference`, the async
  and resource lints raised to errors, and `tool/no_null_assertions.dart`
  fails on any `!` outside tests. Every violation was fixed; nothing is
  waved through with an allow list.
- **Coverage:** a floor per group (rust-core, rust-gui, rust-l10n,
  dart-core, flutter-app) in `tool/coverage-floors.txt`, one point below the
  measured value, raised when coverage rises, never lowered; checked in CI
  and the release gate, shown as README badges.
- **SonarQube Cloud:** analyses every push to `summer`; the release gate
  refuses a tag while its quality gate is not OK.
- **Protected `summer`:** pull requests only, required checks, no deletion,
  no force-push. Work arrives on `release/x.y` and `bugfix/x.y.z` branches.
- **iOS:** `ios.yml` builds the app and runs its XCTest target on every push
  and as a gate of the release; TestFlight is a release job behind it.
- **Fuzzing:** every parser at a trust boundary (bundle import and backup
  restore, the LAN request reader and `/sync` body, pair codes, share QR
  codes, key records) has a cargo-fuzz target; a minute per pull request, a
  quarter hour weekly. The user-text parsers are not fuzzed.
- **Vulnerability reports:** private vulnerability reporting, Dependabot
  alerts and security updates are on; `SECURITY.md` says how to report and
  how to verify a release.
- **Written down:** the Quality gates section of AGENTS.md, this ADR, and the
  header comment of each workflow.

Beside these, by parity: every action pinned to a full commit SHA, every
workflow read-only by default, CodeQL for Rust, Kotlin and the workflows,
Dependabot for the actions, OSV-Scanner with `tool/osv_gate.py` on every push
and in the release gate (every ignore with a reason and an `ignoreUntil`
date), and a release gate that also checks the changelog section, open
high or critical CodeQL alerts, Dart formatting, untranslated strings and the
Android signing key. CI pins Flutter 3.47.9, as oldbrainfix does.

## Consequences

- A release cannot ship while a dependency has a known vulnerability, a
  CodeQL alert is high or critical, coverage fell, or Sonar's gate is red.
- New code handles every `None`, `Err` and `null`; a panic or a null-check
  crash is a lint error before it is a bug report.
- Direct pushes to `summer` stop; every change is a pull request whose
  required checks must pass.
- A downloaded release file can be checked with
  `gh attestation verify <file> --repo paxel/cat-a-log`.
- New licences in the desktop's dependency tree fail cargo-deny until they
  are added to `desktop/deny.toml`.
