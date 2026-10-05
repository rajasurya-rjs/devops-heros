"""Operations Notes HTTP API with PostgreSQL or SQLite persistence and metrics."""
import json
import os
import resource
import sqlite3
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse

DB_PATH = os.environ.get("DB_PATH", "/data/notes.db")
DATABASE_URL = os.environ.get("DATABASE_URL")
POSTGRES = bool(DATABASE_URL or os.environ.get("PGHOST"))
if POSTGRES:
    import psycopg
    DATABASE_ERRORS = (sqlite3.Error, psycopg.Error)
else:
    DATABASE_ERRORS = (sqlite3.Error,)
STARTED = time.monotonic()
COUNTERS = {"requests": 0, "errors": 0}
LOCK = threading.Lock()

class Database:
    """Use the same bound-parameter operations for either storage engine."""
    def __init__(self):
        self.db = (psycopg.connect(DATABASE_URL or "", connect_timeout=5)
                   if POSTGRES else sqlite3.connect(DB_PATH, timeout=15))

    def __enter__(self):
        return self

    def __exit__(self, kind, value, traceback):
        try:
            self.db.rollback() if kind else self.db.commit()
        finally:
            self.db.close()

    def execute(self, query, params=()):
        return self.db.execute(query.replace("?", "%s") if POSTGRES else query, params)


def connect():
    return Database()


def init_db():
    schema = ("CREATE TABLE IF NOT EXISTS notes (id SERIAL PRIMARY KEY, text TEXT NOT NULL)"
              if POSTGRES else
              "CREATE TABLE IF NOT EXISTS notes (id INTEGER PRIMARY KEY, text TEXT NOT NULL)")
    with connect() as db:
        db.execute(schema)

class Handler(BaseHTTPRequestHandler):
    def respond(self, status, body, content_type="application/json"):
        with LOCK:
            COUNTERS["requests"] += 1
            COUNTERS["errors"] += int(status >= 400)
        payload = (json.dumps(body) if content_type == "application/json" else body).encode()
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(payload)))
        self.send_header("X-Content-Type-Options", "nosniff")
        self.end_headers()
        self.wfile.write(payload)

    def do_GET(self):
        path = urlparse(self.path).path
        if path == "/health":
            self.respond(200, {"status": "ok", "version": os.getenv("APP_VERSION", "v1")})
        elif path == "/ready":
            try:
                with connect() as db:
                    db.execute("SELECT 1").fetchone()
                self.respond(200, {"status": "ok", "version": os.getenv("APP_VERSION", "v1")})
            except DATABASE_ERRORS:
                self.respond(503, {"status": "database unavailable"})
        elif path == "/api/notes":
            with connect() as db:
                rows = db.execute("SELECT id, text FROM notes ORDER BY id").fetchall()
            self.respond(200, [{"id": row[0], "text": row[1]} for row in rows])
        elif path == "/api/config":
            self.respond(200, {"title": os.getenv("APP_TITLE", "Operations Notes"),
                              "version": os.getenv("APP_VERSION", "v1"),
                              "secret_injected": bool(os.getenv("APP_TOKEN")),
                              "database": "PostgreSQL" if POSTGRES else "SQLite"})
        elif path == "/metrics":
            usage = resource.getrusage(resource.RUSAGE_SELF)
            with LOCK:
                requests, errors = COUNTERS["requests"], COUNTERS["errors"]
            metrics = f"""# HELP ops_requests_total HTTP responses served.
# TYPE ops_requests_total counter
ops_requests_total {requests}
# HELP ops_errors_total HTTP error responses.
# TYPE ops_errors_total counter
ops_errors_total {errors}
# TYPE ops_uptime_seconds gauge
ops_uptime_seconds {time.monotonic() - STARTED:.3f}
# TYPE ops_cpu_seconds_total counter
ops_cpu_seconds_total {usage.ru_utime + usage.ru_stime:.6f}
# TYPE ops_memory_maxrss gauge
ops_memory_maxrss {usage.ru_maxrss}
"""
            self.respond(200, metrics, "text/plain; version=0.0.4")
        elif path == "/burn":
            deadline = time.monotonic() + 0.05
            value = 1
            while time.monotonic() < deadline:
                value = (value * 13 + 7) % 1000003
            self.respond(200, {"work": value})
        elif path == "/":
            self.respond(200, Path(__file__).with_name("index.html").read_text(), "text/html; charset=utf-8")
        else:
            self.respond(404, {"error": "not found"})

    def write_note(self, update=False):
        try:
            length = int(self.headers.get("Content-Length", "0"))
            if not 0 < length <= 4096:
                raise ValueError("body must be between 1 and 4096 bytes")
            data = json.loads(self.rfile.read(length))
            text = data.get("text")
            if not isinstance(text, str) or not text.strip() or len(text) > 500:
                raise ValueError("text must contain 1 to 500 characters")
            with connect() as db:
                if update:
                    ident = int(urlparse(self.path).path.rsplit("/", 1)[1])
                    cursor = db.execute("UPDATE notes SET text=? WHERE id=?", (text, ident))
                    if cursor.rowcount == 0:
                        self.respond(404, {"error": "note not found"})
                        return
                else:
                    ident = db.execute("INSERT INTO notes(text) VALUES (?) RETURNING id", (text,)).fetchone()[0]
            self.respond(200 if update else 201, {"id": ident, "text": text})
        except (ValueError, TypeError, AttributeError):
            self.respond(400, {"error": "invalid note"})

    def do_POST(self):
        if urlparse(self.path).path == "/api/notes":
            self.write_note()
        else:
            self.respond(404, {"error": "not found"})

    def do_PUT(self):
        if urlparse(self.path).path.startswith("/api/notes/"):
            self.write_note(update=True)
        else:
            self.respond(404, {"error": "not found"})

    def do_DELETE(self):
        try:
            path = urlparse(self.path).path
            if not path.startswith("/api/notes/"):
                self.respond(404, {"error": "not found"})
                return
            ident = int(path.rsplit("/", 1)[1])
            with connect() as db:
                count = db.execute("DELETE FROM notes WHERE id=?", (ident,)).rowcount
            self.respond(200 if count else 404, {"deleted": bool(count)})
        except ValueError:
            self.respond(400, {"error": "invalid id"})

    def log_message(self, fmt, *args):
        print(json.dumps({"component": "http", "message": fmt % args}), flush=True)

if __name__ == "__main__":
    if not POSTGRES:
        Path(DB_PATH).parent.mkdir(parents=True, exist_ok=True)
    for attempt in range(60):
        try:
            init_db()
            break
        except DATABASE_ERRORS:
            if attempt == 59:
                raise
            print("Waiting for database startup", flush=True)
            time.sleep(2)
    # Container port must accept traffic from the Service and probes.
    server = ThreadingHTTPServer(("0.0.0.0", int(os.getenv("PORT", "8080"))), Handler)  # nosec B104
    print("Operations Notes listening on port 8080", flush=True)
    server.serve_forever()
