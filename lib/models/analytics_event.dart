/// Categories for analytics events
enum AnalyticsEventCategory {
  pdfOperation,
  pageView,
  userAction,
  error,
  upgrade,
}

/// Analytics event model for localStorage-based tracking
///
/// This model represents an event that will be stored in localStorage
/// for privacy-first, client-side analytics tracking.
class AnalyticsEvent {
  final String eventName;
  final AnalyticsEventCategory category;
  final DateTime timestamp;
  final Map<String, dynamic> properties;

  AnalyticsEvent({
    required this.eventName,
    required this.category,
    DateTime? timestamp,
    Map<String, dynamic>? properties,
  })  : timestamp = timestamp ?? DateTime.now(),
        properties = properties ?? {};

  /// Create an event for a successful PDF operation
  factory AnalyticsEvent.pdfOperationSuccess({
    required String operationType,
    required int fileCount,
    required int durationMs,
    int? outputSizeBytes,
    String? fileSizeCategory,
  }) {
    return AnalyticsEvent(
      eventName: 'pdf_${operationType}_success',
      category: AnalyticsEventCategory.pdfOperation,
      properties: {
        'operationType': operationType,
        'fileCount': fileCount,
        'durationMs': durationMs,
        if (outputSizeBytes != null) 'outputSizeBytes': outputSizeBytes,
        if (fileSizeCategory != null) 'fileSizeCategory': fileSizeCategory,
      },
    );
  }

  /// Create an event for a failed PDF operation
  factory AnalyticsEvent.pdfOperationError({
    required String operationType,
    required String errorCode,
    String? errorMessage,
    int? fileCount,
  }) {
    return AnalyticsEvent(
      eventName: 'pdf_${operationType}_error',
      category: AnalyticsEventCategory.error,
      properties: {
        'operationType': operationType,
        'errorCode': errorCode,
        if (errorMessage != null) 'errorMessage': errorMessage,
        if (fileCount != null) 'fileCount': fileCount,
      },
    );
  }

  /// Create an event for page view
  factory AnalyticsEvent.pageView({
    required String pageName,
    String? referrer,
  }) {
    return AnalyticsEvent(
      eventName: 'page_view',
      category: AnalyticsEventCategory.pageView,
      properties: {
        'pageName': pageName,
        if (referrer != null) 'referrer': referrer,
      },
    );
  }

  /// Create an event for upgrade action
  factory AnalyticsEvent.upgradeClicked({
    required String source,
    String? reason,
  }) {
    return AnalyticsEvent(
      eventName: 'upgrade_clicked',
      category: AnalyticsEventCategory.upgrade,
      properties: {
        'source': source,
        if (reason != null) 'reason': reason,
      },
    );
  }

  /// Create an event for file size limit hit
  factory AnalyticsEvent.fileSizeLimitHit({
    required int fileSizeBytes,
    required int limitBytes,
    String? operationType,
  }) {
    return AnalyticsEvent(
      eventName: 'file_size_limit_hit',
      category: AnalyticsEventCategory.error,
      properties: {
        'fileSizeBytes': fileSizeBytes,
        'limitBytes': limitBytes,
        'fileSizeMB': (fileSizeBytes / 1024 / 1024).toStringAsFixed(2),
        'limitMB': (limitBytes / 1024 / 1024).toStringAsFixed(0),
        if (operationType != null) 'operationType': operationType,
      },
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'eventName': eventName,
      'category': category.name,
      'timestamp': timestamp.toIso8601String(),
      'properties': properties,
    };
  }

  /// Create from JSON
  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return AnalyticsEvent(
      eventName: json['eventName'] as String,
      category: AnalyticsEventCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => AnalyticsEventCategory.userAction,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      properties: Map<String, dynamic>.from(json['properties'] as Map),
    );
  }

  /// Get a human-readable description of this event
  String get description {
    switch (category) {
      case AnalyticsEventCategory.pdfOperation:
        return 'PDF Operation: $eventName';
      case AnalyticsEventCategory.pageView:
        return 'Page View: ${properties['pageName'] ?? 'Unknown'}';
      case AnalyticsEventCategory.userAction:
        return 'User Action: $eventName';
      case AnalyticsEventCategory.error:
        return 'Error: $eventName';
      case AnalyticsEventCategory.upgrade:
        return 'Upgrade: $eventName';
    }
  }

  /// Get file size category string for analytics
  static String getFileSizeCategory(int bytes) {
    final mb = bytes / 1024 / 1024;
    if (mb < 1) return '<1MB';
    if (mb < 5) return '1-5MB';
    if (mb < 10) return '5-10MB';
    if (mb < 50) return '10-50MB';
    if (mb < 100) return '50-100MB';
    return '>100MB';
  }

  @override
  String toString() => 'AnalyticsEvent($eventName, category: ${category.name}, timestamp: $timestamp)';
}
