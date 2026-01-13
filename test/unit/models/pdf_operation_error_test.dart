import 'package:flutter_test/flutter_test.dart';
import 'package:privatpdf/models/pdf_operation_error.dart';

/// PdfOperationError enum tests
void main() {
  group('PdfOperationError.message', () {
    test('invalidFile has German message', () {
      expect(
        PdfOperationError.invalidFile.message,
        contains('Ungültige PDF-Datei'),
      );
    });

    test('fileTooLarge has German message', () {
      expect(
        PdfOperationError.fileTooLarge.message,
        contains('zu groß'),
      );
      expect(
        PdfOperationError.fileTooLarge.message,
        contains('100 MB'),
      );
    });

    test('operationTooLarge has German message (Phase 7)', () {
      expect(
        PdfOperationError.operationTooLarge.message,
        contains('Gesamtgröße zu groß'),
      );
      expect(
        PdfOperationError.operationTooLarge.message,
        contains('250 MB'),
      );
    });

    test('insufficientFiles has German message', () {
      expect(
        PdfOperationError.insufficientFiles.message,
        contains('Mindestens 2'),
      );
    });

    test('tooManyFiles has German message', () {
      expect(
        PdfOperationError.tooManyFiles.message,
        contains('Maximal 10'),
      );
    });

    test('insufficientPages has German message', () {
      expect(
        PdfOperationError.insufficientPages.message,
        contains('mindestens 2 Seiten'),
      );
    });

    test('invalidPageRange has German message', () {
      expect(
        PdfOperationError.invalidPageRange.message,
        contains('Ungültiger Seitenbereich'),
      );
    });

    test('weakPassword has German message', () {
      expect(
        PdfOperationError.weakPassword.message,
        contains('Passwort zu schwach'),
      );
      expect(
        PdfOperationError.weakPassword.message,
        contains('6 Zeichen'),
      );
    });

    test('encryptionFailed has German message', () {
      expect(
        PdfOperationError.encryptionFailed.message,
        contains('Verschlüsselung fehlgeschlagen'),
      );
    });

    test('jsInteropError has German message', () {
      expect(
        PdfOperationError.jsInteropError.message,
        contains('PDF-Verarbeitung'),
      );
      expect(
        PdfOperationError.jsInteropError.message,
        contains('aktualisiere'),
      );
    });

    test('loadingFailed has German message', () {
      expect(
        PdfOperationError.loadingFailed.message,
        contains('nicht geladen'),
      );
    });

    test('savingFailed has German message', () {
      expect(
        PdfOperationError.savingFailed.message,
        contains('nicht gespeichert'),
      );
    });

    test('unknown has German message', () {
      expect(
        PdfOperationError.unknown.message,
        contains('unbekannter Fehler'),
      );
    });
  });

  group('PdfOperationError.code', () {
    test('returns uppercase code', () {
      expect(PdfOperationError.invalidFile.code, 'INVALIDFILE');
      expect(PdfOperationError.fileTooLarge.code, 'FILETOOLARGE');
      expect(PdfOperationError.weakPassword.code, 'WEAKPASSWORD');
      expect(PdfOperationError.unknown.code, 'UNKNOWN');
    });

    test('all errors have unique codes', () {
      final codes = PdfOperationError.values.map((e) => e.code).toSet();
      expect(codes.length, PdfOperationError.values.length);
    });
  });

  group('PdfOperationError.isRecoverable', () {
    test('user input errors are recoverable', () {
      expect(PdfOperationError.invalidFile.isRecoverable, true);
      expect(PdfOperationError.fileTooLarge.isRecoverable, true);
      expect(PdfOperationError.operationTooLarge.isRecoverable, true); // Phase 7
      expect(PdfOperationError.insufficientFiles.isRecoverable, true);
      expect(PdfOperationError.tooManyFiles.isRecoverable, true);
      expect(PdfOperationError.insufficientPages.isRecoverable, true);
      expect(PdfOperationError.invalidPageRange.isRecoverable, true);
      expect(PdfOperationError.weakPassword.isRecoverable, true);
    });

    test('system errors are not recoverable', () {
      expect(PdfOperationError.encryptionFailed.isRecoverable, false);
      expect(PdfOperationError.jsInteropError.isRecoverable, false);
      expect(PdfOperationError.loadingFailed.isRecoverable, false);
      expect(PdfOperationError.savingFailed.isRecoverable, false);
      expect(PdfOperationError.unknown.isRecoverable, false);
    });
  });

  group('PdfOperationError enum values', () {
    test('all error types exist', () {
      expect(PdfOperationError.values, hasLength(13)); // Phase 7: Added operationTooLarge
      expect(
        PdfOperationError.values,
        containsAll([
          PdfOperationError.invalidFile,
          PdfOperationError.fileTooLarge,
          PdfOperationError.operationTooLarge, // Phase 7: New error type
          PdfOperationError.insufficientFiles,
          PdfOperationError.tooManyFiles,
          PdfOperationError.insufficientPages,
          PdfOperationError.invalidPageRange,
          PdfOperationError.encryptionFailed,
          PdfOperationError.weakPassword,
          PdfOperationError.jsInteropError,
          PdfOperationError.loadingFailed,
          PdfOperationError.savingFailed,
          PdfOperationError.unknown,
        ]),
      );
    });

    test('can iterate over all errors', () {
      var count = 0;
      for (final error in PdfOperationError.values) {
        expect(error.message, isNotEmpty);
        expect(error.code, isNotEmpty);
        count++;
      }
      expect(count, 13); // Phase 7: Updated count
    });
  });
}
