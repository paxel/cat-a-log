import json
import pathlib
import tempfile
import unittest
from contextlib import redirect_stdout
from io import StringIO

from osv_gate import main


def vuln(vid, informational=None):
    specific = {"informational": informational} if informational else {}
    return {
        "id": vid,
        "summary": f"{vid} summary",
        "affected": [{"database_specific": specific}],
    }


def results(*vulns):
    return {
        "results": [
            {
                "source": {"path": "desktop/Cargo.lock"},
                "packages": [
                    {
                        "package": {"name": "paste", "version": "1.0.15"},
                        "vulnerabilities": list(vulns),
                    }
                ],
            }
        ]
    }


class OsvGateTest(unittest.TestCase):
    def run_gate(self, data):
        with tempfile.TemporaryDirectory() as tmp:
            path = pathlib.Path(tmp) / "osv.json"
            path.write_text(json.dumps(data), encoding="utf-8")
            out = StringIO()
            with redirect_stdout(out):
                code = main(["osv_gate.py", str(path)])
            return code, out.getvalue()

    def test_no_findings_passes(self):
        self.assertEqual(self.run_gate({"results": []})[0], 0)

    def test_an_unmaintained_notice_is_listed_but_passes(self):
        code, out = self.run_gate(results(vuln("RUSTSEC-2024-0436", "unmaintained")))
        self.assertEqual(code, 0)
        self.assertIn("unmaintained, reported only: RUSTSEC-2024-0436", out)

    def test_a_vulnerability_fails(self):
        code, out = self.run_gate(
            results(vuln("RUSTSEC-2024-0436", "unmaintained"), vuln("GHSA-xxxx"))
        )
        self.assertEqual(code, 1)
        self.assertIn("VULNERABILITY: GHSA-xxxx paste 1.0.15", out)

    def test_an_unsound_notice_fails(self):
        self.assertEqual(self.run_gate(results(vuln("RUSTSEC-1", "unsound")))[0], 1)

    def test_an_advisory_unmaintained_for_only_some_entries_fails(self):
        mixed = vuln("RUSTSEC-2", "unmaintained")
        mixed["affected"].append({"database_specific": {}})
        self.assertEqual(self.run_gate(results(mixed))[0], 1)

    def test_an_advisory_without_affected_entries_fails(self):
        self.assertEqual(self.run_gate(results({"id": "OSV-1"}))[0], 1)

    def test_a_vulnerable_submodule_commit_fails_and_names_the_commit(self):
        # As osv-scanner 2.7 --include-git-root reports the submodule
        # of a pinned upstream library: no name or
        # version, only the commit, found through the repository's .git.
        submodule = {
            "results": [
                {
                    "source": {"path": "/repo/.git", "type": "git"},
                    "packages": [
                        {
                            "package": {
                                "name": "",
                                "version": "",
                                "ecosystem": "GIT",
                                "commit": "927cfce34f31707e17f2bff35c349632fb9e2c3a",
                            },
                            "vulnerabilities": [vuln("CVE-2026-110810")],
                        }
                    ],
                }
            ]
        }
        code, out = self.run_gate(submodule)
        self.assertEqual(code, 1)
        self.assertIn(
            "VULNERABILITY: CVE-2026-110810 commit "
            "927cfce34f31707e17f2bff35c349632fb9e2c3a in /repo/.git",
            out,
        )

    def test_missing_results_fail_as_a_broken_scan(self):
        with redirect_stdout(StringIO()):
            self.assertEqual(main(["osv_gate.py", "/nonexistent/osv.json"]), 2)


if __name__ == "__main__":
    unittest.main()
