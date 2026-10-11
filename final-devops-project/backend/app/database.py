"""Runtime connections; migrations own the database schema."""
import os

from sqlalchemy import URL, create_engine
from sqlalchemy.orm import DeclarativeBase, sessionmaker


class Base(DeclarativeBase):
    pass


def database_url():
    value = os.getenv("DATABASE_URL")
    if value:
        return value.replace("postgresql://", "postgresql+psycopg://", 1)
    if os.getenv("PGHOST"):
        return URL.create(
            "postgresql+psycopg", username=os.getenv("PGUSER", "notes"),
            password=os.getenv("PGPASSWORD"), host=os.environ["PGHOST"],
            port=int(os.getenv("PGPORT", "5432")), database=os.getenv("PGDATABASE", "notes"),
        )
    return "sqlite:///" + os.getenv("DB_PATH", "notes.db")


def make_engine(url):
    options = {"check_same_thread": False} if str(url).startswith("sqlite") else {"connect_timeout": 5}
    return create_engine(url, connect_args=options, pool_pre_ping=True)


engine = make_engine(database_url())
SessionLocal = sessionmaker(bind=engine)


def get_db():
    with SessionLocal() as session:
        yield session
