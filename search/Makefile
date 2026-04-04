.PHONY: install install-dev migrate run download-model test lint

install:
	uv sync --no-dev

install-dev:
	uv sync

migrate:
	PYTHONPATH=.. uv run alembic upgrade head

run:
	PYTHONPATH=.. uv run uvicorn search.main:app --host 0.0.0.0 --port 8000

download-model:
	PYTHONPATH=.. uv run python -c "from search.model import load_model; load_model()"

test:
	uv run pytest

lint:
	uv run ruff check .
	uv run ruff format --check .
