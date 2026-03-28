import json
import sqlite3
from datetime import datetime, timezone


class SearchLogger:
    def __init__(self, db_path: str):
        self.db_path = db_path
        self._init_db()

    def _init_db(self):
        conn = sqlite3.connect(self.db_path)
        conn.execute(
            """
            CREATE TABLE IF NOT EXISTS search_logs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp TEXT NOT NULL,
                query TEXT NOT NULL,
                results TEXT NOT NULL,
                latency_ms INTEGER
            )
            """
        )
        conn.commit()
        conn.close()

    def log(self, query: str, results: list[dict], latency_ms: int):
        conn = sqlite3.connect(self.db_path)
        conn.execute(
            "INSERT INTO search_logs (timestamp, query, results, latency_ms) VALUES (?, ?, ?, ?)",
            (
                datetime.now(timezone.utc).isoformat(),
                query,
                json.dumps(results),
                latency_ms,
            ),
        )
        conn.commit()
        conn.close()
