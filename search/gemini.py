from google import genai
from google.genai import types
import numpy as np

from search.config import GEMINI_API_KEY, GEMINI_MODEL, EMBEDDING_DIMS


def _get_client() -> genai.Client:
    return genai.Client(api_key=GEMINI_API_KEY)


def embed_query(text: str) -> np.ndarray:
    client = _get_client()
    result = client.models.embed_content(
        model=GEMINI_MODEL,
        contents=text,
        config=types.EmbedContentConfig(
            task_type="RETRIEVAL_QUERY",
            output_dimensionality=EMBEDDING_DIMS,
        ),
    )
    return np.array(result.embeddings[0].values, dtype=np.float32)


def embed_batch(texts: list[str]) -> list[np.ndarray]:
    client = _get_client()
    result = client.models.embed_content(
        model=GEMINI_MODEL,
        contents=texts,
        config=types.EmbedContentConfig(
            task_type="RETRIEVAL_DOCUMENT",
            output_dimensionality=EMBEDDING_DIMS,
        ),
    )
    return [np.array(e.values, dtype=np.float32) for e in result.embeddings]
