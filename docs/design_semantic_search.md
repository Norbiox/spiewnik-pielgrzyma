# Design: Semantic Search for Hymns

**Issue:** #26
**Status:** Implemented
**Date:** 2026-03-28
**Updated:** 2026-05-08

## Problem

The current search is keyword-based: it matches hymn number, title substring, and text substring. It fails when a user remembers a hymn fragment inaccurately — e.g., typing *"o ja pragnę w mym sercu"* when the actual text is *"o jak pragnę w mym sercu"*. It also can't handle conceptual queries where the user describes what the hymn is about rather than quoting it.

## Solution

Add semantic search powered by Cloudflare Workers AI. The hymn corpus is static (875 hymns, 3984 verses, never changes), so verse embeddings are pre-computed once at build time via `scripts/generate_embeddings_bge_m3.py` and stored in Cloudflare Workers KV. At search time, the app sends the user's query to a Cloudflare Worker (`search-worker/`), which embeds it via the `@cf/baai/bge-m3` model and computes cosine similarity against the pre-computed vectors.

The feature is **enabled by default** when the device is online and falls back to keyword-only search when offline. Users can disable it in settings.

> **Note:** The original design used Google Gemini + Python/FastAPI on serv00. This was replaced by a Cloudflare Worker because: (1) the local ONNX model (~470MB) exceeded serv00's 512MB RAM limit, (2) Workers AI eliminates external API dependency, (3) Cloudflare's free tier is sufficient for this app's traffic.

## Architecture

### Embedding Model

**Model:** `@cf/baai/bge-m3` via Cloudflare Workers AI

| Property | Value |
|---|---|
| Embedding dimensions | 1024 raw, truncated to **384** (Matryoshka) |
| Max input tokens | 8,192 per text |
| Polish support | Yes (XLM-RoBERTa backbone, 100+ languages) |
| Pricing | Free tier: 10K neurons/day (~261 neurons for full corpus generation) |

**Rationale:** Available natively on Cloudflare Workers AI (no external API key), supports Polish, and the same model handles both document and query embedding — guaranteeing vector space compatibility. 384-dim truncation (Matryoshka) keeps cosine similarity within the Worker's 10ms free-tier CPU budget.

**Why not on-device inference?** On-device ONNX inference requires a ~470MB model download, a Dart SentencePiece tokenizer (no mature library exists), and adds significant implementation complexity. Since the corpus is static, pre-computing verse embeddings eliminates the need for on-device model inference — only query embedding requires an API call.

### Chunking Strategy

Embed each verse/stanza as a separate chunk. Hymn texts are already stored as `List<String>` where each entry is a verse.

**Data analysis of existing verses (3984 total):**

| Char range | Count | % |
|---|---|---|
| 0–100 | 398 | 10% |
| 100–200 | 2870 | 72% |
| 200–300 | 665 | 17% |
| 300–500 | 50 | 1% |
| 500+ | 1 | <0.1% |

Median verse length is 148 chars. 97% of verses are under 300 chars. All verses fit well within the model's 2,048-token limit. No further splitting is needed.

Hymn titles are also embedded (as additional vectors prepended with the hymn group/subgroup) to support conceptual queries like "pieśni o Duchu Świętym" (songs about the Holy Spirit).

**Pre-computed embeddings size:** ~(3984 verses + 875 titles) × 384 dims × 4 bytes = **~7.5MB**

This data lives in Cloudflare Workers KV only. The app does not ship or load embeddings — it sends queries to the Worker and receives ranked results.

### Query Flow

```
User types query
    │
    ▼ (300ms debounce, existing)
    │
App sends POST /search to Cloudflare Worker
    │
    ▼
    │
Cloudflare Worker (search-worker/)
    ├── Embed query via Workers AI @cf/baai/bge-m3 (384 dims)
    ├── Load pre-computed embeddings from KV (cached in module scope after cold start)
    ├── Dot product similarity vs ~4859 vectors (~1ms)
    └── Return ranked [(hymn_number, verse_index, score), ...]
    │
    ▼
    │
App merges semantic scores with keyword scores
    │
    ▼
    │
Display merged results
```

### Score Merging

When the device is online and semantic search is enabled, both search engines run in parallel:

| Engine | Score range | What it catches |
|---|---|---|
| Keyword (existing) | 0–100 | Exact/partial matches on number, title, text |
| Semantic (new) | 0–1 (cosine similarity), scaled to 0–100 | Fuzzy fragments, paraphrases, conceptual queries |

**Combined score:** `keyword_score + 0.5 * semantic_score`

Keyword results are weighted higher because they are high-precision (user typed exact text). Semantic results supplement but don't compete with keyword matches. This ensures that an exact hymn number match (100 pts keyword) still outranks a vaguely similar verse (e.g., 20 pts semantic). But a query like *"o ja pragnę w mym sercu"* that scores 0 on keyword search will still surface results via semantic score.

**Open question:** The 0.5 weight may need tuning after testing with real queries. Start with 0.5 and adjust based on user feedback.

## Server-Side API

### Endpoint

**URL:** `https://spiewnik-pielgrzyma-search.norbertchmiel-it.workers.dev/search`

Hosted on Cloudflare's global edge network. No additional proxy needed.

### API Contract

**Request:**
```
POST /search
Content-Type: application/json

{
  "query": "o ja pragnę w mym sercu",
  "top_k": 20
}
```

**Response:**
```json
{
  "results": [
    {"hymn_number": "340", "verse_index": 2, "score": 0.87},
    {"hymn_number": "115", "verse_index": 0, "score": 0.72},
    ...
  ]
}
```

### Implementation

**Stack:** TypeScript + Cloudflare Worker (`search-worker/`)

**Components:**
1. **Embeddings store** — pre-computed verse/title embeddings (~7.5MB) stored in Workers KV (binding: `SPIEWNIK_PIELGRZYMA`). Loaded into module-scope `Float32Array` on cold start and cached across warm invocations.
2. **Workers AI client** — calls `@cf/baai/bge-m3` via `env.AI.run()` to embed the user's query. Truncates 1024→384 dims and L2-normalizes.
3. **Similarity search** — dot product (= cosine similarity, since embeddings are pre-normalized) over ~4859 vectors. Returns top-K results. Brute-force is fine for this scale.

**Query logging:** Not implemented yet. Planned: Cloudflare D1 (managed SQLite at the edge, free tier).

### Deployment

```bash
cd search-worker
wrangler deploy
```

Worker is deployed to Cloudflare's free tier. No infrastructure to manage.

## User Experience

### Default Behavior

Semantic search is **enabled by default**. No opt-in, no download, no confirmation dialog.

| Network state | Behavior |
|---|---|
| Online | Keyword + semantic search, merged results |
| Offline | Keyword search only (current behavior, unchanged) |

The transition is seamless — if the API call fails or times out (>2s), the app silently falls back to keyword-only results. No error shown to the user.

### Settings

A toggle in settings: **"Wyszukiwanie inteligentne"** (ON by default)

When disabled, the app skips the API call entirely and uses keyword search only, regardless of network state. This is a user preference stored in SharedPreferences.

### Search UI

The search UI (search bar, debounce, results list) remains unchanged. No visual indicator distinguishes keyword vs. semantic results.

### Web App

Unlike the previous on-device approach, the API-based architecture works identically on web. **No platform exclusion needed** — the web app also benefits from semantic search.

## Implementation

### Build-Time Pipeline

**Script:** `scripts/generate_embeddings_bge_m3.py`

- Reads `assets/hymns_texts.json` and `assets/hymns.csv`
- Calls Workers AI REST API (`@cf/baai/bge-m3`) in batches of 100
- Truncates 1024→384 dims and L2-normalizes (Matryoshka)
- Outputs `search-worker/data/hymns_embeddings_bge_m3.bin` (float32) and `search-worker/data/hymns_embeddings_bge_m3_meta.json`
- Needs `CLOUDFLARE_ACCOUNT_ID` + `CLOUDFLARE_API_TOKEN` (injected via fnox)

Run: `fnox exec -- uv run --project search-worker --group dev python scripts/generate_embeddings_bge_m3.py`

After generation, upload to KV (**always use `--remote`**):
```bash
wrangler kv key put --namespace-id=<id> --remote "hymns_embeddings_bge_m3.bin" --path=search-worker/data/hymns_embeddings_bge_m3.bin
wrangler kv key put --namespace-id=<id> --remote "hymns_embeddings_bge_m3_meta.json" --path=search-worker/data/hymns_embeddings_bge_m3_meta.json
```

### Worker (`search-worker/`)

| File | Purpose |
|---|---|
| `src/index.ts` | Worker entry: embed query, load KV, cosine similarity, return top-K |
| `wrangler.toml` | CF config: AI binding + KV namespace binding |
| `package.json` | Types only (`@cloudflare/workers-types`, `typescript`) |

### App-Side Changes (pending)

| File | Change |
|---|---|
| `lib/app/services/search_api.dart` | **New** — HTTP client for `/search` endpoint, timeout, offline fallback |
| `lib/app/providers/hymns/search_engine.dart` | Hybrid scoring: `keyword_score + 0.5 * (semantic_score * 100)` |
| `lib/app/providers/hymns/provider.dart` | Async search support |
| Settings | Add "Wyszukiwanie inteligentne" toggle (ON by default) |
| `.env` / `.env.example` | Add `SEARCH_API_BASE` |
| `pubspec.yaml` | Add `connectivity_plus`, `http` |

### Deployment

```bash
cd search-worker && wrangler deploy
```

## Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Workers AI free tier (10K neurons/day) exhausted | Search stops working | At ~50 tokens/query, budget = ~185K queries/day. Extremely unlikely to hit for this app. |
| Workers AI latency spikes | Slow search results | 3s timeout in Flutter client; fall back to keyword-only silently. |
| CF Worker cold start | First request after inactivity is slow | Acceptable — KV load takes ~100ms, subsequent warm requests use cached embeddings. |
| Network unavailable | No semantic search | Graceful fallback to keyword-only. Default offline behavior unchanged. |
| Semantic search returns irrelevant results | User confusion | Keyword score weighted 2x higher than semantic. User can disable in settings. |
| BGE-M3 Polish quality insufficient | Poor search results | Can switch query embedding model (only `env.AI.run()` call changes). Corpus re-embedding needed only if model changes. |

## Open Questions

1. **Score weighting** — Start with `keyword + 0.5 * semantic`. Tune after testing with real queries.
2. **Search result explanation** — Should we indicate which verse matched? Defer to post-MVP.
3. **Query logging** — Planned via Cloudflare D1 (managed SQLite, free tier). Not yet implemented.
4. **Monitoring** — Cloudflare Workers analytics covers request count and errors. Add a synthetic health check if needed.
