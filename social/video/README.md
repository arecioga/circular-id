# Producción de vídeo social

Este directorio conserva el montaje reproducible de los dos vídeos de Circular ID.

## Salidas

- Instagram: `../instagram/publicables/ig-03-reel-circular-id.mp4`
- LinkedIn: `../linkedin/publicables/li-03-video-circular-id.mp4`

Ambos archivos utilizan MP4, vídeo H.264, perfil High, píxel `yuv420p` y 30 fotogramas por segundo. No contienen audio: los mensajes esenciales están integrados en pantalla para que puedan entenderse con el sonido desactivado.

## Duración y formato

| Red | Tamaño | Duración | Recorrido |
|---|---:|---:|---|
| Instagram | 1080 × 1920 px | 15 s | Identidad, lectura, coincidencia y servicios |
| LinkedIn | 1080 × 1350 px | 12 s | Registro, consulta, explicación y continuidad |

## Reconstrucción

El archivo `build_videos.swift` genera los fotogramas y los entrega a FFmpeg mediante vídeo crudo BGRA. Para reconstruirlos se necesita:

1. Swift con AppKit y CoreGraphics.
2. FFmpeg con el codificador `libx264`.
3. Pasar al ejecutable la raíz del proyecto y la ruta del binario de FFmpeg.

La música se ha omitido para evitar problemas de derechos. Si el equipo decide añadirla, debe utilizar una pista propia o con licencia compatible y conservar la prueba de uso.
