import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:breathing_halo/breathing_halo.dart';

class FakeHeartRateService implements HeartRateService {
  final StreamController<int> _controller = StreamController<int>.broadcast();
  final List<int> hrValues;
  
  bool started = false;
  bool stopped = false;
  int _currentIndex = 0;
  Timer? _timer;

  FakeHeartRateService(this.hrValues);

  @override
  Stream<int> get heartRateStream => _controller.stream;

  @override
  Future<bool> startMonitoring() async {
    started = true;
    
    // Emit heart rate values periodically
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_currentIndex < hrValues.length && !_controller.isClosed) {
        _controller.add(hrValues[_currentIndex]);
        _currentIndex++;
      } else {
        timer.cancel();
      }
    });
    
    return true;
  }

  @override
  Future<void> stopMonitoring() async {
    stopped = true;
    _timer?.cancel();
  }

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> requestPermissions() async => true;

  @override
  int? get currentHeartRate => 
    _currentIndex > 0 ? hrValues[_currentIndex - 1] : hrValues.first;

  @override
  bool get isMonitoring => started && !stopped;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test("BreathingHalo initial state is idle", () {
    final widget = BreathingHalo(
      config: const BreathingConfig(),
    );

    expect(widget.config.autoStart, false);
    expect(widget.onHeartRateChanged, null);
  });

  testWidgets("BreathingHalo startBreathing() activates session", (tester) async {
    final fakeService = FakeHeartRateService([75, 75, 75]);

    final widget = BreathingHalo(
      heartRateService: fakeService,
      config: const BreathingConfig(
        autoStart: false,
      ),
      key: UniqueKey(),
    );

    await tester.pumpWidget(
      TestWidgetWrapper(child: widget),
    );

    final state = tester.state<State>(find.byType(BreathingHalo)) as dynamic;

    expect(state.isBreathing, false);

    await state.startBreathing();
    await tester.pump();

    expect(state.isBreathing, true);
    expect(fakeService.started, true);
  });

  testWidgets("Calm state is reached when HR drops enough", (tester) async {
    final fakeService = FakeHeartRateService([80, 75, 70, 65, 60]);

    bool calmTriggered = false;

    final widget = BreathingHalo(
      heartRateService: fakeService,
      onCalmStateAchieved: () => calmTriggered = true,
      config: const BreathingConfig(
        initialHeartRate: 80,
        calmThreshold: 10,
        calmCheckDelay: 0,
      ),
    );

    await tester.pumpWidget(
      TestWidgetWrapper(child: widget),
    );

    final state = tester.state<State>(find.byType(BreathingHalo)) as dynamic;

    // Start breathing
    await state.startBreathing();
    await tester.pump();

    // Wait for heart rate values to be emitted and processed
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 150));

    expect(calmTriggered, true);
    expect(state.isCalm, true);
  });

  testWidgets("BreathingHalo stopBreathing() deactivates session", (tester) async {
    final fakeService = FakeHeartRateService([75, 75]);

    final widget = BreathingHalo(
      heartRateService: fakeService,
      config: const BreathingConfig(
        autoStart: false,
      ),
    );

    await tester.pumpWidget(
      TestWidgetWrapper(child: widget),
    );

    final state = tester.state<State>(find.byType(BreathingHalo)) as dynamic;

    // Start breathing
    await state.startBreathing();
    await tester.pump();
    expect(state.isBreathing, true);

    // Stop breathing
    await state.stopBreathing();
    await tester.pump();

    expect(state.isBreathing, false);
    expect(fakeService.stopped, true);
  });

  testWidgets("Heart rate changes are tracked", (tester) async {
    final fakeService = FakeHeartRateService([80, 75, 70]);
    final List<int> recordedHeartRates = [];

    final widget = BreathingHalo(
      heartRateService: fakeService,
      onHeartRateChanged: (hr) => recordedHeartRates.add(hr),
      config: const BreathingConfig(
        autoStart: false,
      ),
    );

    await tester.pumpWidget(
      TestWidgetWrapper(child: widget),
    );

    final state = tester.state<State>(find.byType(BreathingHalo)) as dynamic;

    await state.startBreathing();
    
    // Wait for heart rate emissions
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 150));

    expect(recordedHeartRates.isNotEmpty, true);
    expect(recordedHeartRates, contains(80));
  });

  testWidgets("Session timer increments", (tester) async {
    final fakeService = FakeHeartRateService([75]);

    final widget = BreathingHalo(
      heartRateService: fakeService,
      config: const BreathingConfig(
        autoStart: false,
        showTimer: true,
      ),
    );

    await tester.pumpWidget(
      TestWidgetWrapper(child: widget),
    );

    final state = tester.state<State>(find.byType(BreathingHalo)) as dynamic;

    await state.startBreathing();
    await tester.pump();

    expect(state.sessionSeconds, 0);

    // Wait 2 seconds
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(state.sessionSeconds, greaterThan(0));
  });
}

class TestWidgetWrapper extends StatelessWidget {
  final Widget child;
  const TestWidgetWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }
}