# shellcheck shell=bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [ ! -x .venv/bin/python ]; then
  bash scripts/install_macos.sh
fi
.venv/bin/python image_resizer_3000.py
