import os

MODEL_NAME = "intfloat/multilingual-e5-small"
EMBEDDING_DIMS = 384
DATA_DIR = os.path.join(os.path.dirname(__file__), "data")
DATABASE_URL = os.environ.get("DATABASE_URL", "")
DEFAULT_TOP_K = 20
