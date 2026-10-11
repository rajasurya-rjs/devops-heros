"""Every test gets migrated, isolated storage; production database variables are ignored."""
import os
from pathlib import Path

# Set before importing the runtime module. Only TEST_DATABASE_URL can select PostgreSQL.
os.environ["DATABASE_URL"] = "sqlite:///:memory:"

from alembic import command
from alembic.config import Config
from fastapi.testclient import TestClient
import pytest
from sqlalchemy.engine import make_url
from sqlalchemy.orm import sessionmaker

from app.database import Base, get_db, make_engine
from app.main import app


@pytest.fixture
def migrated_engine(tmp_path):
    url = os.getenv("TEST_DATABASE_URL", f"sqlite:///{tmp_path}/notes.db")
    parsed = make_url(url)
    if parsed.get_backend_name() == "postgresql" and not (parsed.database or "").endswith("_test"):
        raise RuntimeError("PostgreSQL tests require a dedicated database ending in _test")
    engine = make_engine(url)
    config = Config(str(Path(__file__).parents[1] / "alembic.ini"))
    with engine.begin() as connection:
        config.attributes["connection"] = connection
        command.upgrade(config, "head")
    yield engine
    # Preserve the schema and clear only rows in the explicitly selected disposable test DB.
    with engine.begin() as connection:
        for table in reversed(Base.metadata.sorted_tables):
            connection.execute(table.delete())
    engine.dispose()


@pytest.fixture
def client(migrated_engine):
    sessions = sessionmaker(bind=migrated_engine)

    def test_db():
        with sessions() as session:
            yield session

    app.dependency_overrides[get_db] = test_db
    with TestClient(app) as client:
        yield client
    app.dependency_overrides.clear()
