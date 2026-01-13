import 'package:flutter_test/flutter_test.dart';
import 'package:privatpdf/models/compression_quality.dart';

/// CompressionQuality enum tests
void main() {
  group('CompressionQuality enum values', () {
    test('has all three quality levels', () {
      expect(CompressionQuality.values.length, 3);
      expect(CompressionQuality.values, contains(CompressionQuality.low));
      expect(CompressionQuality.values, contains(CompressionQuality.medium));
      expect(CompressionQuality.values, contains(CompressionQuality.high));
    });
  });

  group('CompressionQuality.qualityPercentage', () {
    test('low quality returns 0.5 (50%)', () {
      expect(CompressionQuality.low.qualityPercentage, 0.5);
    });

    test('medium quality returns 0.7 (70%)', () {
      expect(CompressionQuality.medium.qualityPercentage, 0.7);
    });

    test('high quality returns 0.9 (90%)', () {
      expect(CompressionQuality.high.qualityPercentage, 0.9);
    });

    test('all quality percentages are between 0 and 1', () {
      for (final quality in CompressionQuality.values) {
        expect(quality.qualityPercentage, greaterThanOrEqualTo(0.0));
        expect(quality.qualityPercentage, lessThanOrEqualTo(1.0));
      }
    });
  });

  group('CompressionQuality.displayName', () {
    test('low quality has correct German label', () {
      expect(CompressionQuality.low.displayName, 'Niedrig (50%)');
    });

    test('medium quality has correct German label', () {
      expect(CompressionQuality.medium.displayName, 'Mittel (70%)');
    });

    test('high quality has correct German label', () {
      expect(CompressionQuality.high.displayName, 'Hoch (90%)');
    });

    test('all display names are non-empty', () {
      for (final quality in CompressionQuality.values) {
        expect(quality.displayName, isNotEmpty);
      }
    });

    test('display names contain percentage indicators', () {
      expect(CompressionQuality.low.displayName, contains('50%'));
      expect(CompressionQuality.medium.displayName, contains('70%'));
      expect(CompressionQuality.high.displayName, contains('90%'));
    });
  });

  group('CompressionQuality.description', () {
    test('low quality has correct German description', () {
      expect(
        CompressionQuality.low.description,
        'Kleinste Dateigröße, niedrigste Qualität',
      );
    });

    test('medium quality has correct German description', () {
      expect(
        CompressionQuality.medium.description,
        'Ausgewogenes Verhältnis',
      );
    });

    test('high quality has correct German description', () {
      expect(
        CompressionQuality.high.description,
        'Beste Qualität, größere Dateigröße',
      );
    });

    test('all descriptions are non-empty', () {
      for (final quality in CompressionQuality.values) {
        expect(quality.description, isNotEmpty);
      }
    });

    test('descriptions are in German', () {
      // Check for German-specific characters and words
      expect(
        CompressionQuality.low.description,
        contains('Dateigröße'),
      );
      expect(
        CompressionQuality.high.description,
        contains('Qualität'),
      );
    });
  });

  group('CompressionQuality ordering', () {
    test('quality levels are ordered from low to high', () {
      expect(
        CompressionQuality.low.qualityPercentage,
        lessThan(CompressionQuality.medium.qualityPercentage),
      );
      expect(
        CompressionQuality.medium.qualityPercentage,
        lessThan(CompressionQuality.high.qualityPercentage),
      );
    });

    test('can be used in switch statements', () {
      String getTestValue(CompressionQuality quality) {
        switch (quality) {
          case CompressionQuality.low:
            return 'low';
          case CompressionQuality.medium:
            return 'medium';
          case CompressionQuality.high:
            return 'high';
        }
      }

      expect(getTestValue(CompressionQuality.low), 'low');
      expect(getTestValue(CompressionQuality.medium), 'medium');
      expect(getTestValue(CompressionQuality.high), 'high');
    });
  });
}
