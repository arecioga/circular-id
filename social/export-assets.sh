#!/bin/sh
set -eu

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
BASE_URL="http://127.0.0.1:4173/social/render.html?asset="
PROFILE_DIR="/private/tmp/circular-id-social-render-20261116"

export_asset() {
  asset_id="$1"
  dimensions="$2"
  destination="$3"

  "$CHROME" \
    --headless=new \
    --disable-gpu \
    --hide-scrollbars \
    --no-first-run \
    --no-default-browser-check \
    --force-device-scale-factor=1 \
    --user-data-dir="$PROFILE_DIR" \
    --window-size="$dimensions" \
    --virtual-time-budget=1800 \
    --run-all-compositor-stages-before-draw \
    --screenshot="$destination" \
    "${BASE_URL}${asset_id}" >/dev/null 2>&1

  echo "Exported $destination"
}

export_asset "avatar" "400,400" "social/assets/avatar-circular-id.png"
export_asset "linkedin-banner" "1512,256" "social/linkedin/publicables/linkedin-portada.png"

export_asset "ig-01" "1080,1350" "social/instagram/publicables/ig-01-foto-confianza.png"
export_asset "ig-02-1" "1080,1350" "social/instagram/publicables/ig-02-carrusel-01-portada.png"
export_asset "ig-02-2" "1080,1350" "social/instagram/publicables/ig-02-carrusel-02-vendedor.png"
export_asset "ig-02-3" "1080,1350" "social/instagram/publicables/ig-02-carrusel-03-producto.png"
export_asset "ig-02-4" "1080,1350" "social/instagram/publicables/ig-02-carrusel-04-proteccion.png"
export_asset "ig-02-5" "1080,1350" "social/instagram/publicables/ig-02-carrusel-05-identidad.png"
export_asset "ig-03" "1080,1920" "social/instagram/publicables/ig-03-reel-portada.png"
export_asset "ig-04" "1080,1350" "social/instagram/publicables/ig-04-promocion-piloto.png"

export_asset "li-01" "1080,1350" "social/linkedin/publicables/li-01-dato-confianza.png"
export_asset "li-02-1" "1080,1350" "social/linkedin/publicables/li-02-carrusel-01-portada.png"
export_asset "li-02-2" "1080,1350" "social/linkedin/publicables/li-02-carrusel-02-registra.png"
export_asset "li-02-3" "1080,1350" "social/linkedin/publicables/li-02-carrusel-03-comprueba.png"
export_asset "li-02-4" "1080,1350" "social/linkedin/publicables/li-02-carrusel-04-continua.png"
export_asset "li-03" "1080,1350" "social/linkedin/publicables/li-03-video-portada.png"
export_asset "li-04" "1200,627" "social/linkedin/publicables/li-04-anuncio-piloto.png"
