import 'package:flutter_test/flutter_test.dart';
import 'package:privatpdf/models/ocr_language.dart';

void main() {
  group('OcrLanguage', () {
    group('enum values', () {
      test('should have german language with correct code and display name', () {
        expect(OcrLanguage.german.code, equals('deu'));
        expect(OcrLanguage.german.displayName, equals('Deutsch (DEU)'));
      });

      test('should have english language with correct code and display name', () {
        expect(OcrLanguage.english.code, equals('eng'));
        expect(OcrLanguage.english.displayName, equals('Englisch (ENG)'));
      });

      test('should have exactly 2 languages', () {
        expect(OcrLanguage.values.length, equals(2));
      });
    });

    group('fromCode', () {
      test('should return german for "deu" code', () {
        final result = OcrLanguage.fromCode('deu');
        expect(result, equals(OcrLanguage.german));
      });

      test('should return english for "eng" code', () {
        final result = OcrLanguage.fromCode('eng');
        expect(result, equals(OcrLanguage.english));
      });

      test('should return null for invalid code', () {
        final result = OcrLanguage.fromCode('invalid');
        expect(result, isNull);
      });

      test('should return null for empty code', () {
        final result = OcrLanguage.fromCode('');
        expect(result, isNull);
      });

      test('should be case-sensitive', () {
        final result = OcrLanguage.fromCode('DEU');
        expect(result, isNull);
      });
    });

    group('isValidCode', () {
      test('should return true for valid german code', () {
        expect(OcrLanguage.isValidCode('deu'), isTrue);
      });

      test('should return true for valid english code', () {
        expect(OcrLanguage.isValidCode('eng'), isTrue);
      });

      test('should return false for invalid code', () {
        expect(OcrLanguage.isValidCode('fra'), isFalse);
      });

      test('should return false for empty code', () {
        expect(OcrLanguage.isValidCode(''), isFalse);
      });

      test('should return false for uppercase code', () {
        expect(OcrLanguage.isValidCode('ENG'), isFalse);
      });
    });

    group('allCodes', () {
      test('should return all language codes', () {
        final codes = OcrLanguage.allCodes;
        expect(codes, hasLength(2));
        expect(codes, contains('deu'));
        expect(codes, contains('eng'));
      });

      test('should return codes in enum order', () {
        final codes = OcrLanguage.allCodes;
        expect(codes[0], equals('deu'));
        expect(codes[1], equals('eng'));
      });
    });

    group('allDisplayNames', () {
      test('should return all display names', () {
        final names = OcrLanguage.allDisplayNames;
        expect(names, hasLength(2));
        expect(names, contains('Deutsch (DEU)'));
        expect(names, contains('Englisch (ENG)'));
      });

      test('should return names in enum order', () {
        final names = OcrLanguage.allDisplayNames;
        expect(names[0], equals('Deutsch (DEU)'));
        expect(names[1], equals('Englisch (ENG)'));
      });
    });

    group('language code mapping', () {
      test('should maintain bidirectional mapping for all languages', () {
        for (final language in OcrLanguage.values) {
          final codeRoundtrip = OcrLanguage.fromCode(language.code);
          expect(codeRoundtrip, equals(language),
              reason: 'Code ${language.code} should map back to ${language.name}');
        }
      });
    });

    group('code uniqueness', () {
      test('should have unique codes for all languages', () {
        final codes = OcrLanguage.values.map((l) => l.code).toList();
        final uniqueCodes = codes.toSet();
        expect(codes.length, equals(uniqueCodes.length),
            reason: 'All language codes must be unique');
      });
    });
  });
}
