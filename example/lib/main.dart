import 'package:flutter/material.dart';
import 'package:breathing_halo/breathing_halo.dart';

void main() {
  runApp(const WatchBreathingHaloApp());
}

class WatchBreathingHaloApp extends StatefulWidget {
  const WatchBreathingHaloApp({Key? key}) : super(key: key);

  @override
  State<WatchBreathingHaloApp> createState() => _WatchBreathingHaloAppState();
}

class _WatchBreathingHaloAppState extends State<WatchBreathingHaloApp> {
  late HeartRateService _hrService;

  @override
  void initState() {
    super.initState();
    _initHeartRate();
  }

  Future<void> _initHeartRate() async {
    final wear = WearOSHeartRateService();
    final available = await wear.isAvailable();

    setState(() {
      _hrService = available ? wear : SimulatedHeartRateService();
    });

    _hrService.startMonitoring();
  }

  @override
  void dispose() {
    _hrService.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: BreathingHalo(
            config: BreathingConfig(
              size: 220,                // perfect for round screens
              breathDuration: Duration(seconds: 4),
              showHeartRate: true,
              showTimer: true,
            ),
          ),
        ),
      ),
    );
  }
}
