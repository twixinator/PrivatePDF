import 'package:flutter/material.dart';
import '../../models/pdf_operation_error.dart';
import '../../models/error_action.dart';

/// Extension to convert PdfOperationError to EnhancedErrorMessage
extension PdfOperationErrorX on PdfOperationError {
  /// Convert to EnhancedErrorMessage with actionable recovery options
  EnhancedErrorMessage toEnhancedMessage(BuildContext context) {
    switch (this) {
      case PdfOperationError.fileTooLarge:
        return EnhancedErrorMessage.fileSizeLimit(
          fileSizeMB: 5.0, // Will be overridden with actual size
          limitMB: 5.0,
          actions: [
            ErrorAction.navigateRoute(
              label: 'Auf Pro upgraden',
              route: '/pricing',
              icon: Icons.upgrade,
            ),
            ErrorAction.documentation(
              label: 'Dateien komprimieren',
              url: 'https://help.privatpdf.de/compress',
            ),
            ErrorAction.dismiss(),
          ],
        );

      case PdfOperationError.invalidFile:
        return EnhancedErrorMessage.invalidFile(
          fileName: 'Datei', // Will be overridden with actual filename
          actions: [
            ErrorAction.documentation(
              label: 'Was ist eine gültige PDF?',
              url: 'https://help.privatpdf.de/valid-pdf',
            ),
            ErrorAction.dismiss(),
          ],
          reason:
              'Die Datei könnte beschädigt oder kein gültiges PDF sein.',
        );

      case PdfOperationError.insufficientFiles:
        return EnhancedErrorMessage(
          title: 'Zu wenige Dateien',
          userMessage:
              'Sie benötigen mindestens 2 PDF-Dateien zum Zusammenführen. '
              'Bitte laden Sie weitere Dateien hoch.',
          severity: ErrorSeverity.warning,
          suggestedActions: [
            ErrorAction.dismiss(),
          ],
          icon: Icons.upload_file,
        );

      case PdfOperationError.tooManyFiles:
        return EnhancedErrorMessage(
          title: 'Zu viele Dateien',
          userMessage:
              'Sie können maximal 10 PDF-Dateien gleichzeitig zusammenführen. '
              'Für mehr Dateien upgraden Sie bitte auf den Pro-Plan.',
          severity: ErrorSeverity.warning,
          suggestedActions: [
            ErrorAction.navigateRoute(
              label: 'Auf Pro upgraden',
              route: '/pricing',
              icon: Icons.upgrade,
            ),
            ErrorAction.dismiss(),
          ],
          icon: Icons.warning_amber_rounded,
        );

      case PdfOperationError.insufficientPages:
        return EnhancedErrorMessage(
          title: 'Zu wenige Seiten',
          userMessage:
              'Die PDF-Datei muss mindestens 2 Seiten haben, um aufgeteilt zu werden. '
              'Bitte verwenden Sie eine Datei mit mehreren Seiten.',
          severity: ErrorSeverity.warning,
          suggestedActions: [
            ErrorAction.dismiss(),
          ],
          icon: Icons.pages,
        );

      case PdfOperationError.invalidPageRange:
        return EnhancedErrorMessage.pageRangeValidation(
          reason:
              'Der eingegebene Seitenbereich ist ungültig. '
              'Beispiele für gültige Bereiche:\n'
              '• 1-3 (Seiten 1 bis 3)\n'
              '• 5 (nur Seite 5)\n'
              '• 1,3,5 (Seiten 1, 3 und 5)',
          actions: [
            ErrorAction.documentation(
              label: 'Hilfe zu Seitenbereichen',
              url: 'https://help.privatpdf.de/page-ranges',
            ),
            ErrorAction.dismiss(),
          ],
        );

      case PdfOperationError.weakPassword:
        return EnhancedErrorMessage.passwordValidation(
          reason:
              'Das Passwort muss mindestens 6 Zeichen lang sein. '
              'Verwenden Sie eine Kombination aus Buchstaben, Zahlen und Sonderzeichen für mehr Sicherheit.',
          actions: [
            ErrorAction.documentation(
              label: 'Sichere Passwörter erstellen',
              url: 'https://help.privatpdf.de/secure-passwords',
            ),
            ErrorAction.dismiss(),
          ],
        );

      case PdfOperationError.encryptionFailed:
        return EnhancedErrorMessage.processingError(
          operationType: 'Verschlüsselung',
          actions: [
            ErrorAction.retry(
              label: 'Erneut versuchen',
              onRetry: () {
                // Will be overridden with actual retry callback
              },
            ),
            ErrorAction.documentation(
              label: 'Hilfe anzeigen',
              url: 'https://help.privatpdf.de/encryption',
            ),
            ErrorAction.dismiss(),
          ],
        );

      case PdfOperationError.jsInteropError:
        return EnhancedErrorMessage.processingError(
          operationType: 'PDF-Verarbeitung',
          actions: [
            ErrorAction.custom(
              label: 'Seite neu laden',
              onTap: () {
                // Reload the page
                // ignore: avoid_web_libraries_in_flutter
                import 'dart:html' as html;
                html.window.location.reload();
              },
              icon: Icons.refresh,
            ),
            ErrorAction.documentation(
              label: 'Fehler melden',
              url: 'https://help.privatpdf.de/report-error',
            ),
            ErrorAction.dismiss(),
          ],
          details:
              'Ein interner Fehler ist bei der Kommunikation mit der PDF-Bibliothek aufgetreten.',
        );

      case PdfOperationError.loadingFailed:
        return EnhancedErrorMessage.processingError(
          operationType: 'Laden',
          actions: [
            ErrorAction.retry(
              label: 'Erneut versuchen',
              onRetry: () {},
            ),
            ErrorAction.dismiss(),
          ],
          details: 'Die PDF-Datei konnte nicht geladen werden.',
        );

      case PdfOperationError.savingFailed:
        return EnhancedErrorMessage.processingError(
          operationType: 'Speichern',
          actions: [
            ErrorAction.retry(
              label: 'Erneut versuchen',
              onRetry: () {},
            ),
            ErrorAction.dismiss(),
          ],
          details: 'Die PDF-Datei konnte nicht gespeichert werden.',
        );

      case PdfOperationError.unknown:
        return EnhancedErrorMessage.processingError(
          operationType: 'Verarbeitung',
          actions: [
            ErrorAction.retry(
              label: 'Erneut versuchen',
              onRetry: () {},
            ),
            ErrorAction.documentation(
              label: 'Hilfe anzeigen',
              url: 'https://help.privatpdf.de/troubleshooting',
            ),
            ErrorAction.dismiss(),
          ],
          details: 'Ein unbekannter Fehler ist aufgetreten.',
        );
    }
  }

  /// Get severity for this error
  ErrorSeverity get severity {
    switch (this) {
      case PdfOperationError.fileTooLarge:
      case PdfOperationError.insufficientFiles:
      case PdfOperationError.tooManyFiles:
      case PdfOperationError.insufficientPages:
      case PdfOperationError.invalidPageRange:
      case PdfOperationError.weakPassword:
        return ErrorSeverity.warning;

      case PdfOperationError.invalidFile:
      case PdfOperationError.encryptionFailed:
      case PdfOperationError.jsInteropError:
      case PdfOperationError.loadingFailed:
      case PdfOperationError.savingFailed:
      case PdfOperationError.unknown:
        return ErrorSeverity.critical;
    }
  }
}
