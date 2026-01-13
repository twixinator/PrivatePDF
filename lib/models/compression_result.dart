/// Result of a PDF compression operation containing size and performance metrics
class CompressionResult {
  /// Original file size in bytes
  final int originalSizeBytes;

  /// Compressed file size in bytes
  final int compressedSizeBytes;

  /// Time taken to compress the file
  final Duration processingTime;

  const CompressionResult({
    required this.originalSizeBytes,
    required this.compressedSizeBytes,
    required this.processingTime,
  });

  /// Calculate compression ratio (0.0 to 1.0)
  /// - 0.0 = fully compressed (0 bytes)
  /// - 1.0 = no compression (same size)
  /// - >1.0 = file size increased
  double get compressionRatio =>
      originalSizeBytes > 0 ? compressedSizeBytes / originalSizeBytes : 1.0;

  /// Calculate percentage saved (0-100)
  /// - 0% = no savings
  /// - 100% = fully compressed
  /// - negative = file size increased
  double get percentageSaved => (1 - compressionRatio) * 100;

  /// Format bytes into human-readable string
  static String formatBytes(int bytes) {
    if (bytes < 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Get original size formatted
  String get originalSizeFormatted => formatBytes(originalSizeBytes);

  /// Get compressed size formatted
  String get compressedSizeFormatted => formatBytes(compressedSizeBytes);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompressionResult &&
          runtimeType == other.runtimeType &&
          originalSizeBytes == other.originalSizeBytes &&
          compressedSizeBytes == other.compressedSizeBytes;

  @override
  int get hashCode => Object.hash(originalSizeBytes, compressedSizeBytes);

  @override
  String toString() =>
      'CompressionResult(original: $originalSizeFormatted, '
      'compressed: $compressedSizeFormatted, '
      'saved: ${percentageSaved.toStringAsFixed(1)}%, '
      'time: ${processingTime.inMilliseconds}ms)';
}
