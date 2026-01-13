/// Enum representing compression quality levels for PDF image compression
enum CompressionQuality {
  /// Low quality (50% compression) - Smallest file size
  low,

  /// Medium quality (70% compression) - Balanced
  medium,

  /// High quality (90% compression) - Best quality
  high;

  /// Get quality percentage (0.0-1.0) for image compression
  double get qualityPercentage {
    switch (this) {
      case CompressionQuality.low:
        return 0.5;
      case CompressionQuality.medium:
        return 0.7;
      case CompressionQuality.high:
        return 0.9;
    }
  }

  /// Get display name in German for UI
  String get displayName {
    switch (this) {
      case CompressionQuality.low:
        return 'Niedrig (50%)';
      case CompressionQuality.medium:
        return 'Mittel (70%)';
      case CompressionQuality.high:
        return 'Hoch (90%)';
    }
  }

  /// Get description in German
  String get description {
    switch (this) {
      case CompressionQuality.low:
        return 'Kleinste Dateigröße, niedrigste Qualität';
      case CompressionQuality.medium:
        return 'Ausgewogenes Verhältnis';
      case CompressionQuality.high:
        return 'Beste Qualität, größere Dateigröße';
    }
  }
}
