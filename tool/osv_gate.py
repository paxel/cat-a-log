"""Decides whether OSV-Scanner's findings stop CI or a release (cat-1004).

OSV-Scanner writes its findings as JSON (`--format json --output-file`);
this lists every one and fails on a known vulnerability. A notice that a
crate is unmaintained (RustSec's informational "unmaintained", no
vulnerability described) is listed but does not fail. Advisories ignored
in an osv-scanner.toml beside a lockfile are not in the JSON at all. A git
submodule or other git-root dependency is found by its commit, without
a name or version; it is listed as that commit.

    python3 tool/osv_gate.py osv-results.json

Exit 0: nothing blocks. Exit 1: a vulnerability. Exit 2: no readable
results, so the scan itself failed.
"""

import json
import sys


def unmaintained(vuln):
    """True when every affected entry is an informational unmaintained notice."""
    affected = vuln.get("affected") or []
    if not affected:
        return False
    return all(
        (entry.get("database_specific") or {}).get("informational") == "unmaintained"
        for entry in affected
    )


def findings(results):
    """(blocks, id, package, version, lockfile, summary) per vulnerability."""
    rows = []
    for result in results.get("results") or []:
        source = (result.get("source") or {}).get("path", "?")
        for package in result.get("packages") or []:
            info = package.get("package") or {}
            name, version = info.get("name") or "?", info.get("version") or "?"
            if not info.get("name") and info.get("commit"):
                name, version = "commit", info["commit"]
            for vuln in package.get("vulnerabilities") or []:
                rows.append(
                    (
                        not unmaintained(vuln),
                        vuln.get("id", "?"),
                        name,
                        version,
                        source,
                        vuln.get("summary", ""),
                    )
                )
    return rows


def main(argv):
    if len(argv) != 2:
        print("usage: osv_gate.py <osv-scanner json>", file=sys.stderr)
        return 2
    try:
        with open(argv[1], encoding="utf-8") as f:
            results = json.load(f)
    except (OSError, ValueError) as error:
        print(f"no OSV-Scanner results: {error}", file=sys.stderr)
        return 2
    rows = findings(results)
    blocking = 0
    for blocks, vid, name, version, source, summary in rows:
        kind = "VULNERABILITY" if blocks else "unmaintained, reported only"
        print(f"{kind}: {vid} {name} {version} in {source}: {summary}")
        blocking += blocks
    print(f"{len(rows)} findings, {blocking} of them blocking")
    return 1 if blocking else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
