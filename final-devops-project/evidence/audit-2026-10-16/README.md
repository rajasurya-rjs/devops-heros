# Full rubric audit — 16 October 2026

All **47 scored criteria, totaling 100 points**, are mapped individually in the
[full checklist](../../demo/RUBRIC-CHECKLIST.md). This report distinguishes code/artifact
readiness, actual executions, student presentation requirements and missing submission actions.
No numerical grade is guaranteed.

## Actual fresh verification

- **Application/Docker:** the previously stopped Compose stack was rebuilt and started.
  Frontend, backend and PostgreSQL became healthy. Full HTTP CRUD, health, readiness,
  database type, metrics and persistence demonstration passed at **localhost:3000**.
  The real browser screenshot is `images/audit-localhost-3000.png`; its URL/time/config
  metadata is recorded in `browser-3000.json`. Port 3000 was free before use and the
  default **13000** mapping was restored afterward. Both application user IDs are non-root.
- **Tests:** 23 isolated pytest cases passed. Test setup ignores production database
  environment values and uses temporary SQLite or an explicit dedicated `_test` database.
  The single Starlette warning is non-failing.
- **Source/security:** current source and full available Git history pass Gitleaks with
  the documented exact classroom-example exceptions. No AWS access keys, private `.env`,
  kubeconfig or Terraform state are tracked. The review and its limits are in
  `security/secret-scan.md`.
- **CI baseline:** the latest pre-audit main run
  [38521372646](https://github.com/rajasurya-rjs/devops-heros/actions/runs/38521372646)
  is successful for source `002f01c8bd0b3d70d40e312442d762b757a1b1f8`. It includes SQLite
  and PostgreSQL pytest, frontend build, SAST/SCA/secrets, both Docker/Trivy gates,
  full-SHA GHCR publication and a verified kind Helm deployment. The audit publication
  triggers another real main pipeline; its final result is reported separately.
- **AWS:** the expired login was restored using only the authorized `devops-homework`
  profile. The homework project is 089540175430, selected Region ap-southeast-2,
  **ACTIVE FREE with $53.20 remaining credits** at verification. No paid upgrade,
  new infrastructure, console provisioning or company profile was used.
- **Terraform:** init, fmt, validate and the mock-provider test passed. The mock test
  verifies configuration, not provisioning. Original genuine creation/apply evidence and
  the non-empty Oct 13 access-update plan remain preserved. Today's destroy plan is
  planning only; it did not remove resources.
- **Kubernetes/Helm:** both charts lint. The existing real EKS deployment has five
  application Pods Running/Ready with zero restarts, two frontend and two backend
  replicas, ClusterIP Services, configured Ingress, Bound PostgreSQL PVC and deployed
  Helm releases. Direct PostgreSQL inspection confirms Alembic revision `0001_notes`.
- **Argo CD/Ingress:** operations-notes is Synced/Healthy at the inspected main revision.
  The immutable cloud image version remains `cdf8c14b34055fc15651fcde1533c129b7e957b2`.
  Full CRUD succeeds through the real NGINX Ingress hostname via controller forwarding.
  The Ingress has no public LoadBalancer; its load-balancer-status-only Argo health
  check is explicitly ignored, while HTTP routing and workload health are separately verified.
- **Observability:** both backend Prometheus targets are UP, the live request rate is
  positive, Grafana health is OK and its provisioned dashboard has four panels.
- **Documentation/deck:** all required source files and artifact links exist. PPTX and PDF
  both have twelve slides. New repository-root `demo/presentation.pptx` and PDF copies
  are byte-identical to the preserved capstone copies. Root README contains all required
  technical sections. `artifact-checks.json` records these actual file/package checks.

## Gaps corrected during this audit

1. Added the actual slide files and an index in **repository-root `demo/`**.
2. Captured the required genuine **localhost:3000** app screenshot, retaining normal port 13000.
3. Added the latest supplied capstone submission form to root `SUBMISSION.md` and `demo/`.
4. Pinned both CI workflows to Ubuntu 24.04 for a stable demonstration environment.
5. Corrected cleanup ordering: owned Argo/Flux objects are finalized while their controllers
   still run, then controller/application namespaces and PVCs are removed before Terraform
   destroys EKS/CSI. The legacy `gitops-homework` namespace is included. Only syntax and
   plan-only execution were checked; destructive execution has **not** been performed.
   Flux's [garbage collection documentation](https://fluxcd.io/flux/components/kustomize/kustomizations/#prune)
   explains the managed-resource cleanup on Kustomization deletion.

## Still incomplete or unconfirmed

- **Mandatory student video:** no tracked MP4/MOV/WebM or published repository release
  recording was found. Record slides first, then codebase → real push/full CI → Terraform
  and AWS → Argo CD → Kubernetes → Prometheus → Grafana, in that order. Upload directly
  to repository-root `demo/` or a release asset. Missing video means **zero for all M10 (5 points)**.
- **Actual Terraform destroy completion:** still pending after recording/evaluation;
  this criterion is **2 points**. Neither today's plan nor a prepared script satisfies it.
- **Submission form:** public repository status is verified; actual submission through
  https://forms.gle/XWAP1vAumDJgAPM1A is unconfirmed. The student submits the single repo
  URL; the agent never submits the Google Form.
- **Deadline conflict:** supplied text says “Sunday, 19 October 2026, 11:59 PM IST.”
  October 19 is Monday; Sunday is October 18. Instructor confirmation is pending.
  Prepare for **October 18, 11:59 PM IST** until clarified; this precaution does not
  claim to change the official deadline. Late penalty is 5 points per 24-hour period.
- **Student explanation:** the Trivy explanation and speaker notes are ready, but the
  student must actually explain the project and the clean scan in the recorded walkthrough.

## Evidence scope

Files in this directory are actual command output or API data from this audit, not simulated
logs. Existing screenshots under `images/` retain their original capture dates. The new
port-3000 screenshot is from this audit. Earlier failed attempts remain historical evidence;
only later successful execution/status proves recovery. No destroy completion is fabricated.
