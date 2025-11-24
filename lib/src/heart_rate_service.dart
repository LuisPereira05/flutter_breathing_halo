// heart_rate_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service for managing heart rate data from device sensors
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

/// Simulated heart rate service for testing and fallback
class SimulatedHeartRateService implements HeartRateService {
  StreamController<int>? _controller;
  Timer? _timer;
  int _currentHeartRate = 75;
  bool _isMonitoring = false;

  final int initialHeartRate;
  final bool enableVariation;

  SimulatedHeartRateService({
    this.initialHeartRate = 75,
    this.enableVariation = true,
  }) {
    _currentHeartRate = initialHeartRate;
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

    // Simulate heart rate updates every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (enableVariation) {
        // Deterministic small variation (avoid importing dart:math to keep tiny)
        final variation = (DateTime.now().millisecondsSinceEpoch % 3) - 1;
        _currentHeartRate = (_currentHeartRate + variation).clamp(40, 180);
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

/// Lightweight stub RealHeartRateService (SAFE / no external plugin).
///
/// This stub intentionally does **not** import `health` or `flutter_health_connect`
/// to avoid forcing those native dependencies on consumers of the package.
/// If you want real sensor/HConn access, implement a class that implements
/// HeartRateService using the platform plugin of your choice and pass it into
/// the BreathingHalo widget via `heartRateService: yourImplementation`.
class RealHeartRateService implements HeartRateService {
  StreamController<int>? _controller;
  int? _currentHeartRate;
  bool _isMonitoring = false;

  RealHeartRateService();

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
    // Stub: not implemented here to avoid pulling platform plugins.
    // Return false so calling code can fall back to simulation.
    debugPrint('RealHeartRateService.startMonitoring() called — stubbed (no-op).');
    return false;
  }

  @override
  Future<void> stopMonitoring() async {
    _isMonitoring = false;
  }

  @override
  Future<bool> isAvailable() async {
    // Stubbed: report false by default so factory falls back to simulation.
    return false;
  }

  @override
  Future<bool> requestPermissions() async {
    // Stubbed: nothing to request here.
    return false;
  }

  @override
  void dispose() {
    _controller?.close();
  }
}

/// Factory to create appropriate heart rate service
class HeartRateServiceFactory {
  /// Create a heart rate service
  ///
  /// If [useRealSensor] is true and a real implementation is available,
  /// create/return it. Otherwise return a SimulatedHeartRateService.
  ///
  /// IMPORTANT: This package intentionally does not include platform-specific
  /// Health/HealthConnect code. To use a real sensor, implement `HeartRateService`
  /// yourself (native plugin or package) and pass an instance into your widget:
  /// `BreathingHalo(heartRateService: MyPlatformHeartRateService())`.
  static Future<HeartRateService> create({
    bool useRealSensor = true,
    int initialHeartRate = 75,
    bool enableVariation = true,
  }) async {
    if (useRealSensor) {
      // Try to use the RealHeartRateService stub first — it will usually report
      // unavailable in this file because it's intentionally a no-op.
      final real = RealHeartRateService();
      final available = await real.isAvailable();
      if (available) {
        final granted = await real.requestPermissions();
        if (granted) {
          return real;
        }
      }
    }

    // Fallback to simulation
    return SimulatedHeartRateService(
      initialHeartRate: initialHeartRate,
      enableVariation: enableVariation,
    );
  }
}