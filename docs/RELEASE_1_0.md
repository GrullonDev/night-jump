# Night Jump 1.0 — release candidate

Base verificada el 8 de octubre de 2026: main `113de1a`, develop
`10feada`; main tiene tres commits exclusivos y develop ninguno. Rama de
implementación: `feat/night-jump-1.0`. Sin backend ni publicación automática.

## Preparar distribución

Android ya no usa la firma debug para release. Copia
`android/key.properties.example` a `android/key.properties` y configura la
clave privada de subida. El archivo y los keystores están ignorados por Git.
Sin credenciales, el bundle de validación queda sin firma y no debe subirse.

```bash
flutter build appbundle --release
# En un volumen externo macOS:
bash tool/validate_release.sh
flutter build ios --release --no-codesign
```

Para App Store, archiva y firma con las credenciales de distribución del
propietario. El build sin firma verifica compilación, no publicación.
Conserva el identificador `com.grullondev.night_jump` para que las actualizaciones
mantengan los datos del dispositivo.

## Cobertura automatizada

Validación ejecutada: 28 tests aprobados con cobertura; `flutter analyze`
sin incidencias. Build Android release generado sin firma, y build iOS release
compilado con `--no-codesign`. No se han publicado en ninguna tienda.

El SDK Android de esta máquina enlaza cmdline-tools de Homebrew. Eso hace que
`apkanalyzer` deduzca una raíz de SDK incorrecta y Flutter reporte falsamente
un error de símbolos. El helper proporciona la ubicación del SDK a través de
`APKANALYZER_OPTS`, sin modificar herramientas instaladas. La estructura del
bundle incluye las tablas de símbolos separadas para las tres arquitecturas.

- Migración de récords por modo, récord legado sin modo, saldo y temas.
- Compras simultáneas, cobros repetidos, saldo insuficiente y cantidades inválidas.
- Misiones cobradas una sola vez; migración semanal y semana entre años.
- Trayectoria con física real a través de 1.000 barreras por dificultad.
- Consumo único del escudo, expiración y pausa de la protección.
- Cuenta atrás congelada; regreso a primer plano requiere acción explícita.
- Cinco reinicios sin barreras antiguas ni orbes duplicados.
- Finalización persistida aunque la pantalla se descarte durante el guardado.
- Práctica mediante taps reales, sin moneda/records; preferencia de vibración.
- Inicio/resultados en 320×568, 430×932, 768×1024 y 844×390; galería en 320px.
- Exportación PNG 1080×1350; archivo, nombre y ancla de compartir correctos.

La tarjeta de muestra se genera en `build/qa/result-card.png`. Se inspeccionó
visualmente: título, cifra, dificultad, récord, reto y autor legibles y dentro
de los márgenes.

## Comprobaciones en dispositivos antes de publicar

Estas comprobaciones no equivalen a los tests ni a la compilación:

1. Android y iPhone/iPad: abrir la hoja nativa de compartir, cancelar y volver
   a compartir; guardar el PNG y comprobarlo en Fotos/archivos y una app receptora.
2. Jugar en modo avión; probar sonido desactivado, activado y vibración.
3. Bloquear en cuenta atrás, durante vuelo y durante protección. Al desbloquear
   no debe avanzar hasta Continuar; no debe sonar audio en segundo plano.
4. Cerrar/reabrir después de ganar Stardust, finalizar una partida y comprar un
   tema; actualizar sobre una instalación anterior y comprobar la migración.
5. Perfilar una sesión de diez minutos en un Android de gama media y un iPhone:
   frame time, memoria, audio y temperatura. No hay un perfil físico documentado
   todavía; no declarar 60fps garantizados.
6. Prueba casual: 3–5 partidas al día, confirmar primer desbloqueo y objetivo
   semanal de 210. Ajustar el balance si los tiempos reales difieren del supuesto.

No hay enlace de descarga verificado. La configuración de compartir permanece
vacía hasta que exista uno. Completar firmas, revisión en dispositivos y
metadatos de las tiendas antes de llamar a este candidato “publicado”.
