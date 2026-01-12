import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:privatpdf/models/pdf_file_info.dart';
import '../../fixtures/test_helpers.dart';

/// PdfFileInfo model tests
void main() {
  group('PdfFileInfo constructor', () {
    test('creates instance with required properties', () {
      final file = TestHelpers.createMockPdfFileInfo('test.pdf');
      expect(file.name, 'test.pdf');
      expect(file.sizeBytes, 1024);
      expect(file.bytes, isNotEmpty);
      expect(file.id, isNotEmpty);
    });

    test('creates instance with page count', () {
      final file = TestHelpers.createMockPdfFileInfo(
        'test.pdf',
        pageCount: 10,
      );
      expect(file.pageCount, 10);
    });

    test('creates instance without page count', () {
      final file = TestHelpers.createMockPdfFileInfo('test.pdf');
      expect(file.pageCount, isNull);
    });
  });

  group('PdfFileInfo.copyWithPageCount', () {
    test('creates copy with page count', () {
      final original = TestHelpers.createMockPdfFileInfo('test.pdf');
      expect(original.pageCount, isNull);

      final copy = original.copyWithPageCount(5);
      expect(copy.pageCount, 5);
      expect(copy.name, original.name);
      expect(copy.id, original.id);
      expect(copy.sizeBytes, original.sizeBytes);
    });

    test('preserves all properties when copying', () {
      final original = TestHelpers.createFullMockPdf(
        name: 'document.pdf',
        sizeBytes: 2048,
        pageCount: 3,
      );

      final copy = original.copyWithPageCount(10);
      expect(copy.name, 'document.pdf');
      expect(copy.sizeBytes, 2048);
      expect(copy.pageCount, 10); // Changed
      expect(copy.id, original.id);
    });
  });

  group('PdfFileInfo.formattedSize', () {
    test('formats bytes', () {
      final file = TestHelpers.createMockPdfFileInfo(
        'test.pdf',
        sizeBytes: 512,
      );
      expect(file.formattedSize, '512 B');
    });

    test('formats kilobytes', () {
      final file = TestHelpers.createMockPdfFileInfo(
        'test.pdf',
        sizeBytes: 2048, // 2 KB
      );
      expect(file.formattedSize, '2.0 KB');
    });

    test('formats megabytes', () {
      final file = TestHelpers.createMockPdfWithSize('test.pdf', 2);
      expect(file.formattedSize, contains('2.0 MB'));
    });

    test('formats fractional kilobytes', () {
      final file = TestHelpers.createMockPdfFileInfo(
        'test.pdf',
        sizeBytes: 1536, // 1.5 KB
      );
      expect(file.formattedSize, '1.5 KB');
    });
  });

  group('PdfFileInfo.isValid', () {
    test('returns true for valid PDF', () {
      final file = TestHelpers.createMockPdfFileInfo('test.pdf');
      expect(file.isValid, true);
    });

    test('returns false for non-PDF extension', () {
      final file = PdfFileInfo(
        id: 'test',
        name: 'test.txt',
        sizeBytes: 100,
        bytes: Uint8List.fromList([1, 2, 3]),
      );
      expect(file.isValid, false);
    });

    test('returns false for empty bytes', () {
      final file = PdfFileInfo(
        id: 'test',
        name: 'test.pdf',
        sizeBytes: 0,
        bytes: Uint8List(0),
      );
      expect(file.isValid, false);
    });

    test('handles case-insensitive extension', () {
      final file = PdfFileInfo(
        id: 'test',
        name: 'test.PDF',
        sizeBytes: 100,
        bytes: Uint8List.fromList([1, 2, 3]),
      );
      expect(file.isValid, true);
    });
  });

  group('PdfFileInfo.isWithinSizeLimit', () {
    test('returns true when within limit', () {
      final file = TestHelpers.createMockPdfFileInfo(
        'test.pdf',
        sizeBytes: 1024,
      );
      expect(file.isWithinSizeLimit(2048), true);
    });

    test('returns true when exactly at limit', () {
      final file = TestHelpers.createMockPdfFileInfo(
        'test.pdf',
        sizeBytes: 1024,
      );
      expect(file.isWithinSizeLimit(1024), true);
    });

    test('returns false when over limit', () {
      final file = TestHelpers.createMockPdfFileInfo(
        'test.pdf',
        sizeBytes: 2048,
      );
      expect(file.isWithinSizeLimit(1024), false);
    });
  });

  group('PdfFileInfo equality', () {
    test('files with same id are equal', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final file1 = PdfFileInfo(
        id: 'test-id',
        name: 'test.pdf',
        sizeBytes: 100,
        bytes: bytes,
      );
      final file2 = PdfFileInfo(
        id: 'test-id',
        name: 'other.pdf', // Different name, but same ID
        sizeBytes: 200,
        bytes: bytes,
      );
      expect(file1, equals(file2));
      expect(file1.hashCode, equals(file2.hashCode));
    });

    test('files with different ids are not equal', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final file1 = PdfFileInfo(
        id: 'id1',
        name: 'test.pdf',
        sizeBytes: 100,
        bytes: bytes,
      );
      final file2 = PdfFileInfo(
        id: 'id2',
        name: 'test.pdf',
        sizeBytes: 100,
        bytes: bytes,
      );
      expect(file1, isNot(equals(file2)));
    });

    test('identical files are equal', () {
      final file = TestHelpers.createMockPdfFileInfo('test.pdf');
      expect(file, equals(file));
    });
  });

  group('PdfFileInfo toString', () {
    test('includes all properties', () {
      final file = TestHelpers.createFullMockPdf(
        name: 'document.pdf',
        sizeBytes: 2048,
        pageCount: 10,
      );
      final str = file.toString();
      expect(str, contains('PdfFileInfo'));
      expect(str, contains('document.pdf'));
      expect(str, contains('2.0 KB'));
      expect(str, contains('pageCount: 10'));
    });

    test('handles null pageCount', () {
      final file = TestHelpers.createMockPdfFileInfo('test.pdf');
      final str = file.toString();
      expect(str, contains('pageCount: null'));
    });
  });
}
