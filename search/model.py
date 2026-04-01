import os

import numpy as np
from huggingface_hub import snapshot_download
from onnxruntime import InferenceSession
from transformers import AutoTokenizer

from search.config import MODEL_NAME

_tokenizer: AutoTokenizer | None = None
_session: InferenceSession | None = None


def load_model() -> tuple[AutoTokenizer, InferenceSession]:
    """Load tokenizer and ONNX model (cached after first call)."""
    global _tokenizer, _session
    if _tokenizer is None or _session is None:
        model_dir = snapshot_download(
            MODEL_NAME,
            allow_patterns=[
                "onnx/model.onnx",
                "tokenizer*",
                "config.json",
                "special_tokens_map.json",
            ],
        )
        onnx_path = os.path.join(model_dir, "onnx", "model.onnx")
        _tokenizer = AutoTokenizer.from_pretrained(model_dir)
        _session = InferenceSession(onnx_path)
    return _tokenizer, _session


def _embed(texts: list[str]) -> np.ndarray:
    """Run inference and return normalized embeddings."""
    tokenizer, session = load_model()
    encoded = tokenizer(
        texts,
        padding=True,
        truncation=True,
        max_length=512,
        return_token_type_ids=True,
        return_tensors="np",
    )
    outputs = session.run(None, {k: v for k, v in encoded.items()})
    # Mean pooling over token embeddings, masked by attention
    token_embeddings = outputs[0]
    attention_mask = encoded["attention_mask"]
    mask_expanded = np.expand_dims(attention_mask, axis=-1)
    summed = np.sum(token_embeddings * mask_expanded, axis=1)
    counts = np.clip(mask_expanded.sum(axis=1), a_min=1e-9, a_max=None)
    embeddings = summed / counts
    # L2 normalize
    norms = np.linalg.norm(embeddings, axis=1, keepdims=True)
    norms = np.maximum(norms, 1e-10)
    return (embeddings / norms).astype(np.float32)


def embed_query(text: str) -> np.ndarray:
    """Embed a single query string with the 'query: ' prefix."""
    return _embed([f"query: {text}"])[0]


def embed_passages(texts: list[str]) -> list[np.ndarray]:
    """Embed a batch of passages with the 'passage: ' prefix."""
    prefixed = [f"passage: {t}" for t in texts]
    embeddings = _embed(prefixed)
    return [embeddings[i] for i in range(len(texts))]
