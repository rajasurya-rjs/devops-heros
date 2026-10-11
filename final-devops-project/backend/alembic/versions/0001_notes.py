"""Create notes, or adopt the identical table from the earlier lab without losing data."""
from alembic import op
import sqlalchemy as sa

revision = "0001_notes"
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    inspector = sa.inspect(op.get_bind())
    if inspector.has_table("notes"):
        columns = {column["name"] for column in inspector.get_columns("notes")}
        if columns != {"id", "text"}:
            raise RuntimeError("Existing notes schema is incompatible; refusing to alter saved data")
        return
    op.create_table("notes", sa.Column("id", sa.Integer, primary_key=True),
                    sa.Column("text", sa.Text, nullable=False))


def downgrade():
    raise RuntimeError("Destructive downgrade is disabled; restore a backup explicitly")
