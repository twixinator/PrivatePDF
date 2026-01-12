import 'package:flutter/foundation.dart';
import '../models/pdf_file_info.dart';
import '../models/page_range.dart';
import '../models/pdf_operation_error.dart';
import '../models/analytics_event.dart';
import '../services/pdf_service.dart';
import '../services/download_service.dart';
import '../services/analytics_service.dart';
import '../services/operation_queue_service.dart';
import '../services/network_verification_service.dart';
import 'pdf_operation_state.dart';

/// Provider for managing PDF operation state
/// Handles business logic and coordinates between services
class PdfOperationProvider extends ChangeNotifier {
  final PdfService _pdfService;
  final DownloadService _downloadService;
  final AnalyticsProvider _analytics;
  final OperationQueueService _queueService;
  final NetworkVerificationService _networkVerification;

  PdfOperationState _state = const IdleState();
  PdfOperationState get state => _state;

  // Current operation tracking
  String? _currentOperationId;
  DateTime? _operationStartTime;

  /// Get current operation ID
  String? get currentOperationId => _currentOperationId;

  /// Get queue position for current operation
  int? get queuePosition =>
      _currentOperationId != null ? _queueService.getQueuePosition(_currentOperationId!) : null;

  /// Check if operation can be cancelled
  bool get canCancel => _currentOperationId != null && _queueService.isProcessing;

  PdfOperationProvider({
    required PdfService pdfService,
    required DownloadService downloadService,
    required AnalyticsProvider analytics,
    required OperationQueueService queueService,
    required NetworkVerificationService networkVerification,
  })  : _pdfService = pdfService,
        _downloadService = downloadService,
        _analytics = analytics,
        _queueService = queueService,
        _networkVerification = networkVerification {
    // Listen to queue changes
    _queueService.addListener(_onQueueChanged);
  }

  /// Merge multiple PDF files
  Future<void> mergePdfs(List<PdfFileInfo> files) async {
    // Enqueue operation
    final operationId = _queueService.enqueueOperation(PdfOperationType.merge);
    _currentOperationId = operationId;
    _operationStartTime = DateTime.now();

    // Wait for queue position
    _setState(const ProcessingState());

    // Start operation when queue is ready
    final started = _queueService.startOperation(operationId);
    if (!started) {
      // Operation was cancelled or failed to start
      _setState(const ErrorState(PdfOperationError.unknown));
      _logOperationError('merge', files.length, 'Failed to start operation');
      return;
    }

    // Start network monitoring
    _networkVerification.startMonitoring(operationId);

    // Perform PDF operation
    final result = await _pdfService.mergePdfs(files);

    // Stop network monitoring
    final verificationReport = _networkVerification.stopMonitoring(operationId);

    result.when(
      success: (bytes, fileName) {
        // Calculate duration
        final duration = DateTime.now().difference(_operationStartTime!);

        // Download the merged PDF
        _downloadService.downloadPdf(bytes, fileName, operationId: operationId);

        // Log analytics event
        _analytics.logEvent(
          AnalyticsEvent.pdfOperationSuccess(
            operationType: 'merge',
            fileCount: files.length,
            durationMs: duration.inMilliseconds,
            outputSizeBytes: bytes.length,
          ),
        );

        // Complete operation
        _queueService.completeOperation(operationId);
        _setState(SuccessState(fileName));

        // Reset operation tracking
        _currentOperationId = null;
        _operationStartTime = null;

        // Auto-reset after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (_state is SuccessState) {
            reset();
          }
        });
      },
      failure: (error) {
        // Log error analytics
        _logOperationError('merge', files.length, error.code);

        // Fail operation
        _queueService.failOperation(operationId, error: error.message);
        _setState(ErrorState(error));

        // Reset operation tracking
        _currentOperationId = null;
        _operationStartTime = null;
      },
    );
  }

  /// Split PDF into pages
  Future<void> splitPdf(PdfFileInfo file, PageRange range) async {
    // Enqueue operation
    final operationId = _queueService.enqueueOperation(PdfOperationType.split);
    _currentOperationId = operationId;
    _operationStartTime = DateTime.now();

    // Wait for queue position
    _setState(const ProcessingState());

    // Start operation when queue is ready
    final started = _queueService.startOperation(operationId);
    if (!started) {
      _setState(const ErrorState(PdfOperationError.unknown));
      _logOperationError('split', 1, 'Failed to start operation');
      return;
    }

    // Start network monitoring
    _networkVerification.startMonitoring(operationId);

    // Perform PDF operation
    final result = await _pdfService.splitPdf(file, range);

    // Stop network monitoring
    final verificationReport = _networkVerification.stopMonitoring(operationId);

    result.when(
      success: (bytes, fileName) {
        // Calculate duration
        final duration = DateTime.now().difference(_operationStartTime!);

        // Download the split PDF
        _downloadService.downloadPdf(bytes, fileName, operationId: operationId);

        // Log analytics event
        _analytics.logEvent(
          AnalyticsEvent.pdfOperationSuccess(
            operationType: 'split',
            fileCount: 1,
            durationMs: duration.inMilliseconds,
            outputSizeBytes: bytes.length,
          ),
        );

        // Complete operation
        _queueService.completeOperation(operationId);
        _setState(SuccessState(fileName));

        // Reset operation tracking
        _currentOperationId = null;
        _operationStartTime = null;

        // Auto-reset after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (_state is SuccessState) {
            reset();
          }
        });
      },
      failure: (error) {
        // Log error analytics
        _logOperationError('split', 1, error.code);

        // Fail operation
        _queueService.failOperation(operationId, error: error.message);
        _setState(ErrorState(error));

        // Reset operation tracking
        _currentOperationId = null;
        _operationStartTime = null;
      },
    );
  }

  /// Protect PDF with password
  Future<void> protectPdf(PdfFileInfo file, String password) async {
    // Enqueue operation
    final operationId = _queueService.enqueueOperation(PdfOperationType.protect);
    _currentOperationId = operationId;
    _operationStartTime = DateTime.now();

    // Wait for queue position
    _setState(const ProcessingState());

    // Start operation when queue is ready
    final started = _queueService.startOperation(operationId);
    if (!started) {
      _setState(const ErrorState(PdfOperationError.unknown));
      _logOperationError('protect', 1, 'Failed to start operation');
      return;
    }

    // Start network monitoring
    _networkVerification.startMonitoring(operationId);

    // Perform PDF operation
    final result = await _pdfService.protectPdf(file, password);

    // Stop network monitoring
    final verificationReport = _networkVerification.stopMonitoring(operationId);

    result.when(
      success: (bytes, fileName) {
        // Calculate duration
        final duration = DateTime.now().difference(_operationStartTime!);

        // Download the protected PDF
        _downloadService.downloadPdf(bytes, fileName, operationId: operationId);

        // Log analytics event
        _analytics.logEvent(
          AnalyticsEvent.pdfOperationSuccess(
            operationType: 'protect',
            fileCount: 1,
            durationMs: duration.inMilliseconds,
            outputSizeBytes: bytes.length,
          ),
        );

        // Complete operation
        _queueService.completeOperation(operationId);
        _setState(SuccessState(fileName));

        // Reset operation tracking
        _currentOperationId = null;
        _operationStartTime = null;

        // Auto-reset after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (_state is SuccessState) {
            reset();
          }
        });
      },
      failure: (error) {
        // Log error analytics
        _logOperationError('protect', 1, error.code);

        // Fail operation
        _queueService.failOperation(operationId, error: error.message);
        _setState(ErrorState(error));

        // Reset operation tracking
        _currentOperationId = null;
        _operationStartTime = null;
      },
    );
  }

  /// Cancel current operation
  bool cancelCurrentOperation() {
    if (_currentOperationId == null) {
      return false;
    }

    final cancelled = _queueService.cancelOperation(_currentOperationId!);
    if (cancelled) {
      // Log cancellation event
      _analytics.logEvent(
        AnalyticsEvent(
          eventName: 'pdf_operation_cancelled',
          category: AnalyticsEventCategory.pdfOperation,
          properties: {
            'operationId': _currentOperationId!,
          },
        ),
      );

      // Reset state
      _setState(const IdleState());
      _currentOperationId = null;
      _operationStartTime = null;
    }

    return cancelled;
  }

  /// Reset state to idle
  void reset() {
    _setState(const IdleState());
  }

  /// Update state and notify listeners
  void _setState(PdfOperationState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Log operation error to analytics
  void _logOperationError(String operationType, int fileCount, String errorCode) {
    _analytics.logEvent(
      AnalyticsEvent.pdfOperationError(
        operationType: operationType,
        errorCode: errorCode,
        fileCount: fileCount,
      ),
    );
  }

  /// Handle queue changes
  void _onQueueChanged() {
    // Notify listeners when queue state changes
    // This allows UI to update queue position, etc.
    notifyListeners();
  }

  @override
  void dispose() {
    _queueService.removeListener(_onQueueChanged);
    super.dispose();
  }
}
