import assert from "node:assert/strict";
import { test } from "node:test";

import {
  addisDate,
  computeTrendUpdates,
  countLikes,
  pickNameOfTheDay,
  rankRarity,
} from "./trends";

test("countLikes counts each person once per name", () => {
  const counts = countLikes([
    { uid: "a", name_id: "hiwot" },
    { uid: "a", name_id: "hiwot" }, // favorite + partner like
    { uid: "b", name_id: "hiwot" },
    { uid: "b", name_id: "selam" },
    { uid: "", name_id: "selam" }, // malformed
  ]);
  assert.equal(counts.get("hiwot"), 2);
  assert.equal(counts.get("selam"), 1);
});

test("rankRarity: top 10% popular, bottom 50% rare", () => {
  const rows = Array.from({ length: 20 }, (_, i) => ({
    id: `n${String(i).padStart(2, "0")}`,
    trend: 20 - i,
    popularity: 0,
  }));
  const r = rankRarity(rows);
  const count = (k: string) => [...r.values()].filter((v) => v === k).length;
  assert.equal(count("popular"), 2);
  assert.equal(count("rare"), 10);
  assert.equal(count("unique"), 8);
  assert.equal(r.get("n00"), "popular");
  assert.equal(r.get("n19"), "rare");
});

test("rankRarity breaks trend ties by popularity", () => {
  const r = rankRarity([
    { id: "a", trend: 0, popularity: 10 },
    { id: "b", trend: 0, popularity: 90 },
  ]);
  assert.equal(r.get("b"), "popular");
  assert.equal(r.get("a"), "rare");
});

test("computeTrendUpdates only returns changed names", () => {
  const names = [
    { id: "a", popularity: 90, trend_score: 5, rarity: "popular" },
    { id: "b", popularity: 50, trend_score: 0, rarity: "rare" },
  ];
  assert.deepEqual(computeTrendUpdates(names, new Map([["a", 5]])), []);
  assert.deepEqual(computeTrendUpdates(names, new Map([["b", 9]])), [
    { id: "a", trend_score: 0, rarity: "rare" },
    { id: "b", trend_score: 9, rarity: "popular" },
  ]);
});

test("pickNameOfTheDay is stable per day and matches the app formula", () => {
  const names = ["selam", "abebe", "hiwot"].map((id) => ({ id }));
  const d = new Date(Date.UTC(2026, 10, 25, 6));
  const day = Math.floor(Date.UTC(2026, 10, 25) / 86_400_000);
  const expected = ["abebe", "hiwot", "selam"][(day * 7919) % 3];
  assert.equal(pickNameOfTheDay(names, d)?.id, expected);
  assert.equal(pickNameOfTheDay(names, new Date(Date.UTC(2026, 10, 25, 23)))?.id, expected);
  assert.equal(pickNameOfTheDay([], d), null);
});

test("addisDate uses UTC+3", () => {
  assert.equal(addisDate(new Date(Date.UTC(2026, 10, 24, 21, 30))), "2026-11-25");
  assert.equal(addisDate(new Date(Date.UTC(2026, 10, 24, 20, 59))), "2026-11-24");
});
