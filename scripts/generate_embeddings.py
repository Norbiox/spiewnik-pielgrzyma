#!/usr/bin/env python3
"""Generate pre-computed embeddings for all hymn verses and titles.

Reads assets/hymns_texts.json and assets/hymns.csv, calls Gemini batch
embedding API, writes search/data/hymns_embeddings.bin and
search/data/hymns_embeddings_meta.json.

Usage:
    GEMINI_API_KEY=your-key uv run --project search python scripts/generate_embeddings.py
"""

import csv
import json
import os
import sys

import numpy as np

# Add project root to path so we can import search modules
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "search"))

from search.gemini import embed_batch
from search.config import EMBEDDING_DIMS

ASSETS_DIR = os.path.join(os.path.dirname(__file__), "..", "assets")
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "..", "search", "data")
BATCH_SIZE = 250


def load_hymns():
    """Load hymn metadata from CSV and texts from JSON."""
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
    """Build parallel lists of texts to embed and their metadata."""
    texts = []
    metadata = []

    # Verses
    for hymn_number, verses in hymns_texts.items():
        for verse_index, verse_text in enumerate(verses):
            texts.append(verse_text)
            metadata.append(
                {"hymn_number": hymn_number, "verse_index": verse_index}
            )

    # Titles with group/subgroup context
    for hymn_number, meta in hymns_meta.items():
        title_text = f"{meta['group']} - {meta['subgroup']} - {meta['title']}"
        texts.append(title_text)
        metadata.append({"hymn_number": hymn_number, "type": "title"})

    return texts, metadata


def generate_embeddings(texts):
    """Embed all texts in batches."""
    all_embeddings = []
    total = len(texts)

    for i in range(0, total, BATCH_SIZE):
        batch = texts[i : i + BATCH_SIZE]
        print(f"  Embedding batch {i // BATCH_SIZE + 1}/{(total + BATCH_SIZE - 1) // BATCH_SIZE} ({len(batch)} texts)...")
        embeddings = embed_batch(batch)
        all_embeddings.extend(embeddings)

    return np.array(all_embeddings, dtype=np.float32)


def main():
    print("Loading hymn data...")
    hymns_meta, hymns_texts = load_hymns()
    print(f"  {len(hymns_meta)} hymns, {sum(len(v) for v in hymns_texts.values())} verses")

    print("Building texts...")
    texts, metadata = build_texts_and_metadata(hymns_meta, hymns_texts)
    print(f"  {len(texts)} total texts to embed ({len(texts) - len(hymns_meta)} verses + {len(hymns_meta)} titles)")

    print("Generating embeddings...")
    embeddings = generate_embeddings(texts)
    print(f"  Shape: {embeddings.shape}")

    os.makedirs(OUTPUT_DIR, exist_ok=True)

    bin_path = os.path.join(OUTPUT_DIR, "hymns_embeddings.bin")
    embeddings.tofile(bin_path)
    print(f"  Wrote {bin_path} ({os.path.getsize(bin_path) / 1024 / 1024:.1f} MB)")

    meta_path = os.path.join(OUTPUT_DIR, "hymns_embeddings_meta.json")
    with open(meta_path, "w", encoding="utf-8") as f:
        json.dump(metadata, f)
    print(f"  Wrote {meta_path}")

    print("Done!")


if __name__ == "__main__":
    main()
