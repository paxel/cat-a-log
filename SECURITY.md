# Security policy

## Reporting a vulnerability

Please report a vulnerability in cat(a)log (the phone app, the desktop, the release
files, the F-Droid repository, the Homebrew formula and cask, and the Scoop manifest)
privately, through GitHub's
[private vulnerability reporting](https://github.com/paxel/cat-a-log/security/advisories/new)
(the repository's **Security** tab, **Report a vulnerability**). Do not open a public issue,
pull request or discussion for it.

Include what is affected (version, platform, the file or the sync path), how to reproduce it
(a sample bundle, backup or pair code helps most), and what an attacker gains, for example
code execution from a crafted bundle, data read or written through an in-person session or a
sync folder, or a catalog changed without the owner's key. The report and its fix are
discussed in that advisory, which stays private until a release with the fix is out.

## What is already checked

Every pull request and every change to the summer branch runs CodeQL (the desktop's Rust,
the Android Kotlin and the workflows), a dependency scan of every lockfile (OSV-Scanner),
cargo deny for the desktop's dependencies, and the fuzz targets of the parsers that read
untrusted input: bundles and backups, what a peer sends over the network, pair codes, share
QR codes and key records. SonarQube Cloud and OpenSSF Scorecard analyse the summer branch.
The CodeQL and Scorecard findings are the repository's code scanning alerts, SonarQube
Cloud's are on its project page; a report does not need to repeat them.

## Verifying a release

Every file of a GitHub release carries SLSA build provenance, signed with Sigstore by the
release workflow. `gh attestation verify <file> --repo paxel/cat-a-log` checks that a file was
built by this repository's workflow from the tagged commit.
