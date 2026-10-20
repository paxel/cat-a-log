// The site build (#160): front matter, headings, the two trees and their
// siblings, the language switch, aliases, the search index per language and
// the link check. Run with `node --test "tool/site/*.test.js"`.
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { test } from "node:test";
import {
  REPO_ROOT,
  buildSite,
  checkLinks,
  collectPages,
  parseFrontMatter,
  processHeadings,
  readVersion,
  switchHref,
} from "./build.js";
import { generatedPages, parseChangelog, parseGlossary, parseStarters } from "./generated.js";

const PAGE = (title, body = "<p>Text.</p>", extra = "") =>
  `<!-- page: title="${title}" ${extra} -->\n${body}\n`;

/** A tiny site in a temp dir: both trees with an index and the pages given as {path: {en, de}}. */
function tinySite(pages = {}) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "catlog-site-"));
  const src = path.join(dir, "site");
  fs.mkdirSync(path.join(src, "assets"), { recursive: true });
  fs.writeFileSync(path.join(src, "assets", "site.css"), "body{}");
  fs.writeFileSync(path.join(src, "assets", "site.js"), "");
  fs.writeFileSync(path.join(src, "assets", "icon.png"), "");
  for (const lang of ["en", "de"]) {
    fs.mkdirSync(path.join(src, lang), { recursive: true });
    fs.writeFileSync(path.join(src, lang, "index.html"), PAGE(lang === "en" ? "Home" : "Start"));
  }
  for (const [rel, bodies] of Object.entries(pages)) {
    for (const [lang, source] of Object.entries(bodies)) {
      const file = path.join(src, lang, rel);
      fs.mkdirSync(path.dirname(file), { recursive: true });
      fs.writeFileSync(file, source);
    }
  }
  return { dir, src, out: path.join(dir, "site-dist") };
}

test("front matter: keys, order, unknown keys and tracks are refused", () => {
  const { meta, body } = parseFrontMatter(
    '<!-- page: title="A page" track="phone" order=3 summary="Short." alias="a.html" -->\n<p>x</p>',
  );
  assert.deepEqual(meta, { title: "A page", track: "phone", order: 3, summary: "Short.", alias: "a.html" });
  assert.equal(body, "<p>x</p>");
  assert.throws(() => parseFrontMatter("<p>no front matter</p>", "x.html"), /x\.html: missing front matter/);
  assert.throws(() => parseFrontMatter('<!-- page: title="A" track="nope" -->', "x.html"), /unknown track "nope"/);
  assert.throws(() => parseFrontMatter('<!-- page: title="A" colour="red" -->', "x.html"), /unknown front-matter key/);
  assert.throws(() => parseFrontMatter('<!-- page: track="phone" -->', "x.html"), /no title/);
});

test("headings get ids, copy anchors and a table of contents; umlauts slug to ascii", () => {
  const { html, headings, intro, sections } = processHeadings(
    "<p>Intro.</p><h2>Die Katze über alles</h2><p>Body one.</p><h3>Same</h3><h3>Same</h3>",
  );
  assert.deepEqual(
    headings.map((h) => [h.level, h.id, h.text]),
    [
      [2, "die-katze-ueber-alles", "Die Katze über alles"],
      [3, "same", "Same"],
      [3, "same-2", "Same"],
    ],
  );
  assert.match(html, /<h2 id="die-katze-ueber-alles">Die Katze über alles<a class="anchor"/);
  assert.equal(intro, "Intro.");
  assert.equal(sections[0], "Body one.");
});

test("the version comes from pubspec.yaml without the build number", () => {
  assert.equal(readVersion("name: catlog\nversion: 2.4.0+43\n"), "2.4.0");
  assert.throws(() => readVersion("name: catlog\n"), /no version/);
  assert.equal(readVersion(fs.readFileSync(path.join(REPO_ROOT, "pubspec.yaml"), "utf8")).split(".").length, 3);
});

test("every page needs its sibling in the other tree", () => {
  const { src } = tinySite({ "phone/cats.html": { en: PAGE("Cats", "<p>x</p>", 'track="phone"') } });
  assert.throws(() => collectPages({ srcDir: src }), /en\/phone\/cats\.html: no de sibling \(expected de\/phone\/cats\.html\)/);
});

test("the switch leads to the same page in the other language, else to its start page", () => {
  const pages = [
    { lang: "en", path: "index.html", url: "en/index.html" },
    { lang: "de", path: "index.html", url: "de/index.html" },
    { lang: "en", path: "phone/cats.html", url: "en/phone/cats.html" },
    { lang: "de", path: "phone/cats.html", url: "de/phone/cats.html" },
    { lang: "en", path: "phone/only.html", url: "en/phone/only.html" },
  ];
  assert.equal(switchHref(pages[2], pages), "de/phone/cats.html");
  assert.equal(switchHref(pages[3], pages), "en/phone/cats.html");
  assert.equal(switchHref(pages[4], pages), "de/index.html");
});

test("a build writes both trees, a search index per language, the alias, the root and the 404", () => {
  const { src, out } = tinySite({
    "reference/privacy-policy.html": {
      en: PAGE("Privacy", '<p>See <a href="../index.html">home</a>.</p><h2>Data</h2><p>None leaves.</p>', 'track="reference" alias="privacy-policy.html"'),
      de: PAGE("Datenschutz", '<p>Siehe <a href="../index.html">Start</a>.</p><h2>Daten</h2><p>Nichts geht raus.</p>', 'track="reference"'),
    },
  });
  const result = buildSite({ srcDir: src, outDir: out, version: "9.9.9", base: "/cat-a-log/" });
  assert.equal(result.pages, 4);
  const en = fs.readFileSync(path.join(out, "en", "reference", "privacy-policy.html"), "utf8");
  assert.match(en, /<html lang="en"/);
  assert.match(en, /class="lang-switch" href="\.\.\/\.\.\/de\/reference\/privacy-policy\.html"/);
  assert.match(en, /v9\.9\.9/);
  assert.match(en, /<p class="eyebrow track-eyebrow">Reference<\/p>/);
  const de = fs.readFileSync(path.join(out, "de", "reference", "privacy-policy.html"), "utf8");
  assert.match(de, /<html lang="de"/);
  assert.match(de, /Nachschlagen<\/p>/);
  assert.match(de, /Auf dieser Seite/);
  // The alias: the same page at the root, its links one level up.
  const alias = fs.readFileSync(path.join(out, "privacy-policy.html"), "utf8");
  assert.match(alias, /None leaves\./);
  assert.match(alias, /href="en\/index\.html">home</);
  assert.match(alias, /href="assets\/site\.css"/);
  const index = JSON.parse(fs.readFileSync(path.join(out, "en", "search-index.json"), "utf8"));
  assert.deepEqual(index.map((p) => p.url), ["index.html", "reference/privacy-policy.html"]);
  assert.equal(index[1].headings[0].body, "None leaves.");
  const deIndex = JSON.parse(fs.readFileSync(path.join(out, "de", "search-index.json"), "utf8"));
  assert.equal(deIndex[1].track, "Nachschlagen");
  assert.match(fs.readFileSync(path.join(out, "index.html"), "utf8"), /de\/index\.html/);
  assert.match(fs.readFileSync(path.join(out, "404.html"), "utf8"), /Page not found/);
  assert.ok(fs.existsSync(path.join(out, ".nojekyll")));
});

test("a broken link or anchor fails the build, and a root-relative one too", () => {
  const files = new Map([
    ["en/index.html", '<a href="phone/x.html">x</a>'],
    ["en/phone/x.html", '<h2 id="a">A</h2><a href="../index.html#nope">n</a>'],
  ]);
  assert.throws(() => checkLinks(files), /missing anchor #nope/);
  files.set("en/phone/x.html", '<a href="gone.html">g</a>');
  assert.throws(() => checkLinks(files), /"gone\.html" does not resolve/);
  const { src } = tinySite({
    "phone/cats.html": {
      en: PAGE("Cats", '<a href="/en/index.html">root</a>', 'track="phone"'),
      de: PAGE("Katzen", "<p>x</p>", 'track="phone"'),
    },
  });
  assert.throws(() => collectPages({ srcDir: src }), /is root-relative/);
});

test("the repository's own site builds and links, generated pages included", () => {
  const out = fs.mkdtempSync(path.join(os.tmpdir(), "catlog-site-dist-"));
  const result = buildSite({ outDir: out, base: "/cat-a-log/", generated: generatedPages() });
  assert.ok(result.pages >= 100, `${result.pages} pages`);
  for (const lang of ["en", "de"]) {
    for (const page of ["glossary", "whats-new", "fields", "privacy-policy", "troubleshooting"]) {
      assert.ok(fs.existsSync(path.join(out, lang, "reference", `${page}.html`)), `${lang}/${page}`);
    }
  }
  // The privacy policy keeps the address the stores link.
  assert.match(fs.readFileSync(path.join(out, "privacy-policy.html"), "utf8"), /no server, no account/);
});

test("the glossary, the starters and a changelog parse, and a missing German term fails", () => {
  const entries = parseGlossary("## Language\n\n**Cat**:\nAn animal.\n_Avoid_: kitty\n\n**Stray** [Stray]:\nNo home.\n");
  assert.deepEqual(entries.map((e) => [e.term, e.english, e.avoid]), [["Cat", "Cat", "kitty"], ["Stray", "Stray", ""]]);
  assert.throws(() => parseGlossary("nothing here", "x.md"), /x\.md: no glossary entries/);
  const starters = parseStarters("(slug: 'weight', name: 'Weight', type: FieldType.unitValue, scope: FieldScope.cat, options: [])");
  assert.deepEqual(starters, [{ slug: "weight", name: "Weight", type: "unitValue", scope: "cat" }]);
  const log = parseChangelog("## [2.4.0]\n\n### Added\n- One.\n  more\n- Two.\n\n## [2.3.0] - 2026-10-05\n\n### Fixed\n- Three.\n");
  assert.deepEqual(log.map((s) => [s.version, s.date, s.categories.map((c) => [c.name, c.items])]), [
    ["2.4.0", "", [["Added", ["One. more", "Two."]]]],
    ["2.3.0", "2026-10-05", [["Fixed", ["Three."]]]],
  ]);
});
