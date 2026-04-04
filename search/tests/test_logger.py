import pytest
from sqlalchemy import select, text
from sqlalchemy.ext.asyncio import async_sessionmaker, create_async_engine

from search.db import Base, SearchLog
from search.logger import SearchLogger


@pytest.fixture
async def session_factory():
    engine = create_async_engine("sqlite+aiosqlite:///:memory:")
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    factory = async_sessionmaker(engine, expire_on_commit=False)
    yield factory
    await engine.dispose()


@pytest.fixture
def logger(session_factory):
    return SearchLogger(session_factory)


@pytest.mark.asyncio
async def test_log_stores_entry(logger, session_factory):
    results = [{"hymn_number": "1", "score": 0.9}]
    await logger.log("test query", results, 42)

    async with session_factory() as session:
        rows = (await session.execute(select(SearchLog))).scalars().all()
        assert len(rows) == 1
        assert rows[0].query == "test query"
        assert rows[0].results == results
        assert rows[0].latency_ms == 42


@pytest.mark.asyncio
async def test_log_multiple_entries(logger, session_factory):
    await logger.log("query1", [], 10)
    await logger.log("query2", [], 20)

    async with session_factory() as session:
        count = (
            await session.execute(text("SELECT COUNT(*) FROM search_logs"))
        ).scalar()
        assert count == 2
