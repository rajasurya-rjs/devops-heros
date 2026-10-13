#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
kubeconfig_path=${1:?Supply the private homework EKS kubeconfig path.}
python3 scripts/aws-guard.py --kubeconfig "$kubeconfig_path"
kube=(kubectl --kubeconfig "$kubeconfig_path" --context devops-homework-eks)
# Replace the previous monitoring runtime while retaining its manifests and evidence.
if "${kube[@]}" get kustomization notes -n hw-gitops >/dev/null 2>&1; then
  "${kube[@]}" patch kustomization notes -n hw-gitops --type=merge -p '{"spec":{"suspend":true}}'
  "${kube[@]}" delete hpa ops-notes -n final-homework --ignore-not-found
  "${kube[@]}" scale deployment/ops-notes deployment/grafana deployment/prometheus -n final-homework --replicas=0
fi
"${kube[@]}" get secret three-tier-credentials -n project-three-tier >/dev/null
"${kube[@]}" create namespace argocd --dry-run=client -o yaml | "${kube[@]}" apply -f -
"${kube[@]}" apply --server-side --force-conflicts -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.5.5/manifests/install.yaml
"${kube[@]}" wait --for=condition=Established crd/applications.argoproj.io --timeout=120s
"${kube[@]}" scale deployment/argocd-dex-server deployment/argocd-notifications-controller \
  deployment/argocd-applicationset-controller -n argocd --replicas=0
# The walkthrough reaches this internal Service through a localhost-only port-forward.
"${kube[@]}" patch configmap argocd-cmd-params-cm -n argocd --type=merge -p '{"data":{"server.insecure":"true"}}'
"${kube[@]}" rollout restart deployment/argocd-server -n argocd
"${kube[@]}" apply -f gitops/argocd/project.yaml -f gitops/argocd/application-eks.yaml
for deployment in argocd-server argocd-repo-server argocd-redis; do
  "${kube[@]}" rollout status deployment/"$deployment" -n argocd --timeout=300s
done
"${kube[@]}" rollout status statefulset/argocd-application-controller -n argocd --timeout=300s
