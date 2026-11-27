// Refreshes the names bundled in the app from live Firestore, before a
// release, so offline first launch shows the current catalogue.
//
//   cd functions
//   node scripts/export-names.js
//
// Writes:
//  - assets/data/names.json  (version bumped; exact server values incl.
//    rarity, trend_score and updated_at, so the app's first sync downloads
//    only changes made after this export)
//  - data/names.csv          (same rows, so tools/csv_to_json.dart and the
//    "bundle matches CSV" test stay in sync)
//
// Live names only (deleted ones are left out). Uses functions/service-account.json.
"use strict";

const fs = require("node:fs");
const path = require("node:path");
const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");

const ROOT = path.resolve(__dirname, "../..");
const JSON_PATH = path.join(ROOT, "assets/data/names.json");
const CSV_PATH = path.join(ROOT, "data/names.csv");

const JSON_ORDER = [
  "id", "name_latin", "name_geez", "spellings", "gender", "languages", "faiths",
  "meaning_en", "meaning_am", "themes", "pronunciation", "audio_url", "syllables",
  "easy_abroad", "origin_en", "origin_am", "nicknames", "similar", "famous",
  "verified", "popularity", "modern", "rarity", "trend_score", "updated_at",
];
const CSV_ORDER = [
  "id", "name_latin", "name_geez", "spellings", "gender", "languages", "faiths",
  "meaning_en", "meaning_am", "themes", "pronunciation", "audio_url", "syllables",
  "easy_abroad", "origin_en", "origin_am", "nicknames", "similar", "famous",
  "verified", "popularity", "updated_at", "modern", "rarity", "trend_score",
];
const LISTS = new Set(["spellings", "languages", "faiths", "themes", "nicknames", "similar", "famous"]);
const DEFAULTS = {
  pronunciation: null, audio_url: null, syllables: 0, popularity: 0, trend_score: 0,
  rarity: "unique", easy_abroad: false, verified: false, modern: false,
};

initializeApp({
  credential: cert(require(path.resolve(__dirname, "../service-account.json"))),
  projectId: "habesha-baby-names",
});

function csvCell(v) {
  const s = v == null ? "" : Array.isArray(v) ? v.join("|") : String(v);
  return /[",\n\r]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
}

(async () => {
  const docs = (await getFirestore().collection("names").get()).docs
    .filter((d) => d.get("deleted") !== true);

  const names = docs.map((d) => {
    const x = d.data();
    const o = {};
    for (const k of JSON_ORDER) {
      let v = k === "id" ? d.id : x[k];
      if (k === "updated_at") v = v.toDate().toISOString();
      if (v === undefined) v = LISTS.has(k) ? [] : (k in DEFAULTS ? DEFAULTS[k] : "");
      if (k === "pronunciation" && v === "") v = null;
      o[k] = v;
    }
    return o;
  }).sort((a, b) => a.id.localeCompare(b.id));

  const old = JSON.parse(fs.readFileSync(JSON_PATH, "utf8"));
  const out = { version: old.version + 1, count: names.length, names };
  fs.writeFileSync(JSON_PATH, JSON.stringify(out, null, 2) + "\n");
  fs.writeFileSync(
    CSV_PATH,
    CSV_ORDER.join(",") + "\n" + names.map((n) => CSV_ORDER.map((k) => csvCell(n[k])).join(",")).join("\n") + "\n",
  );
  console.log(`names.json v${old.version} → v${out.version}: ${old.count} → ${names.length} names`);
  console.log(`data/names.csv: ${names.length} rows`);
  console.log("Next: flutter test test/tools/name_csv_test.dart, then build the release.");
})().catch((e) => {
  console.error(e.message);
  process.exit(1);
});
