# Design: Semantic Search for Hymns

**Issue:** #26
**Status:** Draft
**Date:** 2026-03-28

## Problem

The current search is keyword-based: it matches hymn number, title substring, and text substring. It fails when a user remembers a hymn fragment inaccurately — e.g., typing *"o ja pragnę w mym sercu"* when the actual text is *"o jak pragnę w mym sercu"*. It also can't handle conceptual queries where the user describes what the hymn is about rather than quoting it.

## Solution

Add semantic search powered by a cloud embedding API (Google Gemini). The hymn corpus is static (875 hymns, 3984 verses, never changes), so verse embeddings are pre-computed once at build time. At search time, the app sends the user's query to a thin Python API on serv00, which embeds it via Google's Gemini API and computes cosine similarity against the pre-computed vectors server-side.

The feature is **enabled by default** when the device is online and falls back to keyword-only search when offline. Users can disable it in settings.

## Architecture

### Embedding Model

**Model:** Google `gemini-embedding-001` (via Gemini API)

| Property | Value |
|---|---|
| Embedding dimensions | configurable: 128–3072 (we use **256**) |
| Max input tokens | 2,048 per text |
| Max texts per request | 250 (batch) |
| Polish support | Yes (100+ languages) |
| Task types | `RETRIEVAL_QUERY`, `RETRIEVAL_DOCUMENT` |
| Pricing | Free tier (sufficient for our scale) |

**Rationale:** Best tradeoff between quality, cost (free), and simplicity. The model supports Polish well, requires only an API key, and handles both query and document embedding with task-specific modes. Using 256 dimensions (via Matryoshka truncation) keeps the pre-computed asset small while retaining good quality.

**Why not on-device inference?** The app's hosting (serv00) has a 512MB RAM limit and runs FreeBSD, making it impossible to host ML models. On-device ONNX inference would require a ~118MB model download, a Dart SentencePiece tokenizer (no mature library exists), and adds significant implementation complexity. Since the corpus is static, pre-computing verse embeddings eliminates the need for on-device model inference entirely — only query embedding requires an API call.

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

**Pre-computed embeddings size:** ~(3984 verses + 875 titles) × 256 dims × 4 bytes = **~5.0MB**

This data lives on the server only. The app does not ship or load embeddings — it sends queries to the API and receives ranked results.

### Query Flow

```
User types query
    │
    ▼ (300ms debounce, existing)
    │
App sends query to server
    │
    ▼
    │
Cloudflare (rate limiting, security)
    │
    ▼
    │
serv00 Python API (FastAPI)
    ├── Call Gemini API: embed query (task_type=RETRIEVAL_QUERY, 256 dims)
    ├── Cosine similarity vs pre-computed verse/title embeddings (~1ms)
    ├── Log query + results to SQLite
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

**URL:** `https://spiewnikpielgrzyma.norbertchmiel.pl/search`

Proxied through Cloudflare for rate limiting and security.

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

**Stack:** Python + FastAPI, running on serv00 (FreeBSD shared hosting)

**Components:**
1. **Embeddings store** — pre-computed verse/title embeddings loaded into memory as a numpy array (~5MB). Loaded once at startup.
2. **Gemini API client** — calls `gemini-embedding-001` via REST to embed the user's query. Uses a Google AI Studio API key (free tier).
3. **Similarity search** — cosine similarity between query embedding and all stored embeddings. Returns top-K results. Brute-force is fine for ~5000 vectors.
4. **Query logger** — logs every query and its results to a local SQLite database for future analysis and improvement.

**Memory footprint:** Python (~30–50MB) + FastAPI (~10MB) + numpy (~30MB) + embeddings (~5MB) ≈ **~100MB**. Well within serv00's 512MB account limit.

### Hosting on serv00

serv00 is FreeBSD shared hosting with:
- 512MB RAM per account
- 3GB disk
- 20 max concurrent processes
- Python 3.11 available
- TCP port reservation (1024–64000)
- No systemd (cron-based keepalive for process management)

**Deployment approach:**
1. Reserve a TCP port via DevilWEB panel
2. Run FastAPI with uvicorn on that port
3. Create proxy website pointing domain to `localhost:PORT`
4. Set up cron keepalive to restart the process if it dies
5. Cloudflare DNS proxies `spiewnikpielgrzyma.norbertchmiel.pl` with `/search` path routed to the API

### Query Logging

All queries are logged anonymously for future improvement:

```sql
CREATE TABLE search_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT NOT NULL,
    query TEXT NOT NULL,
    results TEXT NOT NULL,  -- JSON array of (hymn_number, verse_index, score)
    latency_ms INTEGER
);
```

No user identifiers, device info, or IP addresses are stored.

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

## Implementation Plan

### Build-Time Pipeline

**New script:** `scripts/generate_embeddings.py`

- Reads `assets/hymns_texts.json` and `assets/hymns.csv`
- Calls Gemini API `batchEmbedContents` (task_type=RETRIEVAL_DOCUMENT, 256 dims)
- Embeds each verse and each hymn title (with group/subgroup context)
- Outputs `search/data/hymns_embeddings.bin` (binary float32 array) and `search/data/hymns_embeddings_meta.json` (maps index to hymn_number + verse_index, or hymn_number + "title")

This script runs once (or whenever hymns change). 3984 verses + 875 titles = 4859 texts ÷ 250 per batch = 20 API calls. Completes in seconds.

### Server-Side

**New directory:** `search/`

| File | Purpose |
|---|---|
| `search/main.py` | FastAPI app with `/search` endpoint |
| `search/embeddings.py` | Load pre-computed embeddings, cosine similarity |
| `search/gemini.py` | Gemini API client for query embedding |
| `search/logger.py` | SQLite query logging |
| `search/requirements.txt` | Dependencies: fastapi, uvicorn, numpy, httpx |
| `search/data/hymns_embeddings.bin` | Pre-computed embeddings (generated by script) |
| `search/data/hymns_embeddings_meta.json` | Index-to-hymn mapping (generated by script) |

### App-Side Changes

| File | Change |
|---|---|
| `lib/app/providers/hymns/search_engine.dart` | Add semantic scoring path: call API, merge scores |
| `lib/app/providers/hymns/semantic_search.dart` | **New** — HTTP client for `/search` endpoint, timeout handling, offline fallback |
| `lib/app/widgets/menu/` or settings | Add "Wyszukiwanie inteligentne" toggle (ON by default) |

**No new Flutter dependencies required.** The app only needs `http` or `dart:io` for API calls (already available).

### Deployment

| Step | Action |
|---|---|
| 1 | Generate embeddings: `python scripts/generate_embeddings.py` (outputs to `search/data/`) |
| 2 | Deploy search service to serv00 (SCP + port setup) |
| 3 | Configure Cloudflare DNS + proxy rules |
| 4 | Add server URL to app `.env` (e.g., `SEARCH_API_URL`) |
| 5 | Deploy app update |

## Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Gemini API free tier limits change | Search stops working | Monitor usage; at our scale, even paid tier costs <$0.01/month. Can switch to another provider (Jina, OpenAI) with minimal code change — only the query embedding call changes. |
| Gemini API latency spikes | Slow search results | 2-second timeout; fall back to keyword-only silently. Users still get instant keyword results. |
| serv00 process dies | API unavailable | Cron keepalive restarts the process. App falls back to keyword search. |
| Network unavailable | No semantic search | Graceful fallback to keyword-only. This is the default offline behavior. |
| Semantic search returns irrelevant results | User confusion | Keyword score weighted 2x higher than semantic. User can disable in settings. |
| Cloudflare blocks legitimate requests | Search broken for some users | Monitor Cloudflare analytics. Use permissive WAF rules for the `/search` path. |
| Google API key exposed in server code | Unauthorized usage | Key stored as environment variable on serv00, not in source code. Cloudflare protects the endpoint from abuse. |
| serv00 RAM limit exceeded | Process killed | Total footprint ~100MB, well within 512MB limit. Monitor with periodic checks. |

## Open Questions

1. **Score weighting** — Start with `keyword + 0.5 * semantic`. Tune after testing with real queries from the log.
2. **Gemini API key management** — Store in serv00 environment or a `.env` file on the server. Not committed to the repo.
3. **Search result explanation** — Should we indicate *which verse* matched semantically? (e.g., highlight or show the matching verse snippet in results). Defer to post-MVP.
4. **Title embedding format** — What context to prepend to titles? Proposed: `"{group} - {subgroup} - {title}"` to give the model topical context.
5. **Server deployment automation** — Manual SCP for now. Consider adding a GitHub Action for server deployment later.
6. **Monitoring** — How to monitor the server health and API usage? Basic approach: cron job that pings the endpoint and alerts on failure.
