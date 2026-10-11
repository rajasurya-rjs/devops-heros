import pytest
from sqlalchemy import text
from sqlalchemy.exc import OperationalError

from app.database import get_db
from app.main import app


def test_health(client):
    assert client.get("/health").json()["status"] == "ok"


def test_readiness(client):
    assert client.get("/ready").status_code == 200


def test_crud(client):
    response = client.post("/api/notes", json={"text": "Verify rollout"})
    assert response.status_code == 201
    ident = response.json()["id"]
    assert client.get(f"/api/notes/{ident}").json()["text"] == "Verify rollout"
    assert any(note["id"] == ident for note in client.get("/api/notes").json())
    assert client.put(f"/api/notes/{ident}", json={"text": "Verified"}).status_code == 200
    assert client.get(f"/api/notes/{ident}").json()["text"] == "Verified"
    assert client.delete(f"/api/notes/{ident}").json() == {"deleted": True}
    assert client.get(f"/api/notes/{ident}").status_code == 404


@pytest.mark.parametrize("body", [{"text": ""}, {"text": "   "}, {"text": "x" * 501},
                                     {"text": 123}, {}, [], {"text": "ok", "extra": 1}])
def test_invalid_note(client, body):
    assert client.post("/api/notes", json=body).status_code == 400


def test_sql_injection_is_data(client):
    value = "Robert'); DROP TABLE notes;--"
    assert client.post("/api/notes", json={"text": value}).status_code == 201
    assert client.get("/api/notes").json()[0]["text"] == value


@pytest.mark.parametrize("method", ["get", "put", "delete"])
def test_missing_note(client, method):
    options = {"json": {"text": "missing"}} if method == "put" else {}
    assert getattr(client, method)("/api/notes/999999", **options).status_code == 404


def test_invalid_identifier(client):
    assert client.delete("/api/notes/invalid").status_code == 400


def test_body_size_limit(client):
    assert client.post("/api/notes", content="x" * 4097).status_code == 400


def test_metrics(client):
    client.get("/health")
    response = client.get("/metrics")
    assert response.status_code == 200
    assert "ops_requests_total" in response.text
    assert "ops_request_duration_seconds_bucket" in response.text


def test_secret_is_not_returned(client, monkeypatch):
    monkeypatch.setenv("APP_TOKEN", "private-test-value")
    response = client.get("/api/config")
    assert response.json()["secret_injected"] is True
    assert "private-test-value" not in response.text


def test_openapi_documentation(client):
    assert client.get("/docs").status_code == 200
    assert "/api/notes/{ident}" in client.get("/openapi.json").json()["paths"]


def test_readiness_failure(client):
    class BrokenSession:
        def execute(self, _query):
            raise OperationalError("SELECT 1", {}, Exception("unavailable"))

    app.dependency_overrides[get_db] = lambda: BrokenSession()
    assert client.get("/ready").status_code == 503
    assert client.get("/health").status_code == 200


def test_migration_revision(migrated_engine):
    with migrated_engine.connect() as connection:
        assert connection.execute(text("SELECT version_num FROM alembic_version")).scalar() == "0001_notes"


def test_unknown_route(client):
    assert client.get("/missing").status_code == 404
