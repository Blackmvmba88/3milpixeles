PYTHON ?= python3
VENV ?= .venv
VENV_PYTHON := $(VENV)/bin/python

.PHONY: setup run test build-macos clean

setup:
	bash scripts/install_macos.sh

run:
	bash scripts/run_macos.sh

test:
	@if [ -x "$(VENV_PYTHON)" ]; then \
		$(VENV_PYTHON) test_resizer.py; \
	else \
		$(PYTHON) test_resizer.py; \
	fi

build-macos:
	bash scripts/build_macos.sh

clean:
	python3 -c "import shutil; [shutil.rmtree(p, ignore_errors=True) for p in ('.venv','.venv-build','build','dist','__pycache__','.pytest_cache')]"
