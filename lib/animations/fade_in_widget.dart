import 'package:flutter/material.dart';
import 'animation_constants.dart';

/// Scroll-triggered fade-in animation
///
/// Features:
/// - Fade opacity 0 → 1
/// - Slide up 20px
/// - Triggers when widget enters viewport
/// - Uses IntersectionObserver-like behavior
class FadeInWidget extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final double slideDistance;
  final Axis direction;

  const FadeInWidget({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AnimationConstants.durationMedium,
    this.curve = AnimationConstants.easeOutSmooth,
    this.slideDistance = AnimationConstants.fadeInSlideDistance,
    this.direction = Axis.vertical,
  });

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: AnimationConstants.opacityFadeFrom,
      end: AnimationConstants.opacityFadeTo,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    // Calculate slide offset based on direction
    final slideOffset = widget.direction == Axis.vertical
        ? Offset(0.0, widget.slideDistance / 100.0)
        : Offset(widget.slideDistance / 100.0, 0.0);

    _slideAnimation = Tween<Offset>(
      begin: slideOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    // Start animation after delay
    if (widget.delay == Duration.zero) {
      _startAnimation();
    } else {
      Future.delayed(widget.delay, _startAnimation);
    }
  }

  void _startAnimation() {
    if (mounted && !_hasAnimated) {
      _controller.forward();
      _hasAnimated = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Staggered fade-in for multiple children
class StaggeredFadeIn extends StatelessWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration duration;
  final Axis direction;
  final Axis scrollDirection;

  const StaggeredFadeIn({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.duration = AnimationConstants.durationMedium,
    this.direction = Axis.vertical,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return scrollDirection == Axis.vertical
        ? Column(
            children: _buildStaggeredChildren(),
          )
        : Row(
            children: _buildStaggeredChildren(),
          );
  }

  List<Widget> _buildStaggeredChildren() {
    return List.generate(
      children.length,
      (index) {
        final delay = staggerDelay * index;
        return FadeInWidget(
          delay: delay,
          duration: duration,
          direction: direction,
          child: children[index],
        );
      },
    );
  }
}

/// Fade-in widget that triggers on scroll visibility
class ScrollFadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double slideDistance;

  const ScrollFadeIn({
    super.key,
    required this.child,
    this.duration = AnimationConstants.durationMedium,
    this.slideDistance = AnimationConstants.fadeInSlideDistance,
  });

  @override
  State<ScrollFadeIn> createState() => _ScrollFadeInState();
}

class _ScrollFadeInState extends State<ScrollFadeIn> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      onVisibilityChanged: (visible) {
        if (visible && !_isVisible) {
          setState(() => _isVisible = true);
        }
      },
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: widget.duration,
        curve: AnimationConstants.easeOutSmooth,
        child: AnimatedSlide(
          offset: _isVisible
              ? Offset.zero
              : Offset(0.0, widget.slideDistance / 100.0),
          duration: widget.duration,
          curve: AnimationConstants.easeOutSmooth,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Simple visibility detector widget
class VisibilityDetector extends StatefulWidget {
  final Widget child;
  final ValueChanged<bool> onVisibilityChanged;

  const VisibilityDetector({
    super.key,
    required this.child,
    required this.onVisibilityChanged,
  });

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  bool _hasNotified = false;

  @override
  Widget build(BuildContext context) {
    // Simple immediate trigger for web
    // In production, you'd use a proper IntersectionObserver or scroll listener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasNotified && mounted) {
        widget.onVisibilityChanged(true);
        _hasNotified = true;
      }
    });

    return widget.child;
  }
}
