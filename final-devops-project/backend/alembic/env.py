"""Use a supplied connection for serialized PostgreSQL migrations."""
from alembic import context

from app.database import Base, database_url, make_engine
from app import models  # noqa: F401

config = context.config


def run(connection):
    context.configure(connection=connection, target_metadata=Base.metadata)
    with context.begin_transaction():
        context.run_migrations()


if context.is_offline_mode():
    context.configure(url=database_url(), target_metadata=Base.metadata, literal_binds=True)
    with context.begin_transaction():
        context.run_migrations()
elif config.attributes.get("connection") is not None:
    run(config.attributes["connection"])
else:
    with make_engine(database_url()).connect() as connection:
        run(connection)
