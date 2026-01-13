import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';
import 'package:web/web.dart' as web;
import '../models/ocr_language.dart';
import '../models/ocr_result.dart';
import '../models/pdf_file_info.dart';

/// Progress callback type: (currentPage, totalPages, status, progressPercent)
typedef ProgressCallback = void Function(
  int currentPage,
  int totalPages,
  String status,
  double progressPercent,
);

/// Service for OCR (Optical Character Recognition) operations
/// Uses Tesseract.js via JavaScript interop for client-side text extraction
class OcrService {

  /// Extract text from a PDF file using OCR
  ///
  /// [file] - PDF file to process
  /// [language] - OCR language (German, English, etc.)
  /// [onProgress] - Optional progress callback for UI updates
  ///
  /// Returns [OcrResult] with extracted text per page
  Future<OcrResult> extractTextFromPdf({
    required PdfFileInfo file,
    required OcrLanguage language,
    ProgressCallback? onProgress,
  }) async {
    try {
      print('[OcrService] Starting OCR for file: ${file.name}');
      print('[OcrService] File size: ${file.sizeBytes} bytes');
      print('[OcrService] Language: ${language.displayName} (${language.code})');

      final startTime = DateTime.now();

      // Verify JavaScript OCR processor is available
      if (!_isOcrProcessorAvailable()) {
        throw Exception(
          'OCR processor not available. Ensure ocr_processor.js is loaded.',
        );
      }

      // Create progress callback bridge if needed
      JSFunction? jsProgressCallback;
      if (onProgress != null) {
        jsProgressCallback = _createProgressCallback(onProgress);
      }

      // Call JavaScript OCR processor
      final jsResult = await _callExtractTextFromPDF(
        file.bytes,
        language.code,
        jsProgressCallback,
      );

      // Parse JavaScript result
      final result = _parseOcrResult(jsResult, language, startTime);

      print('[OcrService] OCR complete. Pages: ${result.totalPages}, '
          'Time: ${result.formattedProcessingTime}');

      return result;
    } catch (e, stackTrace) {
      print('[OcrService] OCR error: $e');
      print('[OcrService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Extract text from an image file using OCR
  ///
  /// [imageBytes] - Image file bytes (PNG, JPEG, etc.)
  /// [language] - OCR language
  /// [onProgress] - Optional progress callback
  ///
  /// Returns [OcrResult] with extracted text
  Future<OcrResult> extractTextFromImage({
    required Uint8List imageBytes,
    required OcrLanguage language,
    ProgressCallback? onProgress,
  }) async {
    try {
      print('[OcrService] Starting OCR for image');
      print('[OcrService] Image size: ${imageBytes.length} bytes');
      print('[OcrService] Language: ${language.displayName} (${language.code})');

      final startTime = DateTime.now();

      // Verify JavaScript OCR processor is available
      if (!_isOcrProcessorAvailable()) {
        throw Exception(
          'OCR processor not available. Ensure ocr_processor.js is loaded.',
        );
      }

      // Create progress callback bridge if needed
      JSFunction? jsProgressCallback;
      if (onProgress != null) {
        jsProgressCallback = _createProgressCallback(onProgress);
      }

      // Call JavaScript OCR processor
      final jsResult = await _callExtractTextFromImage(
        imageBytes,
        language.code,
        jsProgressCallback,
      );

      // Parse JavaScript result
      final result = _parseOcrResult(jsResult, language, startTime);

      print('[OcrService] Image OCR complete. Time: ${result.formattedProcessingTime}');

      return result;
    } catch (e, stackTrace) {
      print('[OcrService] Image OCR error: $e');
      print('[OcrService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Check if JavaScript OCR processor is available
  bool _isOcrProcessorAvailable() {
    try {
      final hasOcrProcessor = (web.window as JSObject).hasProperty('ocrProcessor'.toJS).toDart;
      if (!hasOcrProcessor) {
        print('[OcrService] WARNING: window.ocrProcessor not found');
        return false;
      }
      return true;
    } catch (e) {
      print('[OcrService] Error checking OCR processor availability: $e');
      return false;
    }
  }

  /// Create a JavaScript-callable progress callback
  JSFunction _createProgressCallback(ProgressCallback dartCallback) {
    return ((
      JSNumber currentPage,
      JSNumber totalPages,
      JSString status,
      JSNumber progressPercent,
    ) {
      dartCallback(
        currentPage.toDartInt,
        totalPages.toDartInt,
        status.toDart,
        progressPercent.toDartDouble,
      );
    }).toJS;
  }

  /// Call JavaScript extractTextFromPDF function
  Future<JSObject> _callExtractTextFromPDF(
    Uint8List pdfBytes,
    String languageCode,
    JSFunction? progressCallback,
  ) async {
    try {
      // Get ocrProcessor object from window
      final windowObj = web.window as JSObject;
      final ocrProcessor = windowObj.getProperty('ocrProcessor'.toJS) as JSObject;

      // Get extractTextFromPDF function
      final extractFunction =
          ocrProcessor.getProperty('extractTextFromPDF'.toJS) as JSFunction;

      // Convert Uint8List to JSUint8Array
      final jsBytes = pdfBytes.toJS;
      final jsLanguage = languageCode.toJS;

      // Call the function
      final result = extractFunction.callAsFunction(
        ocrProcessor,
        jsBytes,
        jsLanguage,
        progressCallback,
      );

      // Convert Promise to Future
      return _promiseToFuture(result as JSPromise);
    } catch (e) {
      print('[OcrService] Error calling extractTextFromPDF: $e');
      rethrow;
    }
  }

  /// Call JavaScript extractTextFromImage function
  Future<JSObject> _callExtractTextFromImage(
    Uint8List imageBytes,
    String languageCode,
    JSFunction? progressCallback,
  ) async {
    try {
      // Get ocrProcessor object from window
      final windowObj = web.window as JSObject;
      final ocrProcessor = windowObj.getProperty('ocrProcessor'.toJS) as JSObject;

      // Get extractTextFromImage function
      final extractFunction =
          ocrProcessor.getProperty('extractTextFromImage'.toJS) as JSFunction;

      // Convert Uint8List to JSUint8Array
      final jsBytes = imageBytes.toJS;
      final jsLanguage = languageCode.toJS;

      // Call the function
      final result = extractFunction.callAsFunction(
        ocrProcessor,
        jsBytes,
        jsLanguage,
        progressCallback,
      );

      // Convert Promise to Future
      return _promiseToFuture(result as JSPromise);
    } catch (e) {
      print('[OcrService] Error calling extractTextFromImage: $e');
      rethrow;
    }
  }

  /// Convert JavaScript Promise to Dart Future
  Future<JSObject> _promiseToFuture(JSPromise promise) async {
    // Use JS interop to await the promise directly
    final result = await promise.toDart;
    return result as JSObject;
  }

  /// Parse JavaScript OCR result to OcrResult model
  OcrResult _parseOcrResult(
    JSObject jsResult,
    OcrLanguage language,
    DateTime startTime,
  ) {
    try {
      // Extract fields from JavaScript object using js_interop_unsafe
      final jsTextByPage = jsResult.getProperty('textByPage'.toJS) as JSObject;
      final jsConfidenceByPage = jsResult.getProperty('confidenceByPage'.toJS) as JSObject;
      final totalPages = (jsResult.getProperty('totalPages'.toJS) as JSNumber).toDartInt;
      final processingTimeMs = (jsResult.getProperty('processingTimeMs'.toJS) as JSNumber).toDartInt;

      // Convert JavaScript objects to Dart maps
      final textByPage = <int, String>{};
      final confidenceByPage = <int, double>{};

      // Extract text by page
      for (int i = 1; i <= totalPages; i++) {
        final pageKey = i.toString();
        try {
          if (jsTextByPage.hasProperty(pageKey.toJS).toDart) {
            final text = (jsTextByPage.getProperty(pageKey.toJS) as JSString).toDart;
            textByPage[i] = text;
          } else {
            textByPage[i] = '';
          }
        } catch (_) {
          // Page might not have text
          textByPage[i] = '';
        }
      }

      // Extract confidence by page
      for (int i = 1; i <= totalPages; i++) {
        final pageKey = i.toString();
        try {
          if (jsConfidenceByPage.hasProperty(pageKey.toJS).toDart) {
            final confidence = (jsConfidenceByPage.getProperty(pageKey.toJS) as JSNumber).toDartDouble;
            confidenceByPage[i] = confidence;
          } else {
            confidenceByPage[i] = 0.0;
          }
        } catch (_) {
          // Page might not have confidence
          confidenceByPage[i] = 0.0;
        }
      }

      return OcrResult(
        textByPage: textByPage,
        totalPages: totalPages,
        confidenceByPage: confidenceByPage,
        processingTimeMs: processingTimeMs,
        language: language,
        completedAt: DateTime.now(),
      );
    } catch (e) {
      print('[OcrService] Error parsing OCR result: $e');
      rethrow;
    }
  }
}
