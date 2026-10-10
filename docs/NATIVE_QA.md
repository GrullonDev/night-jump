# Validación nativa — Night Jump 1.0.1

Estas pruebas usan `integration_test` del SDK, no mocks de plugins. Son código
de QA, no una funcionalidad de producción. No declarar una prueba física
aprobada hasta obtener el resultado del dispositivo.

Estado del intento del 9 de octubre de 2026: compilación iOS debug y firma
verificada, pero preparación de símbolos detenida por falta de espacio interno.
Seed/verify y benchmark todavía no tienen resultados físicos. Liberar espacio
antes de reintentarlos; no borrar cachés personales o datos del jugador sin
autorización. Un driver interrumpido puede salir con código cero sin ejecutar
los tests: exigir el resumen de pruebas y el resultado del dispositivo.

## Requisitos y protección de datos

- Dispositivo de prueba desbloqueado; USB es preferible a Wi-Fi para iOS.
- Firma de desarrollo configurada localmente. No enviar contraseñas, claves
  privadas ni contenido de perfiles por chat o incluirlos en Git.
- En iOS, ejecutar desde filesystem local APFS: los archivos AppleDouble del
  volumen externo pueden invalidar la firma después de compilar. La copia
  temporal de `tool/validate_release.sh` excluye `._*`, Pods y artefactos viejos.
- Los tests usan prefijos `night_jump.qa.1_0_1.` y
  `night_jump.qa.profile.1_0_1.`, separados de `flutter.*` del jugador.
  Preparar fixtures solo reemplaza el documento QA; no llama a resetProgress
  ni clear sobre datos reales. No modificar IDs de aplicación ni desinstalar
  una app existente para resolver un error de firma.
- Usar un Android dedicado a QA sin datos de producción: instalar una app
  debug con una firma distinta puede requerir reemplazar la instalación.
  No autorizar ese reemplazo destructivo de forma implícita.

## Persistencia entre dos procesos

Desde una copia local actualizada, ejecutar los dos comandos por separado:

```bash
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/native_progress_test.dart -d <device-id> \
  --dart-define=NIGHT_JUMP_QA_PHASE=seed
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/native_progress_test.dart -d <device-id> \
  --dart-define=NIGHT_JUMP_QA_PHASE=verify
```

El segundo proceso exige un marcador escrito por el primero: no vuelve a
crear fixtures cuando faltan datos. Comprueba récords por modo, saldo, compra
de Aurora, selección, ajustes, tutorial, misiones cobradas una vez y menú real.
No equivale a probar una actualización desde todas las versiones anteriores.

Con el iPhone inalámbrico, este SDK rechaza `flutter test` por no publicar
el puerto de depuración y no acepta `--publish-port` en ese comando.
`flutter drive` habilita la publicación para iOS inalámbrico. Si Xcode copia
símbolos de soporte, mantener la conexión hasta que termine. Si aparece una
solicitud de permisos de depuración o firma, debe resolverla el propietario.

## Rendimiento sostenido

```bash
flutter drive --profile --driver=test_driver/integration_test.dart \
  --target=integration_test/game_performance_test.dart -d <device-id> \
  --dart-define=NIGHT_JUMP_QA_SECONDS=600
```

El benchmark realiza diez minutos de juego activo repartidos entre los tres
modos, con física y colisiones reales, taps automáticos y sonido activado.
La vibración se desactiva solo en las preferencias QA. Registra tiempos de
build/raster, GC, RSS por modo, barreras, reinicios y pausas de seguridad.
`NIGHT_JUMP_QA_SECONDS=30` permite un smoke test antes de la sesión larga.
El driver escribe `build/integration_response_data.json` por defecto.

Ejecutarlo en modo profile sobre hardware; resultados debug, de emulador o
de la propia automatización no garantizan 60 fps ni ausencia de fugas.
Revisar percentiles, crecimiento de memoria y pausas, y observar temperatura
y sensación de control mediante juego humano. No usar taps automáticos como
evidencia de diversión o dificultad adecuada para jugadores casuales.

## Compartir y controles del sistema

La suite nativa de persistencia no abre la hoja de compartir. Probar todavía
en Android, iPhone e iPad: abrir, cancelar, repetir, guardar la tarjeta en una
app local y comprobar legibilidad; no enviar resultados a terceros sin elegir
un destinatario autorizado. Verificar especialmente el ancla de iPad.

Probar bloqueo durante cuenta atrás, vuelo y protección; regresar debe exigir
Continuar. Probar modo avión con USB o sin debugger: cortar Wi-Fi durante
depuración inalámbrica rompe la conexión del test, no demuestra un fallo offline.
