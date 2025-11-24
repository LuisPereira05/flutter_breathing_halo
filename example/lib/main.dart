import 'package:flutter/material.dart';
import 'package:breathing_halo/breathing_halo.dart';

void main() {
  runApp(const WatchBreathingHaloApp());
}

class WatchBreathingHaloApp extends StatelessWidget {
  const WatchBreathingHaloApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: BreathingHalo(
            config: const BreathingConfig(
              size: 220,                // perfect for round screens
              breathDuration: Duration(seconds: 4),
              showHeartRate: true,
              showTimer: true,
            ),
            onCalmStateAchieved: () {
              debugPrint('User achieved calm state!');
            },
            onHeartRateChanged: (hr) {
              debugPrint('Heart rate: $hr bpm');
            },
          ),
        ),
      ),
    );
  }
}