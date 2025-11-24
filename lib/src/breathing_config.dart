import 'package:flutter/material.dart';

/// Configuration class for BreathingHalo widget
class BreathingConfig {
  /// Size of the breathing halo
  final double size;
  
  /// Duration of each breath phase
  final Duration breathDuration;
  
  /// Initial heart rate (bpm)
  final int? initialHeartRate;
  
  /// Whether to start automatically
  final bool autoStart;
  
  /// Minimum scale during exhale
  final double minScale;
  
  /// Maximum scale during inhale
  final double maxScale;
  
  /// Normal halo color (before calm state)
  final Color normalColor;
  
  /// Calm halo color (after achieving calm state)
  final Color calmColor;
  
  /// Normal background colors
  final List<Color> normalBackground;
  
  /// Calm background colors
  final List<Color> calmBackground;
  
  /// Heart rate drop threshold to trigger calm state (in bpm)
  final int calmThreshold;
  
  /// Time in seconds before checking for calm state
  final int calmCheckDelay;
  
  /// Show heart rate display
  final bool showHeartRate;
  
  /// Show session timer
  final bool showTimer;

  final bool hideButton;
  
  /// Use English instructions instead of Portuguese
  final bool useEnglish;
  
  /// Use real heart rate sensor (if available) instead of simulation
  final bool useRealHeartRateSensor;

  const BreathingConfig({
    this.size = 200.0,
    this.breathDuration = const Duration(seconds: 4),
    this.initialHeartRate,
    this.autoStart = false,
    this.minScale = 0.75,
    this.maxScale = 1.5,
    this.normalColor = const Color(0xFF06b6d4), // cyan
    this.calmColor = const Color(0xFF818cf8), // indigo
    this.normalBackground = const [
      Color(0xFF0f172a),
      Color(0xFF1e293b),
    ],
    this.calmBackground = const [
      Color(0xFF312e81),
      Color(0xFF581c87),
      Color(0xFF1e3a8a),
    ],
    this.calmThreshold = 5,
    this.calmCheckDelay = 20,
    this.showHeartRate = true,
    this.showTimer = true,
    this.hideButton = false,
    this.useEnglish = false,
    this.useRealHeartRateSensor = true,
  });

  /// Create a copy with modified values
  BreathingConfig copyWith({
    double? size,
    Duration? breathDuration,
    int? initialHeartRate,
    bool? autoStart,
    double? minScale,
    double? maxScale,
    Color? normalColor,
    Color? calmColor,
    List<Color>? normalBackground,
    List<Color>? calmBackground,
    int? calmThreshold,
    int? calmCheckDelay,
    bool? showHeartRate,
    bool? showTimer,
    bool? hideButton,
    bool? useEnglish,
    bool? useRealHeartRateSensor,
  }) {
    return BreathingConfig(
      size: size ?? this.size,
      breathDuration: breathDuration ?? this.breathDuration,
      initialHeartRate: initialHeartRate ?? this.initialHeartRate,
      autoStart: autoStart ?? this.autoStart,
      minScale: minScale ?? this.minScale,
      maxScale: maxScale ?? this.maxScale,
      normalColor: normalColor ?? this.normalColor,
      calmColor: calmColor ?? this.calmColor,
      normalBackground: normalBackground ?? this.normalBackground,
      calmBackground: calmBackground ?? this.calmBackground,
      calmThreshold: calmThreshold ?? this.calmThreshold,
      calmCheckDelay: calmCheckDelay ?? this.calmCheckDelay,
      showHeartRate: showHeartRate ?? this.showHeartRate,
      showTimer: showTimer ?? this.showTimer,
      hideButton: hideButton ?? this.hideButton,
      useEnglish: useEnglish ?? this.useEnglish,
      useRealHeartRateSensor: useRealHeartRateSensor ?? this.useRealHeartRateSensor,
    );
  }
  
  /// Preset: Box Breathing (4-4-4-4)
  static const BreathingConfig boxBreathing = BreathingConfig(
    breathDuration: Duration(seconds: 4),
  );
  
  /// Preset: Deep Breathing (6-6-6-6)
  static const BreathingConfig deepBreathing = BreathingConfig(
    breathDuration: Duration(seconds: 6),
  );
  
  /// Preset: Quick Calm (3-3-3-3)
  static const BreathingConfig quickCalm = BreathingConfig(
    breathDuration: Duration(seconds: 3),
  );
}