import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'animation_constants.dart';

/// Custom loading spinner with pulse animation
///
/// Features:
/// - 360° rotation (2000ms linear)
/// - Scale pulse 1.0 → 1.08 → 1.0
/// - Smooth continuous animation
/// - Editorial sophistication (not flashy)
class LoadingSpinner extends StatefulWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const LoadingSpinner({
    super.key,
    this.size = 48.0,
    this.color,
    this.strokeWidth = 3.0,
  });

  @override
  State<LoadingSpinner> createState() => _LoadingSpinnerState();
}

class _LoadingSpinnerState extends State<LoadingSpinner>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Rotation animation (continuous)
    _rotationController = AnimationController(
      duration: AnimationConstants.durationSpinner,
      vsync: this,
    )..repeat();

    // Pulse animation (continuous)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: AnimationConstants.spinnerPulseFrom,
      end: AnimationConstants.spinnerPulseTo,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spinnerColor = widget.color ?? theme.colorScheme.primary;

    return RepaintBoundary(
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: RotationTransition(
          turns: _rotationController,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _SpinnerPainter(
              color: spinnerColor,
              strokeWidth: widget.strokeWidth,
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for spinner arc
class _SpinnerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _SpinnerPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw arc (270° for editorial look)
    const startAngle = -math.pi / 2; // Start at top
    const sweepAngle = math.pi * 1.5; // 270° arc

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Compact loading spinner (for inline use)
class CompactLoadingSpinner extends StatelessWidget {
  final double size;
  final Color? color;

  const CompactLoadingSpinner({
    super.key,
    this.size = 20.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: color != null
            ? AlwaysStoppedAnimation<Color>(color!)
            : null,
      ),
    );
  }
}

/// Loading overlay with spinner and message
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final double spinnerSize;

  const LoadingOverlay({
    super.key,
    this.message,
    this.spinnerSize = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LoadingSpinner(size: spinnerSize),
                if (message != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    message!,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Inline loading indicator (for buttons, etc.)
class InlineLoadingIndicator extends StatelessWidget {
  final String text;
  final double spinnerSize;

  const InlineLoadingIndicator({
    super.key,
    required this.text,
    this.spinnerSize = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CompactLoadingSpinner(size: spinnerSize),
        const SizedBox(width: 12),
        Text(text),
      ],
    );
  }
}
