#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
set -x
kubectl apply -f mini-project/app.yaml
kubectl rollout status deployment/web-app -n hw13 --timeout=180s
kubectl apply -f hpa.yml
kubectl apply -f 01-kubernetes-volumes/volume-demo.yaml
kubectl wait --for=condition=Ready pod/volume-demo -n hw13 --timeout=120s
kubectl exec -n hw13 volume-demo -- cat /scratch/student.txt
kubectl exec -n hw13 volume-demo -- sh -c 'echo host-volume-demo > /host-demo/proof.txt; cat /host-demo/proof.txt'
kubectl get sc,pv,pvc -n hw13
old_pod=$(kubectl get pods -n hw13 -l app=web-app -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n hw13 "$old_pod" -- sh -c 'echo Rajasurya-24BCS10086 > /data/student.txt'
kubectl delete pod -n hw13 "$old_pod"
kubectl rollout status deployment/web-app -n hw13 --timeout=120s
new_pod=$(kubectl get pods -n hw13 -l app=web-app -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n hw13 "$new_pod" -- cat /data/student.txt
kubectl get pods -n hw13 -o wide
kubectl get hpa -n hw13
kubectl top pods -n hw13
kubectl apply -f load-generator.yaml
for attempt in $(seq 1 24); do
  kubectl get hpa -n hw13
  kubectl top pods -n hw13 || true
  replicas=$(kubectl get deployment web-app -n hw13 -o jsonpath='{.spec.replicas}')
  if [ "$replicas" -gt 2 ]; then break; fi
  sleep 10
done
kubectl get pods -n hw13
kubectl describe hpa web-app -n hw13
[ "$replicas" -gt 2 ]
kubectl delete pod load-generator -n hw13
for attempt in $(seq 1 24); do
  kubectl get hpa -n hw13
  replicas=$(kubectl get deployment web-app -n hw13 -o jsonpath='{.spec.replicas}')
  if [ "$replicas" -eq 2 ]; then break; fi
  sleep 10
done
[ "$replicas" -eq 2 ]
kubectl get pods,hpa,pvc -n hw13
