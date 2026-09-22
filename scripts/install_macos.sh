#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

PYTHON_BIN="${PYTHON_BIN:-python3}"
VENV_DIR="${VENV_DIR:-.venv}"
RUN_AFTER_INSTALL=false

if [[ "${1:-}" == "--run" ]]; then
  RUN_AFTER_INSTALL=true
fi

if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
  echo "ERROR: Python 3 no está instalado."
  echo "Instala Python 3.8+ y vuelve a ejecutar este script."
  exit 1
fi

"$PYTHON_BIN" - <<'PY'
import sys
if sys.version_info < (3, 8):
    raise SystemExit("ERROR: se requiere Python 3.8 o superior")
print(f"Python OK: {sys.version.split()[0]}")
PY

if [[ ! -d "$VENV_DIR" ]]; then
  echo "Creando entorno virtual en $VENV_DIR ..."
  "$PYTHON_BIN" -m venv "$VENV_DIR"
fi

VENV_PYTHON="$VENV_DIR/bin/python"

echo "Actualizando pip..."
"$VENV_PYTHON" -m pip install --upgrade pip

echo "Instalando dependencias..."
"$VENV_PYTHON" -m pip install -r requirements.txt

echo
echo "Instalación lista."
echo "Para ejecutar:"
echo "  $VENV_PYTHON image_resizer_3000.py"
echo
echo "Para activar el venv manualmente:"
echo "  source $VENV_DIR/bin/activate"

if [[ "$RUN_AFTER_INSTALL" == "true" ]]; then
  exec "$VENV_PYTHON" image_resizer_3000.py
fi
