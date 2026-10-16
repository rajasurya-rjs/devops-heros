# Session 21 — complete rubric audit

Rechecked on **16 October 2026**. Repository: **https://github.com/rajasurya-rjs/devops-heros**.
The capstone lives under `final-devops-project/`. This is a readiness audit, not a grade.
The current linked `GRADING.md` has **46 scored criteria totaling 100 points**. [Today’s fresh verification](../evidence/audit-2026-10-16/README.md) records the source, artifact, local and live EKS checks. This is not a promise of full marks.

**Recording completed and uploaded:** [original 33:47 walkthrough](https://github.com/rajasurya-rjs/devops-heros/releases/download/capstone-walkthrough-2026-10-16/walkthrough.mp4).
**Still required:** actual Terraform destroy evidence after evaluation, and confirmation of
student submission of the public repository URL through the capstone form.
A destroy plan does not satisfy M7 cleanup.

Rechecked the instructor’s [current GRADING.md](https://github.com/Nency-Ravaliya/devops-heros/blob/main/session21-python/GRADING.md)
and Session 21 README on 16 October. The current linked rubric assigns M10 2 points for
README and 3 for a live commit/pipeline/deployment demonstration. The separately supplied
submission instructions also require an uploaded recording and slides; both artifacts are
now present. Earlier audit files retain the older 47-criterion/video-and-slides scoring wording.

| Scored criterion | Audit status | Proof / remaining action |
|---|---|---|
| M1: FastAPI `/health` (2) | Verified / evidence present | Fresh [EKS Ingress API verification](../evidence/audit-2026-10-16/aws-ingress-api.txt) and Compose verification return HTTP 200. |
| M1: GET/POST/PUT/DELETE endpoints (3) | Verified / evidence present | `backend/app/`; CRUD passes through EKS Ingress and Compose. |
| M1: PostgreSQL table + Alembic (2) | Verified / evidence present | `backend/alembic/versions/0001_notes.py`; [live database](../evidence/completion/aws-database.txt). |
| M1: Frontend renders + API calls (2) | Verified / evidence present | `frontend/`; [Compose screenshot](../images/24-current-compose-browser.png), [EKS browser](../images/aws-current-ingress-browser.png). |
| M1: Responsive usable UI (1) | Verified / evidence present | [Mobile screenshot](../images/25-current-mobile.png). |
| M2: pytest passes (3) | Verified / evidence present | 23 tests pass today: [fresh output](../evidence/audit-2026-10-16/pytest.txt); [terminal screenshot](../images/current-pytest-terminal.png). CI also passes against dedicated PostgreSQL. |
| M2: ≥5 cases / ≥3 endpoints (4) | Verified / evidence present | `backend/tests/`: 23 cases covering CRUD, health, readiness, metrics, validation and migrations. |
| M2: Isolated database (2) | Verified / evidence present | Temporary SQLite or dedicated `notes_test` PostgreSQL; production environment cannot select test storage. |
| M2: pytest config (1) | Verified / evidence present | `backend/pytest.ini` and `backend/tests/conftest.py`. |
| M3: Public repository (2) | Public verified; FORM UNCONFIRMED | Public URL above; student submits it in the form. Agent does not submit the form. |
| M3: Meaningful commits (2) | Verified / evidence present | More than ten; [history screenshot](../images/current-commits-terminal.png). |
| M3: .gitignore (1) | Verified / evidence present | Repository-root `.gitignore` excludes `.env`, `__pycache__`, `node_modules`, `.venv`, credentials and Terraform state. |
| M4: Backend Dockerfile builds (2) | Verified / evidence present | `backend/Dockerfile`; actual Compose build + green CI. |
| M4: Frontend Node→NGINX multi-stage (3) | Verified / evidence present | `frontend/Dockerfile`; actual Compose build + green CI. |
| M4: Non-root images (2) | Verified / evidence present | [Compose terminal](../images/current-compose-terminal.png) shows both application user IDs; chart enforces non-root too. |
| M4: Compose starts all three services (3) | Verified / evidence present | Three healthy services; [actual port-3000 verification](../evidence/audit-2026-10-16/compose-services-3000.txt) and [required localhost:3000 screenshot](../images/audit-localhost-3000.png). Default port 13000 restored afterward. |
| M5: Workflow present (1) | Verified / evidence present | Repository-root `.github/workflows/three-tier-project.yml`. |
| M5: Push main trigger (1) | Verified / evidence present | Workflow `push.branches: [main]`; real main runs recorded. |
| M5: pytest gates builds (3) | Verified / evidence present | Test job precedes dependent build jobs and exits on failure. |
| M5: Frontend build (2) | Verified / evidence present | `npm ci` and `npm run build` in test job. |
| M5: Both Docker images built (3) | Verified / evidence present | Both backend/frontend builds in the gated build job. |
| M5: Both images pushed GHCR (3) | Verified / evidence present | [Backend package](https://github.com/rajasurya-rjs/devops-heros/pkgs/container/devops-heros%2Fops-notes-backend), [frontend package](https://github.com/rajasurya-rjs/devops-heros/pkgs/container/devops-heros%2Fops-notes-frontend). |
| M5: Commit SHA tags (2) | Verified / evidence present | Full 40-character SHAs; [backend screenshot](../images/29-ghcr-backend.png), [frontend screenshot](../images/30-ghcr-frontend.png). |
| M6: Trivy on both images (3) | Verified / evidence present | Workflow loops over both images; [actual downloaded CI reports](../images/current-trivy-terminal.png). |
| M6: HIGH/CRITICAL failure (1) | Verified / evidence present | `--severity HIGH,CRITICAL --exit-code 1`, without ignoring unfixed findings. |
| M6: Explanation (1) | Written explanation ready; demonstrate in video | [Three-sentence explanation](../evidence/completion/README.md#trivy-explanation). |
| M7: Valid HCL (2) | Verified / evidence present | `terraform/`; init, validate, fmt and mock-provider checks recorded. |
| M7: Terraform init (1) | Verified / evidence present | Fresh [init output](../evidence/audit-2026-10-16/terraform-init.txt), no errors. |
| M7: Non-empty error-free plan (2) | Verified / evidence present | [Actual two-update plan](../evidence/completion/terraform-access-plan.txt) and [plan screenshot](../images/current-terraform-plan-terminal.png); applied successfully. |
| M7: VPC + two public subnets provisioned (3) | Verified / evidence present | [AWS Console VPC screenshot](../images/27-aws-vpc-console.png), VPC/subnet JSON. |
| M7: EKS + worker node group (4) | Verified / evidence present | [AWS EKS Console](../images/26-aws-eks-console.png), node group JSON and Ready node. |
| M7: Actual destroy (2) | PENDING — after recording/evaluation | **PENDING after recording/evaluation**. `scripts/cleanup-aws.sh` is ready; current destroy plan proves planning only. |
| M7: tfvars example / no credentials (1) | Verified / evidence present | `terraform/terraform.tfvars.example`; credentials/state remain outside Git; current and history secret scans pass with exact reviewed classroom exceptions. |
| M8: Namespace (1) | Verified / evidence present | `k8s/namespace.yaml`; live `project-three-tier` namespace. |
| M8: Complete chart (3) | Verified / evidence present | `helm/three-tier/Chart.yaml`, `values.yaml`, templates. |
| M8: Helm install/upgrade (3) | Verified / evidence present | [Actual EKS deploy](../evidence/completion/aws-three-tier-deploy.txt); release `notes` deployed. |
| M8: ≥2 backend/frontend replicas (2) | Verified / evidence present | [Fresh EKS runtime](../evidence/audit-2026-10-16/kubernetes.txt): both Deployments 2/2 Ready; five Pods Running, zero restarts. [Screenshot](../images/current-kubernetes-terminal.png). |
| M8: ClusterIP Services (2) | Verified / evidence present | Same terminal shows backend/frontend Services. |
| M8: Ingress `/` + `/api` (2) | Verified / evidence present | Helm template and actual EKS CRUD verification; [hostname browser](../images/aws-current-ingress-browser.png). |
| M8: All app Pods Running (2) | Verified / evidence present | [Fresh EKS runtime](../evidence/audit-2026-10-16/kubernetes.txt): both Deployments 2/2 Ready; five Pods Running, zero restarts. [Screenshot](../images/current-kubernetes-terminal.png). |
| M9: `/metrics` output (2) | Verified / evidence present | [Live curl terminal](../images/current-metrics-terminal.png), API log. |
| M9: Prometheus installed / scraping (3) | Verified / evidence present | [Fresh targets JSON](../evidence/audit-2026-10-16/prometheus-targets.json): both backend targets UP; [browser screenshot](../images/aws-current-prometheus.png). |
| M9: Grafana installed/accessed (2) | Verified / evidence present | [EKS Grafana dashboard](../images/aws-current-grafana.png). |
| M9: Populated live panel (3) | Verified / evidence present | [Live positive request rate](../evidence/audit-2026-10-16/prometheus-live-rate.json), four provisioned panels, [populated Grafana screenshot](../images/aws-current-grafana.png). |
| M10: Complete technical README (2) | Verified / evidence present | Capstone `README.md` and root README entry, all required sections. |
| M10: Live commit → pipeline → deployment change (3) | Recording and successful run present | [Student walkthrough](https://github.com/rajasurya-rjs/devops-heros/releases/download/capstone-walkthrough-2026-10-16/walkthrough.mp4), [green live-demo CI](https://github.com/rajasurya-rjs/devops-heros/actions/runs/38916498054), and [recorded/live Argo status](../evidence/post-recording-2026-10-16/argocd.json). The configuration title changed; the EKS image SHA remains separately pinned. |
## Submission artifacts beyond the scoring table

All source directories, requirements, migration, Dockerfiles, Compose, workflow, Terraform,
namespace/bootstrap manifests, Helm and monitoring values are present. Current screenshots
cover app/mobile, pytest, commit history, Compose, CI, GHCR, Trivy, Terraform plan, AWS VPC/EKS,
Pods/Services/Helm, Ingress, metrics, Prometheus and Grafana. The
[evidence index](../evidence/completion/README.md) records provenance and environments.

The required **localhost:3000** screenshot is now included. Port 3000 was verified free,
used temporarily for the genuine Compose screenshot, then Ops Notes was restored to
**13000** to preserve the user’s port allocation for Histomics. EKS Ingress is demonstrated through
its hostname and a localhost port-forward to the actual controller, without a public paid
LoadBalancer. Its load-balancer status check is ignored only for that Ingress; HTTP routes
are separately tested. The Helm release was installed with Helm before Argo adopted its objects.

## Required submission artifacts — item by item

| Module | Required submission artifacts | Result |
|---|---|---|
| M1 | `backend/app/`, Alembic versions, requirements, `frontend/`, Compose, running browser image | Present; real API/browser execution verified. |
| M2 | `backend/tests/`, pytest config, `pytest -v` terminal screenshot | Present; 23 tests pass. |
| M3 | Public repo URL, screenshot with ≥10 meaningful commits | Present; actual form submission unconfirmed. |
| M4 | Both Dockerfiles, Compose, actual successful build/start terminal screenshot, browser at localhost:3000 | Present, including the new [port-3000 browser](../images/audit-localhost-3000.png). Normal runtime restored to 13000. |
| M5 | Workflow YAML, successful Actions URL, SHA-tagged GHCR screenshot | Present; fresh post-audit pipeline checked before reporting completion. |
| M6 | Trivy steps, scan-output screenshot, 2–3 sentence explanation | Present for both images; student must explain the scan in the video. |
| M7 | All HCL, non-empty plan screenshot, AWS VPC/EKS Console screenshot, destroy completion screenshot | Everything present **except actual destroy completion**. |
| M8 | Namespace/bootstrap, chart, Running Pods screenshot, Services screenshot, `helm list` screenshot, Ingress browser | Present; the combined [EKS terminal screenshot](../images/current-kubernetes-terminal.png) contains Pods, Services and Helm list. |
| M9 | Prometheus/Grafana values, metrics curl screenshot, Targets UP screenshot, populated Grafana screenshot | Present; current live targets and dashboard API reverified. |
| M10 | Root technical README, live/recorded demonstration; supplied instructions also require video and slides | Root README, [same-repo release recording](https://github.com/rajasurya-rjs/devops-heros/releases/download/capstone-walkthrough-2026-10-16/walkthrough.mp4), [12-slide PPTX](../../demo/presentation.pptx) and [PDF](../../demo/presentation.pdf) present. |

## Mandatory video content audit

The [actual recording and chapter index](../../demo/README.md) now cover presentation slides,
codebase, local app, live push and CI, GHCR, Terraform source/plan/saved apply output, AWS Console,
Argo CD, Kubernetes/Helm, Ingress app, two UP Prometheus targets and populated Grafana panels.
Visual samples and complete media decoding were checked; narration has not been transcribed
word for word. Authentic command corrections and CI waiting remain in the original file.

## Post-recording verification

- 23 local pytest cases and 8 helper tests pass; both Helm charts lint; Terraform fmt/validate pass.
- All three Compose services are healthy on port 13000.
- [Live-demo CI metadata](../evidence/post-recording-2026-10-16/live-demo-ci.json) and downloaded
  [actual CI reports](../evidence/post-recording-2026-10-16/ci/) preserve SQLite/PostgreSQL test,
  Trivy, API and deployment proof for the student’s real push.
- [Fresh EKS runtime](../evidence/post-recording-2026-10-16/runtime.json): five Ready/Running
  application Pods, both Deployments 2/2, ClusterIP Services and Bound database PVC.
- [Monitoring Pods](../evidence/post-recording-2026-10-16/monitoring.json) have zero restarts;
  [two Prometheus targets are UP](../evidence/post-recording-2026-10-16/prometheus-targets.json),
  and [Grafana is healthy](../evidence/post-recording-2026-10-16/grafana-health.json).
- Current and Git-history secret scans pass with the existing reviewed classroom exceptions.
  Required local artifact links resolve; both copies of each slide file match.
- The laptop’s public IP changed back after recording. The actual reviewed
  [access-only Terraform plan](../evidence/post-recording-2026-10-16/network-access-plan.txt)
  and [successful apply](../evidence/post-recording-2026-10-16/network-access-apply.txt) restore
  the current `/32`: zero added, two updated, zero destroyed. ACTIVE FREE with $52.11 credits
  was verified before this update. No nodes or paid features were added.

## Submission and deadline checks

- The repository is PUBLIC. Submit **https://github.com/rajasurya-rjs/devops-heros** to the
  [latest supplied capstone form](https://forms.gle/XWAP1vAumDJgAPM1A). Actual submission
  is unconfirmed; the agent does not submit Google Forms.
- The guideline says **“Sunday, 19 October 2026, 11:59 PM IST.”** October 19 is Monday;
  Sunday is October 18. Instructor confirmation is pending. Prepare for **October 18,
  11:59 PM IST** until the intended deadline is clarified. This is a precaution, not a
  change to the official deadline. Late submissions lose 5 points per 24 hours.
- Root `README.md` has the required technical sections; repository-root `demo/` now has
  the actual PPTX/PDF plus a video status and recording-order index.
- The application domain is Operations Notes, with its own frontend and notes API/model;
  the course TaskBoard reference is not the submitted application.
- Preserve AWS only through recording/evaluation; then capture genuine destroy completion
  and verify cleanup. No numerical grade is guaranteed.
