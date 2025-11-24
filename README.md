# BreathingHalo
### Luis Felipe Castillo Pereira, Matías Andrés Ramírez Porto.

Um widget de respiração guiada inteligente para Flutter, com monitoramento de frequência cardíaca e efeitos visuais relaxantes. Ideal para meditação, relaxamento ou pausas de respiração.

![BreathingHalo](testeGif.gif)

---

📦 Descrição

O `BreathingHalo` permite criar sessões de respiração guiada com animações suaves e feedback visual de calma, além de monitorar a frequência cardíaca em tempo real. Ele inclui:

- Ciclos de respiração (inspirar, segurar, expirar, segurar).
- Mudança de cores para indicar estado calmo.
- Monitoramento de frequência cardíaca (simulado ou real via serviço personalizado).
- Temporizador e indicadores visuais.
- Personalização completa via `BreathingConfig`.

---

⚙️ Instalação

Adicione o pacote no `pubspec.yaml` do seu projeto Flutter usando Git:

```
dependencies:
  flutter:
    sdk: flutter
  breathing_halo:
    git:
      url: https://github.com/LuisPereira05/flutter_breathing_halo
      ref: main  # ou uma branch/tag específica
```
Depois, rode:

```
flutter pub get
```

> O `ref` pode ser uma branch, tag ou commit específico. Se não informado, será usada a branch `main`.

---

🛠️ Uso

Importe o widget no seu código:

```
import 'package:breathing_halo/breathing_halo.dart';
```

Exemplo de uso:

```
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: BreathingHalo(
          config: BreathingConfig(
            size: 250,
            autoStart: true,
            showHeartRate: true,
            calmThreshold: 5,
            calmCheckDelay: 10,
            normalColor: Colors.blue,
            calmColor: Colors.green,
            normalBackground: [Colors.blue, Colors.purple],
            calmBackground: [Colors.green, Colors.teal],
          ),
          onHeartRateChanged: (hr) {
            print("Frequência cardíaca: $hr bpm");
          },
          onCalmStateAchieved: () {
            print("Estado calmo alcançado!");
          },
        ),
      ),
    );
  }
}
```
---

🔧 Configuração

`BreathingConfig` permite ajustar:

- `size` → Tamanho do halo.
- `autoStart` → Iniciar automaticamente.
- `showHeartRate` → Exibir frequência cardíaca.
- `hideButton` → Esconder botão de controle.
- `calmThreshold` → Queda de bpm para atingir estado calmo.
- `calmCheckDelay` → Tempo mínimo antes de verificar estado calmo.
- `normalColor` / `calmColor` → Cores do halo.
- `normalBackground` / `calmBackground` → Gradientes de fundo.
- `minScale` / `maxScale` → Escala da animação de respiração.
- `breathDuration` → Duração de cada fase do ciclo de respiração.
- `useEnglish` → Mostrar instruções em inglês.

---


📄 Callbacks disponíveis

- `onHeartRateChanged(int hr)` → Chamado a cada mudança de bpm.
- `onCalmStateAchieved()` → Chamado quando o usuário atinge estado calmo.
- `onSessionStart()` → Chamado ao iniciar a sessão.
- `onSessionStop()` → Chamado ao parar a sessão.

