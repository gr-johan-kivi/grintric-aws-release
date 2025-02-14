"""Create app template table
Revision ID: b05cd0792f0f
Revises: dc293ff0cbf6
Create Date: 2024-11-28 11:24:35.022199
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic
revision = "b05cd0792f0f"
down_revision = "dc293ff0cbf6"
branch_labels = None
depends_on = None


def upgrade() -> None:
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table(
        "app_templates",
        sa.Column(
            "id", sa.UUID(), server_default=sa.text("gen_random_uuid()"), nullable=False
        ),
        sa.Column("name", sa.String(), nullable=False),
        sa.Column("description", sa.String(), nullable=True),
        sa.Column("category", sa.String(), nullable=False),
        sa.Column("prompt_text", sa.String(), nullable=True),
        sa.Column("input_description", sa.String(), nullable=True),
        sa.Column("input_type", sa.String(), nullable=False),
        sa.Column(
            "completion_model_kwargs",
            postgresql.JSONB(astext_type=sa.Text()),
            nullable=True,
        ),
        sa.Column("wizard", postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column("completion_model_id", sa.UUID(), nullable=False),
        sa.Column(
            "created_at",
            sa.TIMESTAMP(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.TIMESTAMP(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(
            ["completion_model_id"],
            ["completion_models.id"],
        ),
        sa.PrimaryKeyConstraint("id"),
    )
    # ### end Alembic commands ###


def downgrade() -> None:
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_table("app_templates")
    # ### end Alembic commands ###
