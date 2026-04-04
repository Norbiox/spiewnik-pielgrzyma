"""create search_logs table

Revision ID: 75a1ab7fd0eb
Revises:
Create Date: 2026-04-04 19:23:05.810448

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "75a1ab7fd0eb"
down_revision: Union[str, Sequence[str], None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "search_logs",
        sa.Column("id", sa.Integer, primary_key=True, autoincrement=True),
        sa.Column(
            "timestamp",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.func.now(),
        ),
        sa.Column("query", sa.Text, nullable=False),
        sa.Column("results", sa.JSON, nullable=False),
        sa.Column("latency_ms", sa.Integer, nullable=True),
    )


def downgrade() -> None:
    op.drop_table("search_logs")
