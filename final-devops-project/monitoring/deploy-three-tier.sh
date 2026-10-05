#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
[[ $(kubectl config current-context) == devops-completion ]] || { echo 'Select the local devops-completion context.' >&2; exit 1; }
# Use the existing Prometheus/Grafana installation for both application deployments.
kubectl create configmap grafana-dashboard -n final-homework --from-file=dashboard.json --from-file=dashboard-three-tier.json --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f three-tier.yaml
kubectl rollout restart deployment/prometheus -n final-homework
kubectl rollout status deployment/prometheus -n final-homework --timeout=180s
kubectl rollout status deployment/grafana -n final-homework --timeout=180s
