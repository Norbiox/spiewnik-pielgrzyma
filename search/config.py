import os

MODEL_NAME = "intfloat/multilingual-e5-small"
EMBEDDING_DIMS = 384
DATA_DIR = os.path.join(os.path.dirname(__file__), "data")
DB_PATH = os.path.join(os.path.dirname(__file__), "data", "search_logs.db")
DEFAULT_TOP_K = 20
