import 'package:flutter_test/flutter_test.dart';
import 'package:habesha_names/app/core/text/latin_to_geez.dart';

void main() {
  group('LatinToGeez', () {
    // Common given and father's names; the expected value is the usual
    // spelling where the Latin is unambiguous enough to get it right.
    const Map<String, String> cases = {
      'Abebe': 'አበበ',
      'Selam': 'ሰላም',
      'Kebede': 'ከበደ',
      'Tadesse': 'ታደሰ',
      'Girma': 'ግርማ',
      'Gebre': 'ገብረ',
      'Mulugeta': 'ሙሉገታ',
      'Getachew': 'ገታቸው',
      'Tesfaye': 'ተስፋዬ',
      'Amanuel': 'አማኑኤል',
      'Senait': 'ሰናይት',
      'Dawit': 'ዳዊት',
      'Kidist': 'ክድስት', // k/q are indistinguishable (ቅድስት)
      'Birhan': 'ብርሃን',
      'Wondimu': 'ወንድሙ',
      'Eden': 'ኤደን',
      'Hanna': 'ሃና',
      'Desta': 'ደስታ',
      'Alemu': 'አለሙ',
      'Yonas': 'ዮናስ',
    };

    cases.forEach((latin, geez) {
      test('$latin → $geez', () => expect(LatinToGeez.convert(latin), geez));
    });

    test('multi-word and Ge\'ez input pass through', () {
      expect(
        LatinToGeez.convert('Wolde Mariam'),
        'ወልደ ማሪአም', // approximate (ማርያም),
      );
      expect(LatinToGeez.convert('ከበደ'), 'ከበደ');
      expect(LatinToGeez.convert('  '), '');
    });
  });

  group('GeezToLatin', () {
    test('readable, capitalised Latin', () {
      expect(GeezToLatin.convert('ከበደ'), 'Kebede');
      expect(GeezToLatin.convert('ሸዋ'), startsWith('Sh'));
      expect(GeezToLatin.convert('ገታቸው'), 'Getachew');
    });
  });
}
