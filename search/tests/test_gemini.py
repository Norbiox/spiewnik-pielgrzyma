from unittest.mock import MagicMock, patch

import numpy as np

from search.gemini import embed_query, embed_batch


def _make_embedding(values):
    e = MagicMock()
    e.values = values
    return e


@patch("search.gemini._get_client")
def test_embed_query_returns_numpy_array(mock_get_client):
    mock_client = MagicMock()
    mock_get_client.return_value = mock_client
    mock_result = MagicMock()
    mock_result.embeddings = [_make_embedding([0.1, 0.2, 0.3])]
    mock_client.models.embed_content.return_value = mock_result

    result = embed_query("test query")
    assert isinstance(result, np.ndarray)
    assert result.dtype == np.float32
    np.testing.assert_array_almost_equal(result, [0.1, 0.2, 0.3])


@patch("search.gemini._get_client")
def test_embed_query_uses_retrieval_query_task(mock_get_client):
    mock_client = MagicMock()
    mock_get_client.return_value = mock_client
    mock_result = MagicMock()
    mock_result.embeddings = [_make_embedding([0.1])]
    mock_client.models.embed_content.return_value = mock_result

    embed_query("test")

    call_kwargs = mock_client.models.embed_content.call_args
    assert call_kwargs.kwargs["config"].task_type == "RETRIEVAL_QUERY"


@patch("search.gemini._get_client")
def test_embed_batch_returns_list_of_arrays(mock_get_client):
    mock_client = MagicMock()
    mock_get_client.return_value = mock_client
    mock_result = MagicMock()
    mock_result.embeddings = [
        _make_embedding([0.1, 0.2]),
        _make_embedding([0.3, 0.4]),
    ]
    mock_client.models.embed_content.return_value = mock_result

    results = embed_batch(["text1", "text2"])
    assert len(results) == 2
    assert all(isinstance(r, np.ndarray) for r in results)


@patch("search.gemini._get_client")
def test_embed_batch_uses_retrieval_document_task(mock_get_client):
    mock_client = MagicMock()
    mock_get_client.return_value = mock_client
    mock_result = MagicMock()
    mock_result.embeddings = [_make_embedding([0.1])]
    mock_client.models.embed_content.return_value = mock_result

    embed_batch(["text"])

    call_kwargs = mock_client.models.embed_content.call_args
    assert call_kwargs.kwargs["config"].task_type == "RETRIEVAL_DOCUMENT"
