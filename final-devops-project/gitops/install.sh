#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
flux check --pre
flux install --namespace=hw-gitops --components=source-controller,kustomize-controller
kubectl apply -f source.yaml
flux reconcile source git homework -n hw-gitops
flux reconcile kustomization notes -n hw-gitops --with-source
