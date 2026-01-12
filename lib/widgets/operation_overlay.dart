import 'package:flutter/material.dart';
import '../providers/pdf_operation_state.dart';
import '../providers/pdf_operation_provider.dart';
import '../theme/app_theme.dart';
import '../constants/strings.dart';
import '../animations/loading_spinner.dart';
import '../animations/success_checkmark.dart';

/// Overlay widget for showing PDF operation status
/// Displays processing, success, and error states
class OperationOverlay extends StatelessWidget {
  final PdfOperationState state;
  final PdfOperationProvider? provider;

  const OperationOverlay({
    super.key,
    required this.state,
    this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return state.when(
      idle: () => const SizedBox.shrink(),
      processing: () => _ProcessingOverlay(provider: provider),
      success: (fileName) => _SuccessOverlay(fileName: fileName),
      error: (error) => _ErrorOverlay(error: error),
    );
  }
}

/// Processing overlay with spinner
class _ProcessingOverlay extends StatelessWidget {
  final PdfOperationProvider? provider;

  const _ProcessingOverlay({this.provider});

  @override
  Widget build(BuildContext context) {
    final queuePosition = provider?.queuePosition;
    final canCancel = provider?.canCancel ?? false;

    return _BaseOverlay(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Custom loading spinner
          const LoadingSpinner(
            size: 60,
            color: AppTheme.primary,
          ),
          SizedBox(height: Spacing.lg),

          // Main message
          Text(
            Strings.processingPdf,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),

          SizedBox(height: Spacing.sm),

          // Queue position (if available)
          if (queuePosition != null && queuePosition > 0)
            Text(
              '${Strings.queuePosition} $queuePosition',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                  ),
            )
          else
            Text(
              Strings.pleaseWait,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),

          // Cancel button (if cancellable)
          if (canCancel) ...[
            SizedBox(height: Spacing.lg),
            OutlinedButton.icon(
              onPressed: () {
                provider?.cancelCurrentOperation();
              },
              icon: const Icon(Icons.close, size: 18),
              label: Text(Strings.buttonCancel),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.error,
                side: BorderSide(color: AppTheme.error.withOpacity(0.5)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Success overlay with checkmark
class _SuccessOverlay extends StatelessWidget {
  final String fileName;

  const _SuccessOverlay({required this.fileName});

  @override
  Widget build(BuildContext context) {
    return _BaseOverlay(
      backgroundColor: Colors.black54,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated success checkmark
          SuccessCheckmark(
            size: 80,
            color: Colors.white,
            backgroundColor: AppTheme.success,
          ),

          SizedBox(height: Spacing.lg),

          Text(
            Strings.successTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),

          SizedBox(height: Spacing.md),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              fileName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: Spacing.md),

          Text(
            Strings.downloadStarted,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }
}

/// Error overlay with error message
class _ErrorOverlay extends StatelessWidget {
  final dynamic error;

  const _ErrorOverlay({required this.error});

  @override
  Widget build(BuildContext context) {
    final errorMessage = error.message ?? 'Ein Fehler ist aufgetreten';

    return _BaseOverlay(
      backgroundColor: Colors.black54,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.error,
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.white,
            ),
          ),

          SizedBox(height: Spacing.lg),

          Text(
            Strings.errorTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),

          SizedBox(height: Spacing.md),

          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.md,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: Spacing.lg),

          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
            ),
            child: Text(Strings.buttonClose),
          ),
        ],
      ),
    );
  }
}

/// Base overlay container
class _BaseOverlay extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const _BaseOverlay({
    required this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.black38,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(Spacing.xxl),
            constraints: const BoxConstraints(maxWidth: 500),
            child: child,
          ),
        ),
      ),
    );
  }
}
