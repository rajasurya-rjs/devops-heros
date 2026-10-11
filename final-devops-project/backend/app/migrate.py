"""Apply migrations once at startup, serializing concurrent PostgreSQL replicas."""
from pathlib import Path
import time

from alembic import command
from alembic.config import Config
from sqlalchemy import text
from sqlalchemy.exc import OperationalError

from .database import engine


def migrate():
    config = Config(str(Path(__file__).parents[1] / "alembic.ini"))
    with engine.connect() as connection:
        postgres = connection.dialect.name == "postgresql"
        if postgres:
            connection.execute(text("SELECT pg_advisory_lock(2410086)"))
            connection.commit()
        try:
            config.attributes["connection"] = connection
            command.upgrade(config, "head")
            connection.commit()
        finally:
            if postgres:
                connection.rollback()
                connection.execute(text("SELECT pg_advisory_unlock(2410086)"))
                connection.commit()


if __name__ == "__main__":
    for attempt in range(60):
        try:
            migrate()
            break
        except OperationalError:
            if attempt == 59:
                raise
            print("Waiting for database startup", flush=True)
            time.sleep(2)
