"""Check the actual EKS application's HTTP API through localhost Ingress forwarding."""
import json
import os
import urllib.request
from pathlib import Path

base = os.environ.get("APP_URL", "http://127.0.0.1:28080")


def request(path, method="GET", body=None):
    payload = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(
        base + path, data=payload, method=method,
        headers={"Host": "ops.homework.local", "Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=15) as response:
        raw = response.read().decode()
        print(method, path, response.status, raw[:800])
        if response.headers.get_content_type() == "application/json":
            return json.loads(raw)
        return raw


assert request("/health")["status"] == "ok"
assert request("/ready")["status"] == "ok"
assert request("/api/config")["secret_injected"] is True
note = request("/api/notes", "POST", {
    "text": "Genuine AWS EKS deployment verified with Helm and encrypted EBS storage."
})
updated = request("/api/notes/" + str(note["id"]), "PUT", {
    "text": "AWS EKS verification: application, Helm, Ingress and persistent EBS storage."
})
assert updated["text"].startswith("AWS EKS verification:")
second = request("/api/notes", "POST", {"text": "Temporary CRUD verification note"})
assert request("/api/notes/" + str(second["id"]), "DELETE")["deleted"]
assert any(n["id"] == note["id"] for n in request("/api/notes"))
assert "ops_requests_total" in request("/metrics")
Path(os.environ.get("NOTE_RECORD", "/tmp/devops-homework-aws-note.json")).write_text(
    json.dumps(updated) + "\n"
)
print("Verified EKS HTTP, CRUD, Secret injection and metrics; note saved for replacement check.")
