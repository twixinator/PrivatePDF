import '../models/pdf_operation_error.dart';

/// Sealed class representing the state of a PDF operation
/// Uses pattern matching for type-safe state handling
sealed class PdfOperationState {
  const PdfOperationState();

  /// Factory constructors for each state
  factory PdfOperationState.idle() = IdleState;
  factory PdfOperationState.processing() = ProcessingState;
  factory PdfOperationState.success(String fileName) = SuccessState;
  factory PdfOperationState.error(PdfOperationError error) = ErrorState;

  /// Pattern matching for state handling
  T when<T>({
    required T Function() idle,
    required T Function() processing,
    required T Function(String fileName) success,
    required T Function(PdfOperationError error) error,
  }) {
    if (this is IdleState) {
      return idle();
    } else if (this is ProcessingState) {
      return processing();
    } else if (this is SuccessState) {
      return success((this as SuccessState).fileName);
    } else if (this is ErrorState) {
      return error((this as ErrorState).error);
    }
    throw StateError('Unknown PdfOperationState type');
  }

  /// Convenience getters for state checking
  bool get isIdle => this is IdleState;
  bool get isProcessing => this is ProcessingState;
  bool get isSuccess => this is SuccessState;
  bool get isError => this is ErrorState;
}

/// Initial idle state - no operation in progress
class IdleState extends PdfOperationState {
  const IdleState();

  @override
  String toString() => 'IdleState';
}

/// Processing state - operation in progress
class ProcessingState extends PdfOperationState {
  const ProcessingState();

  @override
  String toString() => 'ProcessingState';
}

/// Success state - operation completed successfully
class SuccessState extends PdfOperationState {
  final String fileName;

  const SuccessState(this.fileName);

  @override
  String toString() => 'SuccessState{fileName: $fileName}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuccessState &&
          runtimeType == other.runtimeType &&
          fileName == other.fileName;

  @override
  int get hashCode => fileName.hashCode;
}

/// Error state - operation failed
class ErrorState extends PdfOperationState {
  final PdfOperationError error;

  const ErrorState(this.error);

  /// Get error message for display
  String get errorMessage => error.message;

  /// Check if error is recoverable
  bool get isRecoverable => error.isRecoverable;

  @override
  String toString() => 'ErrorState{error: ${error.code}}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorState &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;
}
