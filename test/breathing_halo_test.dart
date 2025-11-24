import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:breathing_halo/breathing_halo.dart';

class FakeHeartRateService implements HeartRateService {
  late final Stream<int> _stream;

  bool started = false;
  bool stopped = false;

  int _currentHR = 0;

  FakeHeartRateService(List<int> hrValues) {
    if (hrValues.isNotEmpty) {
      _currentHR = hrValues.first;
    }

    _stream = Stream<int>.periodic(
      const Duration(milliseconds: 100),
      (i) => hrValues[i],
    ).take(hrValues.length);
  }

  @override
  Stream<int> get heartRateStream => _stream;

  @override
  Future<bool> startMonitoring() async {
    started = true;
    return true;
  }

  @override
  Future<void> stopMonitoring() async {
    stopped = true;
  }

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> requestPermissions() async => true;

  @override
  int? get currentHeartRate => _currentHR;

  @override
  bool get isMonitoring => started && !stopped;

  @override
  void dispose() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test("BreathingHalo initial state is idle", () async {
    final widget = BreathingHalo(
      config: const BreathingConfig(),
    );

    expect(widget.config.autoStart, false);
    expect(widget.onHeartRateChanged, null);
  });

  testWidgets("BreathingHalo startBreathing() activates session", (tester) async {
    final fakeService = FakeHeartRateService([75]);

    final widget = BreathingHalo(
      heartRateService: fakeService,
      config: const BreathingConfig(
        autoStart: false,
        useRealHeartRateSensor: false,
      ),
      key: UniqueKey(),
    );

    await tester.pumpWidget(
      TestWidgetWrapper(child: widget),
    );

    final state =
        tester.state(find.byType(BreathingHalo)) as dynamic;

    expect(state.isBreathing, false);

    await state.startBreathing();
    await tester.pump();

    expect(state.isBreathing, true);
    expect(fakeService.started, true);
  });

  testWidgets("Calm state is reached when HR drops enough", (tester) async {
    final fakeService = FakeHeartRateService([80, 75, 70, 60]);

    bool calmTriggered = false;

    final widget = BreathingHalo(
      heartRateService: fakeService,
      onCalmStateAchieved: () => calmTriggered = true,
      config: const BreathingConfig(
        calmThreshold: 10,
        calmCheckDelay: 0,
        useRealHeartRateSensor: false,
      ),
    );

    await tester.pumpWidget(
      TestWidgetWrapper(child: widget),
    );

    final state =
        tester.state(find.byType(BreathingHalo)) as dynamic;

    await state.startBreathing();

    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(calmTriggered, true);
  });
}

class TestWidgetWrapper extends StatelessWidget {
  final Widget child;
  const TestWidgetWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }
}
