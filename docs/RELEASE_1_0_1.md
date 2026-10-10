# Night Jump 1.0.1 — candidato de mantenimiento

Versión `1.0.1+2`. Mantiene el alcance offline de 1.0, los cuatro temas,
las dificultades y el balance existente. No añade servicios ni dependencias de
producción. Se declara la interfaz de SharedPreferences como dependencia de
desarrollo (ya era transitiva) para simular fallos de escritura nativa.
También incorpora `integration_test` del SDK como dependencia de desarrollo
para QA en hardware; las instrucciones están en [NATIVE_QA.md](NATIVE_QA.md).

## Correcciones

- Stardust por barrera usa checkpoints acumulados con identificador de
  partida. Repetir o recibir un checkpoint anterior no acredita moneda extra;
  finalizar recupera barreras cuyo guardado individual falló.
- Resultados permite reintentar el guardado. Conserva la celebración del
  récord y los premios mostrados aunque falle una lectura posterior al cobro;
  reintentar no duplica misiones ni premios.
- Restablecer progreso limpia claves antiguas dentro de la cola de
  persistencia. Conserva el documento vacío y las preferencias, evitando
  borrar recompensas encoladas después del restablecimiento.
- La galería ofrece error y reintento en lugar de carga indefinida; confirmar
  tema bloquea taps repetidos y muestra fallos de guardado sin cerrar la página.
- Una escritura rechazada o fallida recarga la caché de SharedPreferences;
  evita que una compra fallida aparezca aplicada o se confirme en una lectura
  posterior. Si también falla la recarga, exige recuperarla antes de operar.

## Datos y actualización

Continúa usando `night_jump.progress.v1`, con claves adicionales internas
`missions.gate_run` y `missions.gate_count`. No elimina progreso al actualizar
ni reasigna récords legados. Restablecer sigue siendo una acción explícita.
Los checkpoints corresponden a una partida activa; no son una API para
registrar múltiples partidas simultáneas o resultados históricos.

El cálculo del primer desbloqueo se revisó para partidas de 6, 8 y 10 barreras:
requiere respectivamente cinco, cuatro y tres partidas completadas en el mismo
día. Se corrige la estimación del README a 3–5; no se modifican precios ni premios.
Esta simulación valida la economía, no sustituye medir dificultad con jugadores.

## Validación

Ejecutadas durante la sesión del 8–9 de octubre de 2026 sobre este parche:

- `flutter analyze`: sin incidencias.
- `flutter test --coverage`: 37 tests aprobados. Incluye nueve regresiones
  adicionales a 1.0: checkpoints, reintento de resultados, restablecimiento
  concurrente, galería, primer desbloqueo casual y fallos de escritura/recarga
  de SharedPreferences.
- `flutter build appbundle --release`: bundle Android generado (50,6 MB),
  sin firma. El helper imprime la ruta del artefacto en su copia temporal.
- `flutter build ios --release --no-codesign`: compilación exitosa (20,1 MB),
  sin firma y sin instalación en dispositivo físico.
- Formato Dart y `git diff --check`: sin cambios pendientes de formato ni
  errores de espacios.

La suite y análisis se ejecutaron también desde la copia temporal creada por
`bash tool/validate_release.sh`, evitando archivos AppleDouble del volumen
externo. Los tests de galería se repitieron tras aislar sus dependencias.
La última suite completa se ejecutó en el workspace especificando los seis
archivos de test para excluir AppleDouble; incluye la comprobación adicional
de balance sin cambios posteriores en el código de producción compilado.

Se verificó `CFBundleShortVersionString = 1.0.1` y `CFBundleVersion = 2` en
el artefacto iOS. En el AAB final, `llvm-objdump -p` mostró alineación de los
segmentos ELF LOAD de al menos 16 KB en las doce bibliotecas de las tres ABI.
Esto no sustituye probar APKs generados ni un dispositivo con páginas de 16 KB.

En la validación adicional del 9 de octubre se generaron AAB y APK release.
El APK pasó `zipalign -c -P 16 -v 4`, declara versión `1.0.1` y no solicita
permiso INTERNET. Sigue sin firma: `apksigner verify` lo rechaza, como se
espera de un paquete sin credenciales de distribución. Los paquetes conservados
están en `build/qa/artifacts/` (ignorados por Git), no son publicaciones.

La app iOS debug compilada en una copia local APFS pasó
`codesign --verify --deep --strict` con firma de desarrollo. Se detuvo el
intento de prueba física durante la preparación de símbolos de Xcode para
evitar volver a llenar el disco interno. No se obtuvo un resultado de
persistencia ni de rendimiento. No confundir firma de desarrollo con distribución.

Se añadieron pruebas nativas de persistencia seed/verify y un benchmark
profile de diez minutos, con datos separados del jugador. El formato de los
tres archivos Dart está comprobado; su ejecución física permanece pendiente.

La compilación Android emite una advertencia sobre el plugin Kotlin externo
y su compatibilidad con futuras versiones de Flutter. La configuración actual
compila; no se realizó una migración de toolchain ajena a este parche.

## Pendiente antes de distribución

Se mantienen los requisitos de [RELEASE_1_0.md](RELEASE_1_0.md): firmas del
propietario, compartir en Android/iPhone/iPad, cierre/reapertura y actualización
en dispositivo físico, perfil prolongado y prueba casual de balance.
No hay URL de descarga verificada ni publicación en tiendas acreditada.
