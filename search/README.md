# Spiewnik Search API

Semantic search API for Śpiewnik Pielgrzyma hymns. Uses multilingual-e5-small (ONNX) for embeddings, FastAPI for serving, PostgreSQL for query logging.

## Requirements

- Python >= 3.14
- [uv](https://docs.astral.sh/uv/) package manager
- PostgreSQL (for query logging)

## Setup

```bash
cp .env.example .env
# Edit .env with your DATABASE_URL

make install          # Install production dependencies
make download-model   # Download ONNX model (~470MB, first time only)
make migrate          # Run database migrations
make run              # Start the server on port 8000
```

## Environment variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | Yes | PostgreSQL connection string, e.g. `postgresql+asyncpg://user:pass@host:5432/dbname` |
| `HF_HOME` | No | HuggingFace cache directory (default: `~/.cache/huggingface`) |

## Makefile targets

| Target | Description |
|--------|-------------|
| `make install` | Install production dependencies |
| `make install-dev` | Install all dependencies (including dev) |
| `make migrate` | Run Alembic database migrations |
| `make run` | Start uvicorn on `0.0.0.0:8000` |
| `make download-model` | Download the ONNX model |
| `make test` | Run pytest |
| `make lint` | Run ruff check + format check |

## Health check

```bash
curl -X POST http://localhost:8000/search \
  -H 'Content-Type: application/json' \
  -d '{"query": "test"}'
```

## Note on PYTHONPATH

The `search` package must be importable as `search.main`, `search.model`, etc. The Makefile targets set `PYTHONPATH=..` automatically. If running commands manually, ensure the parent directory of `search/` is on the Python path.
