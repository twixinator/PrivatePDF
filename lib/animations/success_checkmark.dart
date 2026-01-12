import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'animation_constants.dart';

/// Animated success checkmark with draw effect
///
/// Features:
/// - Scale animation 0 → 1.2 → 1.0 (elastic bounce)
/// - Stroke draw animation
/// - Circle background pulse
/// - 600ms duration with smooth easing
class SuccessCheckmark extends StatefulWidget {
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final Duration duration;
  final VoidCallback? onComplete;

  const SuccessCheckmark({
    super.key,
    this.size = 80.0,
    this.color,
    this.backgroundColor,
    this.duration = AnimationConstants.durationSlow,
    this.onComplete,
  });

  @override
  State<SuccessCheckmark> createState() => _SuccessCheckmarkState();
}

class _SuccessCheckmarkState extends State<SuccessCheckmark>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _drawController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _drawAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation with elastic bounce
    _scaleController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: AnimationConstants.checkmarkScaleFrom,
          end: AnimationConstants.checkmarkScalePeak,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: AnimationConstants.checkmarkScalePeak,
          end: AnimationConstants.checkmarkScaleTo,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_scaleController);

    // Draw animation for checkmark stroke
    _drawController = AnimationController(
      duration: Duration(
        milliseconds: (widget.duration.inMilliseconds * 0.7).round(),
      ),
      vsync: this,
    );

    _drawAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _drawController,
        curve: Curves.easeOut,
      ),
    );

    // Start animations
    _scaleController.forward();
    _drawController.forward();

    // Notify on complete
    _scaleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _drawController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final checkmarkColor = widget.color ?? Colors.white;
    final bgColor = widget.backgroundColor ?? theme.colorScheme.primary;

    return RepaintBoundary(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: bgColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: _drawAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.size * 0.5, widget.size * 0.5),
                  painter: _CheckmarkPainter(
                    progress: _drawAnimation.value,
                    color: checkmarkColor,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for animated checkmark
class _CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CheckmarkPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // Checkmark proportions
    final width = size.width;
    final height = size.height;

    // Start point (bottom-left of checkmark)
    final startX = width * 0.2;
    final startY = height * 0.5;

    // Middle point (bottom of checkmark)
    final midX = width * 0.45;
    final midY = height * 0.75;

    // End point (top-right of checkmark)
    final endX = width * 0.9;
    final endY = height * 0.25;

    // Draw checkmark with progress
    path.moveTo(startX, startY);

    if (progress <= 0.5) {
      // Draw first segment (to middle point)
      final segmentProgress = progress / 0.5;
      final currentX = startX + (midX - startX) * segmentProgress;
      final currentY = startY + (midY - startY) * segmentProgress;
      path.lineTo(currentX, currentY);
    } else {
      // Draw first segment completely
      path.lineTo(midX, midY);

      // Draw second segment (to end point)
      final segmentProgress = (progress - 0.5) / 0.5;
      final currentX = midX + (endX - midX) * segmentProgress;
      final currentY = midY + (endY - midY) * segmentProgress;
      path.lineTo(currentX, currentY);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Compact success checkmark (for inline use)
class CompactSuccessCheckmark extends StatelessWidget {
  final double size;
  final Color? color;

  const CompactSuccessCheckmark({
    super.key,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final checkmarkColor = color ?? theme.colorScheme.primary;

    return Icon(
      Icons.check_circle,
      size: size,
      color: checkmarkColor,
    );
  }
}
