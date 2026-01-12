/// Enumeration of all possible PDF operation errors
enum PdfOperationError {
  // File validation errors
  invalidFile,
  fileTooLarge,
  insufficientFiles,
  tooManyFiles,

  // Page-related errors
  insufficientPages,
  invalidPageRange,

  // Security errors
  encryptionFailed,
  weakPassword,

  // Technical errors
  jsInteropError,
  loadingFailed,
  savingFailed,

  // Generic error
  unknown;

  /// Get German error message for display
  String get message {
    switch (this) {
      case PdfOperationError.invalidFile:
        return 'Ungültige PDF-Datei. Bitte wähle eine gültige PDF-Datei.';
      case PdfOperationError.fileTooLarge:
        return 'Datei zu groß. Die maximale Dateigröße beträgt 5 MB.';
      case PdfOperationError.insufficientFiles:
        return 'Mindestens 2 PDF-Dateien erforderlich.';
      case PdfOperationError.tooManyFiles:
        return 'Maximal 10 PDF-Dateien erlaubt.';
      case PdfOperationError.insufficientPages:
        return 'Das PDF muss mindestens 2 Seiten haben.';
      case PdfOperationError.invalidPageRange:
        return 'Ungültiger Seitenbereich. Bitte überprüfe deine Eingabe.';
      case PdfOperationError.encryptionFailed:
        return 'Verschlüsselung fehlgeschlagen. Bitte versuche es erneut.';
      case PdfOperationError.weakPassword:
        return 'Passwort zu schwach. Mindestens 6 Zeichen erforderlich.';
      case PdfOperationError.jsInteropError:
        return 'Fehler bei der PDF-Verarbeitung. Bitte aktualisiere die Seite.';
      case PdfOperationError.loadingFailed:
        return 'PDF konnte nicht geladen werden. Bitte versuche es erneut.';
      case PdfOperationError.savingFailed:
        return 'PDF konnte nicht gespeichert werden. Bitte versuche es erneut.';
      case PdfOperationError.unknown:
        return 'Ein unbekannter Fehler ist aufgetreten. Bitte versuche es erneut.';
    }
  }

  /// Get short error code for logging
  String get code {
    return name.toUpperCase();
  }

  /// Check if error is recoverable
  bool get isRecoverable {
    switch (this) {
      case PdfOperationError.invalidFile:
      case PdfOperationError.fileTooLarge:
      case PdfOperationError.insufficientFiles:
      case PdfOperationError.tooManyFiles:
      case PdfOperationError.insufficientPages:
      case PdfOperationError.invalidPageRange:
      case PdfOperationError.weakPassword:
        return true;
      case PdfOperationError.encryptionFailed:
      case PdfOperationError.jsInteropError:
      case PdfOperationError.loadingFailed:
      case PdfOperationError.savingFailed:
      case PdfOperationError.unknown:
        return false;
    }
  }
}
