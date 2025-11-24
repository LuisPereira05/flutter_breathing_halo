import 'dart:async';
import 'dart:math' as math;

/// Service for managing heart rate data
abstract class HeartRateService {
  /// Stream of heart rate values in bpm
  Stream<int> get heartRateStream;

  /// Current heart rate value
  int? get currentHeartRate;

  /// Whether the service is currently monitoring
  bool get isMonitoring;

  /// Start monitoring heart rate
  Future<bool> startMonitoring();

  /// Stop monitoring heart rate
  Future<void> stopMonitoring();

  /// Check if heart rate sensor is available
  Future<bool> isAvailable();

  /// Request permissions if needed
  Future<bool> requestPermissions();

  /// Optional cleanup
  void dispose();
}

/// Simulated heart rate service with realistic behavior
/// 
/// This provides a realistic heart rate simulation that:
/// - Starts at a baseline (70-90 bpm)
/// - Gradually decreases during breathing exercises (simulating relaxation)
/// - Has natural variation (±2-3 bpm)
/// - Never goes below 50 or above 100 bpm during session
class SimulatedHeartRateService implements HeartRateService {
  StreamController<int>? _controller;
  Timer? _timer;
  int _currentHeartRate = 75;
  bool _isMonitoring = false;
  
  final int initialHeartRate;
  final bool enableVariation;
  final math.Random _random = math.Random();
  
  // For realistic gradual decrease
  int _baselineHR = 75;
  int _targetHR = 65;
  double _progress = 0.0;

  SimulatedHeartRateService({
    this.initialHeartRate = 75,
    this.enableVariation = true,
  }) {
    _currentHeartRate = initialHeartRate;
    _baselineHR = initialHeartRate;
    // Target is 10-15 bpm lower for calm state
    _targetHR = (initialHeartRate - 10 - _random.nextInt(6)).clamp(50, 100);
  }

  @override
  Stream<int> get heartRateStream {
    _controller ??= StreamController<int>.broadcast();
    return _controller!.stream;
  }

  @override
  int? get currentHeartRate => _currentHeartRate;

  @override
  bool get isMonitoring => _isMonitoring;

  @override
  Future<bool> startMonitoring() async {
    if (_isMonitoring) return true;

    _isMonitoring = true;
    _controller ??= StreamController<int>.broadcast();
    _progress = 0.0;

    // Simulate realistic heart rate updates
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (enableVariation) {
        // Gradual decrease towards target (simulating relaxation)
        _progress = (_progress + 0.005).clamp(0.0, 1.0);
        
        // Interpolate between baseline and target
        final interpolated = _baselineHR + ((_targetHR - _baselineHR) * _progress);
        
        // Add natural variation (±2-3 bpm)
        final variation = _random.nextInt(5) - 2;
        
        _currentHeartRate = (interpolated + variation).round().clamp(50, 100);
      }

      if (!_controller!.isClosed) {
        _controller!.add(_currentHeartRate);
      }
    });

    return true;
  }

  @override
  Future<void> stopMonitoring() async {
    _isMonitoring = false;
    _timer?.cancel();
    _timer = null;
    _progress = 0.0;
  }

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> requestPermissions() async => true;

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.close();
  }
}