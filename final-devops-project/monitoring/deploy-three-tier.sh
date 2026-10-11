#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
[[ $(kubectl config current-context) == devops-completion ]] || { echo 'Select the local devops-completion context.' >&2; exit 1; }
kubectl get namespace project-three-tier >/dev/null
helm upgrade --install notes-monitoring ../helm/observability \
  -n project-monitoring --create-namespace -f values-local.yaml --wait --timeout 300s
