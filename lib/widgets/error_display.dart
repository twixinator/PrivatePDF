import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/error_action.dart';

/// Widget for displaying enhanced error messages with recovery actions
///
/// Provides a user-friendly error UI with:
/// - Clear title and message
/// - Severity-based styling
/// - Actionable buttons for recovery
/// - Optional technical details
class ErrorDisplayWidget extends StatelessWidget {
  final EnhancedErrorMessage errorMessage;
  final VoidCallback? onDismiss;

  const ErrorDisplayWidget({
    super.key,
    required this.errorMessage,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severityColor = errorMessage.getSeverityColor(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: severityColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon and title
            Row(
              children: [
                Icon(
                  errorMessage.getIcon(),
                  color: severityColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: severityColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // User message
            Text(
              errorMessage.userMessage,
              style: theme.textTheme.bodyLarge,
            ),

            // Technical details (if available)
            if (errorMessage.technicalDetails != null) ...[
              const SizedBox(height: 12),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(
                  'Technische Details',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      errorMessage.technicalDetails!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Action buttons
            if (errorMessage.suggestedActions.isNotEmpty) ...[
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: errorMessage.suggestedActions
                    .map((action) => _buildActionButton(context, action))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build an action button
  Widget _buildActionButton(BuildContext context, ErrorAction action) {
    return ElevatedButton.icon(
      onPressed: () => _handleAction(context, action),
      icon: action.icon != null ? Icon(action.icon, size: 18) : const SizedBox.shrink(),
      label: Text(action.label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  /// Handle action button press
  void _handleAction(BuildContext context, ErrorAction action) {
    switch (action.type) {
      case ErrorActionType.navigateRoute:
        if (action.route != null) {
          context.go(action.route!);
        }
        break;

      case ErrorActionType.retryOperation:
        action.onTap?.call();
        onDismiss?.call();
        break;

      case ErrorActionType.documentation:
        if (action.documentationUrl != null) {
          _launchUrl(action.documentationUrl!);
        }
        break;

      case ErrorActionType.dismiss:
        action.onTap?.call();
        onDismiss?.call();
        break;

      case ErrorActionType.custom:
        action.onTap?.call();
        break;
    }
  }

  /// Launch external URL
  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}

/// Compact error display for inline use
class CompactErrorDisplay extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Color? color;

  const CompactErrorDisplay({
    super.key,
    required this.message,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = color ?? theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: errorColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.error_outline,
            color: errorColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Error display with retry button (common pattern)
class RetryableErrorDisplay extends StatelessWidget {
  final EnhancedErrorMessage errorMessage;
  final VoidCallback onRetry;
  final VoidCallback? onDismiss;

  const RetryableErrorDisplay({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    // Add retry action if not already present
    final hasRetryAction = errorMessage.suggestedActions.any(
      (action) => action.type == ErrorActionType.retryOperation,
    );

    final enhancedMessage = hasRetryAction
        ? errorMessage
        : EnhancedErrorMessage(
            title: errorMessage.title,
            userMessage: errorMessage.userMessage,
            severity: errorMessage.severity,
            suggestedActions: [
              ErrorAction.retry(
                label: 'Erneut versuchen',
                onRetry: onRetry,
              ),
              ...errorMessage.suggestedActions,
            ],
            technicalDetails: errorMessage.technicalDetails,
            icon: errorMessage.icon,
          );

    return ErrorDisplayWidget(
      errorMessage: enhancedMessage,
      onDismiss: onDismiss,
    );
  }
}
