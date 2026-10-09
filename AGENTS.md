# AGENTS.md

Instrucciones para agentes que trabajan en este repositorio. Consultar README y configuración para el detalle; este archivo no autoriza publicación ni cambios fuera de la tarea.

## Propósito del proyecto

Juego arcade nocturno sin conexión: controlar un orbe, superar obstáculos, usar escudos y progresar en misiones/temas con puntuaciones locales. Mantener desafío justo y tono tranquilo; los rivales del ranking son muestras locales.

## Stack y plataformas

Flame ^1.38.2, flame_audio ^2.12.2, audioplayers y SharedPreferences; no backend declarado.

Requisito Dart declarado: `^3.13.1` en `pubspec.yaml`; los rangos de dependencias no prueban la versión resuelta. No hay `.fvmrc` versionado; contrastar SDK con README y pubspec.

Proyectos de plataforma presentes: android, ios. Esto no garantiza que todos los plugins funcionen en cada plataforma.

## Estructura del repositorio

Motor en `lib/features/game/night_jump_game.dart`; física/colisiones en `components/`; dificultad/sonido/récord en `state/`. UI del juego en `overlays/` y registro en `page/game_page.dart`. `home`, `missions`, `leaderboard`, `themes`, `settings` son módulos separados. Diseño en `lib/utils/`; efectos en `assets/audio/`.

## Preparación y comandos

Requisitos: SDK Flutter compatible con pubspec. Android necesita su toolchain/JDK de Gradle; iOS requiere macOS/Xcode y la gestión de dependencias del proyecto. Integraciones Firebase requieren configuración de desarrollo existente.

| Acción | Comando desde la raíz |
| --- | --- |
| Dependencias | `flutter pub get` |
| Ejecutar | `flutter run -d <dispositivo>` |
| Formato | `dart format lib test` |
| Análisis | `flutter analyze` |
| Pruebas | `flutter test` |
| Build Android de comprobación | `flutter build apk --debug` |



Los comandos fueron contrastados con dependencias, documentación/configuración y suites presentes; no ejecutados al redactar este archivo. Build de distribución requiere firma/configuración adicional; no sustituye despliegue.

## Arquitectura y convenciones

Registrar todo overlay en `overlayBuilderMap`. Usar GameStatus y GameDifficulty; consultar valores actuales en código, no copiar números históricos de la guía. Mantener hitbox indulgente, pausa sin avance de tiempo y conteo único de obstáculos/recompensas. Todos los sonidos pasan por SoundService; fallo de audio no interrumpe partida. Persistir ajustes en SettingsRepository y definir su comportamiento al restablecer progreso.

Conservar nombres y convenciones del módulo: Dart snake_case para archivos, UpperCamelCase para tipos y lowerCamelCase para miembros. No renombrar APIs/campos persistidos incidentalmente; respetar lints de analysis_options.yaml.

## Experiencia de usuario

Reutilizar AppColor y utilidades responsive; mantener copy español sin culpa ni urgencia. Respetar movimiento reducido, sonido/hápticos desactivados y controles claros. Probar cuenta atrás, diálogo de escudo, pausa, game over y reintento con pantallas pequeñas.

En el flujo afectado, contemplar carga, vacío, éxito y error; dar feedback claro, conservar entradas/datos ante fallos y permitir recuperación. Reutilizar componentes visuales; revisar semántica, foco, contraste y escalado de texto.

## Seguridad y datos

No incluir secretos, credenciales ni datos personales en código, documentación o logs. Usar configuración de entorno existente, validar entradas y manejar fallos de servicios. Respetar autenticación, autorización y permisos. No ejecutar operaciones destructivas sobre datos sin autorización explícita.

No añadir red, cuentas o analítica como parte incidental de una mejora. No borrar puntuaciones, ajustes o desbloqueos sin autorización explícita. No presentar leaderboard local como competición remota real.

## Pruebas y validación

Ejecutar `test/game_test.dart` para dificultad/motor y `test/theme_gallery_test.dart` para temas. Validar física, colisiones, escudos, pausa, reintento, récord por dificultad, canje de polvo y persistencia al reiniciar; cambios de rendering/audio requieren smoke test en dispositivo.

Ejecutar análisis y pruebas relevantes según el cambio; compilar solo plataformas afectadas. Un cambio exclusivamente documental requiere revisar rutas, comandos, alcance y diff, sin pruebas artificiales que repliquen el texto. No afirmar que una prueba pasó si no se ejecutó.

## Flujo de trabajo del agente

Leer también `.agents/Agents.md`; conservar sus reglas válidas. Sus cifras/pendientes históricos se contrastan con código/configuración vigente. Leer instrucciones aplicables antes de modificar archivos, incluidas las de subdirectorios: su alcance local se respeta. Las instrucciones explícitas del usuario prevalecen.

1. Revisar estado del trabajo y comprender el flujo afectado antes de implementar.
2. Hacer cambios acotados al objetivo; respetar cambios existentes del usuario y evitar refactorizaciones ajenas.
3. Reutilizar componentes y dependencias disponibles; justificar dependencias nuevas.
4. Actualizar documentación si cambia comportamiento o configuración.
5. Ejecutar verificaciones pertinentes y comunicar resultados y pendientes con su motivo.
6. No hacer commits, push o despliegues salvo solicitud o autorización previa del usuario. Esta regla prevalece sobre recomendaciones de commit automático en guías antiguas.

No imponer una política nueva de ramas/commits; seguir documentación y CI existentes.

No activar workflows de publicación ni scripts de release como comprobación rutinaria.

## Criterios de finalización

La tarea cumple el comportamiento solicitado, contempla errores/estados relevantes, mantiene convenciones y pasa las verificaciones aplicables que puedan ejecutarse. Comunicar archivos modificados, resultados reales y cualquier validación pendiente con su motivo.

## Limitaciones y aspectos por confirmar

Solo hay proyectos nativos Android/iOS en el árbol revisado, aunque el README menciona más plataformas. No hay `.fvmrc`; escoger SDK compatible con el requisito Dart del pubspec. Los pendientes históricos de `.agents/Agents.md` deben contrastarse con código actual.
