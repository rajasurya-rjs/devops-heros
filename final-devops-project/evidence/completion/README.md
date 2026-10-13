# Current capstone verification — 13 October 2026

All files here are actual command outputs or downloaded GitHub Actions artifacts.
Screenshots under `images/` show actual isolated-browser pages or actual readonly ttyd
terminal sessions. No execution or destroy completion is simulated.
Historical evidence elsewhere remains preserved. Initial Argo installation attempts include a real rollout timeout caused by worker Pod capacity; legacy workloads were paused and all required controllers subsequently became Ready. The final status and screenshots show the recovered runtime.

## Environment and source revisions

- **Compose:** three tiers healthy; frontend localhost:13000; non-root app users.
- **Local minikube:** `devops-completion`, `project-three-tier`, immutable native ARM
  images `05d05bf70daba35eb6dba8c84aff90b552ed3364`. Local `current-*` browser screenshots
  are separate from AWS `aws-current-*` screenshots.
- **AWS EKS:** `rajasurya-final-devops`, ap-southeast-2, explicit profile devops-homework,
  project 089540175430, FREE ACTIVE and $71.84 credit at verification. Two frontend and
  two backend replicas, PostgreSQL EBS PVC, immutable GHCR image revision
  `cdf8c14b34055fc15651fcde1533c129b7e957b2`.
- **Argo CD:** self-hosted v3.5.5, main branch. Actual EKS title rollout at configuration
  commit `5bd0dddb7d16254106879a208e9bfe21f3dc266a` was Synced/Healthy and returned the new
  title through Ingress. Before/after JSON is recorded. Image revision remained unchanged.
- **Final source CI:** [run 38416754688](https://github.com/rajasurya-rjs/devops-heros/actions/runs/38416754688), source `92d269a0ca4f0cba95d7c42503e4226defe177d5`, all jobs successful. Final EKS Argo status is recorded in `aws-final-argocd-status.json`.
- **CI artifacts:** `ci-*` files downloaded from successful
  [run 38400868940](https://github.com/rajasurya-rjs/devops-heros/actions/runs/38400868940),
  source `33af500857a55ffe0931a33203d8f55825211c63`. Later runs also pass; the README links
  a later run. Artifact timestamps and image tags are retained exactly.

## Screenshot index

| Artifact | Environment / what it shows |
|---|---|
| `images/24-current-compose-browser.png` | Compose browser at port 13000, working app/API |
| `images/25-current-mobile.png` | Responsive mobile Compose UI |
| `images/current-pytest-terminal.png` | Actual local pytest -v, 23 passed |
| `images/current-compose-terminal.png` | Actual up --build, healthy services, non-root users |
| `images/current-commits-terminal.png` | Fifteen meaningful commits |
| `images/28-current-ci.png` | Actual successful run 38400868940 |
| `images/29-ghcr-backend.png`, `30-ghcr-frontend.png` | Public GHCR pages, full-SHA tags |
| `images/current-trivy-terminal.png` | Actual CI Trivy artifact text displayed in live terminal; run explicitly labeled |
| `images/current-terraform-plan-terminal.png` | Actual saved Oct 13 two-update Terraform plan, explicitly labeled historical recorded output |
| `images/26-aws-eks-console.png` | Genuine AWS Console, Active EKS cluster in selected Region |
| `images/27-aws-vpc-console.png` | Genuine AWS VPC Console, Available VPC and two-subnet resource map |
| `images/current-kubernetes-terminal.png` | Actual EKS Pods, Services, Ingress, Helm list and 2/2 Deployments |
| `images/current-metrics-terminal.png` | Actual curl through EKS Ingress returns Prometheus exposition |
| `images/aws-current-argocd.png` | Actual EKS Argo app Synced/Healthy; Ingress load-balancer check separately excluded |
| `images/aws-current-ingress-browser.png` | Real EKS Ingress hostname via controller forwarding, current immutable image SHA |
| `images/aws-current-prometheus.png` | Actual EKS Prometheus Targets, all configured targets UP; optional unavailable-target exercise disabled |
| `images/aws-current-grafana.png` | Actual EKS dashboard with populated app metric panels |
| `images/current-argocd.png`, `current-ingress-browser.png`, `current-prometheus.png`, `current-grafana.png` | Separate local minikube verification |

Paths above are relative to the capstone directory. Screenshots were not edited to change
results. Terminal screenshots for saved logs explicitly identify that provenance; fresh
terminal screenshots execute the command shown.

## Command evidence

- `pytest.txt`, `ci-sqlite-tests.txt`, `ci-postgres-tests.txt`: passing tests.
- `compose-build.txt`, `compose-services.txt`, `compose-api.txt`: builds/runtime/CRUD.
- `ci-run.json`, `ci-run.log`, `ci-trivy-*.txt`, `ci-secrets.txt`: successful pipeline/gates.
- `secrets-history.txt`: actual current snapshot and full-history scan; exact classroom
  exceptions described in `security/secret-scan.md`.
- `terraform-init.txt`, `terraform-validate.txt`, `terraform-tests.txt`: actual local checks.
- `terraform-access-plan.txt`, `terraform-access-apply.txt`: two in-place access CIDR
  updates, zero added/destroyed resources. Original provisioning logs remain in older evidence.
- `terraform-destroy-plan.txt`: actual plan only; **no completed destruction**.
- `aws-*.json`: actual project plan, VPC/subnets, EKS/node group and Argo statuses.
- `aws-three-tier-deploy.txt`, `aws-three-tier-helm.txt`, `aws-three-tier-kubernetes.txt`,
  `aws-database.txt`, `aws-ingress-api.txt`: real EKS deploy, migration and HTTP CRUD.
- `aws-prometheus-targets.json`, `aws-prometheus-requests.json`: both backend targets UP,
  live application counters.
- `aws-gitops-title-before.json`, `aws-gitops-title-after.json`, `aws-gitops-after-status.json`:
  actual main push → Argo reconciliation → live title update, preserving image SHA.

## Trivy explanation

Trivy scanned operating-system packages and application dependencies inside both final
Docker images against its vulnerability database. These recorded scans found zero
HIGH/CRITICAL vulnerabilities, and the pipeline is configured to fail when either severity
is found, including unfixed findings. A clean report means no matching finding was detected
at scan time; it is not a guarantee that the software has no vulnerabilities.

## Still pending

The user will record the mandatory PPT-first live presentation and upload it to this
repository. Actual Terraform destroy and its completion screenshot come after recording/
evaluation. Neither a prepared script nor a destroy plan is reported as that evidence.
