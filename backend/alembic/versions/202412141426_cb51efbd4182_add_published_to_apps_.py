"""add published to apps
Revision ID: cb51efbd4182
Revises: 025392d206c5
Create Date: 2024-12-14 14:26:56.232820
"""

import sqlalchemy as sa

from alembic import op

# revision identifiers, used by Alembic
revision = 'cb51efbd4182'
down_revision = '025392d206c5'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('apps', sa.Column('published', sa.Boolean(), nullable=True))

    op.execute(sa.text("UPDATE apps SET published=False"))

    op.alter_column('apps', 'published', nullable=False)

    # ### end Alembic commands ###


def downgrade() -> None:
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_column('apps', 'published')
    # ### end Alembic commands ###
