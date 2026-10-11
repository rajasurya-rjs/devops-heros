# Operations Notes — Session 21 Capstone

**Rajasurya J · 24BCS10086**

**Repository:** https://github.com/rajasurya-rjs/devops-heros

Operations Notes records deployment checks and incident fixes. Users can create, list,
read, edit and delete notes. The responsive HTML/JavaScript frontend uses a FastAPI
backend and PostgreSQL database. This is an original application domain, rather than a
copy of the TaskBoard reference application.

The project follows the [Session 21 brief](https://github.com/Nency-Ravaliya/devops-heros/tree/main/session21-python)
and its [grading rubric](https://github.com/Nency-Ravaliya/devops-heros/blob/main/session21-python/GRADING.md).

## Architecture

```mermaid
flowchart LR
  Browser --> Ingress
  Ingress -->|/| Frontend[HTML/JavaScript built by Vite, served by NGINX]
  Ingress -->|/api| Backend[FastAPI and SQLAlchemy]
  Frontend --> Backend
  Backend --> PostgreSQL[(PostgreSQL with Alembic migrations and a PVC)]
  GitHub --> Tests[pytest, frontend build, SAST, dependency and secret scans]
  Tests --> Images[Docker builds and Trivy gates]
  Images --> GHCR[GHCR images tagged with commit SHA]
  GHCR --> Helm[Helm deployment to CI kind cluster]
  Helm --> Frontend
  Helm --> Backend
  Backend --> Prometheus --> Grafana
```

## Source map

| Path | Purpose |
|---|---|
| [backend/app/](backend/app/) | FastAPI routes, schemas, SQLAlchemy models and connections |
| [backend/alembic/versions/](backend/alembic/versions/) | Versioned database migration |
| [backend/tests/](backend/tests/) | Isolated pytest API and migration tests |
| [frontend/](frontend/) | Responsive HTML/JavaScript, Vite build and multi-stage Dockerfile |
| [docker-compose.yml](docker-compose.yml) | Frontend, backend and PostgreSQL local stack |
| [helm/three-tier/](helm/three-tier/) | Two frontend replicas, backend HPA, database PVC and Ingress |
| [k8s/namespace.yaml](k8s/namespace.yaml) | Application namespace |
| [helm/observability/](helm/observability/) | Standalone Prometheus and Grafana Helm chart |
| [monitoring/values-local.yaml](monitoring/values-local.yaml) | Monitoring Helm values |
| [terraform/](terraform/) | Existing AWS VPC/EKS infrastructure code |
| [CI workflow](../.github/workflows/three-tier-project.yml) | Test, build, scan, SHA-tagged publication and kind deployment |

The earlier Python HTTP-server implementation remains in `application/` for completed
homework exercises. [README-previous.md](README-previous.md) preserves its original deployment
instructions, screenshots, logs and historical cloud results. Those results do not prove
that the newly updated FastAPI code has been deployed to AWS.

## Local Docker setup

Requirements: Docker Desktop/Engine, Compose, Bash and OpenSSL. Run from `final-devops-project`:

```bash
./scripts/local-up.sh
```

The helper generates a random password in the Git-ignored `.env` file with mode 600,
then runs `docker compose up -d --build --wait`. No password is committed.
After that first setup, the standard command also works:

```bash
docker compose -p ops-notes-capstone up --build
```

Open **http://localhost:3000**. The frontend proxies `/api`, `/health`, `/ready`, `/metrics`,
`/burn` and Swagger `/docs` to the backend. PostgreSQL is on an internal network and is not
published to the host. The two application images run without root. The backend runs
Alembic before starting Uvicorn. PostgreSQL replicas serialize migrations with an advisory
lock, so concurrent backend startup does not race schema creation.

```bash
docker compose -p ops-notes-capstone ps
python3 kubernetes/verify-api.py http://127.0.0.1:3000
docker compose -p ops-notes-capstone exec database psql -U notes -d notes -c 'TABLE notes;'
docker compose -p ops-notes-capstone exec database psql -U notes -d notes -c 'TABLE alembic_version;'
```

Stop without deleting saved data: `docker compose -p ops-notes-capstone down`.
The database uses a named volume. Do not remove that volume unless its notes are disposable.
The earlier `docker/compose.yaml` entry point remains available on port 18082 with
`--env-file docker/.env` after generating that local password file as documented in the previous README.

## Backend and migrations

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/health` | Process health |
| GET | `/ready` | Database readiness, 503 when unavailable |
| GET | `/api/notes` | List notes |
| GET | `/api/notes/{id}` | Read one note |
| POST | `/api/notes` | Create a note, 201 |
| PUT | `/api/notes/{id}` | Update a note |
| DELETE | `/api/notes/{id}` | Delete a note |
| GET | `/api/config` | App version, database type and Secret-injection boolean |
| GET | `/metrics` | Prometheus counters, latency, CPU and memory metrics |
| GET | `/docs` | Interactive FastAPI Swagger documentation |

POST/PUT accept `{"text":"Deployment checked"}`. Text must contain 1–500 characters.
SQLAlchemy binds SQL values, and the frontend renders saved text using `textContent`.
The classroom application has no user login. `/api/config` never returns the Secret value.
The initial migration creates `notes` and tracks revision `0001_notes`. It can adopt the
compatible table from the earlier application while preserving saved rows. A regression
test verifies adoption and repeat migration. Destructive downgrade is deliberately disabled.

Run the backend directly from `backend` after installing its requirements:

```bash
python3 -m venv .venv
.venv/bin/pip install -r requirements-dev.txt
# For PostgreSQL, set DATABASE_URL to your private local connection URL.
.venv/bin/python -m app.migrate
.venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8080
```

Without a database URL, direct development uses a local SQLite `notes.db`; Compose and
Kubernetes always use PostgreSQL.

## Tests and frontend build

```bash
cd backend
.venv/bin/python -m pytest -v
cd ../frontend
npm ci
npm run build
```

`pytest.ini` sets the test directory and import path. Each SQLite test uses a fresh temporary
migrated database. PostgreSQL tests require the explicit `TEST_DATABASE_URL` variable and
refuse database names that do not end in `_test`. Production `DATABASE_URL`/`PGHOST` values
cannot select the pytest storage. CI creates a dedicated `notes_test` database.

The tests cover CRUD, invalid bodies, SQL-injection text, missing notes, readiness failure,
health, metrics, Swagger, Secret redaction and migration compatibility.

## CI/CD and security

The root workflow runs on every push to `main`, as well as relevant pull requests and
manual dispatches. Both database test runs and the Vite build must pass before image builds.
Bandit, pip-audit and Gitleaks provide separate source, dependency and secret gates.
Trivy scans both final application images and exits nonzero on any HIGH/CRITICAL finding,
including unfixed findings. Only successful gates permit GHCR publication.

Images use the full Git commit SHA. A kind cluster loads those exact images, deploys Helm,
checks two Ready replicas per application Deployment, exercises the API and queries
PostgreSQL. The backend ConfigMap receives the same SHA as `APP_VERSION`, and the API
verification asserts it. This proves which source revision was deployed in that CI run.
Pull requests build/test/deploy locally in the runner and do not publish images.

Trivy inspects the operating-system packages and application dependencies inside each
container image against its vulnerability database. Earlier frontend findings affected
`libexpat` and `pcre2`; the recorded fix upgraded those packages. A clean scan means the
scanner found no matching findings at the selected severities at scan time. It does not
prove that all possible vulnerabilities are absent.

[Earlier successful pipeline](https://github.com/rajasurya-rjs/devops-heros/actions/runs/37312195057)
belongs to the previous implementation. A fresh run is still needed for this code revision.

## Local Kubernetes and Helm

Use the existing local `devops-completion` minikube profile. These commands do not target AWS:

```bash
kubectl config use-context devops-completion
minikube -p devops-completion start
minikube -p devops-completion addons enable ingress
minikube -p devops-completion addons enable metrics-server
minikube -p devops-completion image load ops-notes-frontend:local
minikube -p devops-completion image load ops-notes-backend:local
minikube -p devops-completion image load postgres:17-alpine
./kubernetes/deploy-three-tier.sh
kubectl get pods,deploy,svc,pvc,hpa,ingress -n project-three-tier
helm list -n project-three-tier
```

The helper applies `k8s/namespace.yaml`, creates random database/demo-token Secret values
when absent, and runs `helm upgrade --install`. The chart has at least two frontend replicas,
backend HPA with minimum two/maximum five replicas, ClusterIP Services, probes, resource
requests/limits, a PostgreSQL StatefulSet and a persistent volume claim.

Ingress routes `/` to frontend and `/api` directly to backend. Add `notes.project.local`
to your local hosts file using the IP from `minikube -p devops-completion ip`, then open
**http://notes.project.local**. Localhost port forwarding provides another verification path:

```bash
kubectl port-forward -n project-three-tier svc/frontend 18083:8080
# Another terminal:
python3 kubernetes/verify-api.py http://127.0.0.1:18083
python3 scripts/load-test.py http://127.0.0.1:18083 --seconds 60
kubectl get hpa -n project-three-tier --watch
```

HPA needs Metrics Server and can take time to react. A configured HPA alone is not evidence
of observed scaling. The rendered manifests in `kubernetes/three-tier.yaml` come from the chart.

## Monitoring from a fresh cluster

```bash
./monitoring/deploy-three-tier.sh
kubectl port-forward -n project-monitoring svc/prometheus 39091:9090
# Another terminal:
kubectl port-forward -n project-monitoring svc/grafana 33001:3000
```

The helper installs the observability Helm chart into `project-monitoring`; it does not
assume an older monitoring installation. Prometheus discovers each backend Pod in the
application namespace, so replica counters remain separate rather than alternating behind
a load-balanced Service. RBAC grants only Pod discovery in that namespace.
Grafana provisions the **Operations Notes - Three Tiers** dashboard. Its request/error rate
panels aggregate across Pods, while CPU and memory series identify each Pod.
Grafana's anonymous access is Viewer-only for this local classroom demo.

## Troubleshooting drill

The local-only [three-tier drill](kubernetes/troubleshooting/verify-three-tier.sh) captures
the live selector, image and readiness URL, then restores them with an exit trap. It
observes missing Service endpoints, an image-pull failure and a 404 readiness failure.
Run it only after the local Helm application is healthy, then repeat the API check.
This new drill has been syntax checked; it has not been run against the stopped local cluster.

## Terraform and cloud evidence

Existing Terraform code and genuine AWS deployment logs remain preserved. The homework
profile is `devops-homework` and the selected Region is `ap-southeast-2`. The reference
brief's Region defaults do not override these project constraints.

Local code checks do not provision AWS:

```bash
terraform -chdir=terraform fmt -check
terraform -chdir=terraform validate
terraform -chdir=terraform test
```

The mock-provider test validates configuration, not live infrastructure. At the user's
request, this review makes no cloud changes. A destroy plan is not evidence of completed
cleanup; the rubric requires an actual destroy completion after evaluation.

## Presentation and evidence

[Presentation checklist](presentation/video-script.md) covers the live commit/pipeline/
deployment sequence and the required screenshots. The existing [slides](presentation/Operations-Notes.pptx)
and [PDF](presentation/Operations-Notes.pdf) describe the earlier three-tier implementation.
[Evidence index](evidence/README.md) explains historical evidence. New local checks use
`code-review-*` filenames and do not replace older results.

A final presentation or recording must show the student explaining the app, committing a
change, watching CI and inspecting the deployed SHA, registry images, Ingress, HPA,
monitoring and recovery from a failure. Source code and a narration script cannot substitute
for that demonstration.
