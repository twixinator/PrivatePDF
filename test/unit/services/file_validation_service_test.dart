import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privatpdf/services/file_validation_service.dart';
import 'package:privatpdf/models/pdf_operation_error.dart';
import 'package:privatpdf/models/page_range.dart';
import 'package:privatpdf/models/pdf_file_info.dart';
import '../../fixtures/test_helpers.dart';
import '../../mocks/mocks.mocks.dart';

/// FileValidationService tests
/// Target: 90%+ code coverage (CRITICAL component)
void main() {
  late FileValidationService service;
  late MockIPdfLibBridge mockBridge;

  setUp(() {
    mockBridge = MockIPdfLibBridge();
    service = FileValidationService(
      maxFileSizeBytes: 5 * 1024 * 1024, // 5MB
      minMergeFiles: 2,
      maxMergeFiles: 10,
      minPasswordLength: 6,
      pdfLibBridge: mockBridge,
    );
  });

  group('validateMerge', () {
    test('succeeds with valid files', () {
      final files = TestHelpers.createMultipleMockPdfs(2);
      final result = service.validateMerge(files);
      expect(result.isValid, true);
      expect(result.error, isNull);
    });

    test('fails with insufficient files (1 file)', () {
      final files = TestHelpers.createMultipleMockPdfs(1);
      final result = service.validateMerge(files);
      expect(result.isValid, false);
      expect(result.error, PdfOperationError.insufficientFiles);
    });

    test('fails with insufficient files (0 files)', () {
      final files = <PdfFileInfo>[];
      final result = service.validateMerge(files);
      expect(result.isValid, false);
      expect(result.error, PdfOperationError.insufficientFiles);
    });

    test('fails with too many files', () {
      final files = TestHelpers.createMultipleMockPdfs(11);
      final result = service.validateMerge(files);
      expect(result.isValid, false);
      expect(result.error, PdfOperationError.tooManyFiles);
    });

    test('succeeds at min boundary (2 files)', () {
      final files = TestHelpers.createMultipleMockPdfs(2);
      final result = service.validateMerge(files);
      expect(result.isValid, true);
    });

    test('succeeds at max boundary (10 files)', () {
      final files = TestHelpers.createMultipleMockPdfs(10);
      final result = service.validateMerge(files);
      expect(result.isValid, true);
    });

    test('fails with oversized file', () {
      final files = [
        TestHelpers.createMockPdfFileInfo('file1.pdf'),
        TestHelpers.createMockPdfWithSize('large.pdf', 6), // 6MB
      ];
      final result = service.validateMerge(files);
      expect(result.isValid, false);
      expect(result.error, PdfOperationError.fileTooLarge);
    });

    test('fails with corrupted file', () {
      final files = [
        TestHelpers.createMockPdfFileInfo('file1.pdf'),
        TestHelpers.createCorruptedPdf('bad.pdf'),
      ];
      final result = service.validateMerge(files);
      expect(result.isValid, false);
      expect(result.error, PdfOperationError.invalidFile);
    });

    test('validates each file in list', () {
      final files = [
        TestHelpers.createMockPdfFileInfo('good1.pdf'),
        TestHelpers.createMockPdfFileInfo('good2.pdf'),
        TestHelpers.createCorruptedPdf('bad.pdf'), // Third file is bad
      ];
      final result = service.validateMerge(files);
      expect(result.isValid, false);
    });
  });

  group('validateSplit', () {
    test('succeeds with valid file and range', () {
      final file = TestHelpers.createFullMockPdf(
        name: 'document.pdf',
        sizeBytes: 1024,
        pageCount: 10,
      );
      final range = PageRange([1, 2, 3]);
      final result = service.validateSplit(file, range);
      expect(result.isValid, true);
    });

    test('fails with insufficient pages', () {
      final file = TestHelpers.createFullMockPdf(
        name: 'document.pdf',
        sizeBytes: 1024,
        pageCount: 1,
      );
      final range = PageRange([1]);
      final result = service.validateSplit(file, range);
      expect(result.isValid, false);
      expect(result.error, PdfOperationError.insufficientPages);
    });

    test('fails with invalid page range', () {
      final file = TestHelpers.createFullMockPdf(
        name: 'document.pdf',
        sizeBytes: 1024,
        pageCount: 5,
      );
      final range = PageRange([1, 2, 10]); // Page 10 doesn't exist
      final result = service.validateSplit(file, range);
      expect(result.isValid, false);
      expect(result.error, PdfOperationError.invalidPageRange);
    });

    test('fails with oversized file', () {
      final file = TestHelpers.createMockPdfWithSize('large.pdf', 6);
      final range = PageRange([1, 2]);
      final result = service.validateSplit(file, range);
      expect(result.isValid, false);
      expect(result.error, PdfOperationError.fileTooLarge);
    });

    test('succeeds with 2 pages (minimum)', () {
      final file = TestHelpers.createFullMockPdf(
        name: 'document.pdf',
        sizeBytes: 1024,
        pageCount: 2,
      );
      final range = PageRange([1, 2]);
      final result = service.validateSplit(file, range);
      expect(result.isValid, true);
    });
  });

  group('validateProtect', () {
    test('succeeds with valid password', () {
      final file = TestHelpers.createMockPdfFileInfo('document.pdf');
      final result = service.validateProtect(file, 'SecurePass123');
      expect(result.isValid, true);
    });

    test('fails with weak password (5 chars)', () {
      final file = TestHelpers.createMockPdfFileInfo('document.pdf');
      final result = service.validateProtect(file, '12345');
      expect(result.isValid, false);
      expect(result.error, PdfOperationError.weakPassword);
    });

    test('succeeds with password at minimum length (6 chars)', () {
      final file = TestHelpers.createMockPdfFileInfo('document.pdf');
      final result = service.validateProtect(file, '123456');
      expect(result.isValid, true);
    });

    test('fails with empty password', () {
      final file = TestHelpers.createMockPdfFileInfo('document.pdf');
      final result = service.validateProtect(file, '');
      expect(result.isValid, false);
      expect(result.error, PdfOperationError.weakPassword);
    });

    test('fails with oversized file', () {
      final file = TestHelpers.createMockPdfWithSize('large.pdf', 6);
      final result = service.validateProtect(file, 'SecurePass123');
      expect(result.isValid, false);
      expect(result.error, PdfOperationError.fileTooLarge);
    });
  });

  group('validatePdfIntegrity', () {
    test('succeeds with valid PDF magic bytes and page count', () async {
      final file = TestHelpers.createMockPdfFileInfo('valid.pdf');

      // Mock successful page count extraction
      when(mockBridge.getPageCount(any)).thenAnswer((_) async => 5);

      final result = await service.validatePdfIntegrity(file);
      expect(result.isValid, true);
      verify(mockBridge.getPageCount(any)).called(1);
    });

    test('fails with invalid magic bytes', () async {
      final file = TestHelpers.createCorruptedPdf('bad.pdf');

      final result = await service.validatePdfIntegrity(file);
      expect(result.isValid, false);
      expect(result.error, PdfOperationError.invalidFile);
      // Should not call bridge if magic bytes fail
      verifyNever(mockBridge.getPageCount(any));
    });

    test('fails with zero page count', () async {
      final file = TestHelpers.createMockPdfFileInfo('empty.pdf');

      // Mock zero pages
      when(mockBridge.getPageCount(any)).thenAnswer((_) async => 0);

      final result = await service.validatePdfIntegrity(file);
      expect(result.isValid, false);
      expect(result.error, PdfOperationError.invalidFile);
    });

    test('fails with negative page count', () async {
      final file = TestHelpers.createMockPdfFileInfo('corrupted.pdf');

      // Mock negative pages (corrupted)
      when(mockBridge.getPageCount(any)).thenAnswer((_) async => -1);

      final result = await service.validatePdfIntegrity(file);
      expect(result.isValid, false);
      expect(result.error, PdfOperationError.invalidFile);
    });

    test('fails when page count extraction throws', () async {
      final file = TestHelpers.createMockPdfFileInfo('corrupted.pdf');

      // Mock exception during page count
      when(mockBridge.getPageCount(any))
          .thenThrow(Exception('Invalid PDF structure'));

      final result = await service.validatePdfIntegrity(file);
      expect(result.isValid, false);
      expect(result.error, PdfOperationError.invalidFile);
    });
  });

  group('convenience methods', () {
    test('formattedMaxFileSize returns correct string', () {
      expect(service.formattedMaxFileSize, '5 MB');
    });

    test('isFileSizeValid returns correct values', () {
      expect(service.isFileSizeValid(1024), true);
      expect(service.isFileSizeValid(5 * 1024 * 1024), true);
      expect(service.isFileSizeValid(6 * 1024 * 1024), false);
    });

    test('isMergeCountValid returns correct values', () {
      expect(service.isMergeCountValid(1), false);
      expect(service.isMergeCountValid(2), true);
      expect(service.isMergeCountValid(5), true);
      expect(service.isMergeCountValid(10), true);
      expect(service.isMergeCountValid(11), false);
    });

    test('isPasswordValid returns correct values', () {
      expect(service.isPasswordValid(''), false);
      expect(service.isPasswordValid('12345'), false);
      expect(service.isPasswordValid('123456'), true);
      expect(service.isPasswordValid('SecurePassword'), true);
    });
  });

  group('custom configuration', () {
    test('respects custom max file size', () {
      final customService = FileValidationService(
        maxFileSizeBytes: 10 * 1024 * 1024, // 10MB
        pdfLibBridge: mockBridge,
      );
      expect(customService.formattedMaxFileSize, '10 MB');
      expect(customService.isFileSizeValid(6 * 1024 * 1024), true);
    });

    test('respects custom merge count limits', () {
      final customService = FileValidationService(
        minMergeFiles: 3,
        maxMergeFiles: 5,
        pdfLibBridge: mockBridge,
      );
      expect(customService.isMergeCountValid(2), false);
      expect(customService.isMergeCountValid(3), true);
      expect(customService.isMergeCountValid(5), true);
      expect(customService.isMergeCountValid(6), false);
    });

    test('respects custom password length', () {
      final customService = FileValidationService(
        minPasswordLength: 8,
        pdfLibBridge: mockBridge,
      );
      expect(customService.isPasswordValid('1234567'), false);
      expect(customService.isPasswordValid('12345678'), true);
    });
  });
}
