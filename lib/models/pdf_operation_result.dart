import 'dart:typed_data';
import 'pdf_operation_error.dart';

/// Sealed class representing the result of a PDF operation
/// Uses pattern matching for type-safe error handling
sealed class PdfOperationResult {
  const PdfOperationResult();

  /// Pattern matching for result handling
  T when<T>({
    required T Function(Uint8List pdfBytes, String suggestedFileName) success,
    required T Function(PdfOperationError error) failure,
  }) {
    if (this is PdfOperationSuccess) {
      final s = this as PdfOperationSuccess;
      return success(s.pdfBytes, s.suggestedFileName);
    } else if (this is PdfOperationFailure) {
      final f = this as PdfOperationFailure;
      return failure(f.error);
    }
    throw StateError('Unknown PdfOperationResult type');
  }

  /// Check if result is success
  bool get isSuccess => this is PdfOperationSuccess;

  /// Check if result is failure
  bool get isFailure => this is PdfOperationFailure;
}

/// Success result containing the processed PDF bytes
class PdfOperationSuccess extends PdfOperationResult {
  final Uint8List pdfBytes;
  final String suggestedFileName;

  const PdfOperationSuccess({
    required this.pdfBytes,
    required this.suggestedFileName,
  });

  @override
  String toString() {
    return 'PdfOperationSuccess{fileName: $suggestedFileName, size: ${pdfBytes.length} bytes}';
  }
}

/// Failure result containing the error
class PdfOperationFailure extends PdfOperationResult {
  final PdfOperationError error;

  const PdfOperationFailure(this.error);

  @override
  String toString() {
    return 'PdfOperationFailure{error: ${error.code}, message: ${error.message}}';
  }
}
