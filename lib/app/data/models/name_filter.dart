import '../../core/text/geez.dart';
import 'gender.dart';
import 'name_model.dart';
import 'rarity.dart';

/// Criteria for narrowing the name list. Empty / null fields don't filter.
///
/// * [genders], [languages], [faiths], [themes]: the name must match **any**
///   of the selected values (e.g. genders {boy, unisex}).
/// * [minSyllables] / [maxSyllables]: inclusive range.
/// * [firstLetter]: a Latin letter (`A`) or a Ge'ez base letter (`ሀ`); for
///   Ge'ez any vowel order matches (`ሀ` matches ሁ, ሂ, ሃ…).
/// * [easyAbroad]: when true, only names easy to say abroad.
class NameFilter {
  const NameFilter({
    this.genders = const {},
    this.languages = const {},
    this.faiths = const {},
    this.themes = const {},
    this.minSyllables,
    this.maxSyllables,
    this.firstLetter,
    this.easyAbroad,
    this.modern,
    this.rarities = const {},
  });

  static const NameFilter none = NameFilter();

  final Set<Gender> genders;
  final Set<String> languages;
  final Set<String> faiths;
  final Set<String> themes;
  final int? minSyllables;
  final int? maxSyllables;
  final String? firstLetter;
  final bool? easyAbroad;

  /// When true, only modern names.
  final bool? modern;

  /// Any of these rarities (empty = all).
  final Set<Rarity> rarities;

  bool get isEmpty =>
      genders.isEmpty &&
      languages.isEmpty &&
      faiths.isEmpty &&
      themes.isEmpty &&
      minSyllables == null &&
      maxSyllables == null &&
      (firstLetter == null || firstLetter!.isEmpty) &&
      easyAbroad != true &&
      modern != true &&
      rarities.isEmpty;

  /// Number of active criteria (for a "Filters (3)" badge).
  int get activeCount => [
    genders.isNotEmpty,
    languages.isNotEmpty,
    faiths.isNotEmpty,
    themes.isNotEmpty,
    minSyllables != null || maxSyllables != null,
    firstLetter != null && firstLetter!.isNotEmpty,
    easyAbroad == true,
    modern == true,
    rarities.isNotEmpty,
  ].where((active) => active).length;

  bool matches(NameModel name) {
    if (genders.isNotEmpty && !genders.contains(name.gender)) return false;
    if (!_anyOf(languages, name.languages)) return false;
    if (!_anyOf(faiths, name.faiths)) return false;
    if (!_anyOf(themes, name.themes)) return false;
    if (minSyllables != null && name.syllables < minSyllables!) return false;
    if (maxSyllables != null && name.syllables > maxSyllables!) return false;
    if (easyAbroad == true && !name.easyAbroad) return false;
    if (modern == true && !name.modern) return false;
    if (rarities.isNotEmpty && !rarities.contains(name.rarity)) return false;
    if (!_matchesFirstLetter(name)) return false;
    return true;
  }

  List<NameModel> apply(Iterable<NameModel> names) => [
    for (final NameModel n in names)
      if (matches(n)) n,
  ];

  NameFilter copyWith({
    Set<Gender>? genders,
    Set<String>? languages,
    Set<String>? faiths,
    Set<String>? themes,
    int? Function()? minSyllables,
    int? Function()? maxSyllables,
    String? Function()? firstLetter,
    bool? Function()? easyAbroad,
    bool? Function()? modern,
    Set<Rarity>? rarities,
  }) {
    return NameFilter(
      genders: genders ?? this.genders,
      languages: languages ?? this.languages,
      faiths: faiths ?? this.faiths,
      themes: themes ?? this.themes,
      minSyllables: minSyllables != null ? minSyllables() : this.minSyllables,
      maxSyllables: maxSyllables != null ? maxSyllables() : this.maxSyllables,
      firstLetter: firstLetter != null ? firstLetter() : this.firstLetter,
      easyAbroad: easyAbroad != null ? easyAbroad() : this.easyAbroad,
      modern: modern != null ? modern() : this.modern,
      rarities: rarities ?? this.rarities,
    );
  }

  static bool _anyOf(Set<String> wanted, List<String> values) {
    if (wanted.isEmpty) return true;
    for (final String v in values) {
      if (wanted.contains(v) || wanted.contains(v.toLowerCase())) return true;
    }
    return false;
  }

  bool _matchesFirstLetter(NameModel name) {
    final String? letter = firstLetter?.trim();
    if (letter == null || letter.isEmpty) return true;
    final int wanted = letter.runes.first;
    if (Geez.isSyllable(wanted)) {
      if (name.nameGeez.isEmpty) return false;
      return Geez.baseOf(name.nameGeez.runes.first) == Geez.baseOf(wanted);
    }
    return name.nameLatin.toUpperCase().startsWith(letter.toUpperCase());
  }
}
