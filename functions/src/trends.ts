export type Rarity = "popular" | "unique" | "rare";

export interface NameRow {
  id: string;
  popularity: number;
  trend_score?: number;
  rarity?: string;
}

export interface TrendUpdate {
  id: string;
  trend_score: number;
  rarity: Rarity;
}

/** A like from either users/{uid}/favorites or couples/{code}/likes. */
export interface LikeRef {
  uid: string;
  name_id: string;
}

/**
 * Likes per name, counting each person once per name (a swipe-like creates
 * both a favorite and a partner like, which must not count twice).
 */
export function countLikes(likes: readonly LikeRef[]): Map<string, number> {
  const seen = new Set<string>();
  const counts = new Map<string, number>();
  for (const l of likes) {
    const key = `${l.uid}:${l.name_id}`;
    if (!l.uid || !l.name_id || seen.has(key)) continue;
    seen.add(key);
    counts.set(l.name_id, (counts.get(l.name_id) ?? 0) + 1);
  }
  return counts;
}

/**
 * Same rule as RarityRanker in the app: rank by trend (desc), then
 * popularity (desc), then id. Top 10% popular, bottom 50% rare, rest unique.
 */
export function rankRarity(
  rows: readonly { id: string; trend: number; popularity: number }[],
): Map<string, Rarity> {
  const sorted = [...rows].sort(
    (a, b) =>
      b.trend - a.trend ||
      b.popularity - a.popularity ||
      (a.id < b.id ? -1 : a.id > b.id ? 1 : 0),
  );
  const n = sorted.length;
  const popularCount = Math.ceil(n * 0.1);
  const rareStart = n - Math.floor(n * 0.5);
  const result = new Map<string, Rarity>();
  sorted.forEach((r, i) =>
    result.set(r.id, i < popularCount ? "popular" : i >= rareStart ? "rare" : "unique"),
  );
  return result;
}

/** Only names whose trend_score or rarity actually changed. */
export function computeTrendUpdates(
  names: readonly NameRow[],
  counts: ReadonlyMap<string, number>,
): TrendUpdate[] {
  const rarity = rankRarity(
    names.map((n) => ({ id: n.id, trend: counts.get(n.id) ?? 0, popularity: n.popularity ?? 0 })),
  );
  const updates: TrendUpdate[] = [];
  for (const n of names) {
    const trend = counts.get(n.id) ?? 0;
    const r = rarity.get(n.id)!;
    if ((n.trend_score ?? 0) !== trend || n.rarity !== r) {
      updates.push({ id: n.id, trend_score: trend, rarity: r });
    }
  }
  return updates;
}

/**
 * Same pick as NamesRepository.nameOfTheDay in the app (no filter):
 * names sorted by id, index = dayNumber * 7919 mod count.
 */
export function pickNameOfTheDay<T extends { id: string }>(
  names: readonly T[],
  date: Date,
): T | null {
  if (names.length === 0) return null;
  const sorted = [...names].sort((a, b) => (a.id < b.id ? -1 : a.id > b.id ? 1 : 0));
  const day = Math.floor(
    Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()) / 86_400_000,
  );
  return sorted[(day * 7919) % sorted.length];
}

/** yyyy-mm-dd of [date] in Africa/Addis_Ababa (UTC+3, no DST). */
export function addisDate(date: Date): string {
  const shifted = new Date(date.getTime() + 3 * 3_600_000);
  return shifted.toISOString().slice(0, 10);
}
