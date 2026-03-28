import os

GEMINI_API_KEY = os.environ["GEMINI_API_KEY"]
GEMINI_MODEL = "gemini-embedding-001"
EMBEDDING_DIMS = 256
DATA_DIR = os.path.join(os.path.dirname(__file__), "data")
DB_PATH = os.path.join(os.path.dirname(__file__), "data", "search_logs.db")
DEFAULT_TOP_K = 20
