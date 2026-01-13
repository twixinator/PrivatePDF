/// OCR language options for Tesseract.js
/// Supports German and English initially, with extensibility for more languages
enum OcrLanguage {
  /// German (Deutsch) - 'deu' language code for Tesseract
  german('deu', 'Deutsch (DEU)'),

  /// English - 'eng' language code for Tesseract
  english('eng', 'Englisch (ENG)');

  /// Tesseract.js language code (e.g., 'deu', 'eng')
  final String code;

  /// Display name in German for UI
  final String displayName;

  const OcrLanguage(this.code, this.displayName);

  /// Get language by Tesseract code
  /// Returns null if code is not found
  static OcrLanguage? fromCode(String code) {
    try {
      return OcrLanguage.values.firstWhere(
        (lang) => lang.code == code,
      );
    } catch (_) {
      return null;
    }
  }

  /// Check if a language code is valid
  static bool isValidCode(String code) {
    return fromCode(code) != null;
  }

  /// Get all available language codes
  static List<String> get allCodes {
    return OcrLanguage.values.map((lang) => lang.code).toList();
  }

  /// Get all display names
  static List<String> get allDisplayNames {
    return OcrLanguage.values.map((lang) => lang.displayName).toList();
  }
}
