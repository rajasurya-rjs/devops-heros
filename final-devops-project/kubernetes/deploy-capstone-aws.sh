#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
kubeconfig_path=${1:?Supply the private homework EKS kubeconfig path.}
python3 scripts/aws-guard.py
kubectl --kubeconfig "$kubeconfig_path" --context devops-homework-eks get storageclass homework-gp3 >/dev/null
kubectl --kubeconfig "$kubeconfig_path" --context devops-homework-eks apply -f k8s/namespace.yaml
if ! kubectl --kubeconfig "$kubeconfig_path" --context devops-homework-eks get secret three-tier-credentials -n project-three-tier >/dev/null 2>&1; then
  password_file=$(mktemp)
  token_file=$(mktemp)
  trap 'rm -f "$password_file" "$token_file"' EXIT
  openssl rand -hex 24 | tr -d '\n' > "$password_file"
  openssl rand -hex 24 > "$token_file"
  kubectl --kubeconfig "$kubeconfig_path" --context devops-homework-eks create secret generic three-tier-credentials \
    -n project-three-tier --from-file=password="$password_file" --from-file=token="$token_file"
fi
helm --kubeconfig "$kubeconfig_path" --kube-context devops-homework-eks upgrade --install notes helm/three-tier \
  -n project-three-tier -f gitops/argocd/values-eks.yaml --wait --timeout 300s
python3 scripts/aws-guard.py
helm --kubeconfig "$kubeconfig_path" --kube-context devops-homework-eks upgrade --install notes-monitoring helm/observability \
  -n project-monitoring --create-namespace -f monitoring/values-local.yaml --wait --timeout 300s
