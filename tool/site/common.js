// What the build and the generated pages share: the repository root and
// the text helpers.
import path from "node:path";
import { fileURLToPath } from "node:url";
import { escapeHtml } from "./html.js";

export const REPO_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");

// ---------------------------------------------------------------------------
// Small helpers

export { escapeHtml };


const NAMED_ENTITIES = {
  lt: "<",
  gt: ">",
  quot: '"',
  apos: "'",
  nbsp: " ",
  mdash: "—",
  ndash: "–",
  hellip: "…",
  rarr: "→",
  larr: "←",
  copy: "©",
  times: "×",
  middot: "·",
  laquo: "«",
  raquo: "»",
};

/** Decodes numeric and the named entities the pages use; `&amp;` last so `&amp;lt;` stays `&lt;`. */
export function decodeEntities(text) {
  return text
    .replace(/&#x([0-9a-f]+);/gi, (_, hex) => String.fromCodePoint(parseInt(hex, 16)))
    .replace(/&#(\d+);/g, (_, dec) => String.fromCodePoint(Number(dec)))
    .replace(/&([a-z]+);/gi, (whole, name) =>
      name === "amp" ? whole : (NAMED_ENTITIES[name] ?? whole),
    )
    .replace(/&amp;/g, "&");
}

const INLINE_TAG = /^<\/?(a|code|em|strong|kbd|span|b|i|abbr|sup|sub|mark|small|var)\b[^>]*>$/i;

/** Text of an HTML fragment: inline tags vanish, block tags become a space, entities are decoded. */
export function stripTags(html) {
  const text = html.replace(/<[^>]*>/g, (tag) => (INLINE_TAG.test(tag) ? "" : " "));
  return decodeEntities(text).replace(/\s+/g, " ").trim();
}

export function slugify(text) {
  const slug = stripTags(text)
    .toLowerCase()
    .replace(/ä/g, "ae")
    .replace(/ö/g, "oe")
    .replace(/ü/g, "ue")
    .replace(/ß/g, "ss")
    .replace(/[^a-z0-9\s-]/g, "")
    .trim()
    .replace(/[\s-]+/g, "-");
  return slug || "section";
}

/** The app's version from pubspec.yaml: `version: X.Y.Z+B` gives X.Y.Z. */
export function readVersion(pubspec) {
  const match = /^version:\s*(\d+\.\d+\.\d+)(?:\+\d+)?\s*$/m.exec(pubspec);
  if (!match) throw new Error("pubspec.yaml: no version found");
  return match[1];
}

