"""FastAPI endpoints with database readiness, request metrics and JSON logs."""
import json
import os
import resource
import time

from fastapi import Depends, FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse, Response
from prometheus_client import CollectorRegistry, Counter, Histogram, generate_latest
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from .database import engine, get_db
from .routes import router

app = FastAPI(title="Operations Notes", version="2.0.0")
app.include_router(router)
registry = CollectorRegistry()
requests = Counter("ops_requests", "HTTP responses served", registry=registry)
errors = Counter("ops_errors", "HTTP error responses", registry=registry)
latency = Histogram("ops_request_duration_seconds", "HTTP request latency", registry=registry)
started = time.monotonic()


@app.middleware("http")
async def observe(request: Request, call_next):
    start = time.monotonic()
    length = request.headers.get("content-length", "0")
    if not length.isdigit() or int(length) > 4096:
        response = JSONResponse({"error": "Body exceeds 4096 bytes"}, status_code=400)
    else:
        response = await call_next(request)
    requests.inc()
    if response.status_code >= 400:
        errors.inc()
    latency.observe(time.monotonic() - start)
    response.headers["X-Content-Type-Options"] = "nosniff"
    print(json.dumps({"component": "http", "method": request.method,
                      "path": request.url.path, "status": response.status_code}), flush=True)
    return response


@app.exception_handler(RequestValidationError)
async def invalid_request(_request, _error):
    return JSONResponse({"error": "Invalid note or identifier"}, status_code=400)


@app.exception_handler(SQLAlchemyError)
async def database_unavailable(_request, _error):
    return JSONResponse({"error": "Database unavailable"}, status_code=503)


@app.get("/")
def overview():
    return {"application": "Operations Notes", "documentation": "/docs"}


@app.get("/health")
def health():
    return {"status": "ok", "version": os.getenv("APP_VERSION", "fastapi-v2")}


@app.get("/ready")
def ready(db: Session = Depends(get_db)):
    db.execute(text("SELECT 1"))
    return {"status": "ok"}


@app.get("/api/config")
def config():
    return {"title": os.getenv("APP_TITLE", "Operations Notes"),
            "version": os.getenv("APP_VERSION", "fastapi-v2"),
            "secret_injected": bool(os.getenv("APP_TOKEN")),
            "database": "PostgreSQL" if engine.dialect.name == "postgresql" else "SQLite"}


@app.get("/metrics", include_in_schema=False)
def metrics():
    usage = resource.getrusage(resource.RUSAGE_SELF)
    extra = (f"# TYPE ops_uptime_seconds gauge\nops_uptime_seconds {time.monotonic() - started}\n"
             f"# TYPE ops_cpu_seconds_total counter\nops_cpu_seconds_total {usage.ru_utime + usage.ru_stime}\n"
             f"# TYPE ops_memory_maxrss gauge\nops_memory_maxrss {usage.ru_maxrss}\n")
    return Response(generate_latest(registry) + extra.encode(),
                    media_type="text/plain; version=0.0.4; charset=utf-8")


@app.get("/burn")
def burn():
    deadline, value = time.monotonic() + 0.05, 1
    while time.monotonic() < deadline:
        value = (value * 13 + 7) % 1000003
    return {"work": value}
