import '../models/gender.dart';
import '../models/name_model.dart';
import 'name_search_index.dart';

/// Picks names related to a given one: curated `similar` ids first, then the
/// best-scoring names by shared gender, themes, languages, faiths and sound.
abstract final class SimilarNames {
  static List<NameModel> find(
    NameModel target,
    Iterable<NameModel> all, {
    required NameModel? Function(String id) byId,
    int limit = 10,
  }) {
    final List<NameModel> result = [];
    final Set<String> seen = {target.id};

    for (final String id in target.similar) {
      final NameModel? n = byId(id);
      if (n != null && seen.add(n.id)) result.add(n);
      if (result.length >= limit) return result;
    }

    final List<(NameModel, int)> scored = [
      for (final NameModel n in all)
        if (!seen.contains(n.id) && _genderCompatible(target, n))
          (n, _score(target, n)),
    ]..removeWhere((e) => e.$2 <= 0);

    scored.sort((a, b) {
      final int byScore = b.$2.compareTo(a.$2);
      return byScore != 0
          ? byScore
          : NameSearchIndex.compareByPopularity(a.$1, b.$1);
    });

    for (final (NameModel n, int _) in scored) {
      if (result.length >= limit) break;
      result.add(n);
    }
    return result;
  }

  static bool _genderCompatible(NameModel a, NameModel b) =>
      a.gender == b.gender ||
      a.gender == Gender.unisex ||
      b.gender == Gender.unisex;

  static int _score(NameModel a, NameModel b) {
    // Meaning (themes) dominates; language / faith overlap counts once, so
    // names used in many languages don't outrank names with a shared theme.
    int score = 0;
    score += 4 * _overlap(a.themes, b.themes);
    if (_overlap(a.languages, b.languages) > 0) score += 2;
    if (_overlap(a.faiths, b.faiths) > 0) score += 1;
    if (a.gender == b.gender) score += 1;
    if (a.syllables > 0 && a.syllables == b.syllables) score += 1;
    if (a.nameLatin.isNotEmpty &&
        b.nameLatin.isNotEmpty &&
        a.nameLatin[0].toLowerCase() == b.nameLatin[0].toLowerCase()) {
      score += 1;
    }
    return score;
  }

  static int _overlap(List<String> a, List<String> b) =>
      a.where(b.contains).length;
}
