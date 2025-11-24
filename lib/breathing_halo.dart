/// A smart guided breathing widget for smartwatches.
/// 
/// This library provides a beautiful, animated breathing guide that:
/// - Expands and contracts to guide breathing rhythm
/// - Monitors heart rate changes
/// - Dynamically changes colors when user achieves calm state
/// - Perfect for smartwatch displays
library breathing_halo;

export 'src/breathing_halo_widget.dart';
export 'src/breath_phase.dart';
export 'src/breathing_config.dart';
export 'src/heart_rate_service.dart';
export 'src/wearos_heart_rate_service.dart';