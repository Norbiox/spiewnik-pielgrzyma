import json
from unittest.mock import AsyncMock, MagicMock, patch

import numpy as np
import pytest
from fastapi.testclient import TestClient


@pytest.fixture
def fake_data_dir(tmp_path):
    """Create minimal embeddings data for the test server."""
    dims = 384
    n_vectors = 3
    vectors = np.random.randn(n_vectors, dims).astype(np.float32)
    norms = np.linalg.norm(vectors, axis=1, keepdims=True)
    vectors = vectors / norms

    bin_path = tmp_path / "hymns_embeddings.bin"
    bin_path.write_bytes(vectors.tobytes())

    meta = [
        {"hymn_number": "1", "verse_index": 0},
        {"hymn_number": "1", "verse_index": 1},
        {"hymn_number": "2", "type": "title"},
    ]
    meta_path = tmp_path / "hymns_embeddings_meta.json"
    meta_path.write_text(json.dumps(meta))

    return str(tmp_path)


@pytest.fixture
def mock_logger():
    logger = MagicMock()
    logger.log = AsyncMock()
    return logger


@pytest.fixture
def client(fake_data_dir, mock_logger):
    with (
        patch("search.main.DATA_DIR", fake_data_dir),
        patch("search.main.DATABASE_URL", "sqlite+aiosqlite:///:memory:"),
        patch("search.main.load_model"),
        patch("search.main.create_async_engine", return_value=AsyncMock()),
        patch("search.main.async_sessionmaker"),
        patch("search.main.SearchLogger", return_value=mock_logger),
        patch(
            "search.main.embed_query",
            return_value=np.random.randn(384).astype(np.float32),
        ),
    ):
        from search.main import app

        with TestClient(app) as tc:
            yield tc


def test_search_returns_200(client):
    response = client.post("/search", json={"query": "test"})
    assert response.status_code == 200


def test_search_returns_results_list(client):
    response = client.post("/search", json={"query": "test"})
    data = response.json()
    assert "results" in data
    assert isinstance(data["results"], list)


def test_search_result_has_required_fields(client):
    response = client.post("/search", json={"query": "test"})
    data = response.json()
    if data["results"]:
        r = data["results"][0]
        assert "hymn_number" in r
        assert "score" in r


def test_search_respects_top_k(client):
    response = client.post("/search", json={"query": "test", "top_k": 1})
    data = response.json()
    assert len(data["results"]) <= 1


def test_search_empty_query_returns_400(client):
    response = client.post("/search", json={"query": ""})
    assert response.status_code == 400


def test_search_missing_query_returns_422(client):
    response = client.post("/search", json={})
    assert response.status_code == 422
