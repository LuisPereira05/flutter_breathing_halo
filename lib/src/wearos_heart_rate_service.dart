import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'heart_rate_service.dart';

/// Health Services API
class WearOSHeartRateService implements HeartRateService {
  static const MethodChannel _channel = MethodChannel('breathing_halo/heart_rate');
  static const EventChannel _eventChannel = EventChannel('breathing_halo/heart_rate_stream');
  
  StreamController<int>? _controller;
  StreamSubscription? _platformSubscription;
  int? _currentHeartRate;
  bool _isMonitoring = false;

  

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
  Future<bool> isAvailable() async {
    try {
      final bool available = await _channel.invokeMethod('isAvailable');
      return available;
    } catch (e) {
      debugPrint('❌ WearOS Health Services not available: $e');
      return false;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      final bool granted = await _channel.invokeMethod('requestPermissions');
      debugPrint("🔐 Health permission granted? $granted");
      return granted;
    } catch (e) {
      debugPrint('❌ Failed to request permissions: $e');
      return false;
    }
  }

  @override
  Future<bool> startMonitoring() async {
    if (_isMonitoring) return true;

    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        debugPrint('❌ Missing Health Services permissions');
        return false;
      }

      final bool started = await _channel.invokeMethod('startMonitoring');

      if (started) {
        _isMonitoring = true;
        _controller ??= StreamController<int>.broadcast();

        _platformSubscription = _eventChannel
            .receiveBroadcastStream()
            .listen((dynamic event) {
          if (event is int) {
            _currentHeartRate = event;
            if (!_controller!.isClosed) {
              _controller!.add(event);
            }
            debugPrint('💓 WearOS HR (Health Services): $event bpm');
          }
        }, onError: (error) {
          debugPrint('❌ WearOS HR error: $error');
        });

        debugPrint('✅ Health Services HR monitoring started');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Failed to start Health Services HR: $e');
      return false;
    }
  }

  @override
  Future<void> stopMonitoring() async {
    if (!_isMonitoring) return;

    try {
      await _channel.invokeMethod('stopMonitoring');
      _isMonitoring = false;

      await _platformSubscription?.cancel();
      _platformSubscription = null;

      debugPrint('⏹️ Health Services HR monitoring stopped');
    } catch (e) {
      debugPrint('❌ Error stopping HR: $e');
    }
  }

  void dispose() {
    _platformSubscription?.cancel();
    _controller?.close();
  }
}
