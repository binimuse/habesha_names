import 'gender.dart';
import 'name_filter.dart';
import 'vocabulary.dart';

enum Expecting { boy, girl, unknown }

/// What the parent told us during onboarding.
class UserPrefs {
  const UserPrefs({
    this.expecting = Expecting.unknown,
    this.faiths = const {},
    this.languages = const {},
  });

  final Expecting expecting;
  final Set<String> faiths;
  final Set<String> languages;

  /// Filter for "For you": the expected gender plus unisex names, the chosen
  /// faiths plus faith-neutral names, and the chosen languages.
  NameFilter toFilter() => NameFilter(
    genders: switch (expecting) {
      Expecting.boy => const {Gender.boy, Gender.unisex},
      Expecting.girl => const {Gender.girl, Gender.unisex},
      Expecting.unknown => const {},
    },
    faiths: faiths.isEmpty ? const {} : {...faiths, Vocabulary.neutralFaith},
    languages: languages,
  );
}
