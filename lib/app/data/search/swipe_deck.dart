import 'dart:math';

import '../models/name_model.dart';

/// Builds the Swipe deck: names not yet seen and not already favorites,
/// shuffled with a fixed [seed] (stable order within a session) while
/// keeping a gentle bias towards popular names.
abstract final class SwipeDeck {
  static List<NameModel> build(
    Iterable<NameModel> candidates, {
    required Set<String> seen,
    required Set<String> exclude,
    required int seed,
  }) {
    final Random random = Random(seed);
    final List<(NameModel, double)> scored = [
      for (final NameModel n in candidates)
        if (!seen.contains(n.id) && !exclude.contains(n.id))
          // Random key in [0, 1) nudged by popularity (0–100) by up to 0.35.
          (n, random.nextDouble() + n.popularity.clamp(0, 100) / 100 * 0.35),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    return [for (final (NameModel n, double _) in scored) n];
  }
}
