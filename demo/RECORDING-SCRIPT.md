# Operations Notes — read-aloud recording script

**Use your School Chrome profile. Follow the browser tabs from 1 to 15.**

**Read ONLY the text in the quoted boxes under SAY.**
SHOW, TYPE, CLICK, WAIT and CHECK are instructions for you. Do not read them aloud.
Finish the instruction before reading the next SAY box. Speak normally and take your time.

## Your screen map — prepare before recording

Your browser tabs are already arranged like this. Keep this order.

| Tab | Screen |
| --- | --- |
| 1 | [Presentation PDF](https://github.com/rajasurya-rjs/devops-heros/blob/main/demo/presentation.pdf) |
| 2 | [Project code](https://github.com/rajasurya-rjs/devops-heros/tree/main/final-devops-project) |
| 3 | [Local app](http://localhost:13000) |
| 4 | [Three-tier Project CI CD](https://github.com/rajasurya-rjs/devops-heros/actions/workflows/three-tier-project.yml) |
| 5 | [Backend image package](https://github.com/rajasurya-rjs/devops-heros/pkgs/container/devops-heros%2Fops-notes-backend) |
| 6 | [Frontend image package](https://github.com/rajasurya-rjs/devops-heros/pkgs/container/devops-heros%2Fops-notes-frontend) |
| 7 | [AWS VPC](https://ap-southeast-2.console.aws.amazon.com/vpcconsole/home?region=ap-southeast-2#vpcs:) |
| 8 | [AWS subnets](https://ap-southeast-2.console.aws.amazon.com/vpcconsole/home?region=ap-southeast-2#subnets:) |
| 9 | [AWS EKS](https://ap-southeast-2.console.aws.amazon.com/eks/home?region=ap-southeast-2#/clusters/rajasurya-final-devops) |
| 10 | [Argo CD](http://127.0.0.1:48080/applications/argocd/operations-notes?view=tree) |
| 11 | [EKS app through Ingress](http://notes.aws.project.local:28080) |
| 12 | [Prometheus Targets](http://127.0.0.1:49091/targets) |
| 13 | [Grafana dashboard](http://127.0.0.1:43001/d/ops-three-tier?orgId=1&from=now-15m&to=now) |
| 14 | [Project README](https://github.com/rajasurya-rjs/devops-heros/blob/main/final-devops-project/README.md) |
| 15 | [Commit history](https://github.com/rajasurya-rjs/devops-heros/commits/main/) |

Your Terminal tabs, matching your screenshots:

| Terminal tab | Use |
| --- | --- |
| 1 | Forwarding helper. Keep running; leave it in the background. |
| 2 | Old isolated browser helper. Leave it in the background; the recording uses School Chrome. |
| 3 | Completed School browser setup. You do not need to show it. |
| **4** | **Demo terminal. This is the tab with the successful Docker build. Use it for every command below.** |

VS Code is your separate code window. It already has the whole `devops-heros` folder open.
To open a file quickly, press **Command + P**, paste the file path shown below, and press Return.
The VS Code paths below start from that repository root.

**Before pressing Record — do this silently:**

- Make sure Argo CD is signed in in School Chrome and the EKS app loads there.
- In tab 8, filter subnets to VPC `vpc-01f95e9237ca7dae1`.
- In tab 9, locate **Compute** in the left sidebar. You will click it during the demo.
- Check that all four Grafana panels finish loading.
- Make sure you can display one whole slide clearly in tab 1. The same PDF is also
  saved locally at `/Users/rajasurya/Downloads/devops-heros/demo/presentation.pdf`.
- Keep this script on your phone or another screen if possible.
- Check that your microphone records your voice.

**TYPE in Terminal tab 4 before recording:**

```bash
cd /Users/rajasurya/Downloads/devops-heros/final-devops-project
export KUBECONFIG="$HOME/.local/share/devops-homework/capstone/kubeconfig"
clear
```

Return to **browser tab 1, slide 1**. Start recording with your microphone enabled.

---

## 1 — Presentation first · browser tab 1

### Slide 1 — Operations Notes

**SHOW:** the whole first slide.

**SAY:**

> Hi everyone, I'm Rajasurya. This is my DevOps capstone project, Operations Notes.
> First, I'll explain the project using these slides. Then I'll show the working setup.

### Slide 2 — Project overview

**SHOW:** slide 2.

**SAY:**

> This app keeps deployment checks and incident notes in one place.
> We can add a note, read it, edit it and delete it.

### Slide 3 — Tech stack

**SHOW:** slide 3.

**SAY:**

> The frontend uses HTML and JavaScript. The backend uses FastAPI, and the database is Postgres.
> The other tools here handle testing, containers, deployment, security and monitoring.

### Slide 4 — Architecture

**SHOW:** slide 4. Point along the arrows as you speak.

**SAY:**

> Here, the browser reaches the frontend through Ingress. API requests go to the backend.
> The backend stores notes in Postgres. Prometheus collects metrics, and Grafana shows the graphs.

### Slide 5 — API and database

**SHOW:** slide 5.

**SAY:**

> The app has health checks and the notes APIs.
> Alembic manages changes to the database schema. The database also has persistent storage in Kubernetes.

### Slide 6 — Testing and security

**SHOW:** slide 6.

**SAY:**

> The tests cover the APIs, validation, health checks and migrations.
> The pipeline also checks code, dependencies and secrets. Trivy scans both container images.

### Slide 7 — CI/CD

**SHOW:** slide 7.

**SAY:**

> A push to main starts the pipeline. Tests run before the image builds.
> After scanning, the images go to GHCR with the commit ID as the tag.
> CI also checks a Helm deployment in a temporary kind cluster.

### Slide 8 — AWS and Terraform

**SHOW:** slide 8.

**SAY:**

> Terraform manages the AWS infrastructure in Sydney.
> It includes a VPC, two public subnets, an EKS cluster and a worker node group.

### Slide 9 — Kubernetes and Helm

**SHOW:** slide 9.

**SAY:**

> There are two frontend replicas and two backend replicas.
> Helm defines the application resources. Services connect the components, and Ingress routes the requests.

### Slide 10 — GitOps

**SHOW:** slide 10.

**SAY:**

> Argo CD watches the application configuration in Git.
> I'll change the app title during this demo and show that change reaching EKS.

### Slide 11 — Monitoring

**SHOW:** slide 11.

**SAY:**

> The backend exposes a metrics endpoint.
> Prometheus collects those metrics. Grafana shows application requests, errors, CPU and memory.

### Slide 12 — Learnings

**SHOW:** slide 12.

**SAY:**

> My main takeaway is that checking only the homepage is not enough.
> We also need to check the API, database, tests and monitoring. Cloud cleanup is part of the work too.

**SAY:**

> Okay, now I'll show the actual project.

## 2 — Code overview · browser tab 2, then VS Code

**SHOW:** browser tab 2. Point to the backend, frontend, Terraform, Helm, GitOps and monitoring folders.

**SAY:**

> This is the project folder in my GitHub repository.
> The app code and the deployment configuration are kept together here.

**SHOW:** VS Code. Open `final-devops-project/backend/app/routes.py`.

**SAY:**

> These are the notes API routes. GET reads notes, POST creates a note,
> PUT updates it, and DELETE removes it.

**SHOW:** `final-devops-project/backend/app/models.py`.

**SAY:**

> This model defines the notes table. Each note has an ID and its text.

**SHOW:** `final-devops-project/backend/alembic/versions/0001_notes.py`.

**SAY:**

> This is the Alembic migration that creates the table.
> So the database structure is managed through code.

**SHOW:** `final-devops-project/backend/app/main.py`.

**SAY:**

> This file starts the FastAPI app. It also provides health, readiness and metrics endpoints.
> Readiness checks whether the database is available.

**SHOW:** `final-devops-project/frontend/src/main.js`.

**SAY:**

> The frontend makes API calls here. These calls load the notes and handle adding, editing and deleting.

## 3 — Working local app, tests and Docker · browser tab 3 and Terminal tab 4

**SHOW:** browser tab 3, `http://localhost:13000`.

**SAY:**

> This is the app running locally with Docker Compose.
> I'll create one note and check the full flow.

**CLICK:** the note input. Type `Live demo: deployment check completed`, then click **Add note**.

**SAY:**

> The note is added. Now I'll refresh the page.

**CLICK:** browser Refresh. Find your new note again.

**WAIT:** the note must still be visible before continuing.

**SAY:**

> The note is still here after refreshing. It is stored in Postgres.

**CLICK:** **Edit** beside only your new demo note. Change it to
`Live demo: deployment check completed and verified`. Accept the edit.

**SAY:**

> Now the text is updated. I'll delete this demo note also.

**CLICK:** **Delete** beside only that demo note.

**WAIT:** confirm that demo note disappears.

**SHOW:** briefly narrow the browser window, then restore its normal size.

**SAY:**

> The layout also adjusts to a smaller window.

**SHOW:** Terminal tab 4.

**TYPE:**

```bash
curl -fsS http://localhost:13000/health
```

**WAIT:** for the successful JSON response.

**SAY:**

> The health endpoint is responding. Next, I'll run the tests.

**TYPE:**

```bash
backend/.venv/bin/python -m pytest -c backend/pytest.ini backend/tests -v
```

**WAIT:** for the final test summary. It must show **23 passed** before the next speech.
If the result is different, stop and check it instead of reading a success claim.

**SAY:**

> All 23 tests have passed. They cover the API behavior, invalid inputs, metrics and migrations.

**SHOW:** VS Code → `final-devops-project/backend/tests/conftest.py`.

**SAY:**

> This fixture uses separate test storage. The PostgreSQL tests require a dedicated test database.
> These tests do not use the live application database.

**SHOW:** `final-devops-project/backend/Dockerfile`, then `final-devops-project/frontend/Dockerfile`.

**SAY:**

> These files build the application images. The frontend has two stages:
> Node builds the files, and NGINX serves them. Both app images run as non-root users.

**SHOW:** `final-devops-project/docker-compose.yml`.

**SAY:**

> Compose brings up the frontend, backend and Postgres together.
> On this laptop, I use port 13000 because port 3000 is needed by another application.

**SHOW:** Terminal tab 4.

**TYPE:**

```bash
docker compose up -d --build --wait
```

**WAIT:** for success. Then **TYPE:**

```bash
docker compose ps
```

**CHECK:** frontend, backend and database all show **healthy**.

**SAY:**

> The build completed, and all three services are healthy.
> Now I'll show the automated pipeline.

## 4 — Real push and CI/CD · browser tab 4, VS Code and Terminal tab 4

**SHOW:** browser tab 4. This is the correct **Three-tier Project CI CD** workflow.

**SAY:**

> These are the earlier pipeline runs. I'll trigger a new run now with a real push.

**SHOW:** VS Code → `final-devops-project/gitops/argocd/values-eks.yaml`.

**CLICK / EDIT:** change only this line:

```yaml
appTitle: Operations Notes
```

to:

```yaml
appTitle: Operations Notes - Live Demo
```

Press **Command + S** to save. The value must actually change.
If you already used `Operations Notes - Live Demo` in a previous take, choose a new visible title
and remember that exact text for the later app check.

**SAY:**

> I'm changing the app title in the GitOps configuration.
> I'll push this change and then show the pipeline and the updated app.

**SHOW:** Terminal tab 4. **TYPE:**

```bash
python3 scripts/aws-guard.py --kubeconfig "$KUBECONFIG"
```

**CHECK:** the command succeeds and shows an ACTIVE FREE plan with available credits.
Stop if it fails.

**SAY:**

> This check confirms I'm using the homework AWS project with an active Free plan and credits.

**TYPE each command separately. Wait for each to finish:**

```bash
git diff -- gitops/argocd/values-eks.yaml
```

**CHECK:** the diff shows your title change. Then:

```bash
git add gitops/argocd/values-eks.yaml
```

```bash
git commit -m "Demonstrate the capstone title change during the live walkthrough"
```

```bash
git push origin main
```

**WAIT:** the push must succeed. If it says there is nothing to commit, return to the title file,
make a new change, save it, and retry. Do not present an old run as this new push.

**SAY:**

> The change is pushed to main. I'll open the run created by this commit.

**SHOW:** browser tab 4. Refresh. Click the newest run matching
**Demonstrate the capstone title change during the live walkthrough** and your new commit ID.

**SAY:**

> This is the new run. The test and security job runs first.
> The image job depends on that job passing.

**SHOW:** while the run is in progress, switch to VS Code and open the repository-root
`.github/workflows/three-tier-project.yml`.
This is outside the `final-devops-project` folder.

**SAY:**

> Here, push to main is the trigger. The first job runs tests with SQLite and Postgres.
> It also builds the frontend and runs the code, dependency and secret checks.

**SHOW:** scroll to the `build-push-deploy` job and the Trivy commands.

**SAY:**

> This next job builds both images. Trivy scans them before publishing.
> A HIGH or CRITICAL finding makes this gate fail.

**SHOW:** return to browser tab 4 and the new run. Open the jobs and their logs as they progress.

**WAIT:** keep recording until **both jobs in this new run are green**.
The latest runs took about three minutes, but this one may take longer. Waiting is normal.
Do not read the next success statement while the run is still in progress or failed.

**SAY — only after the whole new run passes:**

> The complete pipeline has passed. It also deployed the app into a temporary kind cluster
> and checked the frontend, backend and Postgres connection.

**CLICK:** `build-push-deploy` → **Trivy gates for both application images**.
Show the backend and frontend summaries, scrolling between them.

**CHECK:** both scans show no HIGH or CRITICAL findings before reading this:

**SAY:**

> Trivy scanned both final container images. This run found no HIGH or CRITICAL vulnerabilities,
> so the gate passed. That result is based on the vulnerability database at scan time.

## 5 — Backend image · browser tab 5

**SHOW:** tab 5. Refresh after the new pipeline passes.
Find the full commit-ID tag for the push you just made. Point to the tag and the pull command.

**SAY:**

> This is the published backend image. Its tag is the full Git commit ID.
> That lets us identify the exact version.

## 6 — Frontend image · browser tab 6

**SHOW:** tab 6. Refresh and point to the matching new commit-ID tag.

**SAY:**

> The frontend image is published here also, with the same commit ID.
> So both images can be traced back to the source change.

### Terraform — before moving to AWS tabs 7, 8 and 9

**SHOW:** VS Code → `final-devops-project/terraform/main.tf`, then
`final-devops-project/terraform/eks.tf`.

**SAY:**

> Now, coming to infrastructure. Terraform defines the AWS network and the EKS setup here.
> These resources are already provisioned.

**SHOW:** `final-devops-project/terraform/terraform.tfvars.example`.

**SAY:**

> This example file documents the inputs. My real inputs and Terraform state are kept outside Git.

**SHOW:** Terminal tab 4. **TYPE:**

```bash
AWS_PROFILE=devops-homework terraform -chdir=terraform plan -input=false -var-file="$HOME/.local/share/devops-homework/capstone/terraform-inputs.json"
```

**WAIT:** for completion. The pre-recording check returned **No changes**.
Read the next speech only if your current run also returns No changes.
If it reports errors or proposes changes, check those results before continuing.

**SAY:**

> The current plan says no changes. The existing infrastructure matches the configuration.
> I'll also show the saved output from an earlier real apply.

**TYPE:**

```bash
cat evidence/completion/terraform-access-apply.txt
```

**SHOW:** the actual apply summary in the saved output.

**SAY:**

> This is the saved access-update apply from 13 October.
> It is earlier execution evidence. The plan we just ran is the current check.

## 7 — AWS VPC · browser tab 7

**SHOW:** tab 7. Point to the selected Region `ap-southeast-2` in the URL and the project
**For Each and Every**. Select the VPC named `rajasurya-final-devops-vpc`.
Its ID is `vpc-01f95e9237ca7dae1`.

**SAY:**

> This is the actual VPC in the homework AWS project, in Sydney.
> It is available and managed by Terraform.

## 8 — Two public subnets · browser tab 8

**SHOW:** tab 8, filtered to that VPC. Point to these two rows:

- `rajasurya-final-devops-public-0`
- `rajasurya-final-devops-public-1`

**SAY:**

> These are the two public subnets for this VPC.
> They are in different availability zones.

## 9 — EKS and worker node group · browser tab 9

**SHOW:** tab 9, cluster `rajasurya-final-devops`. Point to **Active**.

**SAY:**

> This is the actual EKS cluster. Its status is Active.

**CLICK:** **Compute** in the left sidebar, as shown in your AWS screenshot.
Find **Node groups**, then open `homework-workers-free`.

**WAIT / CHECK:** show the Active node group and its running worker node.

**SAY:**

> This is the managed worker node group. The application workloads run on its worker node.

## 10 — Argo CD, then Kubernetes · browser tab 10 and Terminal tab 4

**SHOW:** browser tab 10. Click **Refresh** in Argo CD if needed.

**WAIT / CHECK:** it must show **Synced**, **Healthy**, and the new Git revision from your live push.
The last sync panel should also reflect the actual application change once that sync has completed.

**SAY:**

> Argo CD watches main in this repository. It has picked up my title change.
> The application is now Synced and Healthy.

**CLICK:** **Details** and show the repository source and Helm configuration path, then close the details panel.

**SAY:**

> This is the GitOps flow. I changed the desired configuration in Git,
> and Argo CD applied that configuration to EKS.

**SHOW:** Terminal tab 4. **TYPE:**

```bash
kubectl --context devops-homework-eks get pods -n project-three-tier
```

**WAIT / CHECK:** all five application pods are **Running**, with **1/1 Ready**.
If a rollout is still finishing, wait and run the command again.

**SAY:**

> Here are the application pods. There are two frontend pods, two backend pods,
> and one Postgres pod. They are all Running and Ready.

**TYPE:**

```bash
kubectl --context devops-homework-eks get deploy,svc,ingress,pvc -n project-three-tier
```

**SHOW:** the deployment counts, Service types, Ingress hostname and Bound PVC.

**SAY:**

> Both application deployments have two ready replicas. The frontend and backend use ClusterIP Services.
> The database volume is Bound, and the Ingress hostname is listed here.

**TYPE:**

```bash
helm --kube-context devops-homework-eks list -n project-three-tier
```

**CHECK:** release `notes` is **deployed**.

**SAY:**

> Helm shows the installed application release as deployed.

**SHOW:** VS Code → `final-devops-project/helm/three-tier/Chart.yaml`, then
`final-devops-project/helm/three-tier/templates/frontend.yaml`.
Scroll to the Ingress paths near the bottom.

**SAY:**

> These are the Helm chart files. Ingress sends slash API to the backend,
> and slash to the frontend.

## 11 — EKS application and the visible GitOps change · browser tab 11

**SHOW:** tab 11. Refresh.
Point to the title you entered in step 4, normally **Operations Notes - Live Demo**,
in the smaller version line below the description.
The large main heading stays **Operations Notes**.

**WAIT:** the smaller title must actually show your new value before reading this:

**SAY:**

> Here, the new title is visible. This is the change I pushed during the recording.
> It has reached the running application through Argo CD.

**SAY:**

> The configuration revision and image version are separate here.
> This demo changes configuration. EKS uses the image version selected in the values file,
> while CI tests the new images in kind.

**CLICK:** add a note named `EKS live check`, then edit that note to `EKS live check verified`.
Delete only that demo note when finished.

**SAY:**

> Adding, editing and deleting work here on EKS also.
> I'm reaching the real cluster Ingress through a local forwarding connection.

### Metrics — before moving to Prometheus

**SHOW:** Terminal tab 4. **TYPE:**

```bash
curl -fsS http://notes.aws.project.local:28080/metrics
```

**WAIT:** for the metrics output. Point to metric names and numeric values.

**SAY:**

> This is the backend metrics endpoint through Ingress.
> It returns metrics in the format Prometheus can collect.

## 12 — Prometheus · browser tab 12

**SHOW:** tab 12. Expand the application target group if needed.

**WAIT / CHECK:** it must show **2/2 up** and both endpoints **UP**.
After a backend rollout, the pod names or IPs can change. Use the current rows.

**SAY:**

> Prometheus is collecting metrics from both backend pods.
> Both targets show UP, so the scrapes are working.

## 13 — Grafana · browser tab 13

**SHOW:** tab 13. Keep **Last 15 minutes** selected. Wait for the refresh to finish.
All four panels should contain data. The error-rate line can correctly be zero.

**SAY:**

> This is the live Grafana dashboard. It gets its data from Prometheus.

**SHOW:** point to each panel as you name it.

**SAY:**

> Here are HTTP responses per second and HTTP errors per second.
> Below, we can see CPU time and peak memory for the backend pods.
> These panels show that application metrics are reaching the dashboard.

## 14 — Documentation · browser tab 14

**SHOW:** tab 14. Scroll through architecture, local setup, CI/CD, Terraform,
Kubernetes deployment, monitoring, and known limitations.

**SAY:**

> The README explains the setup and the main parts of the project.
> It includes the architecture, local commands, pipeline, AWS, Kubernetes and monitoring steps.

**SAY:**

> This capstone uses one worker node, and I access Ingress through local forwarding.
> After the live evaluation, I'll clean up the AWS resources and add the actual destroy completion proof.

## 15 — Commit history and closing · browser tab 15

**SHOW:** tab 15. Refresh so your new live-demo commit is visible. Scroll enough to show
more of the meaningful project history, including at least ten commits.

**SAY:**

> This is the commit history. The latest entry is the change I made during this video.
> The earlier commits show the application and DevOps work over time.

**SAY:**

> So, that's my Operations Notes project. We have seen the app, tests, containers,
> pipeline, security scans, AWS infrastructure, GitOps, Kubernetes and monitoring.
> Thank you for watching.

**STOP RECORDING.**

---

## After recording — instructions only, do not read aloud

- Play back the video. Check your voice, readable text, all slides, the real push,
  the new full green pipeline, AWS proof, Argo CD, Kubernetes, UP targets and populated Grafana panels.
- Upload the real MP4 to this same GitHub repository, under repository-root
  `demo/walkthrough.mp4`, or as a release asset as the rubric permits. A MOV needs
  actual conversion to MP4; changing its filename is not conversion.
- Keep the PPTX/PDF committed. The video is mandatory and is not yet provided by this script.
- Restore `appTitle: Operations Notes` after recording. Run the AWS guard, commit
  the restoration and push it; check Argo CD again.
- Keep the cluster for any agreed live evaluation. At cleanup time, follow
  `final-devops-project/demo/README.md` and capture actual Terraform destroy completion.
  A destroy plan is not completion proof. Cleanup permanently removes the homework stack.
- Submit the repository URL yourself using the instructor's form. The assistant does not submit it.
- The deadline notice has conflicting wording: Sunday is 18 October 2026; 19 October is Monday.
  Until the instructor confirms the intended date, prepare by 18 October, 11:59 PM IST.

## If something does not match — instructions only

Pause and check the actual result. Do not read a success line while a command fails,
a job is still running, a target is down or a panel is empty. The helper can reconnect
a dropped tunnel; wait for its recovery message, then refresh the affected page.
If you need to fix a real issue, do that before your final take.
