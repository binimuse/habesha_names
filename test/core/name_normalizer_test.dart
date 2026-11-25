import 'package:flutter_test/flutter_test.dart';
import 'package:habesha_names/app/core/text/geez.dart';
import 'package:habesha_names/app/core/text/name_normalizer.dart';

void main() {
  String p(String s) => NameNormalizer.phoneticKey(s);
  String k(String s) => NameNormalizer.skeletonKey(s);

  group('phoneticKey folds Latin spelling variants', () {
    for (final List<String> variants in [
      ['Hiwot', 'Heywet', 'Hiywet', 'hiwet', 'HIWOT'],
      ['Haile', 'Hayle', 'Hailé'],
      ['Tsehay', 'Tzehay', 'Tsehai'],
      ['Wondimu', 'Wendimu', 'Wendemu'],
      ['Hana', 'Hanna'],
      ['Kidist', 'Qidist', 'Kedist'],
      ['Nuria', 'Nuriya'],
      ['Mekdes', 'Meqdes'],
    ]) {
      test(variants.join(' = '), () {
        final String expected = p(variants.first);
        for (final String v in variants) {
          expect(p(v), expected, reason: v);
        }
      });
    }

    test('different names stay different', () {
      expect(p('Hiwot'), isNot(p('Hayat')));
      expect(p('Dawit'), isNot(p('Daniel')));
    });
  });

  group('Ge\'ez normalisation', () {
    test('vowel orders and homophones fold: ሕይወት = ህይወት = ሂወት = Hiwot', () {
      expect(p('ሕይወት'), p('Hiwot'));
      expect(p('ህይወት'), p('Hiwot'));
      expect(p('ሂወት'), p('Hiwot'));
    });

    test('ፀሐይ = ጸሀይ = Tsehay', () {
      expect(p('ፀሐይ'), p('Tsehay'));
      expect(p('ጸሀይ'), p('Tsehay'));
    });

    test('ኃይሌ = Haile, ሰናይት = Senait, ኑሪያ = Nuria', () {
      expect(p('ኃይሌ'), p('Haile'));
      expect(p('ሰናይት'), p('Senait'));
      expect(p('ኑሪያ'), p('Nuria'));
    });

    test('skeleton bridges epenthetic vowels and ä spellings', () {
      expect(k('ብርሃን'), k('Birhan'));
      expect(k('ተስፋዬ'), k('Tesfaye'));
      expect(k('ጥሩነሽ'), k('Tirunesh'));
      expect(k('አሕመድ'), k('Ahmed'));
      expect(k('Selam'), k('Salam'));
      expect(k('ሰላም'), k('Selam'));
    });

    test('foldText merges homophone rows but keeps vowel order', () {
      expect(NameNormalizer.foldText('ሐና'), NameNormalizer.foldText('ሀና'));
      expect(NameNormalizer.foldText('ሠላም'), 'ሰላም');
      expect(NameNormalizer.foldText('ሑ'), 'ሁ');
    });

    test('baseOf maps any order to the first order (for the ሀ–ፐ index)', () {
      expect(String.fromCharCode(Geez.baseOf('ሕ'.runes.first)), 'ሐ');
      expect(String.fromCharCode(Geez.baseOf('ቡ'.runes.first)), 'በ');
    });
  });

  test('empty and symbol-only input give empty keys', () {
    expect(p(''), '');
    expect(p(' - '), '');
    expect(k('።'), '');
  });
}
