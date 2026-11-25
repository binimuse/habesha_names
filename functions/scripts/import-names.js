// Uploads assets/data/names.json into the Firestore `names` collection.
//
//   cd functions
//   node scripts/import-names.js --dry-run   # show what would change
//   node scripts/import-names.js             # write
//
// Credentials (Admin SDK, bypasses security rules): a service-account key at
// functions/service-account.json (git-ignored), or GOOGLE_APPLICATION_CREDENTIALS.
//
// Safe to re-run:
//  - unchanged names are skipped;
//  - trend_score / rarity of names already in Firestore are left alone
//    (the updateTrends function owns them);
//  - every written doc gets updated_at = now, so devices that already synced
//    still pick the change up (they sync by updated_at);
//  - names removed from the JSON are NOT deleted (use --prune to mark them
//    deleted: true, which removes them from devices on the next sync).
"use strict";

const fs = require("node:fs");
const path = require("node:path");
const { initializeApp, cert, applicationDefault } = require("firebase-admin/app");
const { getFirestore, Timestamp } = require("firebase-admin/firestore");

const PROJECT_ID = "habesha-baby-names";
const JSON_PATH = path.resolve(__dirname, "../../assets/data/names.json");
const KEY_PATH = path.resolve(__dirname, "../service-account.json");
const SERVER_OWNED = ["trend_score", "rarity"];
const BATCH_LIMIT = 400;

const args = new Set(process.argv.slice(2));
const dryRun = args.has("--dry-run");
const prune = args.has("--prune");

function credential() {
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) return applicationDefault();
  if (fs.existsSync(KEY_PATH)) return cert(require(KEY_PATH));
  console.error(
    "No credentials. Firebase console → Project settings → Service accounts →\n" +
      "Generate new private key, save it as functions/service-account.json.",
  );
  process.exit(1);
}

/** Stable comparison of a name's content, ignoring bookkeeping fields. */
function contentKey(doc) {
  const copy = { ...doc };
  for (const f of ["updated_at", "deleted", ...SERVER_OWNED]) delete copy[f];
  return JSON.stringify(Object.keys(copy).sort().map((k) => [k, copy[k]]));
}

async function main() {
  const { names } = JSON.parse(fs.readFileSync(JSON_PATH, "utf8"));
  if (!Array.isArray(names) || names.length === 0) {
    throw new Error(`No names in ${JSON_PATH}`);
  }
  const ids = new Set();
  for (const n of names) {
    if (typeof n.id !== "string" || !n.id) throw new Error("Name without id");
    if (ids.has(n.id)) throw new Error(`Duplicate id: ${n.id}`);
    ids.add(n.id);
  }

  initializeApp({ credential: credential(), projectId: PROJECT_ID });
  const db = getFirestore();
  const col = db.collection("names");

  const existing = new Map();
  for (const d of (await col.get()).docs) existing.set(d.id, d.data());

  const now = Timestamp.now();
  const writes = []; // [ref, data, label]
  for (const n of names) {
    const old = existing.get(n.id);
    const data = { ...n, deleted: false, updated_at: now };
    if (old) {
      for (const f of SERVER_OWNED) if (f in old) data[f] = old[f];
      if (old.deleted !== true && contentKey(old) === contentKey(n)) continue;
    }
    writes.push([col.doc(n.id), data, old ? "update" : "add"]);
  }
  if (prune) {
    for (const [id, old] of existing) {
      if (!ids.has(id) && old.deleted !== true) {
        writes.push([col.doc(id), { deleted: true, updated_at: now }, "delete"]);
      }
    }
  }

  const count = (l) => writes.filter((w) => w[2] === l).length;
  console.log(
    `${names.length} names in JSON, ${existing.size} in Firestore → ` +
      `${count("add")} new, ${count("update")} changed, ${count("delete")} pruned, ` +
      `${names.length - count("add") - count("update")} unchanged.`,
  );
  for (const [ref, , label] of writes) console.log(`  ${label.padEnd(6)} ${ref.id}`);

  if (dryRun) {
    console.log("Dry run — nothing written.");
    return;
  }
  for (let i = 0; i < writes.length; i += BATCH_LIMIT) {
    const batch = db.batch();
    for (const [ref, data, label] of writes.slice(i, i + BATCH_LIMIT)) {
      if (label === "delete") batch.set(ref, data, { merge: true });
      else batch.set(ref, data);
    }
    await batch.commit();
  }
  console.log(writes.length ? `Wrote ${writes.length} docs.` : "Nothing to write.");
}

main().catch((e) => {
  console.error(e.message ?? e);
  process.exit(1);
});
