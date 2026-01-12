import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/strings.dart';
import '../theme/app_theme.dart';

/// Full-screen overlay for processing states
class ProcessingOverlay extends StatelessWidget {
  final double? progress;

  const ProcessingOverlay({
    super.key,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background.withOpacity(0.95),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(Spacing.xxxl),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: Border.all(color: AppTheme.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated spinner
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  backgroundColor: AppTheme.border,
                ),
              ),

              SizedBox(height: Spacing.xl),

              Text(
                Strings.processingTitle,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: Spacing.md),

              Text(
                Strings.processingMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),

              if (progress != null) ...[
                SizedBox(height: Spacing.lg),
                Text(
                  '${(progress! * 100).toInt()}%',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.primary,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Show processing overlay
  static void show(BuildContext context, {double? progress}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => ProcessingOverlay(progress: progress),
    );
  }

  /// Hide processing overlay
  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}

/// Success state with auto-dismiss
class SuccessOverlay extends StatefulWidget {
  final VoidCallback? onNewFile;

  const SuccessOverlay({
    super.key,
    this.onNewFile,
  });

  @override
  State<SuccessOverlay> createState() => _SuccessOverlayState();
}

class _SuccessOverlayState extends State<SuccessOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Auto-dismiss after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: AppTheme.background.withOpacity(0.95),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(Spacing.xxxl),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border.all(color: AppTheme.success.withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.success.withOpacity(0.1),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: AppTheme.success,
                    ),
                  ),

                  SizedBox(height: Spacing.xl),

                  Text(
                    Strings.successTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppTheme.success,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: Spacing.md),

                  Text(
                    Strings.successMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  if (widget.onNewFile != null) ...[
                    SizedBox(height: Spacing.xl),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onNewFile!();
                      },
                      child: const Text(Strings.successNewFile),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Show success overlay
  static void show(BuildContext context, {VoidCallback? onNewFile}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (context) => SuccessOverlay(onNewFile: onNewFile),
    );
  }
}

/// Error banner for inline errors
class ErrorBanner extends StatefulWidget {
  final String message;
  final VoidCallback? onDismiss;
  final bool autoDismiss;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.autoDismiss = true,
  });

  @override
  State<ErrorBanner> createState() => _ErrorBannerState();
}

class _ErrorBannerState extends State<ErrorBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    if (widget.autoDismiss) {
      Timer(const Duration(seconds: 10), _dismiss);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (!mounted) return;

    _controller.reverse().then((_) {
      if (mounted) {
        setState(() => _isVisible = false);
        widget.onDismiss?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.all(Spacing.md),
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.1),
          border: Border.all(color: AppTheme.error, width: 1),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: AppTheme.error,
              size: 24,
            ),
            SizedBox(width: Spacing.md),
            Expanded(
              child: Text(
                widget.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              onPressed: _dismiss,
              icon: const Icon(Icons.close, size: 20),
              color: AppTheme.error,
              tooltip: Strings.buttonDismiss,
            ),
          ],
        ),
      ),
    );
  }
}

/// Show error snackbar
void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 20,
          ),
          SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppTheme.error,
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      margin: const EdgeInsets.all(Spacing.md),
      duration: const Duration(seconds: 6),
      action: SnackBarAction(
        label: Strings.buttonDismiss,
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}
