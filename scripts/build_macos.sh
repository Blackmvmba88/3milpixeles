#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

PYTHON_BIN="${PYTHON_BIN:-python3}"
VENV_DIR="${VENV_DIR:-.venv-build}"

if ! command -v hdiutil >/dev/null 2>&1; then
  echo "ERROR: este build de DMG debe ejecutarse en macOS."
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

echo "Construyendo 3milpixeles.app..."
"$VENV_PYTHON" -m PyInstaller \
  --noconfirm \
  --clean \
  --windowed \
  --name "3milpixeles" \
  --osx-bundle-identifier "com.blackmamba.3milpixeles" \
  image_resizer_3000.py

APP_PATH="dist/3milpixeles.app"
if [ ! -d "$APP_PATH" ]; then
  echo "ERROR: PyInstaller no generó $APP_PATH"
  exit 1
fi

ARCH="$(uname -m)"
DMG_PATH="dist/3milpixeles-macos-${ARCH}.dmg"
STAGING_DIR="$(mktemp -d)"
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
echo "  App: $APP_PATH"
echo "  DMG: $DMG_PATH"
