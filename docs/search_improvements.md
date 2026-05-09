# Search Result Improvements

Tracked improvements for the semantic search API ranking quality.

## 1. Score threshold

Drop results below a minimum cosine similarity (e.g. 0.4). Currently all `top_k` results are returned regardless of relevance.

## 2. Hymn-level aggregation

Group raw results by `hymn_number` and return one entry per hymn with the best verse score. A hymn with multiple matching verses is more relevant than one with a single weak match, but shouldn't appear multiple times.

## 3. Title/category boost

Apply a multiplier (e.g. 1.3x) to title and category matches. A query like "na pogrzeb" should strongly favor hymns whose group/subgroup matches, not just verses that vaguely mention funeral themes.

## 4. Hybrid keyword + semantic scoring

Combine semantic cosine similarity with keyword matching (e.g. BM25). Exact keyword matches ("na pogrzeb" in a title) should rank above semantically similar but inexact results. Proposed formula: `keyword_score + 0.5 * semantic_score`.
