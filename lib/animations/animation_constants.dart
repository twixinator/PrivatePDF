import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Animation constants for PrivatPDF
///
/// Philosophy: Editorial sophistication, not flashy.
/// Smooth 60fps animations that enhance UX without distraction.
class AnimationConstants {
  AnimationConstants._(); // Private constructor to prevent instantiation

  // ====================================
  // DURATIONS
  // ====================================

  /// Very quick animations (hover feedback, micro-interactions)
  static const Duration durationQuick = Duration(milliseconds: 150);

  /// Standard animations (transitions, fades)
  static const Duration durationStandard = Duration(milliseconds: 250);

  /// Medium animations (page transitions, scroll effects)
  static const Duration durationMedium = Duration(milliseconds: 400);

  /// Slow animations (success checkmark, special effects)
  static const Duration durationSlow = Duration(milliseconds: 600);

  /// Loading spinner full rotation
  static const Duration durationSpinner = Duration(milliseconds: 2000);

  /// Mobile duration multiplier (shorter animations on mobile)
  static const double mobileDurationMultiplier = 0.7;

  // ====================================
  // CURVES
  // ====================================

  /// Quick ease-out for hover effects and micro-interactions
  static const Curve easeOutQuick = Curves.easeOut;

  /// Standard ease-in-out for most animations
  static const Curve easeInOut = Curves.easeInOut;

  /// Smooth ease-out for fades and slides
  static const Curve easeOutSmooth = Curves.easeOutCubic;

  /// Elastic bounce for success animations
  static const Curve elasticOut = Curves.elasticOut;

  /// Decelerate for scroll-triggered animations
  static const Curve decelerate = Curves.decelerate;

  // ====================================
  // TRANSFORMS
  // ====================================

  /// Card hover scale (subtle zoom)
  static const double hoverScale = 1.02;

  /// Card hover shadow elevation increase
  static const double hoverShadowFrom = 12.0;
  static const double hoverShadowTo = 24.0;

  /// Fade-in slide distance (vertical)
  static const double fadeInSlideDistance = 20.0;

  /// Page transition slide distance (horizontal)
  static const double pageTransitionSlideDistance = 100.0;

  /// Success checkmark scale animation
  static const double checkmarkScaleFrom = 0.0;
  static const double checkmarkScalePeak = 1.2;
  static const double checkmarkScaleTo = 1.0;

  /// Loading spinner pulse scale range
  static const double spinnerPulseFrom = 1.0;
  static const double spinnerPulseTo = 1.08;

  // ====================================
  // OPACITY
  // ====================================

  /// Standard fade-in opacity range
  static const double opacityFadeFrom = 0.0;
  static const double opacityFadeTo = 1.0;

  /// Hover opacity change
  static const double hoverOpacity = 0.9;

  // ====================================
  // HELPER METHODS
  // ====================================

  /// Get duration adjusted for platform
  ///
  /// Mobile devices get shorter animations (0.7x) for better performance
  static Duration getPlatformDuration(Duration duration) {
    // For mobile platforms, reduce animation duration
    if (kIsWeb) {
      // Web can handle full durations
      return duration;
    }

    // For mobile, apply multiplier
    return Duration(
      milliseconds: (duration.inMilliseconds * mobileDurationMultiplier).round(),
    );
  }

  /// Get quick duration (adjusted for platform)
  static Duration get quick => getPlatformDuration(durationQuick);

  /// Get standard duration (adjusted for platform)
  static Duration get standard => getPlatformDuration(durationStandard);

  /// Get medium duration (adjusted for platform)
  static Duration get medium => getPlatformDuration(durationMedium);

  /// Get slow duration (adjusted for platform)
  static Duration get slow => getPlatformDuration(durationSlow);

  /// Get spinner duration (not adjusted - needs consistent timing)
  static Duration get spinner => durationSpinner;

  // ====================================
  // ANIMATION PRESETS
  // ====================================

  /// Preset for card hover animation
  static AnimationPreset get cardHover => const AnimationPreset(
        duration: durationStandard,
        curve: easeOutQuick,
      );

  /// Preset for fade-in animation
  static AnimationPreset get fadeIn => const AnimationPreset(
        duration: durationMedium,
        curve: easeOutSmooth,
      );

  /// Preset for page transition
  static AnimationPreset get pageTransition => const AnimationPreset(
        duration: durationMedium,
        curve: easeOutQuick,
      );

  /// Preset for success animation
  static AnimationPreset get success => const AnimationPreset(
        duration: durationSlow,
        curve: elasticOut,
      );
}

/// Animation preset combining duration and curve
class AnimationPreset {
  final Duration duration;
  final Curve curve;

  const AnimationPreset({
    required this.duration,
    required this.curve,
  });

  /// Get platform-adjusted duration
  Duration get platformDuration =>
      AnimationConstants.getPlatformDuration(duration);
}
