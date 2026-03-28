import json

import numpy as np
import pytest

from search.embeddings import EmbeddingsStore


@pytest.fixture
def sample_store(tmp_path):
    """Create a store with 4 vectors of 3 dims for testing."""
    dims = 3
    vectors = np.array(
        [
            [1.0, 0.0, 0.0],
            [0.0, 1.0, 0.0],
            [0.9, 0.1, 0.0],  # similar to vector 0
            [0.0, 0.0, 1.0],
        ],
        dtype=np.float32,
    )
    norms = np.linalg.norm(vectors, axis=1, keepdims=True)
    vectors = vectors / norms

    bin_path = tmp_path / "embeddings.bin"
    bin_path.write_bytes(vectors.tobytes())

    meta = [
        {"hymn_number": "1", "verse_index": 0},
        {"hymn_number": "1", "verse_index": 1},
        {"hymn_number": "2", "type": "title"},
        {"hymn_number": "3", "verse_index": 0},
    ]
    meta_path = tmp_path / "embeddings_meta.json"
    meta_path.write_text(json.dumps(meta))

    return EmbeddingsStore(str(bin_path), str(meta_path), dims)


def test_load_shape(sample_store):
    assert sample_store.embeddings.shape == (4, 3)


def test_search_returns_top_k(sample_store):
    query = np.array([1.0, 0.0, 0.0], dtype=np.float32)
    results = sample_store.search(query, top_k=2)
    assert len(results) == 2


def test_search_best_match(sample_store):
    query = np.array([1.0, 0.0, 0.0], dtype=np.float32)
    results = sample_store.search(query, top_k=2)
    hymn_numbers = [r["hymn_number"] for r in results]
    assert "1" in hymn_numbers


def test_search_result_format(sample_store):
    query = np.array([1.0, 0.0, 0.0], dtype=np.float32)
    results = sample_store.search(query, top_k=1)
    r = results[0]
    assert "hymn_number" in r
    assert "score" in r
    assert 0.0 <= r["score"] <= 1.0


def test_search_orthogonal_query(sample_store):
    query = np.array([0.0, 0.0, 1.0], dtype=np.float32)
    results = sample_store.search(query, top_k=1)
    assert results[0]["hymn_number"] == "3"
