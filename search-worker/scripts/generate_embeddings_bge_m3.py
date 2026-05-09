#!/usr/bin/env python3
"""Generate pre-computed BGE-M3 embeddings via Cloudflare Workers AI.

Reads assets/hymns_texts.json and assets/hymns.csv, calls @cf/baai/bge-m3
via Workers AI REST API, truncates to DIMS dimensions (Matryoshka), writes
search/data/hymns_embeddings_bge_m3.bin and hymns_embeddings_bge_m3_meta.json.

Workers AI always returns 1024 dims; we truncate to 384 + L2-renormalize.
384 dims keeps in-Worker cosine similarity under the 10ms free-tier CPU budget.

Usage:
    CLOUDFLARE_ACCOUNT_ID=... CLOUDFLARE_API_TOKEN=... \
    uv run --project search-worker --group dev python scripts/generate_embeddings_bge_m3.py
"""

import csv
import json
import os
import sys
import time

import httpx
import numpy as np

DIMS = 384  # Matryoshka truncation from 1024
BATCH_SIZE = 100
ASSETS_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "assets")
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "..", "data")


def load_hymns():
    csv_path = os.path.join(ASSETS_DIR, "hymns.csv")
    json_path = os.path.join(ASSETS_DIR, "hymns_texts.json")

    hymns_meta = {}
    with open(csv_path, encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            hymns_meta[row["number"]] = {
                "title": row["title"],
                "group": row["group_name"],
                "subgroup": row["subgroup_name"],
            }

    with open(json_path, encoding="utf-8") as f:
        hymns_texts = json.load(f)

    return hymns_meta, hymns_texts


def build_texts_and_metadata(hymns_meta, hymns_texts):
    texts = []
    metadata = []

    for hymn_number, verses in hymns_texts.items():
        for verse_index, verse_text in enumerate(verses):
            texts.append(verse_text)
            metadata.append({"hymn_number": hymn_number, "verse_index": verse_index})

    for hymn_number, meta in hymns_meta.items():
        title_text = f"{meta['group']} - {meta['subgroup']} - {meta['title']}"
        texts.append(title_text)
        metadata.append({"hymn_number": hymn_number, "type": "title"})

    return texts, metadata


def embed_batch(client: httpx.Client, texts: list[str], account_id: str, api_token: str) -> list[list[float]]:
    url = f"https://api.cloudflare.com/client/v4/accounts/{account_id}/ai/run/@cf/baai/bge-m3"
    for attempt in range(3):
        resp = client.post(
            url,
            headers={"Authorization": f"Bearer {api_token}"},
            json={"text": texts},
            timeout=120,
        )
        if resp.status_code == 429:
            wait = 2**attempt * 5
            print(f"  Rate limited, waiting {wait}s...")
            time.sleep(wait)
            continue
        resp.raise_for_status()
        return resp.json()["result"]["data"]
    raise RuntimeError("Failed after 3 retries")


def truncate_and_normalize(embeddings: np.ndarray, dims: int) -> np.ndarray:
    """Matryoshka truncation: first `dims` elements, then L2-normalize."""
    truncated = embeddings[:, :dims]
    norms = np.linalg.norm(truncated, axis=1, keepdims=True)
    return (truncated / norms).astype(np.float32)


def main():
    account_id = os.environ.get("CLOUDFLARE_ACCOUNT_ID")
    api_token = os.environ.get("CLOUDFLARE_API_TOKEN")
    if not account_id or not api_token:
        print("Error: CLOUDFLARE_ACCOUNT_ID and CLOUDFLARE_API_TOKEN must be set")
        sys.exit(1)

    print("Loading hymn data...")
    hymns_meta, hymns_texts = load_hymns()
    verse_count = sum(len(v) for v in hymns_texts.values())
    print(f"  {len(hymns_meta)} hymns, {verse_count} verses")

    print("Building texts...")
    texts, metadata = build_texts_and_metadata(hymns_meta, hymns_texts)
    print(f"  {len(texts)} total ({verse_count} verses + {len(hymns_meta)} titles)")

    print(f"Embedding via @cf/baai/bge-m3, truncating to {DIMS} dims...")
    all_embeddings: list[list[float]] = []
    batches = [texts[i : i + BATCH_SIZE] for i in range(0, len(texts), BATCH_SIZE)]
    with httpx.Client() as client:
        for i, batch in enumerate(batches):
            print(f"  Batch {i + 1}/{len(batches)} ({len(batch)} texts)...", end="", flush=True)
            t0 = time.time()
            vecs = embed_batch(client, batch, account_id, api_token)
            all_embeddings.extend(vecs)
            print(f" {time.time() - t0:.1f}s")

    embeddings = np.array(all_embeddings, dtype=np.float32)
    embeddings = truncate_and_normalize(embeddings, DIMS)
    print(f"Final shape: {embeddings.shape}")

    os.makedirs(OUTPUT_DIR, exist_ok=True)

    bin_path = os.path.join(OUTPUT_DIR, "hymns_embeddings_bge_m3.bin")
    embeddings.tofile(bin_path)
    print(f"Wrote {bin_path} ({os.path.getsize(bin_path) / 1024 / 1024:.1f} MB)")

    meta_path = os.path.join(OUTPUT_DIR, "hymns_embeddings_bge_m3_meta.json")
    with open(meta_path, "w", encoding="utf-8") as f:
        json.dump(metadata, f)
    print(f"Wrote {meta_path}")

    estimated_neurons = (len(texts) * 50 / 1_000_000) * 1075
    print(f"Estimated neuron cost: ~{estimated_neurons:.0f} neurons ({estimated_neurons / 10000 * 100:.1f}% of daily free limit)")


if __name__ == "__main__":
    main()
