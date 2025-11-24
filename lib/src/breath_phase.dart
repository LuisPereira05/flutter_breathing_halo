/// Represents the different phases of a breathing cycle.
enum BreathPhase {
  /// Inhaling phase - expanding the lungs
  inhale,
  
  /// Hold after inhaling
  holdIn,
  
  /// Exhaling phase - releasing air
  exhale,
  
  /// Hold after exhaling
  holdOut;

  /// Returns the instruction text for each phase
  String get instruction {
    switch (this) {
      case BreathPhase.inhale:
        return 'Inspire';
      case BreathPhase.holdIn:
        return 'Segure';
      case BreathPhase.exhale:
        return 'Expire';
      case BreathPhase.holdOut:
        return 'Pause';
    }
  }

  /// Returns the English instruction for each phase
  String get instructionEn {
    switch (this) {
      case BreathPhase.inhale:
        return 'Inhale';
      case BreathPhase.holdIn:
        return 'Hold';
      case BreathPhase.exhale:
        return 'Exhale';
      case BreathPhase.holdOut:
        return 'Pause';
    }
  }
}