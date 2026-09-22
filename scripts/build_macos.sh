#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

PYTHON_BIN="${PYTHON_BIN:-python3}"
VENV_DIR="${VENV_DIR:-.venv-build}"

if ! command -v hdiutil >/dev/null 2>&1; then
  echo "ERROR: este build de DMG debe ejecutarse en macOS."
  exit 1
fi

if ! command -v iconutil >/dev/null 2>&1; then
  echo "ERROR: iconutil no está disponible; se requiere macOS."
  exit 1
fi

if ! command -v sips >/dev/null 2>&1; then
  echo "ERROR: sips no está disponible; se requiere macOS."
  exit 1
fi

if [ ! -x "$VENV_DIR/bin/python" ]; then
  "$PYTHON_BIN" -m venv "$VENV_DIR"
fi

VENV_PYTHON="$VENV_DIR/bin/python"
"$VENV_PYTHON" -m pip install --upgrade pip
"$VENV_PYTHON" -m pip install -r requirements-dev.txt

echo "Ejecutando tests..."
"$VENV_PYTHON" test_resizer.py

echo "Generando icono canónico..."
"$VENV_PYTHON" scripts/generate_icon.py

ICON_PNG="assets/icon.png"
ICONSET_DIR="assets/macos/3milpixeles.iconset"
ICNS_PATH="assets/macos/3milpixeles.icns"

rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

sips -z 16 16 "$ICON_PNG" --out "$ICONSET_DIR/icon_16x16.png" >/dev/null
sips -z 32 32 "$ICON_PNG" --out "$ICONSET_DIR/icon_16x16@2x.png" >/dev/null
sips -z 32 32 "$ICON_PNG" --out "$ICONSET_DIR/icon_32x32.png" >/dev/null
sips -z 64 64 "$ICON_PNG" --out "$ICONSET_DIR/icon_32x32@2x.png" >/dev/null
sips -z 128 128 "$ICON_PNG" --out "$ICONSET_DIR/icon_128x128.png" >/dev/null
sips -z 256 256 "$ICON_PNG" --out "$ICONSET_DIR/icon_128x128@2x.png" >/dev/null
sips -z 256 256 "$ICON_PNG" --out "$ICONSET_DIR/icon_256x256.png" >/dev/null
sips -z 512 512 "$ICON_PNG" --out "$ICONSET_DIR/icon_256x256@2x.png" >/dev/null
sips -z 512 512 "$ICON_PNG" --out "$ICONSET_DIR/icon_512x512.png" >/dev/null
cp "$ICON_PNG" "$ICONSET_DIR/icon_512x512@2x.png"

iconutil -c icns "$ICONSET_DIR" -o "$ICNS_PATH"

echo "Construyendo 3milpixeles.app..."
"$VENV_PYTHON" -m PyInstaller \
  --noconfirm \
  --clean \
  --windowed \
  --name "3milpixeles" \
  --osx-bundle-identifier "com.blackmamba.3milpixeles" \
  --icon "$ICNS_PATH" \
  image_resizer_3000.py

APP_PATH="dist/3milpixeles.app"
if [ ! -d "$APP_PATH" ]; then
  echo "ERROR: PyInstaller no generó $APP_PATH"
  exit 1
fi

ARCH="$(uname -m)"
DMG_PATH="dist/3milpixeles-macos-${ARCH}.dmg"
STAGING_DIR="$(mktemp -d)"
trap 'rm -rf "$STAGING_DIR"' EXIT

cp -R "$APP_PATH" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

echo "Construyendo DMG..."
hdiutil create \
  -volname "3milpixeles" \
  -srcfolder "$STAGING_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

echo "Build terminado:"
echo "  Icono: $ICNS_PATH"
echo "  App: $APP_PATH"
echo "  DMG: $DMG_PATH"
