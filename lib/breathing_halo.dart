/// A smart guided breathing widget for smartwatches.
/// 
/// This library provides a beautiful, animated breathing guide that:
/// - Expands and contracts to guide breathing rhythm
/// - Monitors heart rate changes (simulated by default)
/// - Dynamically changes colors when user achieves calm state
/// - Perfect for smartwatch displays
/// 
/// ## Quick Start
/// 
/// ```dart
/// import 'package:breathing_halo/breathing_halo.dart';
/// 
/// // Minimal setup - works out of the box!
/// BreathingHalo(
///   config: BreathingConfig(
///     size: 220,
///     breathDuration: Duration(seconds: 4),
///   ),
/// )
/// ```
/// 
/// ## Custom Heart Rate Service
/// 
/// If you want to use real sensor data, implement `HeartRateService`:
/// 
/// ```dart
/// class MyHeartRateService implements HeartRateService {
///   // Your implementation using platform channels or health APIs
/// }
/// 
/// BreathingHalo(
///   heartRateService: MyHeartRateService(),
/// )
/// ```
library breathing_halo;

export 'src/breathing_halo_widget.dart';
export 'src/breath_phase.dart';
export 'src/breathing_config.dart';
export 'src/heart_rate_service.dart';