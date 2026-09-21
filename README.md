# Night Jump

Un juego rápido, directo y fluido pensado para sesiones nocturnas. Toca para saltar,
atraviesa el hueco entre las barras de neón y suma un punto por cada obstáculo superado.

## Cómo se juega

- **Toca en cualquier lugar para saltar.** Al empezar verás una cuenta atrás de 3-2-1-¡GO! para prepararte.
- **Elige tu ritmo** al pulsar para jugar: Tranquilo (lento, hueco amplio), Clásico (el ritmo original) o Intenso (rápido, hueco justo). Se recuerda tu elección.
- **La dificultad sube suavemente** con el tiempo de vuelo (curva logarítmica, tope a ~90 s): más velocidad y más frecuencia, pero el hueco nunca se estrecha.
- **Hitbox justa**: la colisión es menor que el gráfico (~73 %), así no hay muertes "invisibles".
- **Aviso de bordes**: si el orbe brilla en rojo, estás peligrosamente cerca del techo o del suelo.
- **Pausa cuando quieras** con el botón superior derecho (cambia a ▶ en pausa) y continúa donde lo dejaste.
- **Sonido neón** generado proceduralmente: salto, punto, GO, game over y clics de menú. Se puede silenciar en ajustes.
- **Guía inicial**: la primera vez se muestra un diálogo de "Cómo jugar", recuperable con el icono de ayuda (?).
- **Progreso local**: récord, misiones diarias/semanales con polvo astral, paletas desbloqueables y ranking. Todo en el dispositivo.

## Estética visual

- **Contraste alto**: fondo oscuro y frío que hace resaltar intensamente al jugador y los obstáculos, dibujados con colores neón brillantes.
- **Movimiento suave**: sin tirones ni saltos de frames, para no cansar la vista durante partidas largas.
- **Interacción clara**: los elementos con los que el jugador interactúa (personaje, obstáculos) siempre destacan sobre el fondo gracias al contraste de color y brillo.

## Requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (canal estable, Dart SDK `^3.13.1` — ver `pubspec.yaml`)
- Un dispositivo, emulador o navegador soportado por Flutter (Android, iOS, Web, Windows, macOS, Linux)

## Configuración del proyecto

Clonar el repositorio e instalar las dependencias:

```bash
git clone https://github.com/Jorge-Tropigas/night-jump.git
cd night_jump
flutter pub get
```

Ejecutar la app en modo debug:

```bash
flutter run
```

Ejecutar los tests:

```bash
flutter test
```

Generar un build de release (ejemplo Android):

```bash
flutter build apk --release
```

## Estructura

- `lib/features/game/` — motor Flame (orbe, obstáculos, starfield), estados (dificultad, sonido, puntuación) y overlays (menú, HUD, cuenta atrás, pausa, game over, diálogos de ayuda y dificultad)
- `lib/features/home/` — pantalla principal y menú
- `lib/features/missions/` — retos diarios/semanales y polvo astral
- `lib/features/leaderboard/` — rankings
- `lib/features/themes/` — galería de paletas neón
- `lib/features/settings/` — ajustes (sonido, vibración, restablecer progreso)
- `lib/utils/` — tema, colores y responsive
- `assets/images/` — icono y gráficos
- `assets/audio/` — efectos de sonido procedurales (`jump`, `score`, `go`, `game_over`, `ui` en WAV)
- `test/` — pruebas unitarias y de widgets
- `pubspec.yaml` — dependencias y configuración del paquete

## Recursos de Flutter

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)
