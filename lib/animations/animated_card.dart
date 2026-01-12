import 'package:flutter/material.dart';
import 'animation_constants.dart';

/// Animated card with hover effects
///
/// Features:
/// - Scale animation (1.0 → 1.02 on hover)
/// - Border color transition
/// - Shadow elevation increase (12px → 24px)
/// - GPU-accelerated (Transform + BoxShadow)
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? hoverBorderColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderColor,
    this.hoverBorderColor,
    this.borderRadius = 12.0,
    this.padding,
    this.backgroundColor,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBorderColor = theme.colorScheme.outline.withOpacity(0.2);
    final defaultHoverBorderColor = theme.colorScheme.primary.withOpacity(0.5);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: RepaintBoundary(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 1.0,
              end: _isHovered ? AnimationConstants.hoverScale : 1.0,
            ),
            duration: AnimationConstants.durationStandard,
            curve: AnimationConstants.easeOutQuick,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: AnimationConstants.hoverShadowFrom,
                end: _isHovered
                    ? AnimationConstants.hoverShadowTo
                    : AnimationConstants.hoverShadowFrom,
              ),
              duration: AnimationConstants.durationStandard,
              curve: AnimationConstants.easeOutQuick,
              builder: (context, elevation, child) {
                return AnimatedContainer(
                  duration: AnimationConstants.durationStandard,
                  curve: AnimationConstants.easeOutQuick,
                  padding: widget.padding ?? const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? theme.cardColor,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: Border.all(
                      color: _isHovered
                          ? (widget.hoverBorderColor ?? defaultHoverBorderColor)
                          : (widget.borderColor ?? defaultBorderColor),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: elevation,
                        offset: Offset(0, elevation / 4),
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Simplified animated card for less interactive elements
class SimpleAnimatedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double borderRadius;

  const SimpleAnimatedCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: padding ?? const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
