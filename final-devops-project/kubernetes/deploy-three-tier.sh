#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
context=$(kubectl config current-context)
if [[ "$context" != devops-completion && "$context" != three-tier-ci ]]; then
  printf 'Select the local devops-completion cluster before deploying. Current context: %s\n' "$context" >&2
  exit 1
fi
if ! kubectl get namespace project-three-tier >/dev/null 2>&1; then
  kubectl create namespace project-three-tier
fi
if ! kubectl get secret three-tier-credentials -n project-three-tier >/dev/null 2>&1; then
  password_file=$(mktemp)
  token_file=$(mktemp)
  trap 'rm -f "$password_file" "$token_file"' EXIT
  openssl rand -hex 24 | tr -d '\n' > "$password_file"
  openssl rand -hex 24 > "$token_file"
  kubectl create secret generic three-tier-credentials -n project-three-tier --from-file=password="$password_file" --from-file=token="$token_file"
fi
helm upgrade --install notes helm/three-tier -n project-three-tier --wait --timeout 300s "$@"
