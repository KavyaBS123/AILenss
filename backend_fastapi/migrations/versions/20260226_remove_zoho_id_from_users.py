"""
Revision ID: remove_zoho_id_from_users
Revises: 20250218_ailens_initial
Create Date: 2026-02-26
"""
from alembic import op
import sqlalchemy as sa

def upgrade():
    with op.batch_alter_table('users') as batch_op:
        batch_op.drop_column('zoho_id')

def downgrade():
    with op.batch_alter_table('users') as batch_op:
        batch_op.add_column(sa.Column('zoho_id', sa.String(), index=True))
