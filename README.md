# Night Jump

Un juego rápido, directo y fluido pensado para sesiones nocturnas.

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

Proyecto Flutter estándar:

- `lib/` — código fuente de la app
- `test/` — pruebas unitarias y de widgets
- `pubspec.yaml` — dependencias y configuración del paquete

## Recursos de Flutter

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)
