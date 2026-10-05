#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
kubectl create configmap grafana-dashboard -n final-homework --from-file=dashboard.json --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f stack.yaml
kubectl rollout status deployment/prometheus -n final-homework --timeout=180s
kubectl rollout status deployment/grafana -n final-homework --timeout=180s
