from pathlib import Path

from alembic import command
from alembic.config import Config
from sqlalchemy import text

from app.database import make_engine


def test_migration_adopts_existing_notes_without_data_loss(tmp_path):
    engine = make_engine(f"sqlite:///{tmp_path}/legacy.db")
    config = Config(str(Path(__file__).parents[1] / "alembic.ini"))
    with engine.begin() as connection:
        connection.execute(text("CREATE TABLE notes (id INTEGER PRIMARY KEY, text TEXT NOT NULL)"))
        connection.execute(text("INSERT INTO notes VALUES (1, 'Existing deployment evidence')"))
        config.attributes["connection"] = connection
        command.upgrade(config, "head")
        command.upgrade(config, "head")
        assert connection.execute(text("SELECT text FROM notes WHERE id=1")).scalar() == "Existing deployment evidence"
        assert connection.execute(text("SELECT version_num FROM alembic_version")).scalar() == "0001_notes"
    engine.dispose()
