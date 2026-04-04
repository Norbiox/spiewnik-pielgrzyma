from unittest.mock import MagicMock, patch

import numpy as np

from search.model import embed_query, embed_passages


def _mock_model():
    """Create mock tokenizer and session."""
    tokenizer = MagicMock()
    session = MagicMock()
    return tokenizer, session


def _setup_mocks(tokenizer, session, output_shape):
    """Configure mocks to return embeddings of given shape."""
    tokenizer.return_value = {
        "input_ids": np.ones((output_shape[0], 5), dtype=np.int64),
        "attention_mask": np.ones((output_shape[0], 5), dtype=np.int64),
    }
    session.run.return_value = [
        np.random.randn(output_shape[0], 5, output_shape[1]).astype(np.float32)
    ]


@patch("search.model.load_model")
def test_embed_query_returns_numpy_array(mock_load):
    tokenizer, session = _mock_model()
    _setup_mocks(tokenizer, session, (1, 384))
    mock_load.return_value = (tokenizer, session)

    result = embed_query("test query")
    assert isinstance(result, np.ndarray)
    assert result.dtype == np.float32
    assert result.shape == (384,)


@patch("search.model.load_model")
def test_embed_query_adds_query_prefix(mock_load):
    tokenizer, session = _mock_model()
    _setup_mocks(tokenizer, session, (1, 384))
    mock_load.return_value = (tokenizer, session)

    embed_query("hello")

    call_args = tokenizer.call_args
    assert call_args[0][0] == ["query: hello"]


@patch("search.model.load_model")
def test_embed_passages_returns_list_of_arrays(mock_load):
    tokenizer, session = _mock_model()
    _setup_mocks(tokenizer, session, (2, 384))
    mock_load.return_value = (tokenizer, session)

    results = embed_passages(["text1", "text2"])
    assert len(results) == 2
    assert all(isinstance(r, np.ndarray) for r in results)


@patch("search.model.load_model")
def test_embed_passages_adds_passage_prefix(mock_load):
    tokenizer, session = _mock_model()
    _setup_mocks(tokenizer, session, (1, 384))
    mock_load.return_value = (tokenizer, session)

    embed_passages(["hello"])

    call_args = tokenizer.call_args
    assert call_args[0][0] == ["passage: hello"]
