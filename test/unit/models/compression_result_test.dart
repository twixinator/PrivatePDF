import 'package:flutter_test/flutter_test.dart';
import 'package:privatpdf/models/compression_result.dart';

/// CompressionResult model tests
void main() {
  group('CompressionResult constructor', () {
    test('creates instance with all properties', () {
      final result = CompressionResult(
        originalSizeBytes: 1000,
        compressedSizeBytes: 500,
        processingTime: Duration(milliseconds: 100),
      );

      expect(result.originalSizeBytes, 1000);
      expect(result.compressedSizeBytes, 500);
      expect(result.processingTime, Duration(milliseconds: 100));
    });

    test('accepts zero sizes', () {
      final result = CompressionResult(
        originalSizeBytes: 0,
        compressedSizeBytes: 0,
        processingTime: Duration.zero,
      );

      expect(result.originalSizeBytes, 0);
      expect(result.compressedSizeBytes, 0);
    });

    test('accepts larger compressed size (failed compression)', () {
      final result = CompressionResult(
        originalSizeBytes: 100,
        compressedSizeBytes: 150,
        processingTime: Duration(milliseconds: 50),
      );

      expect(result.compressedSizeBytes, greaterThan(result.originalSizeBytes));
    });
  });

  group('CompressionResult.compressionRatio', () {
    test('calculates ratio correctly for 50% compression', () {
      final result = CompressionResult(
        originalSizeBytes: 1000,
        compressedSizeBytes: 500,
        processingTime: Duration(milliseconds: 100),
      );

      expect(result.compressionRatio, 0.5);
    });

    test('calculates ratio correctly for 70% compression', () {
      final result = CompressionResult(
        originalSizeBytes: 1000,
        compressedSizeBytes: 300,
        processingTime: Duration(milliseconds: 100),
      );

      expect(result.compressionRatio, 0.3);
    });

    test('returns 1.0 for no compression', () {
      final result = CompressionResult(
        originalSizeBytes: 1000,
        compressedSizeBytes: 1000,
        processingTime: Duration(milliseconds: 100),
      );

      expect(result.compressionRatio, 1.0);
    });

    test('returns >1.0 when compressed size is larger', () {
      final result = CompressionResult(
        originalSizeBytes: 100,
        compressedSizeBytes: 150,
        processingTime: Duration(milliseconds: 100),
      );

      expect(result.compressionRatio, 1.5);
    });

    test('returns 1.0 when original size is 0', () {
      final result = CompressionResult(
        originalSizeBytes: 0,
        compressedSizeBytes: 0,
        processingTime: Duration(milliseconds: 100),
      );

      expect(result.compressionRatio, 1.0);
    });
  });

  group('CompressionResult.percentageSaved', () {
    test('calculates 50% saved correctly', () {
      final result = CompressionResult(
        originalSizeBytes: 1000,
        compressedSizeBytes: 500,
        processingTime: Duration(milliseconds: 100),
      );

      expect(result.percentageSaved, 50.0);
    });

    test('calculates 70% saved correctly', () {
      final result = CompressionResult(
        originalSizeBytes: 1000,
        compressedSizeBytes: 300,
        processingTime: Duration(milliseconds: 100),
      );

      expect(result.percentageSaved, 70.0);
    });

    test('returns 0% when no compression', () {
      final result = CompressionResult(
        originalSizeBytes: 1000,
        compressedSizeBytes: 1000,
        processingTime: Duration(milliseconds: 100),
      );

      expect(result.percentageSaved, 0.0);
    });

    test('returns negative percentage when size increased', () {
      final result = CompressionResult(
        originalSizeBytes: 100,
        compressedSizeBytes: 150,
        processingTime: Duration(milliseconds: 100),
      );

      expect(result.percentageSaved, -50.0);
    });

    test('calculates 90% saved correctly', () {
      final result = CompressionResult(
        originalSizeBytes: 1000,
        compressedSizeBytes: 100,
        processingTime: Duration(milliseconds: 100),
      );

      expect(result.percentageSaved, 90.0);
    });
  });

  group('CompressionResult.formatBytes', () {
    test('formats bytes correctly', () {
      expect(CompressionResult.formatBytes(0), '0 B');
      expect(CompressionResult.formatBytes(512), '512 B');
      expect(CompressionResult.formatBytes(1023), '1023 B');
    });

    test('formats kilobytes correctly', () {
      expect(CompressionResult.formatBytes(1024), '1.0 KB');
      expect(CompressionResult.formatBytes(2048), '2.0 KB');
      expect(CompressionResult.formatBytes(1536), '1.5 KB');
      expect(CompressionResult.formatBytes(10240), '10.0 KB');
    });

    test('formats megabytes correctly', () {
      expect(CompressionResult.formatBytes(1024 * 1024), '1.0 MB');
      expect(CompressionResult.formatBytes(2 * 1024 * 1024), '2.0 MB');
      expect(CompressionResult.formatBytes(1536 * 1024), '1.5 MB');
      expect(CompressionResult.formatBytes(10 * 1024 * 1024), '10.0 MB');
    });

    test('formats fractional values with one decimal place', () {
      expect(CompressionResult.formatBytes(1587), '1.5 KB'); // 1.55 KB -> 1.5 KB
      expect(
          CompressionResult.formatBytes(2097152 + 524288), '2.5 MB'); // 2.5 MB
    });

    test('handles negative bytes as 0', () {
      expect(CompressionResult.formatBytes(-100), '0 B');
    });
  });

  group('CompressionResult formatted getters', () {
    test('originalSizeFormatted returns formatted string', () {
      final result = CompressionResult(
        originalSizeBytes: 2048,
        compressedSizeBytes: 1024,
        processingTime: Duration(milliseconds: 100),
      );

      expect(result.originalSizeFormatted, '2.0 KB');
    });

    test('compressedSizeFormatted returns formatted string', () {
      final result = CompressionResult(
        originalSizeBytes: 2048,
        compressedSizeBytes: 1024,
        processingTime: Duration(milliseconds: 100),
      );

      expect(result.compressedSizeFormatted, '1.0 KB');
    });

    test('formats different size ranges correctly', () {
      final resultBytes = CompressionResult(
        originalSizeBytes: 512,
        compressedSizeBytes: 256,
        processingTime: Duration(milliseconds: 100),
      );
      expect(resultBytes.originalSizeFormatted, '512 B');
      expect(resultBytes.compressedSizeFormatted, '256 B');

      final resultMB = CompressionResult(
        originalSizeBytes: 5 * 1024 * 1024,
        compressedSizeBytes: 2 * 1024 * 1024,
        processingTime: Duration(milliseconds: 100),
      );
      expect(resultMB.originalSizeFormatted, '5.0 MB');
      expect(resultMB.compressedSizeFormatted, '2.0 MB');
    });
  });

  group('CompressionResult equality', () {
    test('results with same sizes are equal', () {
      final result1 = CompressionResult(
        originalSizeBytes: 1000,
        compressedSizeBytes: 500,
        processingTime: Duration(milliseconds: 100),
      );
      final result2 = CompressionResult(
        originalSizeBytes: 1000,
        compressedSizeBytes: 500,
        processingTime: Duration(milliseconds: 200), // Different time
      );

      expect(result1, equals(result2));
      expect(result1.hashCode, equals(result2.hashCode));
    });

    test('results with different sizes are not equal', () {
      final result1 = CompressionResult(
        originalSizeBytes: 1000,
        compressedSizeBytes: 500,
        processingTime: Duration(milliseconds: 100),
      );
      final result2 = CompressionResult(
        originalSizeBytes: 1000,
        compressedSizeBytes: 600,
        processingTime: Duration(milliseconds: 100),
      );

      expect(result1, isNot(equals(result2)));
    });

    test('identical results are equal', () {
      final result = CompressionResult(
        originalSizeBytes: 1000,
        compressedSizeBytes: 500,
        processingTime: Duration(milliseconds: 100),
      );

      expect(result, equals(result));
    });
  });

  group('CompressionResult toString', () {
    test('includes all metrics', () {
      final result = CompressionResult(
        originalSizeBytes: 2048,
        compressedSizeBytes: 1024,
        processingTime: Duration(milliseconds: 150),
      );

      final str = result.toString();
      expect(str, contains('CompressionResult'));
      expect(str, contains('2.0 KB')); // Original
      expect(str, contains('1.0 KB')); // Compressed
      expect(str, contains('50.0%')); // Percentage saved
      expect(str, contains('150ms')); // Processing time
    });

    test('formats percentage with one decimal place', () {
      final result = CompressionResult(
        originalSizeBytes: 1000,
        compressedSizeBytes: 333, // 66.7% saved
        processingTime: Duration(milliseconds: 100),
      );

      final str = result.toString();
      expect(str, contains('66.7%'));
    });

    test('handles zero processing time', () {
      final result = CompressionResult(
        originalSizeBytes: 1000,
        compressedSizeBytes: 500,
        processingTime: Duration.zero,
      );

      final str = result.toString();
      expect(str, contains('0ms'));
    });
  });

  group('CompressionResult edge cases', () {
    test('handles maximum int values', () {
      final result = CompressionResult(
        originalSizeBytes: 2147483647, // Max 32-bit int
        compressedSizeBytes: 1073741823,
        processingTime: Duration(milliseconds: 100),
      );

      expect(result.compressionRatio, closeTo(0.5, 0.01));
      expect(result.percentageSaved, closeTo(50.0, 1.0));
    });

    test('handles very small compressions', () {
      final result = CompressionResult(
        originalSizeBytes: 1000000,
        compressedSizeBytes: 999999,
        processingTime: Duration(milliseconds: 100),
      );

      expect(result.compressionRatio, closeTo(0.999999, 0.000001));
      expect(result.percentageSaved, closeTo(0.0001, 0.0001));
    });

    test('handles perfect compression (0 bytes)', () {
      final result = CompressionResult(
        originalSizeBytes: 1000,
        compressedSizeBytes: 0,
        processingTime: Duration(milliseconds: 100),
      );

      expect(result.compressionRatio, 0.0);
      expect(result.percentageSaved, 100.0);
    });
  });
}
