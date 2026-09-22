# AGENTS.md — 3milpixeles

Este archivo existe para que futuras IAs, agentes y colaboradores continúen el proyecto sin reconstruir decisiones ya tomadas.

## Regla principal

No dependas de archivos binarios externos para el icono de la aplicación. El icono canónico debe poder reconstruirse desde el propio repositorio.

## Icono

- Fuente visual de referencia: `assets/icon.svg`.
- Generador reproducible: `scripts/generate_icon.py`.
- Salida raster: `assets/icon.png`.
- Salida macOS durante build: `assets/macos/3milpixeles.icns`.
- Identidad: fondo morado/negro, neón verde/violeta, marco de redimensionado, imagen central y texto `3000 × 3000`.

Si se cambia el diseño:
1. Actualiza `assets/icon.svg` como referencia.
2. Actualiza `scripts/generate_icon.py` para mantener el build reproducible.
3. Ejecuta `python3 scripts/generate_icon.py`.
4. Ejecuta tests.
5. En macOS ejecuta `bash scripts/build_macos.sh`.
6. Verifica que `dist/3milpixeles.app` muestre el icono y que se genere el DMG.

## venv

Desarrollo normal:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
python image_resizer_3000.py
```

Atajos:

```bash
make setup
make run
make test
make build-macos
```

## Build macOS

`scripts/build_macos.sh` debe:
1. crear/usar `.venv-build`;
2. instalar `requirements-dev.txt`;
3. correr `test_resizer.py`;
4. regenerar `assets/icon.png`;
5. crear un `.iconset`;
6. convertirlo con `iconutil` a `.icns`;
7. pasar el `.icns` a PyInstaller con `--icon`;
8. crear `dist/3milpixeles.app`;
9. crear el DMG.

## GitHub

Los cambios importantes deben ir en una rama y Pull Request para que el propietario pueda revisarlos y aceptar el merge.

No hagas merge automático cuando el usuario pida explícitamente "déjamelo para aceptar".

## Criterio de terminado

No declares terminado el empaquetado macOS si:
- falta el icono en el comando PyInstaller;
- no existe el paso de generación de ICNS;
- los tests fallan;
- el workflow no produce un DMG;
- se afirma que un DMG está firmado/notarizado sin tener Developer ID + notarización configurados.
