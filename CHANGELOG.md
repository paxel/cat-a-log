# Changelog

All notable changes to cat(a)log are documented in this file.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning: [SemVer](https://semver.org/).

## [2.6.0]

### Added
- Every file of a release carries signed build provenance: `gh attestation verify <file> --repo paxel/cat-a-log` shows it was built by this repository's release workflow from the tagged commit ([cat-1022](https://github.com/paxel/cat-a-log/issues/195)).

### Security
- The desktop's SQLite is 3.54 or newer, which no longer returns stale memory when a database is opened beside a write-ahead log of another page size ([cat-1023](https://github.com/paxel/cat-a-log/issues/196)).

---

Historical changes have been moved to [OLDER_CHANGES.md](OLDER_CHANGES.md).
