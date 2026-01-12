import 'package:flutter/material.dart';
import 'animation_constants.dart';

/// Extension methods for creating reusable animation builders
extension AnimationControllerX on AnimationController {
  /// Create a curved animation
  Animation<double> curved(Curve curve) {
    return CurvedAnimation(
      parent: this,
      curve: curve,
    );
  }

  /// Create a tween animation
  Animation<T> tween<T>(Tween<T> tween, {Curve? curve}) {
    if (curve != null) {
      return tween.animate(curved(curve));
    }
    return tween.animate(this);
  }

  /// Create a fade animation (0.0 to 1.0)
  Animation<double> fade({Curve? curve}) {
    return tween(
      Tween<double>(
        begin: AnimationConstants.opacityFadeFrom,
        end: AnimationConstants.opacityFadeTo,
      ),
      curve: curve ?? AnimationConstants.easeOutSmooth,
    );
  }

  /// Create a scale animation
  Animation<double> scale({
    double from = 0.0,
    double to = 1.0,
    Curve? curve,
  }) {
    return tween(
      Tween<double>(begin: from, end: to),
      curve: curve ?? AnimationConstants.easeOutQuick,
    );
  }

  /// Create a slide animation
  Animation<Offset> slide({
    required Offset begin,
    Offset end = Offset.zero,
    Curve? curve,
  }) {
    return tween(
      Tween<Offset>(begin: begin, end: end),
      curve: curve ?? AnimationConstants.easeOutSmooth,
    );
  }
}

/// Extension methods for widget animations
extension WidgetAnimationX on Widget {
  /// Wrap with fade transition
  Widget fadeTransition(Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: this,
    );
  }

  /// Wrap with scale transition
  Widget scaleTransition(Animation<double> animation) {
    return ScaleTransition(
      scale: animation,
      child: this,
    );
  }

  /// Wrap with slide transition
  Widget slideTransition(Animation<Offset> animation) {
    return SlideTransition(
      position: animation,
      child: this,
    );
  }

  /// Wrap with combined fade + slide transition
  Widget fadeAndSlide({
    required Animation<double> opacity,
    required Animation<Offset> position,
  }) {
    return SlideTransition(
      position: position,
      child: FadeTransition(
        opacity: opacity,
        child: this,
      ),
    );
  }

  /// Wrap with RepaintBoundary (optimization)
  Widget repaintBoundary() {
    return RepaintBoundary(child: this);
  }
}

/// Animation builder helpers
class AnimationBuilders {
  AnimationBuilders._(); // Private constructor

  /// Build a fade-in animation
  static Widget fadeIn({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  /// Build a scale animation
  static Widget scale({
    required Animation<double> animation,
    required Widget child,
    Alignment alignment = Alignment.center,
  }) {
    return ScaleTransition(
      scale: animation,
      alignment: alignment,
      child: child,
    );
  }

  /// Build a slide-up animation
  static Widget slideUp({
    required Animation<double> animation,
    required Widget child,
    double distance = AnimationConstants.fadeInSlideDistance,
  }) {
    final offsetAnimation = Tween<Offset>(
      begin: Offset(0.0, distance / 100.0),
      end: Offset.zero,
    ).animate(animation);

    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }

  /// Build a combined fade + slide up animation
  static Widget fadeAndSlideUp({
    required Animation<double> animation,
    required Widget child,
    double distance = AnimationConstants.fadeInSlideDistance,
  }) {
    return FadeTransition(
      opacity: animation,
      child: slideUp(
        animation: animation,
        child: child,
        distance: distance,
      ),
    );
  }

  /// Build a hover scale animation
  static Widget hoverScale({
    required bool isHovered,
    required Widget child,
    double scale = AnimationConstants.hoverScale,
    Duration duration = AnimationConstants.durationStandard,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 1.0,
        end: isHovered ? scale : 1.0,
      ),
      duration: duration,
      curve: AnimationConstants.easeOutQuick,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Build a rotation animation
  static Widget rotate({
    required Animation<double> animation,
    required Widget child,
    Alignment alignment = Alignment.center,
  }) {
    return RotationTransition(
      turns: animation,
      alignment: alignment,
      child: child,
    );
  }
}

/// Staggered animation helper
class StaggeredAnimationBuilder extends StatelessWidget {
  final Animation<double> controller;
  final List<Widget> children;
  final double staggerDelay;
  final Duration duration;

  const StaggeredAnimationBuilder({
    super.key,
    required this.controller,
    required this.children,
    this.staggerDelay = 0.1,
    this.duration = AnimationConstants.durationMedium,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        children.length,
        (index) {
          final delay = index * staggerDelay;
          final animation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: controller,
              curve: Interval(
                delay,
                delay + (1.0 - delay),
                curve: AnimationConstants.easeOutSmooth,
              ),
            ),
          );

          return AnimationBuilders.fadeAndSlideUp(
            animation: animation,
            child: children[index],
          );
        },
      ),
    );
  }
}
