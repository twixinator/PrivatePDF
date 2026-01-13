import '../models/pdf_file_info.dart';
import '../models/compression_quality.dart';
import '../models/compression_result.dart';
import '../models/pdf_operation_result.dart';
import '../models/pdf_operation_error.dart';
import '../core/js_interop/i_pdf_lib_bridge.dart';

/// Service for compressing PDF files by reducing embedded image quality
///
/// This service uses the Canvas API via JavaScript interop to compress
/// images within PDF files, resulting in smaller file sizes.
class PdfCompressionService {
  final IPdfLibBridge _pdfLibBridge;

  PdfCompressionService({required IPdfLibBridge pdfLibBridge})
      : _pdfLibBridge = pdfLibBridge;

  /// Compress a PDF by reducing image quality
  ///
  /// @param file PDF file to compress
  /// @param quality Compression quality level (low/medium/high)
  /// @returns Success with compressed PDF bytes or Failure with error
  Future<PdfOperationResult> compressPdf(
    PdfFileInfo file,
    CompressionQuality quality,
  ) async {
    try {
      // Validate PDF-lib bridge is available
      if (!_pdfLibBridge.isAvailable()) {
        return const PdfOperationFailure(PdfOperationError.jsInteropError);
      }

      // Perform compression via JavaScript interop
      final compressedBytes = await _pdfLibBridge.compressPdf(
        file.bytes,
        quality.qualityPercentage,
      );

      // Generate output filename
      final outputFileName = _generateOutputFileName(file.name);

      return PdfOperationSuccess(
        pdfBytes: compressedBytes,
        suggestedFileName: outputFileName,
      );
    } on Exception catch (e) {
      print('[PdfCompressionService] Compression failed: $e');
      return const PdfOperationFailure(PdfOperationError.unknown);
    }
  }

  /// Calculate compression result metrics
  ///
  /// Compares original and compressed file sizes to generate statistics
  CompressionResult calculateCompressionResult({
    required int originalSize,
    required int compressedSize,
    required Duration processingTime,
  }) {
    return CompressionResult(
      originalSizeBytes: originalSize,
      compressedSizeBytes: compressedSize,
      processingTime: processingTime,
    );
  }

  /// Generate output filename for compressed PDF
  ///
  /// Appends "_komprimiert" suffix to the original filename
  String _generateOutputFileName(String originalName) {
    // Remove .pdf extension (case insensitive)
    final nameWithoutExtension =
        originalName.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');

    // Add compression suffix
    return '${nameWithoutExtension}_komprimiert.pdf';
  }
}
