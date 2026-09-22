# 3milpixeles - Image Resizer 3000x3000 px

![Version](https://img.shields.io/badge/version-1.1.0-blue)
![Python](https://img.shields.io/badge/python-3.8%2B-brightgreen)
![macOS](https://img.shields.io/badge/macOS-DMG-black)
![License](https://img.shields.io/badge/license-MIT-green)

Aplicación de escritorio para redimensionar imágenes a formato cuadrado de **3000x3000 píxeles (1:1)** con varios modos de ajuste.

## ✨ Características

- 🎨 Interfaz gráfica con Tkinter.
- 📐 Tres modos de redimensionado:
  - **Ajustar**: conserva proporciones y añade márgenes.
  - **Rellenar**: recorta para llenar el cuadro.
  - **Estirar**: fuerza exactamente 3000x3000.
- 📁 Procesamiento de varias imágenes.
- 💾 Carpeta de destino configurable.
- 🖼️ PNG, JPG, JPEG, GIF, BMP y TIFF.
- 🧪 Tests de la lógica de redimensionado.
- 🐍 Entorno virtual reproducible con `.venv`.
- 🍎 Build automático de `.app` y `.dmg` para macOS.
- ⚙️ GitHub Actions para generar el DMG sin tener que empaquetarlo manualmente.

## 📋 Requisitos para desarrollo

- Python 3.8 o superior.
- Pillow.
- Tkinter.

En macOS, una instalación de Python que incluya Tkinter es necesaria para ejecutar la interfaz.

## 🚀 Instalación recomendada con venv

Clona el repositorio:

```bash
git clone https://github.com/Blackmvmba88/3milpixeles.git
cd 3milpixeles
```

Crea el entorno virtual:

```bash
python3 -m venv .venv
```

Actívalo:

```bash
source .venv/bin/activate
```

Actualiza pip e instala dependencias:

```bash
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

Ejecuta la aplicación:

```bash
python image_resizer_3000.py
```

Cuando termines:

```bash
deactivate
```

## ⚡ Instalación automática en macOS

El repositorio incluye un bootstrap que crea el `.venv`, instala dependencias y deja la aplicación lista:

```bash
bash scripts/install_macos.sh
```

Para instalar y abrir inmediatamente:

```bash
bash scripts/install_macos.sh --run
```

Después de la primera instalación puedes arrancarla con:

```bash
bash scripts/run_macos.sh
```

También hay atajos con Make:

```bash
make setup
make run
make test
```

## 🍎 Crear una aplicación .app y un DMG

En una Mac puedes construir el instalador localmente con:

```bash
bash scripts/build_macos.sh
```

El script:

1. crea un venv aislado de build en `.venv-build`;
2. instala Pillow y PyInstaller;
3. ejecuta los tests;
4. regenera el icono desde `scripts/generate_icon.py`;
5. crea `assets/macos/3milpixeles.icns` con herramientas nativas de macOS;
6. aplica ese icono a `dist/3milpixeles.app`;
7. crea un DMG con acceso directo a `/Applications`.

La referencia visual editable del icono vive en `assets/icon.svg`. El flujo completo para futuras IAs/agentes está documentado en `AGENTS.md`.

El resultado queda en:

```text
dist/3milpixeles-macos-<arquitectura>.dmg
```

Por ejemplo, en Apple Silicon normalmente será:

```text
dist/3milpixeles-macos-arm64.dmg
```

> El build actual no está firmado con un certificado Apple Developer ID ni notarizado. macOS puede mostrar una advertencia la primera vez que se abre. Para distribución pública conviene añadir firma y notarización.

## 🤖 Generar el DMG automáticamente con GitHub Actions

El workflow `.github/workflows/build-macos.yml` ejecuta tests y genera el instalador en un runner macOS.

Se puede disparar manualmente desde:

```text
GitHub → Actions → Build macOS DMG → Run workflow
```

Al terminar, el DMG aparece como artifact del workflow durante 30 días.

También se ejecuta al hacer push a `main`.

### Release automático por tag

Si publicas un tag que empiece con `v`, por ejemplo:

```bash
git tag v1.1.0
git push origin v1.1.0
```

GitHub Actions crea o actualiza el Release correspondiente y adjunta el DMG generado.

## 📖 Uso

1. Haz clic en **📁 SELECCIONAR IMÁGENES**.
2. Elige uno de los modos:
   - 📦 Ajustar dentro.
   - 🔲 Rellenar cuadrado.
   - 🎯 Estirar a 3000x3000.
3. Selecciona la carpeta de destino.
4. Decide si quieres conservar el archivo original.
5. Pulsa **🚀 REDIMENSIONAR A 3000x3000 🚀**.

## 🎯 Modos de redimensionado

### Ajustar / Fit

Mantiene la proporción original de la imagen y la centra dentro de un lienzo de 3000x3000 píxeles.

### Rellenar / Fill

Escala la imagen para llenar completamente el cuadrado y recorta el excedente.

### Estirar / Stretch

Ajusta directamente la imagen a 3000x3000 píxeles, aunque pueda deformarla.

## 📁 Estructura

```text
3milpixeles/
├── .github/
│   └── workflows/
│       └── build-macos.yml
├── scripts/
│   ├── build_macos.sh
│   ├── install_macos.sh
│   └── run_macos.sh
├── image_resizer_3000.py
├── test_resizer.py
├── requirements.txt
├── requirements-dev.txt
├── Makefile
├── .gitignore
└── README.md
```

## 🧪 Tests

Con el venv activo:

```bash
python test_resizer.py
```

O:

```bash
make test
```

Los tests verifican que los tres modos produzcan imágenes de exactamente 3000x3000 píxeles.

## 🛠️ Desarrollo

Dependencias normales:

```bash
python -m pip install -r requirements.txt
```

Dependencias de empaquetado:

```bash
python -m pip install -r requirements-dev.txt
```

La clase principal es `ImageResizer3000` y contiene:

- `resize_fit()`
- `resize_fill()`
- `resize_stretch()`
- `process_images()`

## 📝 Formato de salida

Cuando se conserva el original, el nombre generado sigue este patrón:

```text
{nombre_original}_3000x3000_{timestamp}.png
```

Ejemplo:

```text
foto_3000x3000_20260922_111600.png
```

## ⚠️ Notas

- Las imágenes se convierten a RGB durante el procesamiento.
- La salida se guarda como PNG.
- Los archivos de build, DMG y entornos virtuales no se versionan.
- El DMG generado en CI corresponde a la arquitectura del runner macOS usado por GitHub Actions.

## 👤 Autor

**Blackmvmba88**

GitHub: [@Blackmvmba88](https://github.com/Blackmvmba88)

---

🐛 ¿Encontraste un bug? [Reporta un issue](https://github.com/Blackmvmba88/3milpixeles/issues)
