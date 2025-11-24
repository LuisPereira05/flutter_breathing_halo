import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:breathing_halo/breathing_halo.dart';

/// Serviço de batimentos falso para testes
class FakeHeartRateService extends HeartRateService {
  final StreamController<int> _controller = StreamController<int>.broadcast();
  int _current = 75;
  bool _isMonitoring = false;

  final List<int> sequence;

  FakeHeartRateService(this.sequence);

  void emit() {
    if (!_controller.isClosed) {
      final next = sequence.isNotEmpty ? sequence.removeAt(0) : _current;
      _current = next;

      debugPrint("[FakeHR] Emitting HR = $next");

      _controller.add(next);
    }
  }

  @override
  Stream<int> get heartRateStream {
    return _controller.stream.map((hr) {
      debugPrint("[FakeHR] Stream event → HR = $hr");
      return hr;
    });
  }

  @override
  int get currentHeartRate => _current;
  @override
  bool get isMonitoring => _isMonitoring;

  @override
  Future<bool> isAvailable() async {
    debugPrint("[FakeHR] isAvailable() → true");
    return true;
  }

  @override
  Future<bool> requestPermissions() async {
    debugPrint("[FakeHR] requestPermissions() → true");
    return true;
  }

  @override
  Future<bool> startMonitoring() async {
    _isMonitoring = true;
    debugPrint("[FakeHR] startMonitoring()");
    return true;
  }

  @override
  Future<bool> stopMonitoring() async {
    _isMonitoring = false;
    debugPrint("[FakeHR] stopMonitoring()");
    return true;
  }

  void dispose() {
    debugPrint("[FakeHR] dispose()");
    _controller.close();
  }
}

void main() {
  testWidgets('BreathingHalo - inicia e muda estados corretamente',
      (WidgetTester tester) async {
    bool sessionStarted = false;

    debugPrint("===== INICIANDO TESTE =====");

    final fakeHeartRate = FakeHeartRateService([
      68,
      66,
      65,
      65,
      64,
    ]);

    final widget = MaterialApp(
      home: BreathingHalo(
        config: const BreathingConfig(
          autoStart: false,
          showHeartRate: true,
          showTimer: true,
          calmThreshold: 5,
          calmCheckDelay: 1,
          useEnglish: true,
        ),
        heartRateService: fakeHeartRate,
        onSessionStart: () {
          sessionStarted = true;
          debugPrint("[TEST] Sessão iniciada");
        },
      ),
    );

    await tester.pumpWidget(widget);
    debugPrint("[TEST] Widget carregado");

    expect(find.text("Start"), findsOneWidget);
    debugPrint("[TEST] Tela inicial OK");

    await tester.tap(find.text("Start"));
    await tester.pump();
    debugPrint("[TEST] Botão Start pressionado");

    expect(sessionStarted, isTrue);

    await tester.pump(const Duration(seconds: 1));
    debugPrint("[TEST] Passou 1 segundo → deve estar em INHALE");

    expect(find.text("Inhale"), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    debugPrint("[TEST] Passaram mais 3 segundos");

    debugPrint("[TEST] Enviando HR para tentar ativar Calm State");
    fakeHeartRate.emit();
    await tester.pump(const Duration(milliseconds: 50));

    debugPrint("[TEST] Procurando Calm State na tela...");
    expect(find.textContaining("Calm State"), findsOneWidget);

    debugPrint("[TEST] Calm State encontrado!");

    expect(find.textContaining("bpm"), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    debugPrint("[TEST] Passaram mais 3s, verificando Calm State novamente");

    expect(find.textContaining("Calm State"), findsOneWidget);

    debugPrint("===== TESTE FINALIZADO =====");
  });
}
