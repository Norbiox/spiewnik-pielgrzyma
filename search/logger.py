from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker

from search.db import SearchLog


class SearchLogger:
    def __init__(self, session_factory: async_sessionmaker[AsyncSession]):
        self._session_factory = session_factory

    async def log(self, query: str, results: list[dict], latency_ms: int):
        async with self._session_factory() as session:
            entry = SearchLog(query=query, results=results, latency_ms=latency_ms)
            session.add(entry)
            await session.commit()
