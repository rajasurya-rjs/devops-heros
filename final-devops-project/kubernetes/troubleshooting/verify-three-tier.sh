#!/usr/bin/env bash
set -euo pipefail
[[ $(kubectl config current-context) == devops-completion ]] || { echo 'Select devops-completion; this drill is local only.' >&2; exit 1; }
namespace=project-three-tier
original_image=$(kubectl get deployment backend -n "$namespace" -o jsonpath='{.spec.template.spec.containers[0].image}')
original_probe=$(kubectl get deployment backend -n "$namespace" -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}')
original_selector=$(kubectl get service backend -n "$namespace" -o jsonpath='{.spec.selector}')
deployment_patch() {
  python3 - "$1" "$2" <<'PY'
import json,sys
print(json.dumps([{'op':'replace','path':'/spec/template/spec/containers/0/' + sys.argv[1], 'value':sys.argv[2]}]))
PY
}
restore() {
  kubectl patch service backend -n "$namespace" --type=json \
    -p "[{\"op\":\"replace\",\"path\":\"/spec/selector\",\"value\":$original_selector}]"
  kubectl patch deployment backend -n "$namespace" --type=json -p "$(deployment_patch image "$original_image")"
  kubectl patch deployment backend -n "$namespace" --type=json -p "$(deployment_patch readinessProbe/httpGet/path "$original_probe")"
  kubectl rollout status deployment/backend -n "$namespace" --timeout=180s
}
trap restore EXIT

echo 'Failure 1: wrong Service selector. Inspect the EndpointSlice until backend addresses disappear.'
kubectl patch service backend -n "$namespace" --type=json -p '[{"op":"replace","path":"/spec/selector","value":{"app":"deliberately-missing"}}]'
for attempt in $(seq 1 30); do
  count=$(kubectl get endpointslices -n "$namespace" -l kubernetes.io/service-name=backend -o json | python3 -c 'import json,sys; print(sum(len(x.get("endpoints", [])) for x in json.load(sys.stdin)["items"]))')
  [[ "$count" == 0 ]] && break
  sleep 1
done
[[ "$count" == 0 ]] || { echo 'Endpoints did not disappear within the observation window.' >&2; exit 1; }
kubectl get endpointslices -n "$namespace" -l kubernetes.io/service-name=backend -o yaml
restore

echo 'Failure 2: nonexistent image. Old replicas may continue serving during the failed rollout.'
kubectl set image deployment/backend backend=ops-notes-backend:deliberately-missing -n "$namespace"
for attempt in $(seq 1 30); do
  reasons=$(kubectl get pods -n "$namespace" -l app=backend -o jsonpath='{.items[*].status.containerStatuses[*].state.waiting.reason}')
  [[ "$reasons" == *ImagePullBackOff* || "$reasons" == *ErrImagePull* ]] && break
  sleep 1
done
[[ "$reasons" == *ImagePullBackOff* || "$reasons" == *ErrImagePull* ]] || { echo 'Image pull failure was not observed.' >&2; exit 1; }
kubectl get events -n "$namespace" --sort-by=.lastTimestamp
restore

echo 'Failure 3: readiness URL returns 404 while the process is alive.'
kubectl patch deployment backend -n "$namespace" --type=json -p "$(deployment_patch readinessProbe/httpGet/path /deliberately-missing)"
for attempt in $(seq 1 30); do
  events=$(kubectl get events -n "$namespace" --field-selector reason=Unhealthy -o jsonpath='{.items[*].message}')
  [[ "$events" == *404* ]] && break
  sleep 1
done
[[ "$events" == *404* ]] || { echo 'Readiness failure was not observed.' >&2; exit 1; }
kubectl get pods -n "$namespace" -l app=backend
restore
kubectl get deployments,pods,svc -n "$namespace"
echo 'Original image, probe and selector restored. Recheck the API through Ingress.'
