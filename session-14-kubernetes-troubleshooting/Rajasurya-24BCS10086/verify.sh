#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
set -x
retry_http() {
  for attempt in $(seq 1 15); do
    if kubectl exec client -n hw14 -- wget -T 3 -qO- "$1"; then return 0; fi
    sleep 2
  done
  return 1
}
kubectl apply -f mini-project/app.yaml
kubectl rollout status deployment/troubleshooting-app -n hw14 --timeout=120s
kubectl wait --for=condition=Ready pod/client -n hw14 --timeout=90s
kubectl get pods -n hw14 -o wide
kubectl describe deployment troubleshooting-app -n hw14
kubectl logs -n hw14 deployment/troubleshooting-app --tail=8
kubectl exec -n hw14 client -- wget -qO- http://troubleshooting-service | head -6
kubectl events -n hw14
kubectl explain pod.spec.containers.resources
kubectl top pods -n hw14 || true
kubectl apply -f scenarios/crash-broken.yaml
for i in $(seq 1 18); do
  reason=$(kubectl get pod crash -n hw14 -o jsonpath='{.status.containerStatuses[0].state.waiting.reason}')
  if [ "$reason" = CrashLoopBackOff ]; then break; fi
  sleep 3
done
kubectl get pod crash -n hw14
kubectl logs crash -n hw14 --previous || kubectl logs crash -n hw14
kubectl describe pod crash -n hw14
kubectl delete pod crash -n hw14
kubectl apply -f scenarios/crash-fixed.yaml
kubectl wait --for=condition=Ready pod/crash -n hw14 --timeout=90s
kubectl apply -f scenarios/image-broken.yaml
for i in $(seq 1 30); do
  kubectl get pod image -n hw14
  reason=$(kubectl get pod image -n hw14 -o jsonpath='{.status.containerStatuses[0].state.waiting.reason}')
  if [ "$reason" = ImagePullBackOff ]; then break; fi
  sleep 3
done
kubectl describe pod image -n hw14
kubectl set image pod/image app=nginx:alpine -n hw14
kubectl wait --for=condition=Ready pod/image -n hw14 --timeout=90s
kubectl apply -f scenarios/pending-broken.yaml
sleep 3
kubectl get pod pending -n hw14
kubectl describe pod pending -n hw14
kubectl delete pod pending -n hw14
kubectl apply -f scenarios/pending-fixed.yaml
kubectl wait --for=condition=Ready pod/pending -n hw14 --timeout=90s
kubectl apply -f scenarios/mount-broken.yaml
sleep 5
kubectl get pod mount -n hw14
kubectl describe pod mount -n hw14
kubectl create configmap missing-volume-config -n hw14 --from-literal=mode=homework
kubectl wait --for=condition=Ready pod/mount -n hw14 --timeout=120s
kubectl exec mount -n hw14 -- cat /config/mode
kubectl apply -f scenarios/config-broken.yaml
sleep 5
kubectl get pod config -n hw14
kubectl describe pod config -n hw14
kubectl create secret generic missing-config-secret -n hw14 --from-literal=token=classroom-placeholder
kubectl wait --for=condition=Ready pod/config -n hw14 --timeout=90s
kubectl exec config -n hw14 -- sh -c 'test -n "$APP_TOKEN" && echo Secret-injection-verified-without-printing-value'
kubectl patch service troubleshooting-service -n hw14 -p '{"spec":{"selector":{"app":"wrong-app"}}}'
kubectl get endpointslices -n hw14 -l kubernetes.io/service-name=troubleshooting-service
kubectl describe service troubleshooting-service -n hw14
kubectl get pods -n hw14 --show-labels
kubectl exec client -n hw14 -- timeout 3 wget -qO- http://troubleshooting-service || true
kubectl patch service troubleshooting-service -n hw14 -p '{"spec":{"selector":{"app":"troubleshooting-app"}}}'
retry_http http://troubleshooting-service | head -6
kubectl patch service troubleshooting-service -n hw14 -p '{"spec":{"ports":[{"port":80,"targetPort":81}]}}'
kubectl exec client -n hw14 -- timeout 3 wget -qO- http://troubleshooting-service || true
kubectl describe service troubleshooting-service -n hw14
kubectl patch service troubleshooting-service -n hw14 -p '{"spec":{"ports":[{"port":80,"targetPort":80}]}}'
retry_http http://troubleshooting-service | head -6
kubectl apply -f scenarios/dns-broken.yaml
kubectl wait --for=condition=Ready pod/dns -n hw14 --timeout=90s
kubectl exec dns -n hw14 -- cat /etc/resolv.conf
kubectl exec dns -n hw14 -- timeout 5 nslookup troubleshooting-service.hw14.svc.cluster.local || true
kubectl delete pod dns -n hw14
kubectl apply -f scenarios/dns-fixed.yaml
kubectl wait --for=condition=Ready pod/dns -n hw14 --timeout=90s
kubectl exec dns -n hw14 -- nslookup troubleshooting-service.hw14.svc.cluster.local
kubectl apply -f mini-project/network-broken.yaml
kubectl rollout status deployment/loopback -n hw14 --timeout=120s
kubectl exec -n hw14 deployment/loopback -- python -c "import urllib.request; print(urllib.request.urlopen('http://127.0.0.1:8080').status)"
kubectl exec client -n hw14 -- timeout 3 wget -qO- http://loopback:8080 || true
kubectl patch deployment loopback -n hw14 --type=json -p '[{"op":"replace","path":"/spec/template/spec/containers/0/command/5","value":"0.0.0.0"}]'
kubectl rollout status deployment/loopback -n hw14 --timeout=120s
retry_http http://loopback:8080 | head -6
kubectl get pods,svc -n hw14
kubectl events -n hw14 --types=Warning
