import 'package:flutter/material.dart';

/// Types of actions that can be taken in response to an error
enum ErrorActionType {
  /// Navigate to a specific route (e.g., /pricing)
  navigateRoute,

  /// Retry the failed operation
  retryOperation,

  /// Open external documentation or help page
  documentation,

  /// Dismiss the error message
  dismiss,

  /// Custom action with user-defined callback
  custom,
}

/// Severity levels for errors
enum ErrorSeverity {
  /// Critical error that prevents the operation from completing
  critical,

  /// Warning that the user should be aware of
  warning,

  /// Informational message
  info,
}

/// Represents an action the user can take in response to an error
class ErrorAction {
  final String label;
  final ErrorActionType type;
  final VoidCallback? onTap;
  final String? route;
  final String? documentationUrl;
  final IconData? icon;

  const ErrorAction({
    required this.label,
    required this.type,
    this.onTap,
    this.route,
    this.documentationUrl,
    this.icon,
  });

  /// Create a "navigate to route" action
  factory ErrorAction.navigateRoute({
    required String label,
    required String route,
    IconData? icon,
  }) {
    return ErrorAction(
      label: label,
      type: ErrorActionType.navigateRoute,
      route: route,
      icon: icon ?? Icons.arrow_forward,
    );
  }

  /// Create a "retry operation" action
  factory ErrorAction.retry({
    required String label,
    required VoidCallback onRetry,
    IconData? icon,
  }) {
    return ErrorAction(
      label: label,
      type: ErrorActionType.retryOperation,
      onTap: onRetry,
      icon: icon ?? Icons.refresh,
    );
  }

  /// Create a "open documentation" action
  factory ErrorAction.documentation({
    required String label,
    required String url,
    IconData? icon,
  }) {
    return ErrorAction(
      label: label,
      type: ErrorActionType.documentation,
      documentationUrl: url,
      icon: icon ?? Icons.help_outline,
    );
  }

  /// Create a "dismiss" action
  factory ErrorAction.dismiss({
    String label = 'Schließen',
    VoidCallback? onDismiss,
    IconData? icon,
  }) {
    return ErrorAction(
      label: label,
      type: ErrorActionType.dismiss,
      onTap: onDismiss,
      icon: icon ?? Icons.close,
    );
  }

  /// Create a custom action
  factory ErrorAction.custom({
    required String label,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return ErrorAction(
      label: label,
      type: ErrorActionType.custom,
      onTap: onTap,
      icon: icon,
    );
  }
}

/// Enhanced error message with recovery actions
class EnhancedErrorMessage {
  final String title;
  final String userMessage;
  final ErrorSeverity severity;
  final List<ErrorAction> suggestedActions;
  final String? technicalDetails;
  final IconData? icon;

  const EnhancedErrorMessage({
    required this.title,
    required this.userMessage,
    this.severity = ErrorSeverity.critical,
    this.suggestedActions = const [],
    this.technicalDetails,
    this.icon,
  });

  /// Create a file size limit error
  factory EnhancedErrorMessage.fileSizeLimit({
    required double fileSizeMB,
    required double limitMB,
    required List<ErrorAction> actions,
  }) {
    return EnhancedErrorMessage(
      title: 'Datei zu groß (${fileSizeMB.toStringAsFixed(1)} MB)',
      userMessage:
          'Die maximale Größe für den kostenlosen Plan beträgt ${limitMB.toStringAsFixed(0)} MB. '
          'Bitte verwenden Sie eine kleinere Datei oder upgraden Sie auf den Pro-Plan für größere Dateien.',
      severity: ErrorSeverity.warning,
      suggestedActions: actions,
      icon: Icons.warning_amber_rounded,
    );
  }

  /// Create an invalid file error
  factory EnhancedErrorMessage.invalidFile({
    required String fileName,
    required List<ErrorAction> actions,
    String? reason,
  }) {
    return EnhancedErrorMessage(
      title: 'Ungültige PDF-Datei',
      userMessage:
          'Die Datei "$fileName" konnte nicht verarbeitet werden. '
          '${reason ?? "Stellen Sie sicher, dass es sich um eine gültige PDF-Datei handelt."}',
      severity: ErrorSeverity.critical,
      suggestedActions: actions,
      icon: Icons.error_outline,
    );
  }

  /// Create a processing error
  factory EnhancedErrorMessage.processingError({
    required String operationType,
    required List<ErrorAction> actions,
    String? details,
  }) {
    return EnhancedErrorMessage(
      title: 'Verarbeitung fehlgeschlagen',
      userMessage:
          'Die $operationType-Operation konnte nicht abgeschlossen werden. '
          'Bitte versuchen Sie es erneut oder verwenden Sie eine andere Datei.',
      severity: ErrorSeverity.critical,
      suggestedActions: actions,
      technicalDetails: details,
      icon: Icons.error_outline,
    );
  }

  /// Create a password validation error
  factory EnhancedErrorMessage.passwordValidation({
    required String reason,
    required List<ErrorAction> actions,
  }) {
    return EnhancedErrorMessage(
      title: 'Ungültiges Passwort',
      userMessage: reason,
      severity: ErrorSeverity.warning,
      suggestedActions: actions,
      icon: Icons.lock_outline,
    );
  }

  /// Create a page range validation error
  factory EnhancedErrorMessage.pageRangeValidation({
    required String reason,
    required List<ErrorAction> actions,
  }) {
    return EnhancedErrorMessage(
      title: 'Ungültiger Seitenbereich',
      userMessage: reason,
      severity: ErrorSeverity.warning,
      suggestedActions: actions,
      icon: Icons.pages,
    );
  }

  /// Get color based on severity
  Color getSeverityColor(BuildContext context) {
    switch (severity) {
      case ErrorSeverity.critical:
        return Theme.of(context).colorScheme.error;
      case ErrorSeverity.warning:
        return Colors.orange;
      case ErrorSeverity.info:
        return Theme.of(context).colorScheme.primary;
    }
  }

  /// Get icon for this error
  IconData getIcon() {
    if (icon != null) return icon!;

    switch (severity) {
      case ErrorSeverity.critical:
        return Icons.error_outline;
      case ErrorSeverity.warning:
        return Icons.warning_amber_rounded;
      case ErrorSeverity.info:
        return Icons.info_outline;
    }
  }
}
