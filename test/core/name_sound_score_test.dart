import 'package:flutter_test/flutter_test.dart';
import 'package:habesha_names/app/core/text/name_sound_score.dart';

void main() {
  NameSoundScore s(String a, String b, [String c = '']) =>
      NameSoundScore.of([a, b, c]);

  test('syllable estimates', () {
    expect(NameSoundScore.estimateSyllables('Selam'), 2);
    expect(NameSoundScore.estimateSyllables('Tesfaye'), 3);
    expect(NameSoundScore.estimateSyllables('Amanuel'), 3); // ue = one group
    expect(NameSoundScore.estimateSyllables('Hywet'), 2);
    expect(NameSoundScore.estimateSyllables('Brhan'), 1);
  });

  test('a balanced name scores high with no warnings', () {
    final NameSoundScore r = s('Selam', 'Tesfaye', 'Kebede');
    expect(r.total, greaterThanOrEqualTo(85));
    expect(r.notes, [SoundNote.balanced]);
  });

  test('repeated starting sounds are flagged', () {
    expect(
      s('Selam', 'Solomon', 'Kebede').notes,
      contains(SoundNote.sameStartFather),
    );
    final NameSoundScore all = s('Tsion', 'Tsegaye', 'Tsehay');
    expect(all.notes, contains(SoundNote.sameStartAll));
    expect(all.starts.score, lessThan(10));
  });

  test('Sh / Ts digraphs count as one sound', () {
    expect(
      s('Shewit', 'Sisay').notes,
      isNot(contains(SoundNote.sameStartFather)),
    );
  });

  test('flow: run-together consonants and vowel clashes', () {
    expect(s('Selam', 'Mekonnen').notes, contains(SoundNote.runTogether));
    expect(s('Hana', 'Abebe').notes, contains(SoundNote.vowelClash));
    expect(s('Selam', 'Abebe').notes, isNot(contains(SoundNote.vowelClash)));
  });

  test('balance: too short, too long, uneven', () {
    expect(s('Li', 'Bo').notes, contains(SoundNote.tooShort));
    expect(
      s('Woldemariam', 'Gebremedhin', 'Haylemariam').notes,
      contains(SoundNote.tooLong),
    );
    expect(s('Li', 'Woldemariam').notes, contains(SoundNote.uneven));
  });

  test('same as father is penalised', () {
    final NameSoundScore r = s('Dawit', 'Dawit', 'Kebede');
    expect(r.notes, contains(SoundNote.sameAsFather));
    expect(r.total, lessThan(s('Yonas', 'Dawit', 'Kebede').total));
  });

  test('known syllables override the estimate; empty parts ignored', () {
    final NameSoundScore r = NameSoundScore.of(
      ['Amanuel', '', ''],
      knownSyllables: {0: 4},
    );
    expect(r.syllables, [4]);
    expect(r.total, 100);
  });

  test('total is the sum of parts and stays within 0–100', () {
    for (final NameSoundScore r in [
      s('A', 'A', 'A'),
      s('Selam', 'Tesfaye', 'Kebede'),
      s('Woldemariam', 'Woldemariam', 'Woldemariam'),
    ]) {
      expect(r.total, r.balance.score + r.starts.score + r.flow.score);
      expect(r.total, inInclusiveRange(0, 100));
    }
  });
}
