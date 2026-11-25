import '../../core/text/name_normalizer.dart';
import '../models/name_model.dart';

/// In-memory index over all names, rebuilt whenever the data changes.
///
/// The catalogue is small (thousands, not millions), so ranking in memory is
/// fast and lets us apply script-aware normalisation that a DB query can't.
class NameSearchIndex {
  NameSearchIndex(Iterable<NameModel> names)
    : _entries = [for (final NameModel n in names) _Entry(n)];

  final List<_Entry> _entries;

  /// Ranked matches for [query] across Latin spellings, Ge'ez, nicknames and
  /// meanings. Blank queries return an empty list.
  List<NameModel> search(String query) {
    final String raw = NameNormalizer.foldText(query);
    if (raw.isEmpty) return const [];
    final String phonetic = NameNormalizer.phoneticKey(query);
    final String skeleton = NameNormalizer.skeletonFromPhonetic(phonetic);

    final List<(_Entry, int)> hits = [];
    for (final _Entry e in _entries) {
      final int? tier = e.tierFor(raw, phonetic, skeleton);
      if (tier != null) hits.add((e, tier));
    }
    hits.sort((a, b) {
      final int byTier = a.$2.compareTo(b.$2);
      if (byTier != 0) return byTier;
      return compareByPopularity(a.$1.name, b.$1.name);
    });
    return [for (final (_Entry, int) h in hits) h.$1.name];
  }

  /// Most popular first, then alphabetical.
  static int compareByPopularity(NameModel a, NameModel b) {
    final int byPopularity = b.popularity.compareTo(a.popularity);
    if (byPopularity != 0) return byPopularity;
    return a.nameLatin.toLowerCase().compareTo(b.nameLatin.toLowerCase());
  }
}

/// Precomputed keys for one name.
class _Entry {
  _Entry(this.name)
    : rawForms = {
        for (final String f in [...name.latinForms, name.nameGeez])
          if (f.isNotEmpty) NameNormalizer.foldText(f),
      },
      phoneticKeys = _keysOf([...name.latinForms, name.nameGeez]),
      nicknameKeys = _keysOf(name.nicknames),
      meanings = NameNormalizer.foldText(
        '${name.meaningEn} ${name.meaningAm}',
      ) {
    skeletonKeys = {
      for (final String p in phoneticKeys)
        NameNormalizer.skeletonFromPhonetic(p),
    };
  }

  final NameModel name;
  final Set<String> rawForms;
  final Set<String> phoneticKeys;
  late final Set<String> skeletonKeys;
  final Set<String> nicknameKeys;
  final String meanings;

  // Lower tier = better match.
  static const int _exact = 0;
  static const int _phoneticExact = 1;
  static const int _rawPrefix = 2;
  static const int _phoneticPrefix = 3;
  static const int _skeletonExact = 4;
  static const int _skeletonPrefix = 5;
  static const int _nickname = 6;
  static const int _meaning = 7;

  static const int _minSkeletonLength = 2;
  static const int _minMeaningQueryLength = 3;

  int? tierFor(String raw, String phonetic, String skeleton) {
    if (rawForms.contains(raw)) return _exact;
    if (phonetic.isNotEmpty) {
      if (phoneticKeys.contains(phonetic)) return _phoneticExact;
    }
    // Partial Ge'ez words transliterate poorly (the last letter's vowel is
    // unknown), so match the folded script directly while typing.
    if (rawForms.any((f) => f.startsWith(raw))) return _rawPrefix;
    if (phonetic.isNotEmpty) {
      if (phoneticKeys.any((k) => k.startsWith(phonetic))) {
        return _phoneticPrefix;
      }
    }
    if (skeleton.length >= _minSkeletonLength) {
      if (skeletonKeys.contains(skeleton)) return _skeletonExact;
      if (skeletonKeys.any((k) => k.startsWith(skeleton))) {
        return _skeletonPrefix;
      }
    }
    if (phonetic.isNotEmpty &&
        nicknameKeys.any((k) => k.startsWith(phonetic))) {
      return _nickname;
    }
    if (raw.length >= _minMeaningQueryLength && meanings.contains(raw)) {
      return _meaning;
    }
    return null;
  }

  static Set<String> _keysOf(Iterable<String> forms) => {
    for (final String f in forms)
      if (NameNormalizer.phoneticKey(f) case final String k when k.isNotEmpty)
        k,
  };
}
