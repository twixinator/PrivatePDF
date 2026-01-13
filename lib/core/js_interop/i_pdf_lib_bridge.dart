import 'dart:typed_data';

/// Interface for PDF library operations
/// Enables mocking in tests while keeping JavaScript interop isolated
///
/// This interface abstracts the pdf-lib bridge operations, allowing
/// the PdfServiceImpl to be tested without actual JavaScript interop.
abstract class IPdfLibBridge {
  /// Merge multiple PDFs into a single document
  ///
  /// @param pdfFiles List of PDF file byte arrays
  /// @returns Merged PDF bytes
  /// @throws Exception if merge fails
  Future<Uint8List> mergePDFs(List<Uint8List> pdfFiles);

  /// Split PDF by extracting specific pages
  ///
  /// @param pdfBytes Original PDF bytes
  /// @param pageNumbers Zero-indexed page numbers to extract
  /// @returns New PDF with extracted pages
  /// @throws Exception if split fails
  Future<Uint8List> splitPDF(Uint8List pdfBytes, List<int> pageNumbers);

  /// Protect PDF with password encryption
  ///
  /// @param pdfBytes Original PDF bytes
  /// @param password User password (minimum 6 characters)
  /// @returns Encrypted PDF bytes
  /// @throws Exception if protection fails
  Future<Uint8List> protectPDF(Uint8List pdfBytes, String password);

  /// Get page count from a PDF
  ///
  /// @param pdfBytes PDF bytes
  /// @returns Number of pages
  /// @throws Exception if reading fails
  Future<int> getPageCount(Uint8List pdfBytes);

  /// Check if PDF-lib is loaded and available
  ///
  /// @returns true if the JavaScript PDF library is loaded
  bool isAvailable();

  /// Compress PDF by reducing image quality
  ///
  /// @param pdfBytes Original PDF bytes
  /// @param quality Quality factor (0.0-1.0, where 1.0 is best quality)
  /// @returns Compressed PDF bytes
  /// @throws Exception if compression fails
  Future<Uint8List> compressPdf(Uint8List pdfBytes, double quality);
}
