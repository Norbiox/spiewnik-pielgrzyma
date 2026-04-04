import json

import numpy as np


class EmbeddingsStore:
    def __init__(self, bin_path: str, meta_path: str, dims: int):
        raw = np.fromfile(bin_path, dtype=np.float32)
        self.embeddings = raw.reshape(-1, dims)

        with open(meta_path) as f:
            self.metadata = json.load(f)

        if len(self.metadata) != self.embeddings.shape[0]:
            raise ValueError(
                f"Metadata length {len(self.metadata)} != embeddings rows {self.embeddings.shape[0]}"
            )

        # Pre-compute normalized vectors for cosine similarity
        norms = np.linalg.norm(self.embeddings, axis=1, keepdims=True)
        norms = np.maximum(norms, 1e-10)
        self._normalized = self.embeddings / norms

    def search(self, query_embedding: np.ndarray, top_k: int = 20) -> list[dict]:
        query_norm = np.linalg.norm(query_embedding)
        if query_norm < 1e-10:
            return []
        query_normalized = query_embedding / query_norm

        similarities = self._normalized @ query_normalized
        top_indices = np.argsort(similarities)[::-1][:top_k]

        results = []
        for idx in top_indices:
            entry = dict(self.metadata[idx])
            entry["score"] = round(float(similarities[idx]), 4)
            results.append(entry)
        return results
