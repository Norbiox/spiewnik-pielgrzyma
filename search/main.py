import os
import time
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import async_sessionmaker, create_async_engine

from search.config import DATA_DIR, DATABASE_URL, EMBEDDING_DIMS, DEFAULT_TOP_K
from search.embeddings import EmbeddingsStore
from search.model import embed_query, load_model
from search.logger import SearchLogger


@asynccontextmanager
async def lifespan(app: FastAPI):
    load_model()
    app.state.store = EmbeddingsStore(
        bin_path=os.path.join(DATA_DIR, "hymns_embeddings.bin"),
        meta_path=os.path.join(DATA_DIR, "hymns_embeddings_meta.json"),
        dims=EMBEDDING_DIMS,
    )
    engine = create_async_engine(DATABASE_URL)
    session_factory = async_sessionmaker(engine, expire_on_commit=False)
    app.state.logger = SearchLogger(session_factory)
    app.state.engine = engine
    yield
    await engine.dispose()


app = FastAPI(lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["POST"],
    allow_headers=["Content-Type"],
)


class SearchRequest(BaseModel):
    query: str
    top_k: int = DEFAULT_TOP_K


@app.post("/search")
async def search(req: SearchRequest):
    if not req.query.strip():
        raise HTTPException(status_code=400, detail="Query must not be empty")

    start = time.monotonic()
    query_embedding = embed_query(req.query)
    results = app.state.store.search(query_embedding, top_k=req.top_k)
    latency_ms = int((time.monotonic() - start) * 1000)

    await app.state.logger.log(req.query, results, latency_ms)
    return {"results": results}
