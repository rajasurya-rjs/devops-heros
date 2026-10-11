# Session 21 presentation and evidence checklist

This is a plan for a real presentation or recording. A script alone does not satisfy M10.
The existing slides describe the earlier implementation; use the current README for the
FastAPI/Alembic changes. Do not represent historical screenshots as new execution.

1. Introduce Operations Notes, your original app for deployment checks and incident fixes.
2. Open http://localhost:3000, create a note, edit it and delete it. Explain the three tiers.
3. Open /docs. Show GET, POST, PUT and DELETE endpoints, /health, /ready and /metrics.
4. Query PostgreSQL `notes` and `alembic_version`; explain schema revision `0001_notes`.
5. Run `pytest -v`; explain that the temporary/dedicated test database protects saved data.
6. Make a small visible source change and a meaningful Git commit. Push to the homework
   repository and watch the new pipeline. Show tests and frontend build before image builds.
7. Show both multi-stage/frontend and non-root/backend Docker definitions. Show Trivy gates.
8. Show GHCR package pages with the exact SHA tag from that run.
9. Show Terraform source and the genuine existing infrastructure evidence. Cloud execution
   and cleanup are separate work, currently excluded by the user. Do not claim a destroy
   plan has removed resources.
10. Show Kubernetes Deployments with two Ready replicas each, ClusterIP Services, PVC,
    `helm list` and the Ingress `/` and `/api` rules.
11. Compare the latest pipeline SHA to `/api/config` in its kind deployment log. For a local
    update demo, deploy the newly built images with a new tag and matching `appVersion`.
12. Run the bounded load generator while watching HPA. Record actual scale-up if observed.
13. Show `/metrics`, Prometheus targets UP, and a populated Grafana panel.
14. On the local devops-completion cluster only, run
    `./kubernetes/troubleshooting/verify-three-tier.sh`. Explain selector, image and probe
    failures, inspect Events, and show the restored deployment plus a healthy API response.
15. Explain one real problem you fixed, and show the repository/README and meaningful history.

## Screenshots still required for the updated implementation

- Browser at localhost:3000 and through the Ingress hostname.
- `pytest -v` with all tests passing.
- At least ten meaningful Git commits.
- Compose showing healthy services and non-root application processes.
- Green updated pipeline, SHA-tagged GHCR packages and both Trivy reports.
- Running Pods, ClusterIP Services, Helm release and two replicas per application Deployment.
- `/metrics`, Prometheus Targets UP and a Grafana panel populated by fresh application traffic.
- AWS Console VPC/EKS in the selected Region and actual Terraform destroy completion after
  evaluation, when the user resumes AWS work.
- Live presentation or recorded walkthrough that includes a source change and deployment update.

No Google Form is submitted by the agent. Publishing is restricted to the user's homework repository.
