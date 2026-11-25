import 'name_normalizer.dart';

/// Kinds of observations, each mapped to a translated tip in the UI.
enum SoundNote {
  /// Total length is very short / very long.
  tooShort,
  tooLong,

  /// One part is much longer than its neighbour (e.g. Li Woldemariam).
  uneven,

  /// Every part has the same syllable count (can sound monotone).
  sameLength,

  /// Given name and father's name start with the same sound.
  sameStartFather,

  /// All three names start with the same sound.
  sameStartAll,

  /// Last sound of one name repeats as the first of the next (Selam Mekonnen).
  runTogether,

  /// Vowel meets vowel between names (Hana Abebe).
  vowelClash,

  /// The given name is the father's name.
  sameAsFather,

  /// Everything sounds good.
  balanced,
}

class SoundCheck {
  const SoundCheck(this.score, this.max, this.notes);

  final int score;
  final int max;
  final List<SoundNote> notes;

  double get ratio => max == 0 ? 1 : score / max;
}

class NameSoundScore {
  const NameSoundScore({
    required this.total,
    required this.syllables,
    required this.balance,
    required this.starts,
    required this.flow,
  });

  /// 0–100.
  final int total;

  /// Syllables per part (given, father, grandfather).
  final List<int> syllables;
  final SoundCheck balance;
  final SoundCheck starts;
  final SoundCheck flow;

  List<SoundNote> get notes {
    final List<SoundNote> all = [
      ...balance.notes,
      ...starts.notes,
      ...flow.notes,
    ];
    return all.isEmpty ? const [SoundNote.balanced] : all;
  }

  static const int balanceMax = 40;
  static const int startsMax = 30;
  static const int flowMax = 30;

  /// Scores a full name. [parts] are Latin spellings (given, father,
  /// grandfather); empty parts are ignored. [knownSyllables] can override the
  /// estimate for a part (e.g. the given name's curated syllable count).
  static NameSoundScore of(
    List<String> parts, {
    Map<int, int> knownSyllables = const {},
  }) {
    final List<String> names = [
      for (final String p in parts)
        if (p.trim().isNotEmpty) p.trim(),
    ];
    final List<int> syl = [
      for (int i = 0; i < names.length; i++)
        knownSyllables[i] ?? estimateSyllables(names[i]),
    ];
    final SoundCheck balance = _balance(syl);
    final SoundCheck starts = _starts(names);
    final SoundCheck flow = _flow(names);
    return NameSoundScore(
      total: (balance.score + starts.score + flow.score).clamp(0, 100),
      syllables: syl,
      balance: balance,
      starts: starts,
      flow: flow,
    );
  }

  /// Vowel groups in the Latin spelling (y counts as a vowel between
  /// consonants or at the end, as in "Hywet" or "Tesfay").
  static int estimateSyllables(String name) {
    final String s = name
        .toLowerCase()
        .replaceAll(RegExp('[^a-z]'), '')
        .replaceAll(RegExp('(?<=[^aeiou])y(?=[^aeiou]|\$)'), 'i');
    final int groups = RegExp('[aeiou]+').allMatches(s).length;
    return groups == 0 ? 1 : groups;
  }

  // ---------------------------------------------------------------------------

  static SoundCheck _balance(List<int> syl) {
    if (syl.isEmpty) return const SoundCheck(balanceMax, balanceMax, []);
    final List<SoundNote> notes = [];
    int score = balanceMax;
    final int total = syl.fold(0, (a, b) => a + b);
    if (syl.length >= 2) {
      if (total < 5) {
        score -= (5 - total) * 6;
        notes.add(SoundNote.tooShort);
      } else if (total > 10) {
        score -= (total - 10) * 5;
        notes.add(SoundNote.tooLong);
      }
      bool uneven = false;
      for (int i = 1; i < syl.length; i++) {
        if ((syl[i] - syl[i - 1]).abs() >= 3) uneven = true;
      }
      if (uneven) {
        score -= 10;
        notes.add(SoundNote.uneven);
      }
      if (syl.length == 3 && syl.toSet().length == 1) {
        score -= 5;
        notes.add(SoundNote.sameLength);
      }
    }
    return SoundCheck(score.clamp(0, balanceMax), balanceMax, notes);
  }

  static SoundCheck _starts(List<String> names) {
    if (names.length < 2) return const SoundCheck(startsMax, startsMax, []);
    final List<String> firsts = [for (final String n in names) _firstSound(n)];
    final List<SoundNote> notes = [];
    int score = startsMax;
    if (names.length == 3 && firsts.toSet().length == 1) {
      score -= 24;
      notes.add(SoundNote.sameStartAll);
    } else if (firsts[0] == firsts[1]) {
      score -= 12;
      notes.add(SoundNote.sameStartFather);
    }
    return SoundCheck(score, startsMax, notes);
  }

  static SoundCheck _flow(List<String> names) {
    if (names.length < 2) return const SoundCheck(flowMax, flowMax, []);
    final List<SoundNote> notes = [];
    int score = flowMax;
    if (NameNormalizer.phoneticKey(names[0]) ==
        NameNormalizer.phoneticKey(names[1])) {
      score -= 20;
      notes.add(SoundNote.sameAsFather);
    }
    for (int i = 0; i + 1 < names.length; i++) {
      // The given → father boundary matters most; father → grandfather is
      // already fixed, so it counts half.
      final int weight = i == 0 ? 2 : 1;
      final String end = _lastSound(names[i]);
      final String start = _firstSound(names[i + 1]);
      if (_isVowel(end) && _isVowel(start)) {
        score -= 4 * weight;
        if (i == 0) notes.add(SoundNote.vowelClash);
      } else if (!_isVowel(end) && end == start) {
        score -= 7 * weight;
        if (i == 0) notes.add(SoundNote.runTogether);
      }
    }
    return SoundCheck(score.clamp(0, flowMax), flowMax, notes);
  }

  static String _firstSound(String name) {
    final String k = NameNormalizer.phoneticKey(name);
    return k.isEmpty ? '' : (_isVowel(k[0]) ? 'V' : k[0]);
  }

  static String _lastSound(String name) {
    final String k = NameNormalizer.phoneticKey(name);
    return k.isEmpty ? '' : (_isVowel(k[k.length - 1]) ? 'V' : k[k.length - 1]);
  }

  static bool _isVowel(String c) => c == 'V' || 'aeo'.contains(c);
}
