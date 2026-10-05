# Optional two-minute walkthrough

## 0:00–0:20 — Introduction

My project is Operations Notes. It lets me record deployment checks and incident fixes,
then edit or remove them as the status changes.

## 0:20–0:45 — Show the application

Open the page, add a note, edit it and delete it. Explain that the browser uses the frontend,
the Python backend handles the requests, and PostgreSQL stores the notes.

## 0:45–1:10 — Explain the release process

Show the successful GitHub Actions run. The pipeline runs backend tests and security checks,
builds and scans frontend/backend images, pushes them to the registry and deploys with Helm.

## 1:10–1:35 — Show Kubernetes and monitoring

Show the application Pods and database PVC. Open the Grafana dashboard and explain the
request/error metrics. Show the Flux Helm release status.

## 1:35–2:00 — What I learned

Explain one troubleshooting example: the database password file had a trailing newline,
which caused authentication failures. Removing it and checking the rollout fixed the problem.
Finish by showing the repository and README.
