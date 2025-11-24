import 'package:flutter/material.dart';
import 'dart:async';
import 'breath_phase.dart';
import 'breathing_config.dart';
import 'heart_rate_service.dart';

/// A smart guided breathing widget with heart rate monitoring
class BreathingHalo extends StatefulWidget {
  /// Configuration for the breathing halo
  final BreathingConfig config;

  /// Callback when heart rate changes
  final Function(int heartRate)? onHeartRateChanged;

  /// Callback when calm state is achieved
  final VoidCallback? onCalmStateAchieved;

  /// Callback when breathing session starts
  final VoidCallback? onSessionStart;

  /// Callback when breathing session stops
  final VoidCallback? onSessionStop;

  /// Optional custom heart rate service
  final HeartRateService? heartRateService;

  const BreathingHalo({
    Key? key,
    this.config = const BreathingConfig(),
    this.onHeartRateChanged,
    this.onCalmStateAchieved,
    this.onSessionStart,
    this.onSessionStop,
    this.heartRateService,
  }) : super(key: key);

  @override
  State<BreathingHalo> createState() => _BreathingHaloState();
}

class _BreathingHaloState extends State<BreathingHalo>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _colorController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  bool _isBreathing = false;
  int _currentHeartRate = 75;
  int _initialHeartRate = 75;
  BreathPhase _currentPhase = BreathPhase.inhale;
  int _sessionSeconds = 0;
  bool _isCalm = false;

  Timer? _phaseTimer;
  Timer? _sessionTimer;
  StreamSubscription<int>? _heartRateSubscription;
  late HeartRateService _heartRateService;

  // Public getters for tests
  bool get isBreathing => _isBreathing;
  bool get isCalm => _isCalm;
  int get sessionSeconds => _sessionSeconds;
  int get currentHeartRate => _currentHeartRate;

  @override
  void initState() {
    super.initState();

    _initialHeartRate = widget.config.initialHeartRate ?? 75;
    _currentHeartRate = _initialHeartRate;

    // Initialize heart rate service (defaults to simulated)
    _heartRateService = widget.heartRateService ??
        SimulatedHeartRateService(
          initialHeartRate: _initialHeartRate,
          enableVariation: true,
        );

    // Breath animation controller
    _breathController = AnimationController(
      vsync: this,
      duration: widget.config.breathDuration,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.config.minScale,
      end: widget.config.maxScale,
    ).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOut,
      ),
    );

    // Color transition controller
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _colorAnimation = ColorTween(
      begin: widget.config.normalColor,
      end: widget.config.calmColor,
    ).animate(_colorController);

    // Listen to heart rate changes
    _heartRateSubscription = _heartRateService.heartRateStream.listen(
      (hr) {
        if (!mounted) return;
        setState(() {
          _currentHeartRate = hr;

          // Check calm state
          if (_isBreathing &&
              _sessionSeconds >= widget.config.calmCheckDelay &&
              (_initialHeartRate - _currentHeartRate) >=
                  widget.config.calmThreshold &&
              !_isCalm) {
            _isCalm = true;
            _colorController.forward();
            widget.onCalmStateAchieved?.call();
          }
        });

        widget.onHeartRateChanged?.call(hr);
      },
    );

    if (widget.config.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        startBreathing();
      });
    }
  }

  /// Start the breathing session
  Future<void> startBreathing() async {
    setState(() {
      _isBreathing = true;
      _initialHeartRate = _currentHeartRate;
      _sessionSeconds = 0;
      _isCalm = false;
    });

    _colorController.reverse();
    _startBreathCycle();
    _startSessionTimer();

    await _heartRateService.startMonitoring();
    widget.onSessionStart?.call();
  }

  /// Stop the breathing session
  Future<void> stopBreathing() async {
    setState(() => _isBreathing = false);
    _phaseTimer?.cancel();
    _sessionTimer?.cancel();
    _breathController.stop();

    await _heartRateService.stopMonitoring();
    widget.onSessionStop?.call();
  }

  void _startBreathCycle() {
    _currentPhase = BreathPhase.inhale;
    _breathController.forward();

    _phaseTimer = Timer.periodic(widget.config.breathDuration, (timer) {
      if (!_isBreathing) {
        timer.cancel();
        return;
      }

      setState(() {
        switch (_currentPhase) {
          case BreathPhase.inhale:
            _currentPhase = BreathPhase.holdIn;
            _breathController.stop();
            break;
          case BreathPhase.holdIn:
            _currentPhase = BreathPhase.exhale;
            _breathController.reverse();
            break;
          case BreathPhase.exhale:
            _currentPhase = BreathPhase.holdOut;
            _breathController.stop();
            break;
          case BreathPhase.holdOut:
            _currentPhase = BreathPhase.inhale;
            _breathController.forward();
            break;
        }
      });
    });
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isBreathing) {
        timer.cancel();
        return;
      }
      setState(() => _sessionSeconds++);
    });
  }

  @override
  void dispose() {
    _breathController.dispose();
    _colorController.dispose();
    _phaseTimer?.cancel();
    _sessionTimer?.cancel();
    _heartRateSubscription?.cancel();

    if (widget.heartRateService == null) {
      _heartRateService.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.config.hideButton
          ? (_isBreathing ? stopBreathing : startBreathing)
          : null,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.config.size,
        height: widget.config.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Animated background
            AnimatedContainer(
              duration: const Duration(milliseconds: 3000),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isCalm
                      ? widget.config.calmBackground
                      : widget.config.normalBackground,
                ),
              ),
            ),

            // Animated breathing halo
            AnimatedBuilder(
              animation: _breathController,
              builder: (context, child) {
                return AnimatedBuilder(
                  animation: _colorController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: (_currentPhase == BreathPhase.holdIn ||
                                _currentPhase == BreathPhase.holdOut)
                            ? 0.6
                            : 1.0,
                        child: Container(
                          width: widget.config.size * 0.65,
                          height: widget.config.size * 0.65,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _colorAnimation.value ??
                                  widget.config.normalColor,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_colorAnimation.value ??
                                        widget.config.normalColor)
                                    .withOpacity(0.6),
                                blurRadius: 60,
                                spreadRadius: 10,
                              ),
                            ],
                            gradient: RadialGradient(
                              colors: [
                                (_colorAnimation.value ??
                                        widget.config.normalColor)
                                    .withOpacity(0.2),
                                (_colorAnimation.value ??
                                        widget.config.normalColor)
                                    .withOpacity(0.05),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // Center instruction
            if (_isBreathing)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite,
                    color: _isBreathing ? Colors.red : Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.config.useEnglish
                        ? _currentPhase.instructionEn
                        : _currentPhase.instruction,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

            // Heart rate display
            if (widget.config.showHeartRate)
              Positioned(
                top: 20,
                left: 20,
                child: _buildHeartRateDisplay(),
              ),

            // Timer display
            if (widget.config.showTimer && _isBreathing)
              Positioned(
                top: 20,
                right: 20,
                child: _buildTimerDisplay(),
              ),

            // Calm indicator
            if (_isCalm)
              Positioned(
                top: 70,
                child: _buildCalmIndicator(),
              ),

            // Control button
            if (!widget.config.hideButton)
              Positioned(
                bottom: 5,
                child: _buildControlButton(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartRateDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite,
            color: _isBreathing ? Colors.red : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '$_currentHeartRate',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'bpm',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay() {
    final minutes = _sessionSeconds ~/ 60;
    final seconds = _sessionSeconds % 60;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${minutes.toString()}:${seconds.toString().padLeft(2, '0')}',
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'monospace',
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildCalmIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.config.useEnglish ? 'Calm State ✨' : 'Estado Calmo ✨',
              style: const TextStyle(
                color: Color(0xFFc7d2fe),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlButton() {
    return ElevatedButton(
      onPressed: _isBreathing ? stopBreathing : startBreathing,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isBreathing ? Colors.red : Colors.cyan,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        _isBreathing
            ? (widget.config.useEnglish ? 'Stop' : 'Parar')
            : (widget.config.useEnglish ? 'Start' : 'Iniciar'),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
