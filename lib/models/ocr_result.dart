import 'ocr_language.dart';

/// Result of OCR text extraction operation
/// Contains extracted text per page with metadata
class OcrResult {
  /// Extracted text for each page (page number -> text)
  final Map<int, String> textByPage;

  /// Total number of pages processed
  final int totalPages;

  /// Confidence scores per page (0.0 to 1.0)
  /// Higher values indicate better recognition quality
  final Map<int, double> confidenceByPage;

  /// Total processing time in milliseconds
  final int processingTimeMs;

  /// Language used for OCR
  final OcrLanguage language;

  /// Timestamp when OCR was completed
  final DateTime completedAt;

  const OcrResult({
    required this.textByPage,
    required this.totalPages,
    required this.confidenceByPage,
    required this.processingTimeMs,
    required this.language,
    required this.completedAt,
  });

  /// Create an empty result (no text extracted)
  factory OcrResult.empty(OcrLanguage language) {
    return OcrResult(
      textByPage: {},
      totalPages: 0,
      confidenceByPage: {},
      processingTimeMs: 0,
      language: language,
      completedAt: DateTime.now(),
    );
  }

  /// Get all extracted text concatenated with page separators
  String get fullText {
    if (textByPage.isEmpty) return '';

    final buffer = StringBuffer();
    final sortedPages = textByPage.keys.toList()..sort();

    for (final pageNum in sortedPages) {
      if (buffer.isNotEmpty) {
        buffer.write('\n\n--- Seite $pageNum ---\n\n');
      }
      buffer.write(textByPage[pageNum] ?? '');
    }

    return buffer.toString();
  }

  /// Get average confidence score across all pages
  double get averageConfidence {
    if (confidenceByPage.isEmpty) return 0.0;

    final sum = confidenceByPage.values.reduce((a, b) => a + b);
    return sum / confidenceByPage.length;
  }

  /// Check if result is empty (no text extracted)
  bool get isEmpty => textByPage.isEmpty;

  /// Check if result has text
  bool get isNotEmpty => textByPage.isNotEmpty;

  /// Get text for a specific page (1-indexed)
  String? getTextForPage(int pageNumber) {
    return textByPage[pageNumber];
  }

  /// Get confidence for a specific page (1-indexed)
  double? getConfidenceForPage(int pageNumber) {
    return confidenceByPage[pageNumber];
  }

  /// Get processing time in seconds (rounded to 1 decimal)
  double get processingTimeSeconds {
    return (processingTimeMs / 1000.0);
  }

  /// Get formatted processing time string (e.g., "2.5s" or "1m 23s")
  String get formattedProcessingTime {
    final seconds = processingTimeSeconds;
    if (seconds < 60) {
      return '${seconds.toStringAsFixed(1)}s';
    }

    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).round();
    return '${minutes}m ${remainingSeconds}s';
  }

  /// Get a summary string for display
  String get summary {
    return '${totalPages} Seiten verarbeitet in $formattedProcessingTime '
        '(∅ ${(averageConfidence * 100).toStringAsFixed(1)}% Genauigkeit)';
  }

  /// Create a copy with updated fields
  OcrResult copyWith({
    Map<int, String>? textByPage,
    int? totalPages,
    Map<int, double>? confidenceByPage,
    int? processingTimeMs,
    OcrLanguage? language,
    DateTime? completedAt,
  }) {
    return OcrResult(
      textByPage: textByPage ?? this.textByPage,
      totalPages: totalPages ?? this.totalPages,
      confidenceByPage: confidenceByPage ?? this.confidenceByPage,
      processingTimeMs: processingTimeMs ?? this.processingTimeMs,
      language: language ?? this.language,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Convert to JSON (for potential serialization)
  Map<String, dynamic> toJson() {
    return {
      'textByPage': textByPage,
      'totalPages': totalPages,
      'confidenceByPage': confidenceByPage,
      'processingTimeMs': processingTimeMs,
      'language': language.code,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory OcrResult.fromJson(Map<String, dynamic> json) {
    return OcrResult(
      textByPage: Map<int, String>.from(json['textByPage'] ?? {}),
      totalPages: json['totalPages'] as int,
      confidenceByPage: Map<int, double>.from(json['confidenceByPage'] ?? {}),
      processingTimeMs: json['processingTimeMs'] as int,
      language: OcrLanguage.fromCode(json['language'] as String) ??
          OcrLanguage.german,
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'OcrResult(totalPages: $totalPages, language: ${language.displayName}, '
        'processingTime: $formattedProcessingTime, avgConfidence: ${(averageConfidence * 100).toStringAsFixed(1)}%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OcrResult &&
        other.totalPages == totalPages &&
        other.processingTimeMs == processingTimeMs &&
        other.language == language &&
        _mapsEqual(other.textByPage, textByPage) &&
        _mapsEqual(other.confidenceByPage, confidenceByPage);
  }

  @override
  int get hashCode {
    return Object.hash(
      totalPages,
      processingTimeMs,
      language,
      Object.hashAll(textByPage.entries.map((e) => Object.hash(e.key, e.value))),
      Object.hashAll(confidenceByPage.entries.map((e) => Object.hash(e.key, e.value))),
    );
  }

  /// Helper to compare maps
  bool _mapsEqual<K, V>(Map<K, V> a, Map<K, V> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
