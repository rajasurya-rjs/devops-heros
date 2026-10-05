#!/bin/bash
set -euxo pipefail
kubectl create namespace hw9-tutorial
kubectl create deployment tutorial --image=nginx:alpine -n hw9-tutorial
kubectl rollout status deployment/tutorial -n hw9-tutorial --timeout=120s
kubectl get deployments,pods -n hw9-tutorial
kubectl logs -n hw9-tutorial deployment/tutorial --tail=5
kubectl exec -n hw9-tutorial deployment/tutorial -- nginx -v
kubectl expose deployment tutorial -n hw9-tutorial --port=80 --type=NodePort
port=$(kubectl get svc tutorial -n hw9-tutorial -o jsonpath='{.spec.ports[0].nodePort}')
curl --fail --retry 15 --retry-all-errors --retry-delay 1 --max-time 4 "http://192.168.64.2:$port" | head -6
kubectl scale deployment/tutorial -n hw9-tutorial --replicas=3
kubectl rollout status deployment/tutorial -n hw9-tutorial --timeout=90s
kubectl get pods -n hw9-tutorial
kubectl set image deployment/tutorial nginx=nginx:1.27-alpine -n hw9-tutorial
kubectl rollout status deployment/tutorial -n hw9-tutorial --timeout=120s
kubectl get replicasets,pods -n hw9-tutorial
kubectl rollout undo deployment/tutorial -n hw9-tutorial
kubectl rollout status deployment/tutorial -n hw9-tutorial --timeout=120s
kubectl get deployment tutorial -n hw9-tutorial -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
