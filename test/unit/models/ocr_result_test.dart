import 'package:flutter_test/flutter_test.dart';
import 'package:privatpdf/models/ocr_language.dart';
import 'package:privatpdf/models/ocr_result.dart';

void main() {
  group('OcrResult', () {
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2026, 1, 13, 10, 30, 0);
    });

    group('constructor', () {
      test('should create result with all fields', () {
        final result = OcrResult(
          textByPage: {1: 'Page 1 text', 2: 'Page 2 text'},
          totalPages: 2,
          confidenceByPage: {1: 0.95, 2: 0.88},
          processingTimeMs: 5000,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        expect(result.textByPage, hasLength(2));
        expect(result.totalPages, equals(2));
        expect(result.confidenceByPage, hasLength(2));
        expect(result.processingTimeMs, equals(5000));
        expect(result.language, equals(OcrLanguage.german));
        expect(result.completedAt, equals(testDate));
      });

      test('should allow empty text map', () {
        final result = OcrResult(
          textByPage: {},
          totalPages: 0,
          confidenceByPage: {},
          processingTimeMs: 0,
          language: OcrLanguage.english,
          completedAt: testDate,
        );

        expect(result.textByPage, isEmpty);
        expect(result.totalPages, equals(0));
      });
    });

    group('empty factory', () {
      test('should create empty result with given language', () {
        final result = OcrResult.empty(OcrLanguage.german);

        expect(result.textByPage, isEmpty);
        expect(result.totalPages, equals(0));
        expect(result.confidenceByPage, isEmpty);
        expect(result.processingTimeMs, equals(0));
        expect(result.language, equals(OcrLanguage.german));
        expect(result.isEmpty, isTrue);
      });

      test('should create empty result with current timestamp', () {
        final before = DateTime.now();
        final result = OcrResult.empty(OcrLanguage.english);
        final after = DateTime.now();

        expect(
          result.completedAt.isAfter(before) || result.completedAt.isAtSameMomentAs(before),
          isTrue,
        );
        expect(
          result.completedAt.isBefore(after) || result.completedAt.isAtSameMomentAs(after),
          isTrue,
        );
      });
    });

    group('fullText', () {
      test('should return empty string for empty result', () {
        final result = OcrResult.empty(OcrLanguage.german);
        expect(result.fullText, isEmpty);
      });

      test('should return single page text without separator', () {
        final result = OcrResult(
          textByPage: {1: 'Single page content'},
          totalPages: 1,
          confidenceByPage: {1: 0.9},
          processingTimeMs: 1000,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        expect(result.fullText, equals('Single page content'));
      });

      test('should concatenate multiple pages with separators', () {
        final result = OcrResult(
          textByPage: {
            1: 'Page 1 text',
            2: 'Page 2 text',
            3: 'Page 3 text',
          },
          totalPages: 3,
          confidenceByPage: {1: 0.9, 2: 0.85, 3: 0.92},
          processingTimeMs: 3000,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        final expected = 'Page 1 text\n\n--- Seite 2 ---\n\nPage 2 text\n\n--- Seite 3 ---\n\nPage 3 text';
        expect(result.fullText, equals(expected));
      });

      test('should sort pages numerically', () {
        final result = OcrResult(
          textByPage: {
            3: 'Page 3',
            1: 'Page 1',
            2: 'Page 2',
          },
          totalPages: 3,
          confidenceByPage: {1: 0.9, 2: 0.9, 3: 0.9},
          processingTimeMs: 3000,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        final fullText = result.fullText;
        expect(fullText.indexOf('Page 1'), lessThan(fullText.indexOf('Page 2')));
        expect(fullText.indexOf('Page 2'), lessThan(fullText.indexOf('Page 3')));
      });
    });

    group('averageConfidence', () {
      test('should return 0.0 for empty result', () {
        final result = OcrResult.empty(OcrLanguage.german);
        expect(result.averageConfidence, equals(0.0));
      });

      test('should calculate average for single page', () {
        final result = OcrResult(
          textByPage: {1: 'Text'},
          totalPages: 1,
          confidenceByPage: {1: 0.85},
          processingTimeMs: 1000,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        expect(result.averageConfidence, equals(0.85));
      });

      test('should calculate average for multiple pages', () {
        final result = OcrResult(
          textByPage: {1: 'Text 1', 2: 'Text 2', 3: 'Text 3'},
          totalPages: 3,
          confidenceByPage: {1: 0.90, 2: 0.80, 3: 0.85},
          processingTimeMs: 3000,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        // (0.90 + 0.80 + 0.85) / 3 = 0.85
        expect(result.averageConfidence, closeTo(0.85, 0.001));
      });

      test('should handle varying confidence values', () {
        final result = OcrResult(
          textByPage: {1: 'Text 1', 2: 'Text 2'},
          totalPages: 2,
          confidenceByPage: {1: 1.0, 2: 0.5},
          processingTimeMs: 2000,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        expect(result.averageConfidence, equals(0.75));
      });
    });

    group('isEmpty and isNotEmpty', () {
      test('isEmpty should return true for empty result', () {
        final result = OcrResult.empty(OcrLanguage.german);
        expect(result.isEmpty, isTrue);
        expect(result.isNotEmpty, isFalse);
      });

      test('isEmpty should return false for result with text', () {
        final result = OcrResult(
          textByPage: {1: 'Text'},
          totalPages: 1,
          confidenceByPage: {1: 0.9},
          processingTimeMs: 1000,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        expect(result.isEmpty, isFalse);
        expect(result.isNotEmpty, isTrue);
      });
    });

    group('getTextForPage', () {
      test('should return text for existing page', () {
        final result = OcrResult(
          textByPage: {1: 'Page 1', 2: 'Page 2'},
          totalPages: 2,
          confidenceByPage: {1: 0.9, 2: 0.85},
          processingTimeMs: 2000,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        expect(result.getTextForPage(1), equals('Page 1'));
        expect(result.getTextForPage(2), equals('Page 2'));
      });

      test('should return null for non-existing page', () {
        final result = OcrResult(
          textByPage: {1: 'Page 1'},
          totalPages: 1,
          confidenceByPage: {1: 0.9},
          processingTimeMs: 1000,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        expect(result.getTextForPage(2), isNull);
        expect(result.getTextForPage(99), isNull);
      });
    });

    group('getConfidenceForPage', () {
      test('should return confidence for existing page', () {
        final result = OcrResult(
          textByPage: {1: 'Page 1', 2: 'Page 2'},
          totalPages: 2,
          confidenceByPage: {1: 0.95, 2: 0.88},
          processingTimeMs: 2000,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        expect(result.getConfidenceForPage(1), equals(0.95));
        expect(result.getConfidenceForPage(2), equals(0.88));
      });

      test('should return null for non-existing page', () {
        final result = OcrResult(
          textByPage: {1: 'Page 1'},
          totalPages: 1,
          confidenceByPage: {1: 0.9},
          processingTimeMs: 1000,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        expect(result.getConfidenceForPage(2), isNull);
      });
    });

    group('processingTimeSeconds', () {
      test('should convert milliseconds to seconds', () {
        final result = OcrResult(
          textByPage: {1: 'Text'},
          totalPages: 1,
          confidenceByPage: {1: 0.9},
          processingTimeMs: 5000,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        expect(result.processingTimeSeconds, equals(5.0));
      });

      test('should handle fractional seconds', () {
        final result = OcrResult(
          textByPage: {1: 'Text'},
          totalPages: 1,
          confidenceByPage: {1: 0.9},
          processingTimeMs: 2500,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        expect(result.processingTimeSeconds, equals(2.5));
      });
    });

    group('formattedProcessingTime', () {
      test('should format time under 60 seconds with decimal', () {
        final result = OcrResult(
          textByPage: {1: 'Text'},
          totalPages: 1,
          confidenceByPage: {1: 0.9},
          processingTimeMs: 2500,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        expect(result.formattedProcessingTime, equals('2.5s'));
      });

      test('should format whole seconds', () {
        final result = OcrResult(
          textByPage: {1: 'Text'},
          totalPages: 1,
          confidenceByPage: {1: 0.9},
          processingTimeMs: 5000,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        expect(result.formattedProcessingTime, equals('5.0s'));
      });

      test('should format time over 60 seconds as minutes and seconds', () {
        final result = OcrResult(
          textByPage: {1: 'Text'},
          totalPages: 1,
          confidenceByPage: {1: 0.9},
          processingTimeMs: 83000, // 83 seconds
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        expect(result.formattedProcessingTime, equals('1m 23s'));
      });

      test('should format exactly 60 seconds', () {
        final result = OcrResult(
          textByPage: {1: 'Text'},
          totalPages: 1,
          confidenceByPage: {1: 0.9},
          processingTimeMs: 60000,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        expect(result.formattedProcessingTime, equals('1m 0s'));
      });

      test('should format large times', () {
        final result = OcrResult(
          textByPage: {1: 'Text'},
          totalPages: 1,
          confidenceByPage: {1: 0.9},
          processingTimeMs: 325000, // 5 minutes 25 seconds
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        expect(result.formattedProcessingTime, equals('5m 25s'));
      });
    });

    group('summary', () {
      test('should generate correct summary string', () {
        final result = OcrResult(
          textByPage: {1: 'Text 1', 2: 'Text 2'},
          totalPages: 2,
          confidenceByPage: {1: 0.90, 2: 0.88},
          processingTimeMs: 3000,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        expect(
          result.summary,
          equals('2 Seiten verarbeitet in 3.0s (∅ 89.0% Genauigkeit)'),
        );
      });

      test('should format confidence with one decimal place', () {
        final result = OcrResult(
          textByPage: {1: 'Text'},
          totalPages: 1,
          confidenceByPage: {1: 0.856},
          processingTimeMs: 1000,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        expect(result.summary, contains('85.6%'));
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final original = OcrResult(
          textByPage: {1: 'Text'},
          totalPages: 1,
          confidenceByPage: {1: 0.9},
          processingTimeMs: 1000,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        final updated = original.copyWith(
          totalPages: 2,
          processingTimeMs: 2000,
        );

        expect(updated.totalPages, equals(2));
        expect(updated.processingTimeMs, equals(2000));
        expect(updated.textByPage, equals(original.textByPage));
        expect(updated.language, equals(original.language));
      });

      test('should preserve original when no fields specified', () {
        final original = OcrResult(
          textByPage: {1: 'Text'},
          totalPages: 1,
          confidenceByPage: {1: 0.9},
          processingTimeMs: 1000,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        final copy = original.copyWith();

        expect(copy.textByPage, equals(original.textByPage));
        expect(copy.totalPages, equals(original.totalPages));
        expect(copy.language, equals(original.language));
      });
    });

    group('JSON serialization', () {
      test('should convert to JSON', () {
        final result = OcrResult(
          textByPage: {1: 'Page 1', 2: 'Page 2'},
          totalPages: 2,
          confidenceByPage: {1: 0.95, 2: 0.88},
          processingTimeMs: 5000,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        final json = result.toJson();

        expect(json['textByPage'], equals({1: 'Page 1', 2: 'Page 2'}));
        expect(json['totalPages'], equals(2));
        expect(json['confidenceByPage'], equals({1: 0.95, 2: 0.88}));
        expect(json['processingTimeMs'], equals(5000));
        expect(json['language'], equals('deu'));
        expect(json['completedAt'], equals(testDate.toIso8601String()));
      });

      test('should create from JSON', () {
        final json = {
          'textByPage': {1: 'Page 1', 2: 'Page 2'},
          'totalPages': 2,
          'confidenceByPage': {1: 0.95, 2: 0.88},
          'processingTimeMs': 5000,
          'language': 'deu',
          'completedAt': testDate.toIso8601String(),
        };

        final result = OcrResult.fromJson(json);

        expect(result.textByPage, equals({1: 'Page 1', 2: 'Page 2'}));
        expect(result.totalPages, equals(2));
        expect(result.confidenceByPage, equals({1: 0.95, 2: 0.88}));
        expect(result.processingTimeMs, equals(5000));
        expect(result.language, equals(OcrLanguage.german));
        expect(result.completedAt, equals(testDate));
      });

      test('should roundtrip through JSON', () {
        final original = OcrResult(
          textByPage: {1: 'Text 1', 2: 'Text 2'},
          totalPages: 2,
          confidenceByPage: {1: 0.9, 2: 0.85},
          processingTimeMs: 3000,
          language: OcrLanguage.english,
          completedAt: testDate,
        );

        final json = original.toJson();
        final restored = OcrResult.fromJson(json);

        expect(restored, equals(original));
      });

      test('should handle empty maps in JSON', () {
        final json = {
          'textByPage': {},
          'totalPages': 0,
          'confidenceByPage': {},
          'processingTimeMs': 0,
          'language': 'eng',
          'completedAt': testDate.toIso8601String(),
        };

        final result = OcrResult.fromJson(json);

        expect(result.textByPage, isEmpty);
        expect(result.confidenceByPage, isEmpty);
        expect(result.totalPages, equals(0));
      });
    });

    group('toString', () {
      test('should generate readable string representation', () {
        final result = OcrResult(
          textByPage: {1: 'Text'},
          totalPages: 1,
          confidenceByPage: {1: 0.856},
          processingTimeMs: 2500,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        final str = result.toString();

        expect(str, contains('totalPages: 1'));
        expect(str, contains('Deutsch (DEU)'));
        expect(str, contains('2.5s'));
        expect(str, contains('85.6%'));
      });
    });

    group('equality', () {
      test('should be equal for identical results', () {
        final result1 = OcrResult(
          textByPage: {1: 'Text'},
          totalPages: 1,
          confidenceByPage: {1: 0.9},
          processingTimeMs: 1000,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        final result2 = OcrResult(
          textByPage: {1: 'Text'},
          totalPages: 1,
          confidenceByPage: {1: 0.9},
          processingTimeMs: 1000,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('should not be equal for different text', () {
        final result1 = OcrResult(
          textByPage: {1: 'Text 1'},
          totalPages: 1,
          confidenceByPage: {1: 0.9},
          processingTimeMs: 1000,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        final result2 = OcrResult(
          textByPage: {1: 'Text 2'},
          totalPages: 1,
          confidenceByPage: {1: 0.9},
          processingTimeMs: 1000,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        expect(result1, isNot(equals(result2)));
      });

      test('should not be equal for different languages', () {
        final result1 = OcrResult(
          textByPage: {1: 'Text'},
          totalPages: 1,
          confidenceByPage: {1: 0.9},
          processingTimeMs: 1000,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        final result2 = OcrResult(
          textByPage: {1: 'Text'},
          totalPages: 1,
          confidenceByPage: {1: 0.9},
          processingTimeMs: 1000,
          language: OcrLanguage.english,
          completedAt: testDate,
        );

        expect(result1, isNot(equals(result2)));
      });

      test('should handle identity', () {
        final result = OcrResult(
          textByPage: {1: 'Text'},
          totalPages: 1,
          confidenceByPage: {1: 0.9},
          processingTimeMs: 1000,
          language: OcrLanguage.german,
          completedAt: testDate,
        );

        expect(result, equals(result));
      });
    });
  });
}
