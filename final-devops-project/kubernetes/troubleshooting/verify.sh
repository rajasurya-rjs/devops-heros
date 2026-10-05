#!/usr/bin/env bash
set -euo pipefail
namespace=final-homework
image=ghcr.io/rajasurya-rjs/devops-heros/ops-notes:e1b3f65fc09b6226b28141fc6748c03ceda87c93-arm64
ip=$(minikube -p devops-completion ip)
health() { curl --max-time 8 -fsS -H 'Host: ops.homework.local' "http://$ip/health"; }
restore() {
  kubectl patch svc ops-notes -n "$namespace" --type=merge -p '{"spec":{"selector":{"app":"ops-notes"}}}'
  kubectl set image deployment/ops-notes app="$image" -n "$namespace"
  kubectl patch deployment ops-notes -n "$namespace" --type=json -p '[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/ready"}]'
}
trap restore EXIT
set -x
health
# 1. Empty Service endpoints from an incorrect selector.
kubectl patch svc ops-notes -n "$namespace" --type=merge -p '{"spec":{"selector":{"app":"deliberately-wrong"}}}'
sleep 3
kubectl get endpointslice -n "$namespace" -l kubernetes.io/service-name=ops-notes -o wide
failed=false
for attempt in {1..20}; do if ! health; then failed=true; break; fi; sleep 2; done
$failed
kubectl describe svc ops-notes -n "$namespace"
kubectl patch svc ops-notes -n "$namespace" --type=merge -p '{"spec":{"selector":{"app":"ops-notes"}}}'
for attempt in {1..12}; do if health; then break; fi; sleep 2; done
health
# 2. Nonexistent image. The healthy old ReplicaSet remains available during rollout.
kubectl set image deployment/ops-notes app=nginx:homework-nonexistent-image -n "$namespace"
for attempt in {1..30}; do
  reason=$(kubectl get pods -n "$namespace" -l app=ops-notes -o jsonpath='{range .items[*]}{.status.containerStatuses[*].state.waiting.reason}{" "}{end}')
  if [[ "$reason" == *ImagePullBackOff* || "$reason" == *ErrImagePull* ]]; then break; fi
  sleep 2
 done
[[ "$reason" == *ImagePullBackOff* || "$reason" == *ErrImagePull* ]]
kubectl get pods -n "$namespace" -l app=ops-notes
kubectl describe pods -n "$namespace" -l app=ops-notes
kubectl set image deployment/ops-notes app="$image" -n "$namespace"
kubectl rollout status deployment/ops-notes -n "$namespace" --timeout=90s
health
# 3. Wrong readiness route: process runs but replacement Pod cannot receive traffic.
kubectl patch deployment ops-notes -n "$namespace" --type=json -p '[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/deliberately-missing"}]'
sleep 20
kubectl get pods -n "$namespace" -l app=ops-notes
kubectl describe pods -n "$namespace" -l app=ops-notes
kubectl logs -n "$namespace" -l app=ops-notes --tail=8 --prefix
kubectl patch deployment ops-notes -n "$namespace" --type=json -p '[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/ready"}]'
kubectl rollout status deployment/ops-notes -n "$namespace" --timeout=90s
health
kubectl get deployment,pods,svc,pvc,hpa,ingress -n "$namespace"
