// ignore_for_file: avoid_web_libraries_in_flutter

/// JavaScript interop bridge for pdf-lib operations
/// Isolates all JavaScript communication in this single layer
///
/// This bridge converts between Dart types and JavaScript types,
/// handling Promise conversion and error mapping.
@JS()
library pdf_lib_bridge;

import 'dart:js_util' as js_util;
import 'dart:typed_data';
import 'package:js/js.dart';

// JavaScript function declarations
@JS('PDFLibProcessor.mergePDFs')
external Object _mergePDFs(List<Uint8List> pdfBytesArray);

@JS('PDFLibProcessor.splitPDF')
external Object _splitPDF(Uint8List pdfBytes, List<int> pageNumbers);

@JS('PDFLibProcessor.protectPDF')
external Object _protectPDF(Uint8List pdfBytes, String password);

@JS('PDFLibProcessor.getPageCount')
external Object _getPageCount(Uint8List pdfBytes);

/// Main bridge class for PDF-lib operations
/// All methods are static for simplicity
class PdfLibBridge {
  /// Private constructor to prevent instantiation
  PdfLibBridge._();

  /// Merge multiple PDFs into a single document
  ///
  /// @param pdfFiles List of PDF file byte arrays
  /// @returns Merged PDF bytes
  /// @throws Exception if merge fails
  static Future<Uint8List> mergePDFs(List<Uint8List> pdfFiles) async {
    try {
      final promise = _mergePDFs(pdfFiles);
      final result = await js_util.promiseToFuture<dynamic>(promise);

      // Convert JavaScript Uint8Array to Dart Uint8List
      if (result is Uint8List) {
        return result;
      } else {
        // Handle case where result needs conversion
        return Uint8List.fromList(List<int>.from(result as List));
      }
    } catch (e) {
      throw _convertJsError(e, 'mergePDFs');
    }
  }

  /// Split PDF by extracting specific pages
  ///
  /// @param pdfBytes Original PDF bytes
  /// @param pageNumbers Zero-indexed page numbers to extract
  /// @returns New PDF with extracted pages
  /// @throws Exception if split fails
  static Future<Uint8List> splitPDF(
    Uint8List pdfBytes,
    List<int> pageNumbers,
  ) async {
    try {
      final promise = _splitPDF(pdfBytes, pageNumbers);
      final result = await js_util.promiseToFuture<dynamic>(promise);

      if (result is Uint8List) {
        return result;
      } else {
        return Uint8List.fromList(List<int>.from(result as List));
      }
    } catch (e) {
      throw _convertJsError(e, 'splitPDF');
    }
  }

  /// Protect PDF with password encryption
  ///
  /// @param pdfBytes Original PDF bytes
  /// @param password User password (minimum 6 characters)
  /// @returns Encrypted PDF bytes
  /// @throws Exception if protection fails
  static Future<Uint8List> protectPDF(
    Uint8List pdfBytes,
    String password,
  ) async {
    try {
      final promise = _protectPDF(pdfBytes, password);
      final result = await js_util.promiseToFuture<dynamic>(promise);

      if (result is Uint8List) {
        return result;
      } else {
        return Uint8List.fromList(List<int>.from(result as List));
      }
    } catch (e) {
      throw _convertJsError(e, 'protectPDF');
    }
  }

  /// Get page count from a PDF
  ///
  /// @param pdfBytes PDF bytes
  /// @returns Number of pages
  /// @throws Exception if reading fails
  static Future<int> getPageCount(Uint8List pdfBytes) async {
    try {
      final promise = _getPageCount(pdfBytes);
      final result = await js_util.promiseToFuture<dynamic>(promise);
      return result as int;
    } catch (e) {
      throw _convertJsError(e, 'getPageCount');
    }
  }

  /// Convert JavaScript errors to meaningful Dart exceptions
  static Exception _convertJsError(dynamic error, String operation) {
    final errorMessage = error.toString();

    // Log for debugging
    print('[PdfLibBridge] Error in $operation: $errorMessage');

    // Map common errors
    if (errorMessage.contains('Invalid PDF')) {
      return Exception('Invalid PDF file');
    } else if (errorMessage.contains('password')) {
      return Exception('Password must be at least 6 characters');
    } else if (errorMessage.contains('page number')) {
      return Exception('Invalid page number');
    } else if (errorMessage.contains('not defined') ||
        errorMessage.contains('undefined')) {
      return Exception(
        'PDF library not loaded. Please refresh the page.',
      );
    }

    return Exception('PDF operation failed: $errorMessage');
  }

  /// Check if PDF-lib is loaded and available
  static bool isAvailable() {
    try {
      return js_util.hasProperty(js_util.globalThis, 'PDFLibProcessor');
    } catch (e) {
      return false;
    }
  }
}
