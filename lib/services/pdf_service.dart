import '../models/pdf_file_info.dart';
import '../models/page_range.dart';
import '../models/pdf_operation_result.dart';
import '../models/compression_quality.dart';

/// Abstract interface for PDF processing operations
/// Defines the contract for all PDF manipulation services
///
/// This interface enables:
/// - Easy mocking for unit tests
/// - Switching between different PDF library implementations
/// - Dependency inversion principle
abstract class PdfService {
  /// Merge multiple PDF files into a single document
  ///
  /// @param files List of PDF files to merge (2-10 files)
  /// @returns Success with merged PDF bytes or Failure with error
  Future<PdfOperationResult> mergePdfs(List<PdfFileInfo> files);

  /// Split PDF by extracting specific pages
  ///
  /// @param file Source PDF file
  /// @param range Pages to extract (1-indexed)
  /// @returns Success with extracted pages or Failure with error
  Future<PdfOperationResult> splitPdf(PdfFileInfo file, PageRange range);

  /// Protect PDF with password encryption
  ///
  /// @param file Source PDF file
  /// @param password User password (minimum 6 characters)
  /// @returns Success with encrypted PDF or Failure with error
  Future<PdfOperationResult> protectPdf(PdfFileInfo file, String password);

  /// Compress PDF by reducing image quality
  ///
  /// @param file Source PDF file
  /// @param quality Compression quality level
  /// @returns Success with compressed PDF or Failure with error
  Future<PdfOperationResult> compressPdf(
    PdfFileInfo file,
    CompressionQuality quality,
  );
}
