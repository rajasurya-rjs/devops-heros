# Record and finish the submission

The completed student recording and slides are in [repository-root demo](../../demo/README.md).

The **12-slide PPTX and PDF are ready**. Start with [presentation.pptx](presentation.pptx),
then record a continuous live walkthrough. Speaker notes provide narration cues.
The **[student recording](https://github.com/rajasurya-rjs/devops-heros/releases/download/capstone-walkthrough-2026-10-16/walkthrough.mp4) is uploaded**; see the [chapter index](../../demo/README.md).
AWS cleanup completed after recording on 16 October 2026: [completion log](../evidence/completion/terraform-destroy-complete.txt) and
[screenshot](../images/terraform-destroy-complete.png). The first attempt removed 26 resources before an expired
Internet Gateway request; the successful retry removed the final two and exited 0.
The EKS, Argo CD, Prometheus and Grafana URLs below describe the recorded deployment
and are no longer live. Local Compose remains runnable at localhost:13000.

## Reproduce the recorded EKS demonstration with a new deployment

From `final-devops-project`, if AWS reports an expired session, restore the homework
session first and complete the browser sign-in:

```bash
aws login --profile devops-homework --region ap-southeast-2
```

Keep the forwarding terminal open:

```bash
./scripts/recording-up.sh
```

If it reports occupied ports, the capstone forwards may already be running; reuse them.
Do not stop Histomics or PathReed. Ops Notes Compose is on **13000**.
In a second terminal:

```bash
python3 scripts/recording-browser.py
```

The isolated browser opens the real EKS Argo CD, Ingress, Prometheus and Grafana pages.
It signs into Argo CD without printing the password. Keep it open while recording.
The forwarding helper checks each endpoint and reconnects a failed tunnel independently;
the other pages stay connected. A service restart or network outage can still cause a
brief interruption. Its private logs are under
`~/.local/share/devops-homework/capstone/recording/`. Grafana has a 1 GiB container limit
and a 768 MiB Go soft memory target after a genuine 512 MiB OOM restart on 16 October.
This uses the existing worker; no additional AWS nodes or paid features are required.
Keep the same network during recording. EKS permits the laptop's configured public
IPv4 `/32`; switching Wi-Fi, hotspot or VPN can change that address and block every
cloud forward. Startup now checks that address explicitly. Refresh the private
Terraform `web_cidr` input and apply the reviewed access-only plan if the network
changes. The 16 October recovery evidence records an actual update with zero added
or destroyed resources. The helper also allows slow connections to start before
retrying and cleans up their credential child processes.
AWS Console sign-in uses your own homework project, **For Each and Every**; selected
Region **ap-southeast-2**. Never show credentials, private Terraform inputs or Secret values.

## Suggested recording order

1. Present all twelve slides first: overview, stack, architecture, delivery, AWS,
   Kubernetes, observability and learnings.
2. Show the folder structure and original Operations Notes domain. Open backend routes,
   SQLAlchemy model, Alembic revision, frontend code, Dockerfiles and pytest isolation.
   Open localhost:13000 and demonstrate create, read, edit and delete.
3. Run `backend/.venv/bin/python -m pytest -c backend/pytest.ini backend/tests -v`.
   Explain the dedicated test database and the passing 23 cases.
4. Trigger a real push as described below. Follow that run until all jobs are green.
   Show tests and frontend build preceding image builds, both Trivy gates, both GHCR
   packages and full commit-SHA tags. Explain that clean HIGH/CRITICAL scan results
   mean no matching vulnerabilities at that scan time, rather than absolute safety.
5. Open Terraform source and example variables. Run the safe current plan command below.
   Show the genuine provisioning/access-apply output, AWS VPC with two public subnets,
   EKS Active cluster and worker node group. A fresh plan can correctly say no changes.
6. Show Argo CD operations-notes **Synced / Healthy**, its Git revision and source path.
   Explain the visible title change after your push and configuration checksum rollout.
   Image SHA and configuration Git revision are separate. The current immutable cloud
   image revision is `cdf8c14b34055fc15651fcde1533c129b7e957b2`.
7. Run the Kubernetes commands below: all five application Pods Running, two replicas
   each, ClusterIP Services, Ingress and Helm release. Open the app through
   `http://notes.aws.project.local:28080` in the helper's browser and exercise CRUD.
8. Show `/metrics`, Prometheus Targets with both backend Pods **UP**, and Grafana's
   populated HTTP request panel. Generate traffic while watching Grafana.
9. Explain learnings, the single-worker/private-Ingress limitations and the cleanup plan.
   Show the complete README, meaningful commit history and evidence index.

## Real push and GitOps demonstration

Change `appTitle` in `gitops/argocd/values-eks.yaml` to a short visible title, for example
`Operations Notes - Video Demo`. Before a cloud-affecting push, verify the Free plan:

```bash
python3 scripts/aws-guard.py --kubeconfig "$HOME/.local/share/devops-homework/capstone/kubeconfig"
git add gitops/argocd/values-eks.yaml
git commit -m 'Demonstrate the capstone title rollout during the presentation'
git push origin main
gh run list --repo rajasurya-rjs/devops-heros --workflow three-tier-project.yml --limit 1
gh run watch <run-id> --repo rajasurya-rjs/devops-heros --exit-status
```

Use the actual run ID displayed. Argo CD polls main and applies the title; refresh the app
browser to show it. After recording, restore `Operations Notes` with another meaningful
commit and push. Do not claim the newest CI image is deployed until both image tags and
`appVersion` have been explicitly promoted to its SHA.

## Commands to show

```bash
export KUBECONFIG="$HOME/.local/share/devops-homework/capstone/kubeconfig"
kubectl --context devops-homework-eks get pods -n project-three-tier
kubectl --context devops-homework-eks get deploy,svc,ingress,pvc -n project-three-tier
helm --kube-context devops-homework-eks list -n project-three-tier
curl -H 'Host: notes.aws.project.local' http://127.0.0.1:28080/metrics
OPS_HOST=notes.aws.project.local python3 kubernetes/verify-api.py http://127.0.0.1:28080
AWS_PROFILE=devops-homework terraform -chdir=terraform plan -input=false \
  -var-file="$HOME/.local/share/devops-homework/capstone/terraform-inputs.json"
```

For the Terraform segment, show the genuine saved apply output as well as your current plan:

```bash
cat evidence/completion/terraform-access-apply.txt
```

The file records the actual 13 October apply, with two in-place access updates. The current
plan can correctly report no changes. Keep that distinction clear in your narration.

The EKS Ingress uses an internal NGINX Service and localhost forwarding, with no public
LoadBalancer. Argo CD's load-balancer-address health check is ignored **only for that
Ingress**, while HTTP routing is tested separately and workload health checks stay active.

## Upload the video

Save your MP4 in the **repository-root** `demo/walkthrough.mp4` (from this capstone
directory, `../demo/walkthrough.mp4`), then commit/push it if under GitHub's 100 MB
per-file limit. For a larger recording, upload it as an asset to a release in this same
homework repository; the rubric explicitly allows release assets. Add its direct GitHub
link here and in the repository-root `demo/README.md`. A YouTube link alone does not meet this rubric.

## Cleanup after recording/evaluation

`./scripts/cleanup-aws.sh --plan` reviews cleanup without changing resources.
After the live evaluation, privately back up any notes you want to retain, then run:

```bash
./scripts/cleanup-aws.sh --execute 2>&1 | tee evidence/completion/terraform-destroy-complete.txt
```

Capture the actual `Destroy complete!` terminal output, verify no homework volumes/resources
remain, then retain the genuine log and screenshot. Do not substitute the destroy
plan screenshot for completion. This action permanently removes the homework application.
Do not run it before recording or while the grader still needs the cluster.
