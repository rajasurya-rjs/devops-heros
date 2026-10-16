# Operations Notes — recording setup and speaking script

Read the quoted sentences aloud in your own voice. Text under **OPEN**, **DO** and
**TYPE** is an instruction for you; do not read those labels aloud. You can use your
own words. Only describe a result as successful after it appears on screen.

The required order is slides → codebase → real push and CI/CD → Terraform and AWS →
Argo CD → Kubernetes → Prometheus → Grafana. The extra application, test and Docker
demonstrations below help you show the rest of the grading criteria.

## Before recording — arrange your laptop

You will show one demo terminal window. Two other terminal tabs keep connections
alive in the background. These three tabs are inside the same Terminal application.
Do not close the two helper tabs until you finish.

### Terminal tab 1: connections

Paste:

```bash
cd /Users/rajasurya/Downloads/devops-heros/final-devops-project
./scripts/recording-up.sh
```

Wait for **All four recording endpoints returned HTTP 200** and **Ready**. Leave it
running. The updated helper automatically reconnects individual dropped connections.
If a page briefly loses its connection, wait for the helper's recovered message and
refresh the page. Pause the demonstration if an endpoint remains unavailable.
If the AWS session has expired, finish this sign-in and retry the helper:

```bash
aws login --profile devops-homework --region ap-southeast-2
```

If a port is occupied, do not stop unrelated applications. Check whether your existing
capstone helper is already running. Do not start a second copy.

### Terminal tab 2: browser

Open a new Terminal tab with Command-T, then paste:

```bash
cd /Users/rajasurya/Downloads/devops-heros/final-devops-project
python3 scripts/recording-browser.py
```

It opens a separate Chrome window with four real EKS pages. Leave this terminal tab
running too. Do not press Enter at its closing prompt until after recording.

In that Chrome window, arrange the tabs and keep them open:

| Tab | Page |
| --- | --- |
| App | `http://notes.aws.project.local:28080` |
| Argo CD | `http://127.0.0.1:48080/applications/argocd/operations-notes?view=tree` |
| Prometheus | `http://127.0.0.1:49091/targets` |
| Grafana | `http://127.0.0.1:43001/d/ops-three-tier?orgId=1&from=now-15m&to=now` |
| GitHub | `https://github.com/rajasurya-rjs/devops-heros` |
| Actions | `https://github.com/rajasurya-rjs/devops-heros/actions/workflows/three-tier-project.yml` |

Use the helper's browser for the app hostname. An ordinary browser window may not
resolve it. Sign in to GitHub yourself if necessary; no password needs to be recorded.

In your usual signed-in browser, open the AWS Console. Select the homework project
**For Each and Every** and **Sydney / ap-southeast-2**. Prepare these pages:

- VPC → Your VPCs → `vpc-01f95e9237ca7dae1`.
- VPC → Subnets → the two subnets belonging to that VPC.
- EKS → Clusters → `rajasurya-final-devops` → Overview.
- That cluster → Compute → managed node group `homework-workers-free`.

Do not open access keys, private inputs, `.env`, Secrets, Terraform state or login caches.

### Terminal tab 3: the visible demo terminal

Open another Terminal tab and paste:

```bash
cd /Users/rajasurya/Downloads/devops-heros/final-devops-project
export KUBECONFIG="$HOME/.local/share/devops-homework/capstone/kubeconfig"
docker compose up -d --build --wait
docker compose ps
```

All three services should be healthy. This runs Ops Notes on **13000** and leaves
Histomics' port 3000 alone. Add `http://localhost:13000` as a browser tab for the local demo.

Open the whole `devops-heros` folder in VS Code. Expand `final-devops-project` in the
Explorer. Keep these files easy to find:

- `backend/app/routes.py`, `models.py`, `main.py`.
- `backend/alembic/versions/` and its migration file.
- `backend/tests/test_api.py` and `backend/tests/conftest.py`.
- `frontend/src/main.js`.
- `backend/Dockerfile`, `frontend/Dockerfile`, `docker-compose.yml`.
- Repository-root `.github/workflows/three-tier-project.yml`.
- `terraform/main.tf`, `terraform/eks.tf`, `terraform/terraform.tfvars.example`.
- `helm/three-tier/values.yaml`, `helm/three-tier/templates/`.
- `gitops/argocd/values-eks.yaml`.
- Repository-root `README.md` and `demo/`.

Open `demo/presentation.pdf` from the repository root, or the PPTX in PowerPoint.
Keep this script beside your laptop or on another device if possible. Make a short
test recording to check that your voice and screen text are clear before the full take.

## Part 1 — present the slides first

**OPEN:** the presentation, starting at slide 1. Advance once after each paragraph.

### Slide 1 — Operations Notes

> Hi everyone, I am Rajasurya. In this video, I will explain my DevOps capstone project,
> Operations Notes. First I will show the architecture, and then I will demonstrate
> the application, pipeline, AWS infrastructure, Kubernetes and monitoring.

### Slide 2 — Project overview

> This application is for keeping deployment checks and incident notes in one place.
> We can add a note, view it, edit it and delete it. The main idea of this project is
> to take a working application through the complete DevOps process.

### Slide 3 — Tech stack

> For the frontend, I used HTML and JavaScript with Vite, served through NGINX. The
> backend is Python with FastAPI, and the database is PostgreSQL. For delivery, I used
> Docker, GitHub Actions, GHCR, Helm and Argo CD. Terraform manages the AWS
> infrastructure, and Prometheus and Grafana provide monitoring.

### Slide 4 — Application architecture

> Here, the browser reaches the frontend through NGINX Ingress. Requests starting
> with slash API go to the FastAPI backend. The backend reads and writes notes in
> PostgreSQL. Separately, Prometheus collects metrics from the backend, and Grafana
> displays those metrics in a dashboard.

### Slide 5 — API and database

> The backend has health and readiness checks, along with the notes APIs. Alembic
> manages the database schema, so table creation is recorded as a migration. In
> Kubernetes, PostgreSQL uses persistent storage so the data can survive an
> application restart.

### Slide 6 — Testing and security

> The test suite covers the notes APIs, validation, readiness, metrics and migrations.
> The tests use separate test storage. The pipeline also runs code and dependency
> checks, secret scanning, and Trivy scans for both container images. HIGH or CRITICAL
> findings cause the image security gate to fail.

### Slide 7 — CI/CD flow

> A push to main starts GitHub Actions. Tests and the frontend build run first. Then
> the pipeline builds and scans both images and publishes them to GHCR using the
> full commit SHA. It also deploys them into a temporary kind cluster and checks
> that the application works with PostgreSQL and two replicas per application tier.

### Slide 8 — AWS infrastructure with Terraform

> Terraform defines the VPC, two public subnets, EKS cluster and managed worker node
> group in the Sydney region. The infrastructure is already provisioned. I will show
> the current plan and the actual resources in the AWS Console during the live demo.

### Slide 9 — Kubernetes and Helm

> The application runs in the project-three-tier namespace. There are two frontend
> replicas and two backend replicas. ClusterIP Services connect the components, and
> Ingress routes the frontend and API requests. The Helm chart keeps these resources
> together as one application release.

### Slide 10 — GitOps with Argo CD

> Argo CD watches the configuration in Git. When the desired configuration changes,
> it reconciles the application in EKS. I will demonstrate this with a small visible
> title change and show the application reaching Synced and Healthy.

### Slide 11 — Prometheus and Grafana

> The backend exposes a metrics endpoint. Prometheus scrapes the backend pods, and
> Grafana uses that data to show application traffic and performance. I will show
> the live targets and dashboard in the walkthrough.

### Slide 12 — Key learnings

> My main learning is that opening the homepage alone is not enough. We also need
> to check the API, database, tests, deployment health and monitoring. I also learned
> the importance of keeping credentials private, using immutable image tags, and
> cleaning up cloud resources after the evaluation.

## Part 2 — codebase and working application

**OPEN:** VS Code Explorer, with `final-devops-project` expanded.

> Now I will show the implementation. This folder contains the backend, frontend,
> Terraform, Kubernetes, Helm, GitOps and monitoring configuration. The workflow file
> is under dot GitHub, workflows, at the repository root.

**OPEN:** `backend/app/routes.py`, then `models.py`, then the Alembic migration.

> These routes implement GET, POST, PUT and DELETE for notes. The model defines the
> notes table, and this Alembic migration creates it. So the database schema is
> managed through code.

**OPEN:** `backend/app/main.py`, then `frontend/src/main.js`.

> The backend also exposes health, readiness and metrics endpoints. Here in the
> frontend, we can see the API calls used to load, create, edit and delete notes.

**OPEN:** local app tab, `http://localhost:13000`.

**DO:** Add `Deployment check: backend and database are healthy`. Refresh the page,
edit that note to add `— verified`, then delete only that demo note. Narrow the window
briefly to show the responsive layout, then restore it.

> I will add a deployment note here. After refreshing, the note is still available
> because it is stored in PostgreSQL. Now I will edit it and delete it. This shows
> the frontend and backend working together with the database.

**OPEN:** demo terminal. **TYPE:**

```bash
curl -fsS http://localhost:13000/health
backend/.venv/bin/python -m pytest -c backend/pytest.ini backend/tests -v
```

**WAIT:** for the results. If all tests pass:

> The health endpoint is responding, and all 23 tests have passed. These tests cover
> several endpoints and include success cases and invalid requests.

**OPEN:** `backend/tests/conftest.py`.

> This fixture uses a temporary test database by default. PostgreSQL tests require
> a dedicated database ending in underscore test. The production database is not
> used for the test suite.

**OPEN:** both Dockerfiles, then `docker-compose.yml`.

> The frontend uses a multi-stage build: Node builds the assets and NGINX serves
> them. Both application images run as non-root users. Docker Compose brings up the
> frontend, backend and PostgreSQL together. I use port 13000 on this laptop because
> another application needs port 3000.

**OPEN:** demo terminal. **TYPE:**

```bash
docker compose up -d --build --wait
docker compose ps
```

**WAIT:** for success and healthy services. Show the output before moving on.

## Part 3 — make a real push and show CI/CD

**OPEN:** `.github/workflows/three-tier-project.yml` at the repository root.

> This workflow runs on a push to main. The test and security job must pass before
> the image job starts. Both images are scanned before they are pushed to GHCR.

**OPEN:** `final-devops-project/gitops/argocd/values-eks.yaml`.

**DO:** Change only:

```yaml
appTitle: Operations Notes
```

to:

```yaml
appTitle: Operations Notes - Video Demo
```

Save with Command-S. If that demo title is already present, use a different visible
title so this is a genuine new change.

> For the live demonstration, I am changing the application title in the GitOps
> configuration. I will commit this change and push it to main.

**OPEN:** demo terminal. **TYPE, one line at a time:**

```bash
python3 scripts/aws-guard.py --kubeconfig "$KUBECONFIG"
git diff -- gitops/argocd/values-eks.yaml
git add gitops/argocd/values-eks.yaml
git commit -m "Demonstrate the capstone GitOps title rollout"
git push origin main
```

**STOP if the guard fails.** Do not bypass the Free-plan check. If Git says there
is nothing to commit, return to the file, make a new title change and save it.

**OPEN:** Actions tab. Refresh and open the new **Three-tier Project CI CD** run
for the commit you just pushed. Keep recording while it runs; explain the workflow
and open the job logs. Wait for this new run to finish successfully.

> This is the run triggered by my push. First it runs the backend tests and builds
> the frontend. After those checks, it builds the two Docker images and runs Trivy.
> It then publishes the scanned images and verifies a Helm deployment in kind.

**AFTER the new run is green:**

> The complete run has now passed. I will show the security results and image tags.

**OPEN:** the **Trivy gates for both application images** step. Show the backend
and frontend summaries. If both summaries show zero HIGH and CRITICAL findings:

> Trivy scanned both final container images. In this run, it found no HIGH or
> CRITICAL vulnerabilities, so the security gate passed. This result is based on
> the vulnerability database at the time of the scan.

If findings appear or the job fails, explain the actual result and resolve it before
claiming a successful final walkthrough.

**OPEN:** repository page → Packages → `ops-notes-backend`, then
`ops-notes-frontend`. Open the newly published versions and show their full SHA tags.

> Both images have been published with the Git commit SHA. This identifies the
> exact version, instead of relying on a moving latest tag.

## Part 4 — Terraform and AWS Console

**OPEN:** `terraform/main.tf`, `eks.tf`, and `terraform.tfvars.example`.

> These files define the AWS infrastructure. The example variables file documents
> the required inputs without including real credentials. My real inputs and
> Terraform state are kept outside Git.

**OPEN:** demo terminal. **TYPE:**

```bash
AWS_PROFILE=devops-homework terraform -chdir=terraform plan -input=false -var-file="$HOME/.local/share/devops-homework/capstone/terraform-inputs.json"
```

**WAIT:** for completion. If it reports **No changes**:

> This current plan reports no changes because the infrastructure is already
> provisioned and matches this configuration. I will also show the saved output
> from the earlier real apply.

If it proposes changes, describe those actual changes. Do not apply them just to
make the video more interesting.

**TYPE:**

```bash
cat evidence/completion/terraform-access-apply.txt
```

> This is saved evidence from the real access update on 13 October. It is an
> earlier execution log; the plan we just ran is the current check.

**OPEN:** AWS Console VPC page, then the two subnets, then the EKS cluster and its
Compute tab. Show **ap-southeast-2**, the Active cluster and Active node group.

> Here is the actual VPC in Sydney, with two public subnets. This is the EKS
> cluster, and this is its managed worker node group. These resources are the
> infrastructure managed by Terraform for this project.

## Part 5 — Argo CD and the GitOps result

**OPEN:** Argo CD tab → `operations-notes`. Wait for **Synced** and **Healthy**.
Use Refresh if necessary. Show the Git revision and the source configuration.

> Argo CD is tracking main in my repository. It has picked up the title change
> and reconciled the Helm configuration into EKS. The application is now Synced
> and Healthy.

**OPEN:** EKS app tab, `http://notes.aws.project.local:28080`. Refresh. Point to
**Operations Notes - Video Demo** in the subtitle below the main heading.

> The updated title is visible here. This demonstrates the configuration moving
> from a Git commit to the running application through Argo CD.

> The configuration revision and the container image version are separate. This
> demo changes configuration. CI verifies the newly built images in kind, while
> EKS uses the explicitly selected immutable image version in these values.

If the title is not visible yet, wait for Argo CD to sync and the backend rollout
to finish; then refresh. Do not claim the change reached the app before it does.

## Part 6 — Kubernetes, Helm and Ingress

**OPEN:** demo terminal. **TYPE each command and show its output:**

```bash
kubectl --context devops-homework-eks get pods -n project-three-tier
kubectl --context devops-homework-eks get deploy,svc,ingress,pvc -n project-three-tier
helm --kube-context devops-homework-eks list -n project-three-tier
```

> These are the application pods. There are two frontend pods, two backend pods
> and the PostgreSQL pod. The deployments show two ready replicas each. The
> application Services are ClusterIP, and the database has persistent storage.
> Helm shows the installed application release.

**OPEN:** `helm/three-tier/values.yaml` and the frontend/backend templates.

> The Helm chart defines these resources and the Ingress routes. Slash goes to
> the frontend, and slash API goes to the backend.

**OPEN:** EKS app tab again. Add and delete a new note named `EKS live demo`.

> This browser is reaching the real EKS Ingress through a local forwarding
> connection. The cluster uses an internal NGINX Service rather than a public
> cloud LoadBalancer. Here I can create and delete a note through that route.

## Part 7 — metrics and Prometheus

**OPEN:** demo terminal. **TYPE:**

```bash
curl -fsS -H 'Host: notes.aws.project.local' http://127.0.0.1:28080/metrics
```

> This is the backend metrics endpoint. It returns Prometheus-formatted metrics,
> including application requests and latency.

**OPEN:** Prometheus tab → Targets. Expand the backend target group if collapsed.
Point to both backend endpoints and their **UP** status.

> Prometheus is scraping both backend pods. Both targets show UP, which confirms
> that Prometheus can reach the metrics endpoints and collect their data.

## Part 8 — Grafana

**OPEN:** EKS app tab. Refresh it a few times and load the notes. Then open Grafana.
Keep the last 15 minutes selected and refresh the dashboard. Allow a little time
for the next scrape; check that the panels contain data.

> This is the Grafana application dashboard. It uses Prometheus as its data
> source. After making requests to the application, we can see the request
> activity here. The dashboard also helps us observe latency and errors.

Point to actual populated panels. Do not call an empty panel a working live result.

## Part 9 — documentation and closing

**OPEN:** repository-root `README.md`, then the GitHub commit history and `demo/`.

> The README explains the architecture, local setup, pipeline, Terraform, Helm
> deployment and monitoring. The repository also includes the presentation and
> genuine execution evidence. The commit history records the project changes.

> This is a capstone environment with one worker node, so it is not a highly
> available production setup. The Ingress access in this demonstration uses local
> forwarding. After the live evaluation, I will run the cleanup procedure and
> add the actual Terraform destroy completion evidence.

> That completes my walkthrough of Operations Notes, from application development
> and testing to deployment, security and monitoring. Thank you.

## After recording — submission is not finished until these are done

1. Watch the recording. Confirm audible narration, readable output, slides first,
   a real push and the new pipeline finishing green, AWS proof, Argo CD, Kubernetes,
   UP targets and populated Grafana panels. There is no duration or face-camera
   requirement in the instructions you supplied.
2. Upload the actual video to this same GitHub repository: repository-root
   `demo/walkthrough.mp4`, or a release asset as the rubric permits. A renamed MOV
   is not an MP4 conversion. Keep the existing PPTX/PDF committed.
3. Restore `appTitle: Operations Notes` in `gitops/argocd/values-eks.yaml`, save,
   run the AWS guard, then commit and push that restoration. Check Argo CD again.
4. Keep the cluster available for the required live evaluation. At the agreed
   cleanup time, use the documented cleanup procedure in the capstone demo README
   and capture the real **Destroy complete!** output. A destroy plan is not proof
   that resources were destroyed. Cleanup permanently deletes the homework stack.
5. Add the genuine cleanup evidence and verify the uploaded video link works.
6. Submit the repository link yourself using the instructor's form. The assistant
   will not submit the form. Confirm the deadline with the instructor: the supplied
   notice says Sunday 19 October 2026, but 19 October is Monday. Until clarified,
   prepare by Sunday 18 October, 11:59 PM IST.

The script helps cover the required demonstrations. Final marks are decided by the
grader; the video, actual destroy evidence and form submission must still be completed.
