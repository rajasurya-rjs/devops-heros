# Full rubric recheck — 14 October 2026

The repository and its 12-slide PPTX/PDF were checked against every Session 21 rubric
criterion and submission artifact. All local links are valid, both presentation formats
contain twelve slides, and the repository is PUBLIC. The complete criterion mapping is
in `demo/RUBRIC-CHECKLIST.md`.

Actual fresh checks:

- 23 pytest cases pass; isolated test storage, with one non-failing deprecation warning.
- Compose frontend/backend/database are healthy; all CRUD, health, readiness and metrics
  checks pass through localhost:13000 with PostgreSQL.
- Both Helm charts lint successfully. Terraform fmt, validate and its mock-provider test
  pass. The mock test is configuration verification, not a cloud provisioning claim.
- Current source and all 56 available Git commits scan clean, with the documented exact
  classroom-example exceptions. No AWS credentials or Terraform state are tracked.
- Latest existing main pipeline [38417521000](https://github.com/rajasurya-rjs/devops-heros/actions/runs/38417521000)
  is green at source `3e0a4e196f3df493a57927a7abdc72f86f2fc3b8`, including both image/Trivy
  gates, SHA-tagged GHCR publication and kind deployment.
- Homework AWS login restored after overnight expiry. The explicit devops-homework
  profile points to project 089540175430; ap-southeast-2 remains ACTIVE FREE with $66.88
  credits at verification. No new AWS resources or paid upgrade were requested.
- Live EKS has all five application Pods Running, two Ready replicas for both Deployments,
  ClusterIP Services, Bound PostgreSQL PVC, Ingress and deployed Helm releases.
- Argo CD is Synced/Healthy at the current source revision. Current image SHA remains
  cdf8c14b34055fc15651fcde1533c129b7e957b2, independently identified by /api/config.
- Real HTTP CRUD succeeds through EKS Ingress. Both Prometheus targets are UP; request
  rate is populated. Grafana health and the provisioned dashboard API are verified.
- All four recording forwards start successfully and their endpoints return HTTP 200.

Logs and JSON in this directory are genuine fresh executions; older screenshots/logs remain
preserved under `images/` and `evidence/completion/`. Credentials remain outside Git.

**Pending:** student-recorded PPT-first video uploaded to this repository, followed by
actual Terraform destroy completion evidence after recording/evaluation. AWS is retained
for the requested live walkthrough. A destroy plan is not reported as cleanup completion.
The student submits the repository URL/form and checks the deadline; the agent does not
submit the Google Form or guarantee a numerical grade.
