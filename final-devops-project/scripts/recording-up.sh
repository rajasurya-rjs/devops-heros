#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
kubeconfig_path=${1:-$HOME/.local/share/devops-homework/capstone/kubeconfig}
runtime_dir=$HOME/.local/share/devops-homework/capstone/recording
python3 scripts/aws-guard.py --kubeconfig "$kubeconfig_path"
kube=(kubectl --kubeconfig "$kubeconfig_path" --context devops-homework-eks)
status=$("${kube[@]}" get application operations-notes -n argocd -o 'jsonpath={.status.sync.status}{" "}{.status.health.status}')
[[ "$status" == 'Synced Healthy' ]] || { printf 'Recording is not ready: Argo CD is %s\n' "$status" >&2; exit 1; }
# Fail before starting anything if a required port belongs to an existing listener.
for port_number in 28080 49091 43001 48080; do
  if lsof -tiTCP:"$port_number" -sTCP:LISTEN >/dev/null 2>&1; then
    printf 'Port %s is occupied. Stop only the old capstone forwarding process before retrying.\n' "$port_number" >&2
    exit 1
  fi
done
exec python3 scripts/recording-forwards.py "$kubeconfig_path" "$runtime_dir"
