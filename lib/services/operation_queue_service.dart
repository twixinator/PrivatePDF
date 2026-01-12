import 'package:flutter/foundation.dart';
import '../config/environment.dart';

/// Types of PDF operations
enum PdfOperationType {
  merge,
  split,
  protect,
}

/// Status of a queued operation
enum OperationStatus {
  queued,
  processing,
  completed,
  failed,
  cancelled,
}

/// Represents a queued operation
class QueuedOperation {
  final String id;
  final PdfOperationType type;
  final DateTime createdAt;
  OperationStatus status;

  QueuedOperation({
    required this.id,
    required this.type,
    DateTime? createdAt,
    this.status = OperationStatus.queued,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Get human-readable operation name
  String get typeName {
    switch (type) {
      case PdfOperationType.merge:
        return 'Zusammenführen';
      case PdfOperationType.split:
        return 'Aufteilen';
      case PdfOperationType.protect:
        return 'Schützen';
    }
  }

  /// Duration since creation
  Duration get age => DateTime.now().difference(createdAt);

  @override
  String toString() =>
      'QueuedOperation($id, type: ${type.name}, status: ${status.name})';
}

/// Service for managing PDF operation queue
///
/// Ensures one-at-a-time processing to:
/// - Prevent race conditions
/// - Avoid memory issues from concurrent operations
/// - Provide clear UX (user sees queue position)
/// - Allow operation cancellation
class OperationQueueService extends ChangeNotifier {
  final List<QueuedOperation> _queue = [];
  QueuedOperation? _currentOperation;

  /// Get current operation being processed
  QueuedOperation? get currentOperation => _currentOperation;

  /// Get all queued operations (excluding current)
  List<QueuedOperation> get queuedOperations {
    return List.unmodifiable(
      _queue.where((op) => op.status == OperationStatus.queued),
    );
  }

  /// Get total queue size (including current operation)
  int get queueSize {
    final queuedCount = queuedOperations.length;
    return _currentOperation != null ? queuedCount + 1 : queuedCount;
  }

  /// Check if queue is empty
  bool get isEmpty => _queue.isEmpty && _currentOperation == null;

  /// Check if currently processing
  bool get isProcessing => _currentOperation != null;

  /// Enqueue a new operation
  ///
  /// Returns the operation ID for tracking
  String enqueueOperation(PdfOperationType type) {
    final operationId = _generateOperationId();
    final operation = QueuedOperation(
      id: operationId,
      type: type,
    );

    _queue.add(operation);

    if (Environment.enableDebugLogging) {
      print('[OperationQueue] Enqueued: ${operation.typeName} ($operationId)');
      print('[OperationQueue] Queue size: ${queueSize}');
    }

    notifyListeners();

    // Auto-start if nothing is processing
    if (_currentOperation == null) {
      _processNext();
    }

    return operationId;
  }

  /// Start processing an operation
  ///
  /// Returns true if operation was started, false if queue is busy
  bool startOperation(String operationId) {
    // Check if already processing
    if (_currentOperation != null) {
      if (Environment.enableDebugLogging) {
        print(
          '[OperationQueue] Cannot start $operationId - already processing ${_currentOperation!.id}',
        );
      }
      return false;
    }

    // Find operation in queue
    final operationIndex = _queue.indexWhere((op) => op.id == operationId);
    if (operationIndex == -1) {
      if (Environment.enableDebugLogging) {
        print('[OperationQueue] Operation not found: $operationId');
      }
      return false;
    }

    // Move to current operation
    final operation = _queue.removeAt(operationIndex);
    operation.status = OperationStatus.processing;
    _currentOperation = operation;

    if (Environment.enableDebugLogging) {
      print('[OperationQueue] Started: ${operation.typeName} ($operationId)');
    }

    notifyListeners();
    return true;
  }

  /// Complete an operation (success)
  Future<void> completeOperation(String operationId) async {
    if (_currentOperation?.id != operationId) {
      if (Environment.enableDebugLogging) {
        print(
          '[OperationQueue] Warning: Completing non-current operation $operationId',
        );
      }
      return;
    }

    _currentOperation!.status = OperationStatus.completed;

    if (Environment.enableDebugLogging) {
      print(
        '[OperationQueue] Completed: ${_currentOperation!.typeName} ($operationId) in ${_currentOperation!.age.inSeconds}s',
      );
    }

    _currentOperation = null;
    notifyListeners();

    // Process next operation after delay
    await Future.delayed(Environment.queueProcessingDelay);
    _processNext();
  }

  /// Fail an operation
  Future<void> failOperation(String operationId, {String? error}) async {
    if (_currentOperation?.id != operationId) {
      if (Environment.enableDebugLogging) {
        print(
          '[OperationQueue] Warning: Failing non-current operation $operationId',
        );
      }
      return;
    }

    _currentOperation!.status = OperationStatus.failed;

    if (Environment.enableDebugLogging) {
      print(
        '[OperationQueue] Failed: ${_currentOperation!.typeName} ($operationId)${error != null ? " - $error" : ""}',
      );
    }

    _currentOperation = null;
    notifyListeners();

    // Process next operation after delay
    await Future.delayed(Environment.queueProcessingDelay);
    _processNext();
  }

  /// Cancel an operation
  bool cancelOperation(String operationId) {
    // Check if it's the current operation
    if (_currentOperation?.id == operationId) {
      _currentOperation!.status = OperationStatus.cancelled;
      if (Environment.enableDebugLogging) {
        print(
          '[OperationQueue] Cancelled current operation: ${_currentOperation!.typeName} ($operationId)',
        );
      }
      _currentOperation = null;
      notifyListeners();

      // Process next
      Future.delayed(Duration.zero, _processNext);
      return true;
    }

    // Check if it's in the queue
    final operationIndex = _queue.indexWhere((op) => op.id == operationId);
    if (operationIndex != -1) {
      final operation = _queue.removeAt(operationIndex);
      operation.status = OperationStatus.cancelled;

      if (Environment.enableDebugLogging) {
        print(
          '[OperationQueue] Cancelled queued operation: ${operation.typeName} ($operationId)',
        );
      }

      notifyListeners();
      return true;
    }

    return false;
  }

  /// Clear all queued operations (not current)
  void clearQueue() {
    final clearedCount = _queue.length;
    _queue.clear();

    if (Environment.enableDebugLogging && clearedCount > 0) {
      print('[OperationQueue] Cleared $clearedCount queued operations');
    }

    notifyListeners();
  }

  /// Get operation by ID
  QueuedOperation? getOperation(String operationId) {
    if (_currentOperation?.id == operationId) {
      return _currentOperation;
    }

    try {
      return _queue.firstWhere((op) => op.id == operationId);
    } catch (e) {
      return null;
    }
  }

  /// Get queue position for an operation (1-indexed)
  ///
  /// Returns 0 if operation is current, null if not found
  int? getQueuePosition(String operationId) {
    if (_currentOperation?.id == operationId) {
      return 0; // Currently processing
    }

    final index = _queue.indexWhere((op) => op.id == operationId);
    if (index == -1) return null;

    return index + 1; // 1-indexed position
  }

  /// Process next operation in queue
  void _processNext() {
    if (_currentOperation != null) {
      return; // Already processing
    }

    if (_queue.isEmpty) {
      return; // No operations to process
    }

    // Get first queued operation
    final nextOperation = _queue.firstWhere(
      (op) => op.status == OperationStatus.queued,
      orElse: () => _queue.first,
    );

    // Note: Actual processing is triggered by the provider
    // This just marks it as ready to process
    if (Environment.enableDebugLogging) {
      print(
        '[OperationQueue] Next operation ready: ${nextOperation.typeName} (${nextOperation.id})',
      );
    }
  }

  /// Generate unique operation ID
  String _generateOperationId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'op_$timestamp';
  }

  /// Get queue statistics
  Map<String, dynamic> getQueueStats() {
    return {
      'queueSize': queueSize,
      'queuedCount': queuedOperations.length,
      'isProcessing': isProcessing,
      'currentOperation': _currentOperation?.toMap(),
      'queuedOperations': queuedOperations.map((op) => op.toMap()).toList(),
    };
  }

  @override
  void dispose() {
    if (Environment.enableDebugLogging) {
      print('[OperationQueue] Service disposed');
    }
    _queue.clear();
    _currentOperation = null;
    super.dispose();
  }
}

/// Extension for QueuedOperation serialization
extension QueuedOperationX on QueuedOperation {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'typeName': typeName,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'ageSeconds': age.inSeconds,
    };
  }
}
