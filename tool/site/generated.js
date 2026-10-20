// Pages the build writes from the repository's own files (#168, #169):
// the glossary from CONTEXT.md and site/glossary.de.md, the fields
// catalogue from the starter set in the Dart core with the names the app
// shows, and What's new from the changelogs. Each is a page like an
// authored one, in both languages, and the build fails when the sources
// disagree with each other.
import fs from "node:fs";
import path from "node:path";
import { REPO_ROOT, escapeHtml, slugify } from "./common.js";

/** Markdown inline: `code`, **bold**, _em_ and [text](url). */
export function inline(text) {
  return escapeHtml(text)
    .replace(/`([^`]+)`/g, "<code>$1</code>")
    .replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>")
    .replace(/\[([^\]]+)\]\((https?:[^)]+)\)/g, '<a href="$2">$1</a>')
    .replace(/(^|\s)_([^_]+)_(?=[\s.,;:]|$)/g, "$1<em>$2</em>");
}

// ---------------------------------------------------------------------------
// Glossary

/** The `**Term**:\n description\n _Avoid_: …` entries of a text; `[English]` after a term names its English twin. */
export function parseGlossary(text, file = "glossary") {
  const body = text.includes("## Language") ? text.slice(text.indexOf("## Language")) : text;
  const entries = [];
  for (const block of body.split(/\n\s*\n/)) {
    const lines = block.trim().split("\n");
    const head = /^\*\*([^*]+)\*\*(?:\s*\[([^\]]+)\])?:\s*$/.exec(lines[0] || "");
    if (!head) continue;
    const rest = lines.slice(1);
    const avoid = rest.filter((l) => l.startsWith("_Avoid_:")).map((l) => l.replace("_Avoid_:", "").trim());
    const description = rest.filter((l) => !l.startsWith("_Avoid_:")).join(" ").trim();
    entries.push({ term: head[1].trim(), english: (head[2] || head[1]).trim(), description, avoid: avoid[0] || "" });
  }
  if (!entries.length) throw new Error(`${file}: no glossary entries found`);
  return entries;
}

const GLOSSARY_TEXT = {
  en: {
    title: "Glossary",
    summary: "Every word cat(a)log uses, in one or two sentences: what it means, and the words it avoids.",
    lede: "Every term in one or two sentences, in the order the model lists them. The pages link here on the first use of a term.",
    avoid: "Not called",
  },
  de: {
    title: "Glossar",
    summary: "Jedes Wort, das cat(a)log benutzt, in ein oder zwei Sätzen: was es bedeutet, und die Wörter, die es meidet.",
    lede: "Jeder Begriff in ein oder zwei Sätzen, in der Reihenfolge des Modells. Die Seiten verlinken hierher, wo ein Begriff zum ersten Mal vorkommt.",
    avoid: "Heißt nicht",
  },
};

export function glossaryPages(repoRoot = REPO_ROOT, srcDir = path.join(REPO_ROOT, "site")) {
  const en = parseGlossary(fs.readFileSync(path.join(repoRoot, "CONTEXT.md"), "utf8"), "CONTEXT.md");
  const deFile = path.join(srcDir, "glossary.de.md");
  const de = parseGlossary(fs.readFileSync(deFile, "utf8"), "site/glossary.de.md");
  const deByEnglish = new Map(de.map((e) => [e.english, e]));
  for (const entry of en) {
    if (!deByEnglish.has(entry.term)) {
      throw new Error(`site/glossary.de.md: no German entry for "${entry.term}" (write **Deutsch** [${entry.term}]:)`);
    }
  }
  const render = (lang, entries) => {
    const t = GLOSSARY_TEXT[lang];
    const items = entries
      .map(
        (e) =>
          `<dt id="${slugify(e.english)}">${escapeHtml(e.term)}</dt>\n<dd>${inline(e.description)}` +
          (e.avoid ? ` <span class="avoid">${escapeHtml(t.avoid)}: ${escapeHtml(e.avoid)}.</span>` : "") +
          `</dd>`,
      )
      .join("\n");
    return `<p class="lede">${escapeHtml(t.lede)}</p>\n<dl class="glossary">\n${items}\n</dl>`;
  };
  // The German list in the English order, so the two pages read alike.
  const deOrdered = en.map((e) => deByEnglish.get(e.term));
  return [
    { lang: "en", path: "reference/glossary.html", url: "en/reference/glossary.html", track: "reference", order: 1, title: GLOSSARY_TEXT.en.title, summary: GLOSSARY_TEXT.en.summary, alias: "", body: render("en", en) },
    { lang: "de", path: "reference/glossary.html", url: "de/reference/glossary.html", track: "reference", order: 1, title: GLOSSARY_TEXT.de.title, summary: GLOSSARY_TEXT.de.summary, alias: "", body: render("de", deOrdered) },
  ];
}

// ---------------------------------------------------------------------------
// Fields catalogue

const TYPE_TEXT = {
  en: {
    text: "Text, as many lines as you write.",
    yesNo: "Yes or no.",
    date: "A date, which may be only a month or a year.",
    number: "A number.",
    choice: "One of several options; your own word is allowed.",
    location: "A place: coordinates picked on the map or found by address, shown as a pin.",
    cat: "A reference to another cat of the catalog.",
    id: "An identifier typed or scanned, shown on the card as plain text, a QR or a barcode; it can point at a registry.",
    unitValue: "A measurement kept in the base unit and shown in yours.",
    tags: "Chips you tick: size, colours, pattern, fur, tail, ears, marks.",
  },
  de: {
    text: "Text, so viele Zeilen, wie du schreibst.",
    yesNo: "Ja oder Nein.",
    date: "Ein Datum, das auch nur ein Monat oder ein Jahr sein darf.",
    number: "Eine Zahl.",
    choice: "Eine von mehreren Optionen; ein eigenes Wort ist erlaubt.",
    location: "Ein Ort: Koordinaten, auf der Karte gewählt oder über die Adresse gefunden, als Pin gezeigt.",
    cat: "Ein Verweis auf eine andere Katze des Katalogs.",
    id: "Eine Kennung, getippt oder gescannt, auf der Karte als Text, QR-Code oder Strichcode; sie kann auf ein Register zeigen.",
    unitValue: "Ein Messwert, in der Basiseinheit gespeichert und in deiner gezeigt.",
    tags: "Chips, die du anhakst: Größe, Farben, Muster, Fell, Schwanz, Ohren, Zeichnungen.",
  },
};
const SCOPE_TEXT = {
  en: { cat: "Cats", clowder: "Clowders", both: "Cats and clowders" },
  de: { cat: "Katzen", clowder: "Kolonien", both: "Katzen und Kolonien" },
};
const FIELDS_TEXT = {
  en: {
    title: "Fields catalogue",
    summary: "Every starter field cat(a)log comes with: its name, what it holds, whom it belongs to, and what each field type can hold.",
    lede: "The fields every new catalog starts with. Your own are added on any page; see Fields and values in the Phone track.",
    columns: ["Field", "On", "Holds"],
    types: "The types",
    dimension: "Dimension: weight, in grams, shown in kilograms or pounds.",
  },
  de: {
    title: "Felderverzeichnis",
    summary: "Jedes Starterfeld, mit dem cat(a)log kommt: sein Name, was es hält, wem es gehört, und was jeder Feldtyp halten kann.",
    lede: "Die Felder, mit denen jeder neue Katalog beginnt. Eigene legst du auf jeder Seite an; siehe Felder und Werte beim Telefon.",
    columns: ["Feld", "An", "Hält"],
    types: "Die Typen",
    dimension: "Dimension: Gewicht, in Gramm, gezeigt in Kilogramm oder Pfund.",
  },
};
const TYPE_NAMES = {
  en: { text: "text", yesNo: "yes/no", date: "date", number: "number", choice: "choice", location: "location", cat: "cat", id: "ID", unitValue: "measurement", tags: "tags" },
  de: { text: "Text", yesNo: "Ja/Nein", date: "Datum", number: "Zahl", choice: "Auswahl", location: "Ort", cat: "Katze", id: "ID", unitValue: "Messwert", tags: "Schlagwörter" },
};

/** The starter fields of the Dart core: slug, English name, type and scope. */
export function parseStarters(dart) {
  const re = /\(slug:\s*'([^']+)',\s*name:\s*'([^']+)',\s*type:\s*FieldType\.(\w+),\s*scope:\s*FieldScope\.(\w+)/g;
  const out = [];
  let m;
  while ((m = re.exec(dart)) !== null) out.push({ slug: m[1], name: m[2], type: m[3], scope: m[4] });
  if (!out.length) throw new Error("fields.dart: no starter fields found");
  return out;
}

const STARTER_KEYS = { chipid: "starterChipId", responsible: "starterResponsible", position: "starterPosition" };
function starterKey(slug) {
  return STARTER_KEYS[slug] || `starter${slug[0].toUpperCase()}${slug.slice(1)}`;
}

export function fieldsPages(repoRoot = REPO_ROOT) {
  const starters = parseStarters(
    fs.readFileSync(path.join(repoRoot, "packages/catalog_core/lib/src/fields.dart"), "utf8"),
  );
  const arb = (lang) => JSON.parse(fs.readFileSync(path.join(repoRoot, `lib/l10n/app_${lang}.arb`), "utf8"));
  const names = { en: arb("en"), de: arb("de") };
  for (const f of starters) {
    const key = starterKey(f.slug);
    if (!names.en[key]) throw new Error(`app_en.arb: no "${key}" for the starter field "${f.slug}"`);
    if (!names.de[key]) throw new Error(`app_de.arb: no "${key}" for the starter field "${f.slug}"`);
    if (!TYPE_TEXT.en[f.type]) throw new Error(`fields.dart: unknown field type "${f.type}" on "${f.slug}"`);
  }
  const render = (lang) => {
    const t = FIELDS_TEXT[lang];
    const rows = starters
      .map((f) => {
        const held = f.type === "unitValue" ? `${TYPE_NAMES[lang][f.type]}; ${t.dimension}` : TYPE_NAMES[lang][f.type];
        return `<tr><td>${escapeHtml(names[lang][starterKey(f.slug)])}</td><td>${SCOPE_TEXT[lang][f.scope]}</td><td>${escapeHtml(held)}</td></tr>`;
      })
      .join("\n");
    const types = Object.keys(TYPE_TEXT.en)
      .map((ty) => `<dt>${escapeHtml(TYPE_NAMES[lang][ty])}</dt><dd>${escapeHtml(TYPE_TEXT[lang][ty])}</dd>`)
      .join("\n");
    return (
      `<p class="lede">${escapeHtml(t.lede)}</p>\n<table>\n<thead><tr>${t.columns.map((c) => `<th>${c}</th>`).join("")}</tr></thead>\n<tbody>\n${rows}\n</tbody>\n</table>\n` +
      `<h2>${escapeHtml(t.types)}</h2>\n<dl class="glossary">\n${types}\n</dl>`
    );
  };
  return ["en", "de"].map((lang) => ({
    lang,
    path: "reference/fields.html",
    url: `${lang}/reference/fields.html`,
    track: "reference",
    order: 6,
    title: FIELDS_TEXT[lang].title,
    summary: FIELDS_TEXT[lang].summary,
    alias: "",
    body: render(lang),
  }));
}

// ---------------------------------------------------------------------------
// What's new

const CATEGORY = {
  en: { Added: "Added", Changed: "Changed", Deprecated: "Deprecated", Removed: "Removed", Fixed: "Fixed", Security: "Security" },
  de: { Added: "Neu", Changed: "Geändert", Deprecated: "Veraltet", Removed: "Entfernt", Fixed: "Behoben", Security: "Sicherheit" },
};
const NEWS_TEXT = {
  en: { title: "What's new", summary: "Every release of cat(a)log, newest first, with what changed for a keeper.", lede: "Every release, newest first: what a keeper sees, in the words of the changelog.", unreleased: "In the works", english: "This release's notes exist in English only." },
  de: { title: "Was ist neu", summary: "Jede Version von cat(a)log, neueste zuerst, mit dem, was sich für einen Betreuer geändert hat.", lede: "Jede Version, neueste zuerst: was ein Betreuer sieht, in den Worten des Änderungsprotokolls.", unreleased: "In Arbeit", english: "Die Notizen dieser Version gibt es nur auf Englisch." },
};

/** The `## [version] - date` sections of a changelog, each with its categories and bullet lines. */
export function parseChangelog(text, file = "changelog") {
  const sections = [];
  let current = null;
  let category = null;
  for (const line of text.split("\n")) {
    const head = /^## \[([^\]]+)\](?:\s*-\s*(\S+))?/.exec(line);
    if (head) {
      current = { version: head[1], date: head[2] || "", categories: [] };
      sections.push(current);
      category = null;
      continue;
    }
    if (!current) continue;
    const cat = /^### (\w+)/.exec(line);
    if (cat) {
      category = { name: cat[1], items: [] };
      current.categories.push(category);
      continue;
    }
    if (line.startsWith("- ") && category) category.items.push(line.slice(2).trim());
    else if (line.startsWith("  ") && category && category.items.length) category.items[category.items.length - 1] += " " + line.trim();
  }
  if (!sections.length) throw new Error(`${file}: no version sections found`);
  return sections;
}

/** The English changelog pair at the root; the German one, every section in one file, beside the site's sources. */
const CHANGELOGS = {
  en: ["CHANGELOG.md", "OLDER_CHANGES.md"],
  de: ["site/changelog.de.md"],
};

function readChangelog(repoRoot, lang) {
  const sections = [];
  for (const file of CHANGELOGS[lang]) {
    const full = path.join(repoRoot, file);
    if (fs.existsSync(full)) sections.push(...parseChangelog(fs.readFileSync(full, "utf8"), file));
  }
  return sections;
}

const GERMAN_FROM = "2.0.0";
function atLeast(version, floor) {
  const a = version.split(".").map(Number);
  const b = floor.split(".").map(Number);
  for (let i = 0; i < 3; i++) if ((a[i] || 0) !== (b[i] || 0)) return (a[i] || 0) > (b[i] || 0);
  return true;
}

export function whatsNewPages(repoRoot = REPO_ROOT) {
  const en = readChangelog(repoRoot, "en");
  const de = readChangelog(repoRoot, "de");
  const deByVersion = new Map(de.map((s) => [s.version, s]));
  const enByVersion = new Map(en.map((s) => [s.version, s]));
  for (const s of en) {
    if (atLeast(s.version, GERMAN_FROM) && !deByVersion.has(s.version)) {
      throw new Error(`site/changelog.de.md: no German section for [${s.version}]`);
    }
    const twin = deByVersion.get(s.version);
    if (twin && twin.date !== s.date) {
      throw new Error(`[${s.version}]: the German section is dated "${twin.date}", the English "${s.date}"`);
    }
  }
  for (const s of de) {
    if (!enByVersion.has(s.version)) throw new Error(`German changelog: [${s.version}] has no English section`);
  }
  const render = (lang) => {
    const t = NEWS_TEXT[lang];
    const parts = en.map((section) => {
      const source = lang === "de" && deByVersion.has(section.version) ? deByVersion.get(section.version) : section;
      const foreign = lang === "de" && source === section;
      const empty = !source.categories.some((c) => c.items.length);
      const heading = `${section.version}${section.date ? ` <small>${escapeHtml(section.date)}</small>` : ` <small>${escapeHtml(t.unreleased)}</small>`}`;
      const cats = source.categories
        .filter((c) => c.items.length)
        .map((c) => `<h3>${escapeHtml(CATEGORY[lang][c.name] || c.name)}</h3>\n<ul>\n${c.items.map((i) => `<li>${inline(i)}</li>`).join("\n")}\n</ul>`)
        .join("\n");
      return `<h2 id="v${section.version.replace(/\./g, "-")}">${heading}</h2>\n${foreign ? `<p class="platform">${escapeHtml(t.english)}</p>\n` : ""}${empty ? "" : cats}`;
    });
    return `<p class="lede">${escapeHtml(t.lede)}</p>\n${parts.join("\n")}`;
  };
  return ["en", "de"].map((lang) => ({
    lang,
    path: "reference/whats-new.html",
    url: `${lang}/reference/whats-new.html`,
    track: "reference",
    order: 2,
    title: NEWS_TEXT[lang].title,
    summary: NEWS_TEXT[lang].summary,
    alias: "",
    body: render(lang),
  }));
}

export function generatedPages(srcDir = path.join(REPO_ROOT, "site"), repoRoot = REPO_ROOT) {
  return [...glossaryPages(repoRoot, srcDir), ...fieldsPages(repoRoot), ...whatsNewPages(repoRoot)];
}
