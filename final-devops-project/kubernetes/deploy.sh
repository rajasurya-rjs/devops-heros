#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
kubectl apply -f kubernetes/namespace.yaml
if ! kubectl get secret app-credentials -n final-homework >/dev/null 2>&1; then
  token_file=$(mktemp)
  trap 'rm -f "$token_file"' EXIT
  openssl rand -hex 24 > "$token_file"
  kubectl create secret generic app-credentials -n final-homework --from-file=token="$token_file"
fi
helm upgrade --install ops-notes helm/ops-notes -n final-homework --wait --timeout 180s "$@"
