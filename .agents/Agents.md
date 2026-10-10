# Guía de agentes — Night Jump

## Propósito del proyecto

Night Jump es un arcade móvil sin conexión, con interfaz en español y control de un toque para saltar. Está dirigido a sesiones casuales: jugar, superar récords personales, completar misiones, ganar Stardust, desbloquear temas y compartir resultados.

Están implementadas tres dificultades, tutorial jugable, escudos automáticos, tres misiones diarias y una semanal, cuatro temas, ajustes locales y tarjeta de resultados. Los récords son personales y separados por dificultad; no hay rankings globales, amigos, ligas, temporadas remotas, autenticación ni backend. La versión `1.0.1+2` es candidata a distribución, no prueba de publicación. Consulta [README.md](README.md), [docs/RELEASE_1_0.md](docs/RELEASE_1_0.md) y [docs/RELEASE_1_0_1.md](docs/RELEASE_1_0_1.md).

## Stack y plataformas

- Dart: restricción `^3.13.1` en `pubspec.yaml`. Flutter no tiene versión fijada en el repositorio; la validación documentada utilizó Flutter `3.47.6` y Dart `3.13.5`.
- Dependencias declaradas: Flame `^1.38.2`, SharedPreferences `^2.5.5`, flame_audio `^2.12.2`, audioplayers `^6.8.1` y share_plus `^13.3.1`. Son rangos, no versiones bloqueadas.
- Validación: `flutter_test` e `integration_test` del SDK, flutter_lints `^6.0.0` y shared_preferences_platform_interface `^2.4.2` para simular fallos nativos de almacenamiento; iconos mediante flutter_launcher_icons `^0.14.3`.
- Plataformas configuradas: Android e iOS, incluyendo iPhone/iPad. No tratar web o escritorio como soportados por disponer de Flutter.
- Android: Gradle `9.3.1`, AGP `9.1.0`, Kotlin `2.4.0`, Java/JVM `21`. SDK y NDK se obtienen de las propiedades de Flutter, no de números fijados en esta guía.
- iOS: deployment target `15.0` en el proyecto Xcode, familias `1,2`, integración CocoaPods. Requiere macOS y Xcode para compilar.
- Fuentes empaquetadas: Sora y Space Grotesk. `assets/DESIGN.md` también propone Plus Jakarta Sans, pero no está declarada en `pubspec.yaml`.

## Estructura del repositorio

- `lib/main.dart` y `lib/utils/app.dart`: entrada y `MaterialApp`.
- `lib/features/game/`: motor `night_jump_game.dart`; física y peligros en `components/`; dificultad, generación, audio, récords y exportación en `state/`; UI en `overlays/` y montaje/lifecycle en `page/game_page.dart`.
- `lib/features/home/`: menú y componentes visuales reutilizables.
- `lib/features/missions/`, `themes/`, `settings/`: repositorios en `state/`, pantallas en `page/` y componentes en `widgets/` cuando corresponda.
- `lib/features/leaderboard/`: nombre histórico; contiene los récords personales, no un servicio de rankings.
- `lib/utils/progress_store.dart`: persistencia compartida del progreso; `theme/` y `responsive/`: colores y adaptación de interfaz.
- `assets/`: audio, imágenes, fuentes y referencia visual. `android/` e `ios/`: configuración nativa.
- `test/`: pruebas de motor, generación, persistencia, lifecycle, galería y compartir. `integration_test/` y `test_driver/`: persistencia nativa entre procesos y benchmark en profile. `tool/validate_release.sh`: validación Android en copia temporal local. `docs/`: notas de distribución.

Añade código a la funcionalidad correspondiente; conserva la separación existente entre motor, repositorios y widgets. No crees capas globales para una necesidad local.

## Preparación y comandos

Ejecuta desde la raíz con Flutter compatible con el rango de Dart. Android requiere SDK y JDK 21; iOS requiere Xcode y CocoaPods. Comprueba el entorno con `flutter doctor -v` y los destinos con `flutter devices`.

```bash
flutter pub get
flutter run -d <device-id>
dart format lib test integration_test test_driver
flutter analyze
flutter test --coverage
flutter build appbundle --release
flutter build ios --release --no-codesign
```

Instalación, análisis, pruebas y ambas compilaciones release fueron ejecutados en la validación documentada. `flutter run` es el comando de desarrollo disponible; esa validación no acredita una sesión interactiva en dispositivo físico. Ejecuta pruebas puntuales con `flutter test test/progress_test.dart`, sustituyendo el archivo según el cambio.

En volúmenes externos de macOS, archivos AppleDouble `._*` pueden interferir con tests y recursos Android. `bash tool/validate_release.sh` copia el proyecto a `/private/tmp`, instala dependencias, analiza, ejecuta tests y genera el bundle; requiere Bash, rsync, mktemp y Flutter. Conserva la copia y muestra su ruta. No publica ni instala el juego; su ruta temporal es específica de macOS.

La firma Android usa `.env` en la raíz, basado en `.env.example`; sin `.env` el release queda sin firma. El build iOS anterior también queda sin firma. Sigue las instrucciones de distribución existentes, sin incluir claves privadas.

## Arquitectura y convenciones

- El motor es un `FlameGame` con detección de colisiones y taps. Conserva sus estados `menu`, `countdown`, `playing`, `paused` y `gameOver`; no permitas avance de física, cuenta atrás o protección al estar pausado.
- El estado observable usa `ValueNotifier` y widgets con `ValueListenableBuilder`; también hay estado local y `FutureBuilder`. No introducir Riverpod, Bloc o GoRouter sin una necesidad autorizada. Los repositorios y el juego permiten inyección para pruebas.
- La navegación usa `Navigator`, rutas Material, diálogos y bottom sheets. Registra cada overlay Flame en `GamePage.overlayBuilderMap`.
- Centraliza balance en `game_difficulty.dart` y física/generación en `gate_planner.dart`; conserva IDs persistidos `chill`, `classic`, `intense`. Valida trayectorias reales al ajustar velocidad, gravedad, salto, huecos o peligros.
- Un escudo se consume automáticamente una vez por colisión; la recuperación despeja peligros y protege durante 1,5 segundos de juego activo. Evita callbacks duplicados y componentes pendientes al reiniciar.
- Usa los repositorios existentes para datos. Las escrituras de saldo, compras, premios, récords y temas pasan por la cola serializada de `ProgressStore`, en `night_jump.progress.v1`. No eludas esa cola con escrituras paralelas a preferencias.
- Conserva la migración de claves antiguas y el récord legado sin dificultad; no atribuyas ese récord a un modo arbitrario. Las partidas de práctica no generan moneda ni récords.
- Ajustes y nuevas preferencias pertenecen a `SettingsRepository` con claves `settings.*`. Define su comportamiento al restablecer progreso; actualmente se conservan preferencias y tutorial completado.
- Canaliza efectos de sonido por `SoundService`; un fallo de audio no debe romper la partida. Respeta las preferencias reales de sonido y vibración y libera reproductores, timers y listeners al salir.
- Mantén `snake_case` para archivos, `UpperCamelCase` para tipos y `lowerCamelCase` para miembros; aplica los lints de `analysis_options.yaml` y `dart format`. Sigue las convenciones del archivo afectado.
- Captura errores esperables de plugins/persistencia en su frontera, muestra feedback útil y evita confirmar una operación antes de guardarla. Protege acciones asíncronas frente a taps repetidos y widgets descartados.

## Experiencia de usuario

- Mantén texto español, tono sereno, estética nocturna neón y legibilidad de obstáculos. Reutiliza `AppColor`, paletas y componentes existentes; efectos y celebraciones no deben tapar el recorrido.
- Para cargas muestra progreso; para listas vacías explica la situación; para compras, premios y compartir comunica éxito o error y desactiva la acción mientras se procesa. Un récord vacío no necesita jugadores simulados.
- Respeta SafeArea, tamaños de texto accesibles, contraste, etiquetas de controles y preferencias de movimiento reducido en animaciones Flutter. Usa los helpers responsive existentes: tablet desde 600 px y contenido limitado a 560 px cuando corresponda.
- El campo de juego mantiene coordenadas lógicas de 400×720 mediante `FittedBox`; adaptar la pantalla no debe cambiar la física. Revisa móviles pequeños, tablets y paisaje sin recortes ni controles inaccesibles.
- Al regresar de segundo plano exige una acción explícita para continuar. Reintentar conserva dificultad y evita repetir el tutorial completado.
- Preserva saldo, temas y récords al cerrar/reabrir. El resumen y la tarjeta compartida deben describir resultados locales, no posiciones globales.

## Seguridad y datos

- No incluyas secretos, credenciales ni datos personales en código, documentación o logs. Usa la configuración nativa existente; respeta archivos ignorados y no añadas keystores ni `.env` al control de versiones.
- El progreso es local mediante SharedPreferences, no almacenamiento seguro para secretos. No hay autenticación ni autorización remota que deban simularse.
- Valida cantidades, saldo, identificadores de temas/modos y datos migrados; conserva la protección contra premios o cargos repetidos. Gestiona errores de plataforma al compartir y permisos solo si una funcionalidad los necesita.
- `ResultShareService.verifiedDownloadUrl` está vacío porque no existe enlace de descarga verificado. Compártese la imagen sin URL hasta confirmar una real; no inventes enlaces.
- No borres datos, restablezcas progreso, cambies identificadores de aplicación ni realices operaciones destructivas sin autorización explícita. No incorpores backend o servicios externos a una tarea de mantenimiento offline.

## Pruebas y validación

- Para Dart/Flutter ejecuta formato, `flutter analyze` y los tests afectados; usa la suite completa si cambias estado compartido, persistencia o el motor. Para documentación valida referencias y `git diff --check`; no necesita reconstruir el juego.
- Persistencia/economía: `progress_test.dart` cubre migración, separación de récords, calendario semanal, compras concurrentes, premios únicos y conservación de ajustes.
- Física/balance: `gate_planner_test.dart` valida trayectorias a través de 1.000 barreras por modo; complementa con `game_test.dart` y juego manual cuando cambie la sensación de control.
- Lifecycle/interacción: `game_lifecycle_test.dart` cubre tutorial, vibración, escudos, pausa, reinicios, salida durante guardado y tamaños de pantalla. Galería: `theme_gallery_test.dart`.
- Compartir: `result_share_test.dart` valida PNG y parámetros del plugin; genera `build/qa/result-card.png` para inspección visual. El mock no sustituye comprobar la hoja nativa Android/iOS, cancelación y ancla iPad.
- QA nativa: sigue `docs/NATIVE_QA.md` para ejecutar seed y verify en procesos separados y el benchmark en profile. Sus prefijos de SharedPreferences están aislados del progreso real; no desinstales una app del jugador para resolver firmas. Una suite preparada o compilada no equivale a una prueba física aprobada.
- Para cambios nativos o dependencias compila la plataforma afectada. Antes de distribuir sigue las comprobaciones físicas de `docs/RELEASE_1_0.md`: modo avión, bloqueo/reanudación, cierre/reapertura, compartir, rendimiento y balance casual.

## Flujo de trabajo del agente

1. Lee este archivo y las instrucciones aplicables antes de modificar; revisa `git status` y entiende el flujo afectado. Respeta instrucciones de subdirectorios dentro de su alcance.
2. `.agents/Agents.md` es una guía heredada: conserva sus criterios de calma, justicia, español, lectura neón y reutilización. Esta guía actualiza sus datos obsoletos sobre rankings, balance y escudos y sustituye su regla de commits automáticos. Ante conflictos prevalecen las instrucciones del usuario.
3. Limita cambios al objetivo solicitado; preserva cambios del usuario y evita refactorizaciones ajenas. Reutiliza componentes y dependencias; justifica cualquier dependencia nueva.
4. Actualiza documentación si cambia comportamiento o configuración. Respeta `.gitignore`; no incluyas artefactos generados ni cambios incidentales de locks, salvo que sean parte del objetivo.
5. Ejecuta verificaciones pertinentes y comunica resultados y límites. No afirmes que pasó una prueba que no ejecutaste.
6. No hagas commits, pushes ni despliegues sin petición o autorización previa del usuario. No es obligatorio crear ramas para una tarea que no lo solicita.

## Criterios de finalización

La tarea está completa cuando cumple el comportamiento solicitado, contempla errores y estados relevantes, mantiene convenciones y datos existentes, y supera las verificaciones aplicables que pueden ejecutarse. Comunica archivos afectados, resultados de validación y cualquier comprobación pendiente con su motivo.

## Limitaciones y aspectos por confirmar

- No hay configuración CI/CD versionada; las verificaciones actuales son locales. La suite `integration_test` requiere hardware y permisos nativos. No afirmar validación automática remota.
- Firmas de distribución, publicación y enlace de descarga requieren configuración o confirmación del propietario. Un build sin firma no es un artefacto listo para subir a una tienda.
- Falta validación física documentada de compartir, persistencia entre aperturas y rendimiento prolongado; los widget tests y builds no la sustituyen. El balance semanal y el tiempo del primer desbloqueo requieren prueba casual antes de declararlos definitivos.
