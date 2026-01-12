import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'animation_constants.dart';

/// Page transition configurations for GoRouter
///
/// Provides smooth fade + slide transitions for all routes
class PageTransitions {
  PageTransitions._(); // Private constructor

  /// Fade transition (default)
  static CustomTransitionPage<T> fade<T>({
    required Widget child,
    required GoRouterState state,
    Duration? duration,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration:
          duration ?? AnimationConstants.durationMedium,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: AnimationConstants.easeOutQuick,
          ),
          child: child,
        );
      },
    );
  }

  /// Fade + slide right transition (primary navigation)
  static CustomTransitionPage<T> fadeSlideRight<T>({
    required Widget child,
    required GoRouterState state,
    Duration? duration,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration:
          duration ?? AnimationConstants.durationMedium,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: AnimationConstants.easeOutQuick,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, 0.0), // Slide from right (subtle)
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  /// Fade + slide up transition (modal-like)
  static CustomTransitionPage<T> fadeSlideUp<T>({
    required Widget child,
    required GoRouterState state,
    Duration? duration,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration:
          duration ?? AnimationConstants.durationMedium,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: AnimationConstants.easeOutQuick,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.1), // Slide from bottom
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  /// Scale + fade transition (tool pages)
  static CustomTransitionPage<T> scaleFade<T>({
    required Widget child,
    required GoRouterState state,
    Duration? duration,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration:
          duration ?? AnimationConstants.durationMedium,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: AnimationConstants.easeOutQuick,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.95,
              end: 1.0,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  /// No transition (instant)
  static CustomTransitionPage<T> none<T>({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: Duration.zero,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }

  /// Get default page transition for route
  static CustomTransitionPage<T> getDefaultTransition<T>({
    required Widget child,
    required GoRouterState state,
    TransitionType type = TransitionType.fadeSlideRight,
  }) {
    switch (type) {
      case TransitionType.fade:
        return fade<T>(child: child, state: state);
      case TransitionType.fadeSlideRight:
        return fadeSlideRight<T>(child: child, state: state);
      case TransitionType.fadeSlideUp:
        return fadeSlideUp<T>(child: child, state: state);
      case TransitionType.scaleFade:
        return scaleFade<T>(child: child, state: state);
      case TransitionType.none:
        return none<T>(child: child, state: state);
    }
  }
}

/// Transition types
enum TransitionType {
  fade,
  fadeSlideRight,
  fadeSlideUp,
  scaleFade,
  none,
}

/// Extension to easily apply transitions to GoRoute
extension GoRouteX on GoRoute {
  /// Create a route with fade transition
  static GoRoute withFade({
    required String path,
    required Widget Function(BuildContext, GoRouterState) builder,
    String? name,
    List<RouteBase> routes = const [],
  }) {
    return GoRoute(
      path: path,
      name: name,
      routes: routes,
      pageBuilder: (context, state) {
        return PageTransitions.fade(
          child: builder(context, state),
          state: state,
        );
      },
    );
  }

  /// Create a route with fade + slide transition
  static GoRoute withFadeSlide({
    required String path,
    required Widget Function(BuildContext, GoRouterState) builder,
    String? name,
    List<RouteBase> routes = const [],
  }) {
    return GoRoute(
      path: path,
      name: name,
      routes: routes,
      pageBuilder: (context, state) {
        return PageTransitions.fadeSlideRight(
          child: builder(context, state),
          state: state,
        );
      },
    );
  }
}

/// Hero animation wrapper for shared element transitions
class HeroTransition extends StatelessWidget {
  final String tag;
  final Widget child;

  const HeroTransition({
    super.key,
    required this.tag,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }
}
