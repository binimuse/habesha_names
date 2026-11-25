/// How common a name is, recomputed daily by the `updateTrends` function:
/// top 10% → popular, bottom 50% → rare, the rest → unique.
enum Rarity {
  popular,
  unique,
  rare;

  static Rarity? tryParse(String? raw) {
    for (final Rarity r in values) {
      if (r.name == raw?.trim().toLowerCase()) return r;
    }
    return null;
  }
}

/// Same ranking rule as `functions/src/trends.ts` (keep them in sync).
abstract final class RarityRanker {
  static const double popularShare = 0.10;
  static const double rareShare = 0.50;

  /// Ranks ids by [trend] (desc), ties broken by [popularity] (desc), then id.
  static Map<String, Rarity> rank(
    Iterable<String> ids, {
    required int Function(String id) trend,
    required int Function(String id) popularity,
  }) {
    final List<String> sorted = [...ids]
      ..sort((a, b) {
        final int t = trend(b).compareTo(trend(a));
        if (t != 0) return t;
        final int p = popularity(b).compareTo(popularity(a));
        return p != 0 ? p : a.compareTo(b);
      });
    final int n = sorted.length;
    final int popularCount = (n * popularShare).ceil();
    final int rareStart = n - (n * rareShare).floor();
    return {
      for (int i = 0; i < n; i++)
        sorted[i]: i < popularCount
            ? Rarity.popular
            : i >= rareStart
            ? Rarity.rare
            : Rarity.unique,
    };
  }
}
