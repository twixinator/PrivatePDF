// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import '../config/environment.dart';

/// Represents a network request
class NetworkRequest {
  final String url;
  final String method;
  final DateTime timestamp;
  final String? operationId;

  NetworkRequest({
    required this.url,
    required this.method,
    required this.timestamp,
    this.operationId,
  });

  /// Check if this request is whitelisted
  bool get isWhitelisted {
    return Environment.whitelistedDomains.any(
      (domain) => url.contains(domain),
    );
  }

  /// Check if this request is suspicious (POST/PUT to unknown domain)
  bool get isSuspicious {
    if (isWhitelisted) return false;

    final suspiciousMethods = ['POST', 'PUT', 'PATCH'];
    return suspiciousMethods.contains(method.toUpperCase());
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'method': method,
      'timestamp': timestamp.toIso8601String(),
      'operationId': operationId,
      'isWhitelisted': isWhitelisted,
      'isSuspicious': isSuspicious,
    };
  }

  @override
  String toString() => 'NetworkRequest($method $url)';
}

/// Report of network activity
class NetworkVerificationReport {
  final String operationId;
  final List<NetworkRequest> allRequests;
  final List<NetworkRequest> suspiciousRequests;
  final DateTime startTime;
  final DateTime endTime;

  NetworkVerificationReport({
    required this.operationId,
    required this.allRequests,
    required this.suspiciousRequests,
    required this.startTime,
    required this.endTime,
  });

  /// Check if verification passed (no suspicious requests)
  bool get passed => suspiciousRequests.isEmpty;

  /// Get duration of monitoring
  Duration get duration => endTime.difference(startTime);

  Map<String, dynamic> toMap() {
    return {
      'operationId': operationId,
      'passed': passed,
      'totalRequests': allRequests.length,
      'suspiciousRequests': suspiciousRequests.length,
      'duration': duration.inMilliseconds,
      'requests': allRequests.map((r) => r.toMap()).toList(),
    };
  }
}

/// Service for monitoring network requests during PDF operations
///
/// Verifies the "100% local processing" claim by tracking all
/// network activity and flagging suspicious requests.
class NetworkVerificationService extends ChangeNotifier {
  final Map<String, List<NetworkRequest>> _requestsByOperation = {};
  final Map<String, DateTime> _operationStartTimes = {};
  bool _isMonitoring = false;

  /// Check if monitoring is active
  bool get isMonitoring => _isMonitoring;

  /// Start monitoring network requests for an operation
  void startMonitoring(String operationId) {
    if (!Environment.enableNetworkVerification) {
      return; // Feature disabled
    }

    _requestsByOperation[operationId] = [];
    _operationStartTimes[operationId] = DateTime.now();
    _isMonitoring = true;

    if (Environment.enableDebugLogging) {
      print('[NetworkVerification] Started monitoring: $operationId');
    }

    notifyListeners();
  }

  /// Stop monitoring and return report
  NetworkVerificationReport stopMonitoring(String operationId) {
    final requests = _requestsByOperation[operationId] ?? [];
    final startTime = _operationStartTimes[operationId] ?? DateTime.now();
    final endTime = DateTime.now();

    // Find suspicious requests
    final suspicious = requests.where((req) => req.isSuspicious).toList();

    final report = NetworkVerificationReport(
      operationId: operationId,
      allRequests: requests,
      suspiciousRequests: suspicious,
      startTime: startTime,
      endTime: endTime,
    );

    // Clean up
    _requestsByOperation.remove(operationId);
    _operationStartTimes.remove(operationId);

    if (_requestsByOperation.isEmpty) {
      _isMonitoring = false;
    }

    if (Environment.enableDebugLogging) {
      print('[NetworkVerification] Stopped monitoring: $operationId');
      print('  Total requests: ${requests.length}');
      print('  Suspicious: ${suspicious.length}');
      print('  Status: ${report.passed ? "PASSED" : "FAILED"}');

      if (suspicious.isNotEmpty) {
        print('  Suspicious requests:');
        for (final req in suspicious) {
          print('    - ${req.method} ${req.url}');
        }
      }
    }

    notifyListeners();
    return report;
  }

  /// Log a network request (called by monitoring code)
  void logRequest({
    required String url,
    required String method,
    String? operationId,
  }) {
    if (!Environment.enableNetworkVerification) {
      return;
    }

    final request = NetworkRequest(
      url: url,
      method: method,
      timestamp: DateTime.now(),
      operationId: operationId,
    );

    // Add to all active operations
    if (operationId != null && _requestsByOperation.containsKey(operationId)) {
      _requestsByOperation[operationId]!.add(request);
    } else {
      // Add to all active operations if no specific operation ID
      for (final operations in _requestsByOperation.values) {
        operations.add(request);
      }
    }

    if (Environment.enableDebugLogging && request.isSuspicious) {
      print('[NetworkVerification] ⚠️ SUSPICIOUS REQUEST: ${request.method} ${request.url}');
    }

    notifyListeners();
  }

  /// Get all requests for an operation
  List<NetworkRequest> getOperationRequests(String operationId) {
    return List.unmodifiable(_requestsByOperation[operationId] ?? []);
  }

  /// Get active operations being monitored
  List<String> get activeOperations =>
      List.unmodifiable(_requestsByOperation.keys);

  /// Clear all monitoring data
  void clearAll() {
    _requestsByOperation.clear();
    _operationStartTimes.clear();
    _isMonitoring = false;

    if (Environment.enableDebugLogging) {
      print('[NetworkVerification] Cleared all monitoring data');
    }

    notifyListeners();
  }

  @override
  void dispose() {
    if (Environment.enableDebugLogging) {
      print('[NetworkVerification] Service disposed');
    }
    clearAll();
    super.dispose();
  }
}

/// Web-based network interceptor
class NetworkInterceptor {
  static void setupInterceptor(NetworkVerificationService service) {
    if (!kIsWeb) return;

    // Setup JavaScript-to-Dart channel using dart:js
    final channel = _NetworkVerificationChannel(service);
    js.context['networkVerificationChannel'] = js.JsObject.jsify({
      'logRequest': channel.logRequest,
    });

    if (Environment.enableDebugLogging) {
      print('[NetworkInterceptor] Setup complete');
      print('  Whitelisted domains: ${Environment.whitelistedDomains.join(", ")}');
    }
  }
}

/// JavaScript-to-Dart communication channel
class _NetworkVerificationChannel {
  final NetworkVerificationService _service;

  _NetworkVerificationChannel(this._service);

  /// Called from JavaScript to log network requests
  void logRequest(String url, String method) {
    _service.logRequest(url: url, method: method);
  }
}
