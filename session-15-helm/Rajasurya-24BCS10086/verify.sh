#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
set -x
helm version --short
helm lint mini-project/notes-chart
helm template notes mini-project/notes-chart > evidence/rendered.yaml
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update bitnami
helm repo list
helm search repo bitnami/nginx | awk 'NR<=5'
helm install notes mini-project/notes-chart -n hw15 --create-namespace --wait --timeout 120s
helm list -n hw15
helm status notes -n hw15
helm get values notes -n hw15
curl --fail --retry 15 --retry-all-errors --retry-delay 1 --max-time 5 http://192.168.64.2:30095
helm upgrade notes mini-project/notes-chart -n hw15 -f mini-project/notes-chart/values-prod.yaml --wait --timeout 120s
curl --fail --retry 15 --retry-all-errors --retry-delay 1 --max-time 5 http://192.168.64.2:30095
helm upgrade notes mini-project/notes-chart -n hw15 -f mini-project/notes-chart/values-prod.yaml --set app.version=v3 --wait --timeout 120s
curl --fail --retry 15 --retry-all-errors --retry-delay 1 --max-time 5 http://192.168.64.2:30095
helm history notes -n hw15
helm rollback notes 1 -n hw15 --wait --timeout 120s
curl --fail --retry 15 --retry-all-errors --retry-delay 1 --max-time 5 http://192.168.64.2:30095
helm history notes -n hw15
helm get manifest notes -n hw15 | awk 'NR<=45'
kubectl get pods,svc,cm -n hw15
helm install disposable mini-project/notes-chart -n hw15 --set service.nodePort=30096 --wait --timeout 120s
helm uninstall disposable -n hw15
helm list -n hw15
