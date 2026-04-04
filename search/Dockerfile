FROM python:3.14-slim

WORKDIR /app/search

# Install uv for fast dependency resolution
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Copy project files and install dependencies
COPY pyproject.toml .
COPY uv.lock* .
RUN uv sync --no-dev

# Copy source code (includes data/ with pre-computed embeddings)
COPY . .

# Download ONNX model at build time so the image is self-contained
RUN PYTHONPATH=/app uv run python -c "from search.model import load_model; load_model()"

EXPOSE 8000

ENV PYTHONPATH=/app
ENV DATABASE_URL=""

CMD ["sh", "-c", "cd search && uv run alembic upgrade head && uv run uvicorn search.main:app --host 0.0.0.0 --port 8000"]
