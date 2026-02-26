"""
Add embedding column to face_data table
"""
from alembic import op
import sqlalchemy as sa

def upgrade():
    with op.batch_alter_table('face_data') as batch_op:
        batch_op.add_column(sa.Column('embedding', sa.String(), nullable=True))

def downgrade():
    with op.batch_alter_table('face_data') as batch_op:
        batch_op.drop_column('embedding')
