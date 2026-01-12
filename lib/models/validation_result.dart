import 'pdf_operation_error.dart';

/// Represents the result of a validation operation
class ValidationResult {
  final bool isValid;
  final PdfOperationError? error;

  const ValidationResult._({
    required this.isValid,
    this.error,
  });

  /// Create a successful validation result
  factory ValidationResult.success() {
    return const ValidationResult._(isValid: true);
  }

  /// Create a failed validation result
  factory ValidationResult.failure(PdfOperationError error) {
    return ValidationResult._(isValid: false, error: error);
  }

  /// Get error message (null if valid)
  String? get errorMessage => error?.message;

  /// Check if validation failed
  bool get isFailure => !isValid;

  @override
  String toString() {
    if (isValid) {
      return 'ValidationResult{valid}';
    } else {
      return 'ValidationResult{invalid, error: ${error?.code}}';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidationResult &&
          runtimeType == other.runtimeType &&
          isValid == other.isValid &&
          error == other.error;

  @override
  int get hashCode => Object.hash(isValid, error);
}
