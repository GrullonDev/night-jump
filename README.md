# Night Jump 1.0

Arcade nocturno sin conexión para Android e iOS. Toca para saltar, supera tu
récord, completa misiones, gana Stardust, desbloquea temas y comparte tu vuelo.

## Cómo jugar

La primera partida ofrece una práctica jugable: toca para saltar y supera tres
barreras fáciles. No entrega moneda ni récords y permite recuperarte sin perder.
Ayuda (?) permite repetirla. Al completarla se recuerda en el dispositivo.

- Tranquilo: velocidad baja, huecos amplios, pocas barreras y sin peligros extra.
- Clásico: experiencia principal con progresión suave.
- Intenso: mayor velocidad y encuentros anunciados con minas, cohetes y minas
  flotantes. Se mantienen fuera del corredor central seguro.
- Cada barrera superada entrega un punto y un Stardust. Las gemas verdes
  recargan escudos (máximo tres); comienzas con uno.
- Al chocar, un escudo se consume automáticamente, limpia los peligros y
  protege durante 1,5 segundos de juego. El halo y el contador explican el estado.
- La pausa y el bloqueo de pantalla congelan la partida, la protección y la
  cuenta atrás. Al volver debes pulsar Continuar.
- Los resultados ofrecen Jugar otra vez (mismo modo, sin tutorial ni cuenta
  atrás), Compartir resultado e Inicio. Incluyen causa del choque y misiones.

## Progreso y balance

Mis récords muestra Tranquilo, Clásico e Intenso por separado. No hay rivales
simulados, amigos, ligas, temporadas ni clasificaciones globales.

Las tres misiones diarias se conservan: 30 obstáculos (+150), tres partidas
(+80) y diez obstáculos en una partida (+100). La misión semanal pide 210
obstáculos (+500) y se reinicia el lunes. La moneda única es Stardust.

Se conservan los cuatro temas: Default y Cyberpunk gratuitos; Aurora cuesta
200 y Eclipse 500. Un día con las tres misiones otorga 330 más los obstáculos.
Con partidas casuales de 6–10 puntos, el primer tema pagado es alcanzable en
aproximadamente 4–5 partidas; 210 por semana equivale a siete objetivos diarios
de 30. Son valores razonados para 1.0; la duración real y diversión todavía
deben revisarse mediante pruebas con jugadores.

El balance del motor está centralizado en
`lib/features/game/state/game_difficulty.dart`. `gate_planner.dart` usa gravedad,
impulso, tamaño de colisión y tiempo entre barreras para limitar los cambios del
corredor. Las pruebas verifican una trayectoria repetible y atravesable en
1.000 barreras por modo. El área lógica de juego es 400 × 720 y se ajusta sin
deformación a la pantalla; se usan márgenes en formatos anchos.

## Migración y persistencia

La primera lectura copia las claves existentes al documento versionado
`night_jump.progress.v1`. Récords por modo, Stardust, misiones, recompensas ya
cobradas y temas seleccionados/desbloqueados se conservan. Las claves anteriores
quedan intactas como referencia; la nueva versión usa el documento migrado.

Un récord antiguo `night_jump.high_score` sin modo se muestra como “Récord
anterior sin modo”. No se asigna arbitrariamente a una dificultad. El objetivo
semanal cambia sin borrar el progreso vigente ni recompensas ya cobradas; la
clave semanal anterior se convierte al lunes correspondiente.

Saldo, recompensas y compras usan una cola compartida entre repositorios.
Cobrar una misión y marcarla cobrada forma una sola escritura. Cobrar un tema y
desbloquearlo también. Repetir la compra no vuelve a cobrar. Un resultado tiene
identificador de partida para impedir su registro repetido. Stardust por barrera
se guarda durante el vuelo; misiones y récords se registran al finalizar.

`settings.tutorial_completed.v1` recuerda la práctica completada. La antigua
`settings.how_to_play_seen` solo representaba un diálogo abierto y no se toma
como práctica completada. Restablecer progreso conserva preferencias y la nueva
marca de tutorial, pero elimina récords, moneda, misiones y temas pagados.

## Compartir

Se exporta un PNG independiente de 1080 × 1350 con Night Jump, puntuación, modo,
récord personal, “Can you beat me?” y atribución a GrullonDev. Funciona sin
conexión y no presenta resultados locales como ranking global.

No se ha configurado una URL pública de descarga. La imagen se comparte sin
enlace. `ResultShareService.verifiedDownloadUrl` debe permanecer vacía hasta
verificar una URL real de descarga o prueba. iPad recibe el rectángulo real del
botón para anclar correctamente la hoja de compartir.

Sora y Space Grotesk están incluidas, con sus licencias OFL; no se descargan
fuentes al jugar.

## Desarrollo y validación

Flutter 3.47 / Dart 3.13, Flame, shared_preferences y audio local.

```bash
git clone https://github.com/GrullonDev/night-jump.git
cd night-jump
flutter pub get
flutter run
flutter analyze
flutter test --coverage
```

En volúmenes externos de macOS, los archivos AppleDouble `._*` pueden romper
la búsqueda de tests y el procesamiento de recursos Android. El flujo
reproducible usa una copia temporal local y conserva el bundle para revisarlo:

```bash
bash tool/validate_release.sh
```

Consulta [docs/RELEASE_1_0.md](docs/RELEASE_1_0.md) para firmas, resultados de
validación y comprobaciones pendientes antes de distribución.
