#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
[[ $(kubectl config current-context) == devops-completion ]] || { echo 'Select devops-completion; this installer is local only.' >&2; exit 1; }
# Stop the previous Flux reconciler before adopting the same application in Argo CD.
if kubectl get kustomization three-tier -n hw-gitops >/dev/null 2>&1; then
  kubectl patch kustomization three-tier -n hw-gitops --type=merge -p '{"spec":{"suspend":true}}'
fi
if kubectl get helmrelease notes -n project-three-tier >/dev/null 2>&1; then
  kubectl patch helmrelease notes -n project-three-tier --type=merge -p '{"spec":{"suspend":true}}'
fi
kubectl get secret three-tier-credentials -n project-three-tier >/dev/null
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply --server-side --force-conflicts -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.5.5/manifests/install.yaml
kubectl wait --for=condition=Established crd/applications.argoproj.io --timeout=120s
# This single-app recording uses local admin auth; optional controllers stay stopped.
kubectl scale deployment/argocd-dex-server deployment/argocd-notifications-controller \
  deployment/argocd-applicationset-controller -n argocd --replicas=0
kubectl apply -f project.yaml -f application.yaml
kubectl rollout status deployment/argocd-server -n argocd --timeout=300s
kubectl rollout status deployment/argocd-repo-server -n argocd --timeout=300s
kubectl rollout status statefulset/argocd-application-controller -n argocd --timeout=300s
echo 'Argo CD installed. Keep its port-forward bound to localhost for the recording.'
