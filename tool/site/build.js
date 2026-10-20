#!/usr/bin/env node
// Builds the documentation site (#160): site/<lang>/**/*.html fragments with a
// front-matter comment -> site-dist/ with full pages, the assets, a search
// index per language, a 404 page and the root redirect. Two trees, en and
// de, authored page for page; the header switch leads to the same page in
// the other language or to that language's start page when it is missing.
// Zero dependencies; Node 22+. Usage:
//   node tool/site/build.js [--src site] [--out site-dist] [--base /] [--serve [port]]

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import http from "node:http";
import { fileURLToPath } from "node:url";
import { REPO_ROOT, decodeEntities, escapeHtml, readVersion, slugify, stripTags } from "./common.js";
import { generatedPages } from "./generated.js";
export const REPO_URL = "https://github.com/paxel/catlog";
export const SITE_URL = "https://paxel.github.io/cat-a-log/";

/** The two trees, and what the header calls them. */
export const LANGS = [
  { id: "en", label: "English", switchLabel: "Deutsch", switchTo: "de" },
  { id: "de", label: "Deutsch", switchLabel: "English", switchTo: "en" },
];

/** The keeper's tracks, labelled per language. */
export const TRACKS = [
  { id: "start", label: { en: "Start", de: "Start" } },
  { id: "phone", label: { en: "Phone", de: "Telefon" } },
  { id: "desk", label: { en: "Desk", de: "Schreibtisch" } },
  { id: "reference", label: { en: "Reference", de: "Nachschlagen" } },
];

/** The chrome's words per language; the pages carry their own. */
export const UI = {
  en: {
    overview: "Overview",
    noChapters: "No chapters yet",
    onThisPage: "On this page",
    search: "Search the docs",
    searchLabel: "Search the documentation",
    searchResults: "Search results",
    skip: "Skip to content",
    openNav: "Open navigation",
    switchTheme: "Switch theme",
    toDark: "Switch to dark theme",
    copyLink: "Copy link to",
    copyLinkTitle: "Copy link to this section",
    notFound: "Page not found",
    notFoundLede: "There is nothing at this address. The page may have moved, or the link is older than the site.",
    notFoundHelp: "Try the search box above (press /) or start from the",
    overviewLink: "overview",
    projectLinks: "Project links",
    whatsNew: "What's new",
    versionTitle: "cat(a)log version",
    language: "Language",
    stepOf: "Step {n} of {m}",
    step: "Step",
    noMatches: "No matches",
    searchUnavailable: "Search unavailable",
    results: "results",
    result: "result",
    linkCopied: "Link copied",
    copyFailed: "Could not copy automatically; the heading is selected",
    previous: "← Previous",
    next: "Next →",
    steps: "Steps",
  },
  de: {
    overview: "Übersicht",
    noChapters: "Noch keine Kapitel",
    onThisPage: "Auf dieser Seite",
    search: "Doku durchsuchen",
    searchLabel: "Die Dokumentation durchsuchen",
    searchResults: "Suchergebnisse",
    skip: "Zum Inhalt springen",
    openNav: "Navigation öffnen",
    switchTheme: "Farbschema wechseln",
    toDark: "Zum dunklen Farbschema wechseln",
    copyLink: "Link kopieren zu",
    copyLinkTitle: "Link zu diesem Abschnitt kopieren",
    notFound: "Seite nicht gefunden",
    notFoundLede: "Unter dieser Adresse gibt es nichts. Die Seite ist umgezogen, oder der Link ist älter als die Seite.",
    notFoundHelp: "Versuch die Suche oben (Taste /) oder fang bei der",
    overviewLink: "Übersicht an",
    projectLinks: "Projektlinks",
    whatsNew: "Was ist neu",
    versionTitle: "cat(a)log-Version",
    language: "Sprache",
    stepOf: "Schritt {n} von {m}",
    step: "Schritt",
    noMatches: "Keine Treffer",
    searchUnavailable: "Suche nicht verfügbar",
    results: "Treffer",
    result: "Treffer",
    linkCopied: "Link kopiert",
    copyFailed: "Konnte nicht automatisch kopieren; die Überschrift ist markiert",
    previous: "← Zurück",
    next: "Weiter →",
    steps: "Schritte",
  },
};

const FRONT_MATTER_KEYS = ["title", "track", "order", "summary", "alias"];

const FONTS_HREF =
  "https://fonts.googleapis.com/css2?family=Noto+Sans:ital,wght@0,400;0,600;1,400&family=Noto+Serif:wght@400;600&display=swap";

// ---------------------------------------------------------------------------
// Small helpers live in common.js, shared with the generated pages.

export { REPO_ROOT, escapeHtml, decodeEntities, stripTags, slugify, readVersion };

function collectIds(html) {
  const ids = new Set();
  const re = /\sid\s*=\s*(?:"([^"]+)"|'([^']+)'|([^\s>"']+))/g;
  let m;
  while ((m = re.exec(html)) !== null) ids.add(m[1] ?? m[2] ?? m[3]);
  return ids;
}

// ---------------------------------------------------------------------------
// Front matter: <!-- page: title="…" track="start" order=1 summary="…" alias="privacy-policy.html" -->

export function parseFrontMatter(source, file = "page") {
  const match = /^\s*<!--\s*page:([\s\S]*?)-->/.exec(source);
  if (!match) throw new Error(`${file}: missing front matter (<!-- page: … -->)`);
  const meta = {};
  const pair = /^([a-z]+)\s*=\s*(?:"([^"]*)"|([^\s"]+))(?:\s+|$)/;
  let rest = match[1].trim();
  while (rest.length) {
    const m = pair.exec(rest);
    if (!m) {
      throw new Error(
        `${file}: cannot read front matter at "${rest.slice(0, 40)}": expected key="value" ` +
          `pairs; a bare value is a single token, values with spaces must be quoted`,
      );
    }
    if (!FRONT_MATTER_KEYS.includes(m[1])) {
      throw new Error(`${file}: unknown front-matter key "${m[1]}"`);
    }
    meta[m[1]] = m[2] !== undefined ? m[2] : m[3];
    rest = rest.slice(m[0].length);
  }
  if (!meta.title) throw new Error(`${file}: front matter has no title`);
  if (meta.track && !TRACKS.some((t) => t.id === meta.track)) {
    throw new Error(`${file}: unknown track "${meta.track}"`);
  }
  const order = meta.order === undefined ? 0 : Number(meta.order);
  if (Number.isNaN(order)) throw new Error(`${file}: order "${meta.order}" is not a number`);
  return {
    meta: {
      title: meta.title,
      track: meta.track || "",
      order,
      summary: meta.summary || "",
      alias: meta.alias || "",
    },
    body: source.slice(match[0].length).trim(),
  };
}

// ---------------------------------------------------------------------------
// Headings: ids, copy-link anchors, table of contents, section text.

export function processHeadings(body, ui = UI.en) {
  const used = collectIds(body);
  const emitted = new Set();
  const headings = [];
  const matches = [];
  const re = /<(h[23])(\s[^>]*)?>([\s\S]*?)<\/\1>/g;
  let m;
  while ((m = re.exec(body)) !== null) {
    const [whole, tag, attrs = "", inner] = m;
    const text = stripTags(inner);
    const authored = /\sid\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s>"']+))/.exec(attrs);
    const base = authored ? (authored[1] ?? authored[2] ?? authored[3]) : slugify(text);
    let id = base;
    let n = 1;
    while (authored ? emitted.has(id) : used.has(id)) id = `${base}-${++n}`;
    emitted.add(id);
    used.add(id);
    headings.push({ level: Number(tag[1]), id, text });
    const rest = attrs.replace(/\sid\s*=\s*(?:"[^"]*"|'[^']*'|[^\s>"']+)/, "");
    const anchor =
      `<a class="anchor" href="#${id}" aria-label="${escapeHtml(ui.copyLink)} ${escapeHtml(text)}" ` +
      `title="${escapeHtml(ui.copyLinkTitle)}">#</a>`;
    matches.push({
      start: m.index,
      end: m.index + whole.length,
      html: `<${tag} id="${id}"${rest}>${inner}${anchor}</${tag}>`,
    });
  }
  let html = "";
  let cursor = 0;
  const sections = [];
  for (let i = 0; i < matches.length; i++) {
    html += body.slice(cursor, matches[i].start) + matches[i].html;
    cursor = matches[i].end;
    const next = i + 1 < matches.length ? matches[i + 1].start : body.length;
    sections.push(stripTags(body.slice(cursor, next)));
  }
  html += body.slice(cursor);
  const intro = stripTags(body.slice(0, matches.length ? matches[0].start : body.length));
  return { html, headings, intro, sections };
}

// ---------------------------------------------------------------------------
// Pages, nav and search index. A page's url is `<lang>/<track>/<name>.html`;
// `path` is the part after the language, the same in both trees.

export function loadPages(srcDir) {
  const pages = [];
  for (const lang of LANGS) {
    const root = path.join(srcDir, lang.id);
    if (!fs.existsSync(root)) throw new Error(`${srcDir}: no ${lang.id}/ tree`);
    const walk = (dir) => {
      for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
        const full = path.join(dir, entry.name);
        if (entry.isDirectory()) walk(full);
        else if (entry.name.endsWith(".html")) {
          const rel = path.relative(root, full).split(path.sep).join("/");
          const url = `${lang.id}/${rel}`;
          const { meta, body } = parseFrontMatter(fs.readFileSync(full, "utf8"), url);
          pages.push({ ...meta, lang: lang.id, path: rel, url, body });
        }
      }
    };
    walk(root);
  }
  return sortPages(pages);
}

/** Language, then landing page, then tracks in order, then page order. */
export function sortPages(pages) {
  const langNo = (id) => LANGS.findIndex((l) => l.id === id);
  const trackNo = (id) => (id ? TRACKS.findIndex((t) => t.id === id) : -1);
  return pages.sort(
    (a, b) =>
      langNo(a.lang) - langNo(b.lang) ||
      trackNo(a.track) - trackNo(b.track) ||
      a.order - b.order ||
      a.url.localeCompare(b.url),
  );
}

/** Every page of one language has its sibling in the other; the trees never drift apart. */
export function checkSiblings(pages) {
  for (const lang of LANGS) {
    const other = LANGS.find((l) => l.id === lang.switchTo);
    const theirs = new Set(pages.filter((p) => p.lang === other.id).map((p) => p.path));
    for (const page of pages.filter((p) => p.lang === lang.id)) {
      if (!theirs.has(page.path)) {
        throw new Error(`${page.url}: no ${other.id} sibling (expected ${other.id}/${page.path})`);
      }
    }
  }
}

export function buildNav(pages, lang) {
  return TRACKS.map((track) => ({
    id: track.id,
    label: track.label[lang],
    pages: pages
      .filter((p) => p.lang === lang && p.track === track.id)
      .sort((a, b) => a.order - b.order || a.title.localeCompare(b.title))
      .map(({ title, url, order, summary }) => ({ title, url, order, summary })),
  }));
}

export function buildIndex(pages, lang) {
  const trackLabel = (id) => TRACKS.find((t) => t.id === id)?.label[lang] || "";
  return pages
    .filter((p) => p.lang === lang)
    .map((page) => {
      const { headings, intro, sections } = processHeadings(page.body, UI[lang]);
      return {
        title: page.title,
        track: trackLabel(page.track),
        url: page.path,
        summary: page.summary,
        intro,
        headings: headings.map((h, i) => ({ id: h.id, text: h.text, body: sections[i] || "" })),
      };
    });
}

// ---------------------------------------------------------------------------
// Rendering

function relPrefix(url) {
  const depth = url.split("/").length - 1;
  return depth === 0 ? "" : "../".repeat(depth);
}

function renderNav(nav, currentUrl, rel, lang, ui) {
  const link = (p) =>
    `<li><a href="${rel}${p.url}"${p.url === currentUrl ? ' aria-current="page"' : ""}>${escapeHtml(p.title)}</a></li>`;
  const homeUrl = `${lang}/index.html`;
  const home = `<a class="nav-home" href="${rel}${homeUrl}"${currentUrl === homeUrl ? ' aria-current="page"' : ""}>${escapeHtml(ui.overview)}</a>`;
  const tracks = nav
    .map(
      (t) =>
        `<section class="nav-track" aria-label="${escapeHtml(t.label)}"><p class="eyebrow">${escapeHtml(t.label)}</p>` +
        (t.pages.length
          ? `<ul>${t.pages.map(link).join("")}</ul>`
          : `<p class="nav-empty">${escapeHtml(ui.noChapters)}</p>`) +
        `</section>`,
    )
    .join("");
  return home + tracks;
}

function renderToc(headings, ui) {
  if (!headings.length) return "";
  const items = headings
    .map((h) => `<li class="toc-l${h.level}"><a href="#${h.id}">${escapeHtml(h.text)}</a></li>`)
    .join("");
  return `<aside class="toc" aria-label="${escapeHtml(ui.onThisPage)}">\n<p class="eyebrow">${escapeHtml(ui.onThisPage)}</p><ol>${items}</ol>\n</aside>\n`;
}

/** The same page in the other language, or that language's start page. */
export function switchHref(page, pages) {
  const lang = LANGS.find((l) => l.id === page.lang);
  const sibling = pages.find((p) => p.lang === lang.switchTo && p.path === page.path);
  return sibling ? sibling.url : `${lang.switchTo}/index.html`;
}

const BRAND = (rel) =>
  `<img class="mark" src="${rel}assets/icon.png" width="28" height="28" alt="">`;

function shell({ lang, title, summary, rel, root, nav, currentUrl, eyebrow, main, toc, version, switchTo, whatsNew }) {
  const ui = UI[lang];
  const language = LANGS.find((l) => l.id === lang);
  const i18n = {
    stepOf: ui.stepOf,
    step: ui.step,
    noMatches: ui.noMatches,
    searchUnavailable: ui.searchUnavailable,
    results: ui.results,
    result: ui.result,
    linkCopied: ui.linkCopied,
    copyFailed: ui.copyFailed,
    openNav: ui.openNav,
    closeNav: lang === "de" ? "Navigation schließen" : "Close navigation",
    toLight: lang === "de" ? "Zum hellen Farbschema wechseln" : "Switch to light theme",
    toDark: ui.toDark,
  };
  return `<!doctype html>
<html lang="${lang}" data-root="${root}" data-lang="${lang}" data-i18n='${escapeHtml(JSON.stringify(i18n)).replace(/'/g, "&#39;")}'>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${escapeHtml(title)} — cat(a)log</title>
${summary ? `<meta name="description" content="${escapeHtml(summary)}">\n` : ""}<script>try{var t=localStorage.getItem("catlog-theme");if(t==="light"||t==="dark"){document.documentElement.setAttribute("data-theme",t)}}catch(e){}</script>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="${FONTS_HREF}">
<link rel="stylesheet" href="${rel}assets/site.css">
<link rel="icon" href="${rel}assets/icon.png" type="image/png">
</head>
<body>
<a class="skip" href="#content">${escapeHtml(ui.skip)}</a>
<div class="sr-only" id="live" aria-live="polite" aria-atomic="true"></div>
<header class="site-header">
<button class="nav-toggle" type="button" aria-controls="sidebar" aria-expanded="false" aria-label="${escapeHtml(ui.openNav)}"><span class="nav-toggle-bars" aria-hidden="true"></span></button>
<a class="brand" href="${rel}${lang}/index.html">${BRAND(rel)}<span class="brand-name">cat(a)log</span></a>
<span class="chip" title="${escapeHtml(ui.versionTitle)}">v${escapeHtml(version)}</span>
<div class="search" role="search">
<input class="search-input" id="search" type="search" placeholder="${escapeHtml(ui.search)}" aria-label="${escapeHtml(ui.searchLabel)}" role="combobox" aria-autocomplete="list" aria-controls="search-results" aria-expanded="false" autocomplete="off" spellcheck="false">
<kbd class="search-kbd" aria-hidden="true">/</kbd>
<ul class="search-results" id="search-results" role="listbox" aria-label="${escapeHtml(ui.searchResults)}" hidden></ul>
</div>
<a class="lang-switch" href="${rel}${switchTo}" lang="${language.switchTo}" hreflang="${language.switchTo}" aria-label="${escapeHtml(ui.language)}: ${escapeHtml(language.switchLabel)}">${escapeHtml(language.switchLabel)}</a>
<button class="theme-toggle" type="button" aria-label="${escapeHtml(ui.toDark)}" title="${escapeHtml(ui.switchTheme)}">
<svg class="icon-sun" viewBox="0 0 24 24" width="18" height="18" aria-hidden="true"><circle cx="12" cy="12" r="4" fill="currentColor"/><g stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M12 2v2M12 20v2M2 12h2M20 12h2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/></g></svg>
<svg class="icon-moon" viewBox="0 0 24 24" width="18" height="18" aria-hidden="true"><path d="M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5z" fill="currentColor"/></svg>
</button>
</header>
<div class="layout">
<nav class="sidebar" id="sidebar" aria-label="${lang === "de" ? "Dokumentation" : "Documentation"}">
${renderNav(nav, currentUrl, rel, lang, ui)}
</nav>
<main class="content" id="content" tabindex="-1">
${eyebrow ? `<p class="eyebrow track-eyebrow">${escapeHtml(eyebrow)}</p>\n` : ""}${main}
</main>
${toc}</div>
<footer class="site-footer">
<span>cat(a)log <span class="chip" title="${escapeHtml(ui.versionTitle)}">v${escapeHtml(version)}</span></span>
<nav aria-label="${escapeHtml(ui.projectLinks)}"><a href="${REPO_URL}">GitHub</a>${whatsNew ? `<a href="${rel}${whatsNew}">${escapeHtml(ui.whatsNew)}</a>` : ""}</nav>
</footer>
<script src="${rel}assets/site.js" defer></script>
</body>
</html>
`;
}

export function renderPage(page, { navs, version, pages, url = page.url }) {
  const rel = relPrefix(url);
  const ui = UI[page.lang];
  const { html, headings } = processHeadings(page.body, ui);
  // An alias at the root sees the page's relative links from one level up.
  const body = (url === page.url ? html : html.replace(/(href|src)="\.\.\//g, `$1="${page.lang}/`))
    .replace(/<table(\s[^>]*)?>[\s\S]*?<\/table>/g, (t) => `<div class="table-wrap">${t}</div>`);
  const track = TRACKS.find((t) => t.id === page.track);
  const main = `<h1>${escapeHtml(page.title)}</h1>\n${body}`;
  return shell({
    lang: page.lang,
    title: page.title,
    summary: page.summary,
    rel,
    root: rel || "./",
    nav: navs[page.lang],
    currentUrl: page.url,
    eyebrow: track ? track.label[page.lang] : "",
    main,
    toc: renderToc(headings, ui),
    version,
    switchTo: switchHref(page, pages),
    whatsNew: pages.find((p) => p.lang === page.lang && p.path === "reference/whats-new.html")?.url,
  });
}

export function render404({ navs, version, base = "/" }) {
  const ui = UI.en;
  const main = `<h1>${escapeHtml(ui.notFound)}</h1>
<p class="lede">${escapeHtml(ui.notFoundLede)}</p>
<p>${escapeHtml(ui.notFoundHelp)} <a href="${base}en/index.html">${escapeHtml(ui.overviewLink)}</a>.</p>
<p lang="de">${escapeHtml(UI.de.notFoundLede)} <a href="${base}de/index.html">${escapeHtml(UI.de.overview)}</a>.</p>`;
  return shell({
    lang: "en",
    title: ui.notFound,
    summary: "",
    rel: base,
    root: base,
    nav: navs.en,
    currentUrl: "",
    eyebrow: "404",
    main,
    toc: "",
    version,
    switchTo: "de/index.html",
  });
}

/** The root page: German browsers go to de/, everyone else to en/; without script the links are there. */
export function renderRoot() {
  return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>cat(a)log</title>
<script>var l=(navigator.language||"").toLowerCase().slice(0,2)==="de"?"de":"en";location.replace(l+"/index.html")</script>
<meta http-equiv="refresh" content="1; url=en/index.html">
<link rel="icon" href="assets/icon.png" type="image/png">
</head>
<body>
<p><a href="en/index.html">English</a> · <a href="de/index.html" lang="de">Deutsch</a></p>
</body>
</html>
`;
}

// ---------------------------------------------------------------------------
// Link check

const ATTR_LINK = /\s(?:xlink:)?(?:href|src)\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s>"']+))/g;
const SRCSET = /\ssrcset\s*=\s*(?:"([^"]*)"|'([^']*)')/g;
const CSS_URL = /url\(\s*(?:"([^"]*)"|'([^']*)'|([^)"']*))\s*\)/g;

/** Every link (href, src, srcset candidates, CSS url()) in one output file. */
export function extractLinks(file, content) {
  const links = [];
  if (file.endsWith(".css")) {
    for (const m of content.matchAll(CSS_URL)) links.push((m[1] ?? m[2] ?? m[3]).trim());
    return links;
  }
  if (!file.endsWith(".html")) return links;
  for (const m of content.matchAll(ATTR_LINK)) links.push(m[1] ?? m[2] ?? m[3]);
  for (const m of content.matchAll(SRCSET)) {
    for (const candidate of (m[1] ?? m[2]).split(",")) {
      const url = candidate.trim().split(/\s+/)[0];
      if (url) links.push(url);
    }
  }
  return links;
}

const EXTERNAL = /^(https?:|mailto:|data:|tel:)/i;

/** files: Map<relativePath, content> of every output file. Throws on the first broken link or anchor. */
export function checkLinks(files, { base = "/" } = {}) {
  const ids = new Map();
  for (const [file, html] of files) if (file.endsWith(".html")) ids.set(file, collectIds(html));
  const asIndex = (target) => `${target.replace(/\/$/, "")}/index.html`;
  const exists = (target) => files.has(target) || files.has(asIndex(target));
  for (const [file, content] of files) {
    for (const link of extractLinks(file, content)) {
      if (EXTERNAL.test(link)) continue;
      const hashAt = link.indexOf("#");
      const fragment = hashAt >= 0 ? link.slice(hashAt + 1) : "";
      let target = (hashAt >= 0 ? link.slice(0, hashAt) : link).replace(/\?.*$/, "");
      if (target.startsWith("/")) {
        if (!target.startsWith(base)) {
          throw new Error(`Broken link in ${file}: "${link}" is outside the site base ${base}`);
        }
        target = target.slice(base.length) || "index.html";
      } else if (target) {
        target = path.posix.normalize(path.posix.join(path.posix.dirname(file), target));
        if (target === "." || target === "./") target = "index.html";
      }
      let resolved = target || file;
      if (target) {
        if (!exists(resolved)) {
          throw new Error(`Broken link in ${file}: "${link}" does not resolve to a file in the output`);
        }
        if (!files.has(resolved)) resolved = asIndex(resolved);
      }
      if (fragment && !ids.get(resolved)?.has(fragment)) {
        throw new Error(`Broken link in ${file}: "${link}" points to a missing anchor #${fragment}`);
      }
    }
  }
}

// Authored pages must not use root-relative links: on GitHub Pages the site
// lives under /cat-a-log/, so "/en/x.html" breaks there however it looks locally.
function rejectRootRelativeLinks(page) {
  for (const link of extractLinks(page.url, page.body)) {
    if (link.startsWith("/")) {
      throw new Error(
        `Broken link in ${page.url}: "${link}" is root-relative; the site is served under a ` +
          `path on GitHub Pages, use a relative link`,
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Build

function copyDir(from, to, files) {
  fs.mkdirSync(to, { recursive: true });
  for (const entry of fs.readdirSync(from, { withFileTypes: true })) {
    const src = path.join(from, entry.name);
    const dst = path.join(to, entry.name);
    if (entry.isDirectory()) copyDir(src, dst, files);
    else {
      fs.copyFileSync(src, dst);
      files.push(dst);
    }
  }
}

const isInside = (dir, parent) => {
  const rel = path.relative(parent, dir);
  return rel !== "" && !rel.startsWith("..") && !path.isAbsolute(rel);
};

/** The output folder is wiped; refuse anything that is not clearly a build output. */
function guardOutDir(outDir, srcDir) {
  const tmp = fs.realpathSync(os.tmpdir());
  const out = path.resolve(outDir);
  if (!isInside(out, REPO_ROOT) && !isInside(out, tmp)) {
    throw new Error(`Refusing to wipe ${out}: the output folder must be inside the repository or the temp dir`);
  }
  const src = path.resolve(srcDir);
  if (out === src || isInside(src, out)) {
    throw new Error(`Refusing to wipe ${out}: it contains the source folder ${src}`);
  }
}

/** Every page of the site in nav order and checked: both trees, each page with its sibling. */
export function collectPages({ srcDir = path.join(REPO_ROOT, "site"), generated = [] } = {}) {
  const pages = loadPages(srcDir);
  for (const page of generated) {
    if (pages.some((p) => p.url === page.url)) {
      throw new Error(`${page.url}: an authored page shadows the generated page`);
    }
    pages.push(page);
  }
  sortPages(pages);
  for (const lang of LANGS) {
    if (!pages.some((p) => p.url === `${lang.id}/index.html`)) {
      throw new Error(`${srcDir}: no ${lang.id}/index.html`);
    }
  }
  checkSiblings(pages);
  for (const page of pages) rejectRootRelativeLinks(page);
  return pages;
}

export function buildSite({
  srcDir = path.join(REPO_ROOT, "site"),
  outDir = path.join(REPO_ROOT, "site-dist"),
  version = readVersion(fs.readFileSync(path.join(REPO_ROOT, "pubspec.yaml"), "utf8")),
  base = "/",
  assetsDir = path.join(srcDir, "assets"),
  pages = null,
  generated = [],
} = {}) {
  if (!base.startsWith("/") || !base.endsWith("/")) {
    throw new Error(`--base must start and end with "/": got "${base}"`);
  }
  guardOutDir(outDir, srcDir);
  if (!pages) pages = collectPages({ srcDir, generated });
  const navs = Object.fromEntries(LANGS.map((l) => [l.id, buildNav(pages, l.id)]));
  const ctx = { navs, version, pages, base };

  fs.rmSync(outDir, { recursive: true, force: true });
  fs.mkdirSync(outDir, { recursive: true });

  const files = new Map();
  for (const page of pages) {
    files.set(page.url, renderPage(page, ctx));
    // An alias is the same page at a second address, for links the stores hold.
    if (page.alias) {
      if (page.alias.includes("/") || !page.alias.endsWith(".html")) {
        throw new Error(`${page.url}: alias "${page.alias}" must be a plain root file name`);
      }
      if (files.has(page.alias)) throw new Error(`${page.url}: alias "${page.alias}" is taken`);
      files.set(page.alias, renderPage(page, { ...ctx, url: page.alias }));
    }
  }
  files.set("404.html", render404(ctx));
  files.set("index.html", renderRoot());

  const copied = [];
  if (fs.existsSync(assetsDir)) copyDir(assetsDir, path.join(outDir, "assets"), copied);
  for (const file of copied) {
    const rel = path.relative(outDir, file).split(path.sep).join("/");
    if (!files.has(rel)) files.set(rel, /\.(css|js|html|svg)$/.test(rel) ? fs.readFileSync(file, "utf8") : "");
  }

  checkLinks(files, { base });

  for (const [rel, html] of files) {
    if (!rel.endsWith(".html")) continue;
    const dest = path.join(outDir, rel);
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    fs.writeFileSync(dest, html);
  }
  for (const lang of LANGS) {
    fs.writeFileSync(
      path.join(outDir, lang.id, "search-index.json"),
      JSON.stringify(buildIndex(pages, lang.id), null, 0),
    );
  }
  fs.writeFileSync(path.join(outDir, ".nojekyll"), "");
  return { pages: pages.length, outDir, version };
}

// ---------------------------------------------------------------------------
// Preview server

const MIME = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".svg": "image/svg+xml",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".webp": "image/webp",
  ".ico": "image/x-icon",
  ".txt": "text/plain; charset=utf-8",
};

export function resolveRequest(root, urlPath) {
  let decoded;
  try {
    decoded = decodeURIComponent(urlPath);
  } catch {
    return null;
  }
  let file = path.resolve(root, `.${decoded}`);
  const rel = path.relative(root, file);
  if (rel.startsWith("..") || path.isAbsolute(rel)) return null;
  if (fs.existsSync(file) && fs.statSync(file).isDirectory()) file = path.join(file, "index.html");
  return fs.existsSync(file) ? file : null;
}

export function serve(outDir, port, host = "127.0.0.1") {
  const root = path.resolve(outDir);
  const server = http.createServer((req, res) => {
    const urlPath = new URL(req.url, "http://localhost").pathname;
    let file = resolveRequest(root, urlPath);
    let status = 200;
    if (!file) {
      file = path.join(root, "404.html");
      status = 404;
    }
    res.writeHead(status, { "content-type": MIME[path.extname(file)] || "application/octet-stream" });
    fs.createReadStream(file).pipe(res);
  });
  server.listen(port, host, () => {
    const { port: bound } = server.address();
    console.log(`Serving ${root} at http://${host}:${bound}/ (Ctrl+C to stop)`);
  });
  return server;
}

// ---------------------------------------------------------------------------
// CLI

function parseArgs(argv) {
  const opts = { serve: false, port: 8080 };
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--serve") {
      opts.serve = true;
      if (/^\d+$/.test(argv[i + 1] || "")) opts.port = Number(argv[++i]);
    } else if (arg === "--src") opts.srcDir = path.resolve(argv[++i]);
    else if (arg === "--out") opts.outDir = path.resolve(argv[++i]);
    else if (arg === "--base") opts.base = argv[++i];
    else throw new Error(`Unknown argument: ${arg}`);
  }
  return opts;
}

const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  try {
    const opts = parseArgs(process.argv.slice(2));
    const result = buildSite({ ...opts, generated: generatedPages(opts.srcDir) });
    console.log(`Built ${result.pages} pages (v${result.version}) into ${result.outDir}`);
    if (opts.serve) serve(result.outDir, opts.port);
  } catch (err) {
    console.error(`build-site: ${err.message}`);
    process.exit(1);
  }
}
