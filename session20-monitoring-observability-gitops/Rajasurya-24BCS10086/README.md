# Session 20 - Monitoring, Observability and GitOps

**Name:** Rajasurya J

**Enrollment number:** 24BCS10086

## Task 1: Monitoring demo

The original [Operations Notes application](../../final-devops-project/application/app.py) exposes
`/health`, `/ready` and `/metrics`. [Monitoring manifests](../../final-devops-project/monitoring/stack.yaml)
deploy Prometheus and Grafana with provisioned data source and dashboard.

| Signal | Actual measurement |
|---|---|
| Metrics | HTTP responses/errors, process CPU seconds, peak resident memory and uptime. |
| Logs | JSON request/status messages in `kubectl logs`. |
| Alerts | Prometheus `TargetUnavailable` rule fires for an intentionally unavailable scrape target. |
| CPU / memory | Process metrics in Grafana and Kubernetes `kubectl top pods`. |
| Health | HTTP probes and a successful application scrape (`up=1`). |

The intentionally unavailable target is labelled `deliberate-unavailable-target`; it is an alert drill,
not the application. The application's own target must be UP.
Peak RSS is reported in KiB by the Linux container's `resource.getrusage`; it is a maximum,
not instantaneous working-set memory. CPU is cumulative process seconds; use its rate to inspect usage.

## Task 2: Observability

Metrics summarize behavior numerically over time; logs record individual events with context;
traces connect the spans of a request across services. Correlating these signals helps explain failures
instead of only reporting that a health check failed. Prometheus/Grafana are common metrics tools,
Loki or Elasticsearch can centralize logs, and OpenTelemetry with Jaeger/Tempo can instrument traces.
This demo implements metrics and logs. Traces are documented conceptually; distributed tracing is not
claimed for this single-service application.

In Kubernetes, combine application signals with Pod conditions, Events, resource usage, Service endpoints
and controller status. A healthy process may still be unreachable because of selectors, DNS or readiness.

## Task 3: GitOps demo

[Flux configuration](../../final-devops-project/gitops/source.yaml) watches **this user's repository** on
`main`. A GitRepository fetches the desired revision; a Kustomization applies
`final-devops-project/gitops/app` every 30 seconds. The dedicated `gitops-homework` namespace keeps this
separate from the Helm-managed application.

Git is the source of truth: review a declarative change, commit/push it, let the controller reconcile it,
then verify the observed revision and resulting resources. Continuous reconciliation also repairs live
changes that disagree with Git. `prune: true` removes resources that were managed by this Kustomization
and subsequently removed from its source.

```text
Git commit → GitRepository artifact → Kustomization reconciliation → Kubernetes resources
                         ↑                                  |
                         └───────── repeat every 30s ───────┘
```

The GitOps notes copy uses temporary local data for this demonstration; the main Helm application owns
the persistent PVC. Flux does not manage or prune the earlier session namespaces.

## Commands

```bash
./final-devops-project/monitoring/deploy.sh
./final-devops-project/gitops/install.sh
kubectl top pods -n final-homework
kubectl logs -n final-homework deployment/ops-notes --tail=10
flux get sources git -n hw-gitops
flux get kustomizations -n hw-gitops
```

Run from the repository root. See the final-project README for the current minikube profile and ports.
Both scripts assume kubectl is pointing at that homework cluster.

## Evidence

- [Prometheus targets](../../final-devops-project/evidence/prometheus-targets.json)
- [Prometheus alerts](../../final-devops-project/evidence/prometheus-alerts.json)
- [Monitoring and GitOps commands/output](../../final-devops-project/evidence/monitoring-gitops.txt)

![Prometheus target](../../final-devops-project/images/03-prometheus-targets.png)
![Grafana metrics](../../final-devops-project/images/04-grafana.png)
![GitOps reconciliation](../../final-devops-project/images/07-gitops.png)

The screenshots are genuine browser or live-terminal captures. Final runtime verification is recorded in
the linked evidence, including the applied Git revision and correction of a deliberate replica-count drift.

[Prometheus documentation](https://prometheus.io/docs/introduction/overview/)
[Flux reconciliation documentation](https://fluxcd.io/flux/components/kustomize/kustomizations/)
