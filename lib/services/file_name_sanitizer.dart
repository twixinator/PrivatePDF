/// Service for sanitizing file names while preserving German umlauts
///
/// Ensures file names are safe for all operating systems while maintaining
/// German language characters (ä, ö, ü, ß, etc.).
class FileNameSanitizer {
  /// Maximum filename length (filesystem limit)
  static const int maxFilenameLength = 255;

  /// Maximum basename length for readability
  static const int maxBasenameLength = 200;

  /// Invalid characters for Windows filesystems
  static final RegExp _windowsInvalidChars = RegExp(r'[<>:"/\\|?*\x00-\x1F]');

  /// Leading/trailing dots and spaces (problematic on Windows/Mac)
  static final RegExp _leadingDotsSpaces = RegExp(r'^[.\s]+');
  static final RegExp _trailingSpaces = RegExp(r'\s+$');

  /// Multiple consecutive spaces
  static final RegExp _multipleSpaces = RegExp(r'\s{2,}');

  /// Sanitize a filename while preserving German umlauts
  ///
  /// Preserves:
  /// - German umlauts: ä, ö, ü, ß, Ä, Ö, Ü
  /// - Special chars: -, _, ., (), spaces
  /// - All ASCII alphanumeric
  ///
  /// Removes:
  /// - Windows invalid: < > : " / \ | ? *
  /// - Control characters: \x00-\x1F
  /// - Leading dots/spaces
  ///
  /// @param filename The filename to sanitize
  /// @param preserveExtension Whether to ensure the .pdf extension is preserved
  /// @returns Sanitized filename
  static String sanitize(
    String filename, {
    bool preserveExtension = true,
  }) {
    if (filename.isEmpty) {
      return preserveExtension ? 'document.pdf' : 'document';
    }

    String sanitized = filename;

    // Remove Windows invalid characters
    sanitized = sanitized.replaceAll(_windowsInvalidChars, '');

    // Remove leading dots and spaces
    sanitized = sanitized.replaceAll(_leadingDotsSpaces, '');

    // Remove trailing spaces
    sanitized = sanitized.replaceAll(_trailingSpaces, '');

    // Replace multiple spaces with single space
    sanitized = sanitized.replaceAll(_multipleSpaces, ' ');

    // If empty after sanitization, use default
    if (sanitized.isEmpty) {
      return preserveExtension ? 'document.pdf' : 'document';
    }

    // Handle extension
    String basename;
    String extension = '';

    if (preserveExtension) {
      if (sanitized.toLowerCase().endsWith('.pdf')) {
        final lastDot = sanitized.lastIndexOf('.');
        basename = sanitized.substring(0, lastDot);
        extension = '.pdf';
      } else {
        basename = sanitized;
        extension = '.pdf';
      }
    } else {
      basename = sanitized;
    }

    // Trim basename if too long
    if (basename.length > maxBasenameLength) {
      basename = basename.substring(0, maxBasenameLength);
      // Add ellipsis to indicate truncation
      basename = '${basename.substring(0, maxBasenameLength - 3)}...';
    }

    // Reconstruct filename
    final result = '$basename$extension';

    // Final length check (filesystem limit)
    if (result.length > maxFilenameLength) {
      final availableLength = maxFilenameLength - extension.length - 3; // -3 for "..."
      return '${basename.substring(0, availableLength)}...$extension';
    }

    return result;
  }

  /// Sanitize multiple filenames
  static List<String> sanitizeMultiple(List<String> filenames) {
    return filenames.map((name) => sanitize(name)).toList();
  }

  /// Check if a filename is valid (already sanitized)
  static bool isValid(String filename) {
    // Check for Windows invalid characters
    if (_windowsInvalidChars.hasMatch(filename)) {
      return false;
    }

    // Check for leading dots/spaces
    if (_leadingDotsSpaces.hasMatch(filename)) {
      return false;
    }

    // Check for trailing spaces
    if (_trailingSpaces.hasMatch(filename)) {
      return false;
    }

    // Check length
    if (filename.length > maxFilenameLength) {
      return false;
    }

    return true;
  }

  /// Get a safe filename for downloading
  ///
  /// This ensures the filename is safe for download by:
  /// 1. Sanitizing invalid characters
  /// 2. Ensuring .pdf extension
  /// 3. Trimming to reasonable length
  static String getSafeDownloadName(String originalName) {
    return sanitize(originalName, preserveExtension: true);
  }

  /// Create a merged filename from multiple sources
  ///
  /// Example: "document1.pdf" + "document2.pdf" → "document1_document2_merged.pdf"
  static String createMergedFilename(List<String> sourceFilenames) {
    if (sourceFilenames.isEmpty) {
      return 'merged.pdf';
    }

    if (sourceFilenames.length == 1) {
      final basename = _getBasename(sourceFilenames[0]);
      return sanitize('${basename}_merged.pdf');
    }

    // Take first two basenames
    final basename1 = _getBasename(sourceFilenames[0]);
    final basename2 = _getBasename(sourceFilenames[1]);

    String mergedName;
    if (sourceFilenames.length == 2) {
      mergedName = '${basename1}_${basename2}_merged.pdf';
    } else {
      mergedName = '${basename1}_${basename2}_+${sourceFilenames.length - 2}_merged.pdf';
    }

    return sanitize(mergedName);
  }

  /// Create a split filename
  ///
  /// Example: "document.pdf" + pages "1-3" → "document_pages_1-3.pdf"
  static String createSplitFilename(String sourceFilename, String pageRange) {
    final basename = _getBasename(sourceFilename);
    final sanitizedRange = pageRange.replaceAll(_windowsInvalidChars, '-');
    return sanitize('${basename}_pages_$sanitizedRange.pdf');
  }

  /// Create a protected filename
  ///
  /// Example: "document.pdf" → "document_protected.pdf"
  static String createProtectedFilename(String sourceFilename) {
    final basename = _getBasename(sourceFilename);
    return sanitize('${basename}_protected.pdf');
  }

  /// Get basename without extension
  static String _getBasename(String filename) {
    final lastDot = filename.lastIndexOf('.');
    if (lastDot > 0) {
      return filename.substring(0, lastDot);
    }
    return filename;
  }

  /// Validate German umlauts are preserved
  static bool areUmlautsPreserved(String filename) {
    const germanChars = ['ä', 'ö', 'ü', 'ß', 'Ä', 'Ö', 'Ü'];
    for (final char in germanChars) {
      if (filename.contains(char)) {
        final sanitized = sanitize(filename);
        if (!sanitized.contains(char)) {
          return false;
        }
      }
    }
    return true;
  }
}
