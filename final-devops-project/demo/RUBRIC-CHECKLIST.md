# Session 21 — complete rubric audit

Rechecked on **14 October 2026**. Repository: **https://github.com/rajasurya-rjs/devops-heros**.
The capstone lives under `final-devops-project/`. This is a readiness audit, not a grade.
[Today’s fresh verification](../evidence/recheck-2026-10-14/README.md) records the new local and live EKS checks.

**Two completion requirements remain:** student-recorded walkthrough uploaded to this
repository, and real Terraform destroy completion evidence after recording/evaluation.
The rubric gives **zero for M10 if the video is missing**. A destroy plan does not satisfy M7 cleanup.

| Module / scored criterion | Status and proof |
|---|---|
| M1: FastAPI `/health` (2) | Verified in [EKS API log](../evidence/completion/aws-ingress-api.txt). |
| M1: GET/POST/PUT/DELETE endpoints (3) | `backend/app/`; CRUD passes through EKS Ingress and Compose. |
| M1: PostgreSQL table + Alembic (2) | `backend/alembic/versions/0001_notes.py`; [live database](../evidence/completion/aws-database.txt). |
| M1: Frontend renders + API calls (2) | `frontend/`; [Compose screenshot](../images/24-current-compose-browser.png), [EKS browser](../images/aws-current-ingress-browser.png). |
| M1: Responsive usable UI (1) | [Mobile screenshot](../images/25-current-mobile.png). |
| M2: pytest passes (3) | 23 tests pass; [terminal screenshot](../images/current-pytest-terminal.png). CI also passes on PostgreSQL. |
| M2: ≥5 cases / ≥3 endpoints (4) | `backend/tests/`: 23 cases covering CRUD, health, readiness, metrics, validation and migrations. |
| M2: Isolated database (2) | Temporary SQLite or dedicated `notes_test` PostgreSQL; production environment cannot select test storage. |
| M2: pytest config (1) | `backend/pytest.ini` and `backend/tests/conftest.py`. |
| M3: Public repository (2) | Public URL above; student submits it in the form. Agent does not submit the form. |
| M3: Meaningful commits (2) | More than ten; [history screenshot](../images/current-commits-terminal.png). |
| M3: .gitignore (1) | Repository-root `.gitignore` excludes `.env`, `__pycache__`, `node_modules`, `.venv`, credentials and Terraform state. |
| M4: Backend Dockerfile builds (2) | `backend/Dockerfile`; actual Compose build + green CI. |
| M4: Frontend Node→NGINX multi-stage (3) | `frontend/Dockerfile`; actual Compose build + green CI. |
| M4: Non-root images (2) | [Compose terminal](../images/current-compose-terminal.png) shows both application user IDs; chart enforces non-root too. |
| M4: Compose starts all three services (3) | `docker-compose.yml`; [actual terminal](../images/current-compose-terminal.png) shows healthy frontend/backend/database. |
| M5: Workflow present (1) | Repository-root `.github/workflows/three-tier-project.yml`. |
| M5: Push main trigger (1) | Workflow `push.branches: [main]`; real main runs recorded. |
| M5: pytest gates builds (3) | Test job precedes dependent build jobs and exits on failure. |
| M5: Frontend build (2) | `npm ci` and `npm run build` in test job. |
| M5: Both Docker images built (3) | Both backend/frontend builds in the gated build job. |
| M5: Both images pushed GHCR (3) | [Backend package](https://github.com/rajasurya-rjs/devops-heros/pkgs/container/devops-heros%2Fops-notes-backend), [frontend package](https://github.com/rajasurya-rjs/devops-heros/pkgs/container/devops-heros%2Fops-notes-frontend). |
| M5: Commit SHA tags (2) | Full 40-character SHAs; [backend screenshot](../images/29-ghcr-backend.png), [frontend screenshot](../images/30-ghcr-frontend.png). |
| M6: Trivy on both images (3) | Workflow loops over both images; [actual downloaded CI reports](../images/current-trivy-terminal.png). |
| M6: HIGH/CRITICAL failure (1) | `--severity HIGH,CRITICAL --exit-code 1`, without ignoring unfixed findings. |
| M6: Explanation (1) | [Three-sentence explanation](../evidence/completion/README.md#trivy-explanation). |
| M7: Valid HCL (2) | `terraform/`; init, validate, fmt and mock-provider checks recorded. |
| M7: Terraform init (1) | [Actual init output](../evidence/completion/terraform-init.txt). |
| M7: Non-empty error-free plan (2) | [Actual two-update plan](../evidence/completion/terraform-access-plan.txt) and [plan screenshot](../images/current-terraform-plan-terminal.png); applied successfully. |
| M7: VPC + two public subnets provisioned (3) | [AWS Console VPC screenshot](../images/27-aws-vpc-console.png), VPC/subnet JSON. |
| M7: EKS + worker node group (4) | [AWS EKS Console](../images/26-aws-eks-console.png), node group JSON and Ready node. |
| M7: Actual destroy (2) | **PENDING after recording/evaluation**. `scripts/cleanup-aws.sh` is ready; current destroy plan proves planning only. |
| M7: tfvars example / no credentials (1) | `terraform/terraform.tfvars.example`; credentials/state remain outside Git; current and history secret scans pass with exact reviewed classroom exceptions. |
| M8: Namespace (1) | `k8s/namespace.yaml`; live `project-three-tier` namespace. |
| M8: Complete chart (3) | `helm/three-tier/Chart.yaml`, `values.yaml`, templates. |
| M8: Helm install/upgrade (3) | [Actual EKS deploy](../evidence/completion/aws-three-tier-deploy.txt); release `notes` deployed. |
| M8: ≥2 backend/frontend replicas (2) | [Current EKS terminal](../images/current-kubernetes-terminal.png) shows 2/2 each. |
| M8: ClusterIP Services (2) | Same terminal shows backend/frontend Services. |
| M8: Ingress `/` + `/api` (2) | Helm template and actual EKS CRUD verification; [hostname browser](../images/aws-current-ingress-browser.png). |
| M8: All app Pods Running (2) | Same EKS terminal: both frontend, both backend and database Running/Ready. |
| M9: `/metrics` output (2) | [Live curl terminal](../images/current-metrics-terminal.png), API log. |
| M9: Prometheus installed / scraping (3) | [EKS Targets UP](../images/aws-current-prometheus.png), two healthy targets in JSON. |
| M9: Grafana installed/accessed (2) | [EKS Grafana dashboard](../images/aws-current-grafana.png). |
| M9: Populated live panel (3) | Same dashboard has request-rate, CPU and memory data. |
| M10: Complete technical README (2) | Capstone `README.md` and root README entry, all required sections. |
| M10: Video in repo/release (2) | **PENDING: student recording**. Follow [recording guide](README.md); upload MP4 to `demo/` or same repo release asset. Missing video makes entire M10 zero. |
| M10: ≥8-slide PPT/PDF committed (1) | [12-slide PPTX](presentation.pptx), [PDF](presentation.pdf), including architecture diagram and speaker notes. |

## Submission artifacts beyond the scoring table

All source directories, requirements, migration, Dockerfiles, Compose, workflow, Terraform,
namespace/bootstrap manifests, Helm and monitoring values are present. Current screenshots
cover app/mobile, pytest, commit history, Compose, CI, GHCR, Trivy, Terraform plan, AWS VPC/EKS,
Pods/Services/Helm, Ingress, metrics, Prometheus and Grafana. The
[evidence index](../evidence/completion/README.md) records provenance and environments.

Browser evidence uses **localhost:13000** because port 3000 belongs to Histomics. The grader's
3000 example is changed deliberately and documented. EKS Ingress is demonstrated through
its hostname and a localhost port-forward to the actual controller, without a public paid
LoadBalancer. Its load-balancer status check is ignored only for that Ingress; HTTP routes
are separately tested. The Helm release was installed with Helm before Argo adopted its objects.

## Mandatory video content audit

The recording guide covers every required segment: **PPT first**, real push and end-to-end CI,
codebase/design, Terraform plan/apply and AWS Console, Argo CD synced application and GitOps
change, Kubernetes Pods/Services/Ingress, Prometheus UP and live Grafana panel. These are
instructions until the student's real video has been recorded and uploaded.

Keep AWS running only through recording/evaluation. Add genuine destroy completion output
and screenshot afterwards. No deadline or instructor-access status was provided; the student
must ensure timely submission and repository access. No numerical grade is guaranteed.
