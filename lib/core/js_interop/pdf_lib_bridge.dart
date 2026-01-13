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
import 'i_pdf_lib_bridge.dart';

// JavaScript function declarations
@JS('PDFLibProcessor.mergePDFs')
external Object _mergePDFs(List<Uint8List> pdfBytesArray);

@JS('PDFLibProcessor.splitPDF')
external Object _splitPDF(Uint8List pdfBytes, List<int> pageNumbers);

@JS('PDFLibProcessor.protectPDF')
external Object _protectPDF(Uint8List pdfBytes, String password);

@JS('PDFLibProcessor.getPageCount')
external Object _getPageCount(Uint8List pdfBytes);

@JS('PDFLibProcessor.compressPdf')
external Object _compressPdf(Uint8List pdfBytes, double quality);

/// Main bridge class for PDF-lib operations
/// Implements IPdfLibBridge interface for testability
class PdfLibBridge implements IPdfLibBridge {
  /// Singleton instance
  static final IPdfLibBridge _instance = PdfLibBridge._();

  /// Private constructor to prevent direct instantiation
  PdfLibBridge._();

  /// Get singleton instance
  static IPdfLibBridge get instance => _instance;

  @override
  Future<Uint8List> mergePDFs(List<Uint8List> pdfFiles) async {
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

  @override
  Future<Uint8List> splitPDF(
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

  @override
  Future<Uint8List> protectPDF(
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

  @override
  Future<int> getPageCount(Uint8List pdfBytes) async {
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

  @override
  bool isAvailable() {
    try {
      return js_util.hasProperty(js_util.globalThis, 'PDFLibProcessor');
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Uint8List> compressPdf(
    Uint8List pdfBytes,
    double quality,
  ) async {
    try {
      final promise = _compressPdf(pdfBytes, quality);
      final result = await js_util.promiseToFuture<dynamic>(promise);

      if (result is Uint8List) {
        return result;
      } else {
        return Uint8List.fromList(List<int>.from(result as List));
      }
    } catch (e) {
      throw _convertJsError(e, 'compressPdf');
    }
  }
}
