import json
import sqlite3

import pytest

from search.logger import SearchLogger


@pytest.fixture
def logger(tmp_path):
    db_path = str(tmp_path / "test_logs.db")
    return SearchLogger(db_path)


def test_log_creates_table(logger):
    logger.log("test query", [{"hymn_number": "1", "score": 0.9}], 50)
    conn = sqlite3.connect(logger.db_path)
    cursor = conn.execute("SELECT name FROM sqlite_master WHERE type='table'")
    tables = [row[0] for row in cursor]
    conn.close()
    assert "search_logs" in tables


def test_log_stores_entry(logger):
    results = [{"hymn_number": "1", "verse_index": 0, "score": 0.9}]
    logger.log("pieśń o miłości", results, 120)

    conn = sqlite3.connect(logger.db_path)
    row = conn.execute("SELECT query, results, latency_ms FROM search_logs").fetchone()
    conn.close()

    assert row[0] == "pieśń o miłości"
    assert json.loads(row[1]) == results
    assert row[2] == 120


def test_log_multiple_entries(logger):
    logger.log("query1", [], 10)
    logger.log("query2", [], 20)

    conn = sqlite3.connect(logger.db_path)
    count = conn.execute("SELECT COUNT(*) FROM search_logs").fetchone()[0]
    conn.close()

    assert count == 2
