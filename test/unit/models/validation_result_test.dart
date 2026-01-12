import 'package:flutter_test/flutter_test.dart';
import 'package:privatpdf/models/validation_result.dart';
import 'package:privatpdf/models/pdf_operation_error.dart';

/// ValidationResult model tests
void main() {
  group('ValidationResult.success', () {
    test('creates successful validation result', () {
      final result = ValidationResult.success();
      expect(result.isValid, true);
      expect(result.isFailure, false);
      expect(result.error, isNull);
      expect(result.errorMessage, isNull);
    });
  });

  group('ValidationResult.failure', () {
    test('creates failed validation result', () {
      final result = ValidationResult.failure(PdfOperationError.invalidFile);
      expect(result.isValid, false);
      expect(result.isFailure, true);
      expect(result.error, PdfOperationError.invalidFile);
      expect(result.errorMessage, isNotNull);
    });

    test('stores error correctly', () {
      final result = ValidationResult.failure(PdfOperationError.fileTooLarge);
      expect(result.error, PdfOperationError.fileTooLarge);
      expect(result.errorMessage, contains('zu groß'));
    });
  });

  group('ValidationResult properties', () {
    test('isFailure is inverse of isValid', () {
      final success = ValidationResult.success();
      final failure = ValidationResult.failure(PdfOperationError.unknown);

      expect(success.isValid, true);
      expect(success.isFailure, false);

      expect(failure.isValid, false);
      expect(failure.isFailure, true);
    });

    test('errorMessage returns null for success', () {
      final result = ValidationResult.success();
      expect(result.errorMessage, isNull);
    });

    test('errorMessage returns message for failure', () {
      final result = ValidationResult.failure(PdfOperationError.weakPassword);
      expect(result.errorMessage, isNotEmpty);
    });
  });

  group('ValidationResult equality', () {
    test('successful results are equal', () {
      final result1 = ValidationResult.success();
      final result2 = ValidationResult.success();
      expect(result1, equals(result2));
      expect(result1.hashCode, equals(result2.hashCode));
    });

    test('failed results with same error are equal', () {
      final result1 = ValidationResult.failure(PdfOperationError.invalidFile);
      final result2 = ValidationResult.failure(PdfOperationError.invalidFile);
      expect(result1, equals(result2));
      expect(result1.hashCode, equals(result2.hashCode));
    });

    test('failed results with different errors are not equal', () {
      final result1 = ValidationResult.failure(PdfOperationError.invalidFile);
      final result2 = ValidationResult.failure(PdfOperationError.fileTooLarge);
      expect(result1, isNot(equals(result2)));
    });

    test('success and failure are not equal', () {
      final success = ValidationResult.success();
      final failure = ValidationResult.failure(PdfOperationError.unknown);
      expect(success, isNot(equals(failure)));
    });

    test('identical results are equal', () {
      final result = ValidationResult.success();
      expect(result, equals(result));
    });
  });

  group('ValidationResult toString', () {
    test('toString for success includes valid', () {
      final result = ValidationResult.success();
      expect(result.toString(), contains('valid'));
      expect(result.toString(), contains('ValidationResult'));
    });

    test('toString for failure includes error code', () {
      final result = ValidationResult.failure(PdfOperationError.invalidFile);
      final str = result.toString();
      expect(str, contains('invalid'));
      expect(str, contains('INVALIDFILE'));
    });
  });
}
