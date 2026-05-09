interface Env {
  SPIEWNIK_PIELGRZYMA: KVNamespace;
  AI: Ai;
}

interface EmbeddingMeta {
  hymn_number: string;
  verse_index?: number;
  type?: string;
}

interface SearchResult extends EmbeddingMeta {
  score: number;
}

const DIMS = 384;

// Persists across warm invocations in the same isolate
let cachedEmbeddings: Float32Array | null = null;
let cachedMeta: EmbeddingMeta[] | null = null;

async function loadEmbeddings(kv: KVNamespace): Promise<{ embeddings: Float32Array; meta: EmbeddingMeta[] }> {
  if (cachedEmbeddings !== null && cachedMeta !== null) {
    return { embeddings: cachedEmbeddings, meta: cachedMeta };
  }

  const [binBuffer, metaText] = await Promise.all([
    kv.get("hymns_embeddings_bge_m3.bin", "arrayBuffer"),
    kv.get("hymns_embeddings_bge_m3_meta.json", "text"),
  ]);

  if (!binBuffer || !metaText) {
    throw new Error("Embeddings not found in KV — upload them first");
  }

  cachedEmbeddings = new Float32Array(binBuffer);
  cachedMeta = JSON.parse(metaText) as EmbeddingMeta[];

  return { embeddings: cachedEmbeddings, meta: cachedMeta };
}

function truncateAndNormalize(vec: number[], dims: number): Float32Array {
  const out = new Float32Array(dims);
  let norm = 0;
  for (let i = 0; i < dims; i++) {
    out[i] = vec[i];
    norm += vec[i] * vec[i];
  }
  norm = Math.sqrt(norm);
  for (let i = 0; i < dims; i++) out[i] /= norm;
  return out;
}

function topK(scores: Float32Array, meta: EmbeddingMeta[], k: number): SearchResult[] {
  const indices = Array.from({ length: scores.length }, (_, i) => i);
  indices.sort((a, b) => scores[b] - scores[a]);
  return indices.slice(0, k).map((i) => ({ ...meta[i], score: scores[i] }));
}

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

const JSON_HEADERS = { ...CORS_HEADERS, "Content-Type": "application/json" };

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    if (request.method === "OPTIONS") {
      return new Response(null, { headers: CORS_HEADERS });
    }

  if (request.method !== "POST" || url.pathname !== "/search") {
      return new Response("Not found", { status: 404 });
    }

    let query: string;
    let topKCount: number;
    try {
      const body = (await request.json()) as { query?: string; top_k?: number };
      if (!body.query || typeof body.query !== "string") {
        return new Response(JSON.stringify({ error: "Missing query" }), { status: 400, headers: JSON_HEADERS });
      }
      query = body.query;
      topKCount = body.top_k ?? 20;
    } catch {
      return new Response(JSON.stringify({ error: "Invalid JSON" }), { status: 400, headers: JSON_HEADERS });
    }

    try {
      // Embed query and load corpus in parallel to minimize latency
      const [aiResult, { embeddings, meta }] = await Promise.all([
        env.AI.run("@cf/baai/bge-m3", { text: [query] }) as Promise<{ data: number[][] }>,
        loadEmbeddings(env.SPIEWNIK_PIELGRZYMA),
      ]);

      const queryVec = truncateAndNormalize(aiResult.data[0], DIMS);

      // Dot product = cosine similarity because corpus embeddings are L2-normalized
      const numVecs = meta.length;
      const scores = new Float32Array(numVecs);
      for (let i = 0; i < numVecs; i++) {
        let dot = 0;
        const offset = i * DIMS;
        for (let j = 0; j < DIMS; j++) {
          dot += queryVec[j] * embeddings[offset + j];
        }
        scores[i] = dot;
      }

      return new Response(JSON.stringify({ results: topK(scores, meta, topKCount) }), { headers: JSON_HEADERS });
    } catch (err) {
      const message = err instanceof Error ? err.message : "Internal error";
      return new Response(JSON.stringify({ error: message }), { status: 500, headers: JSON_HEADERS });
    }
  },
};
