#!/usr/bin/env bash
set -euo pipefail
: "${KUBECONFIG:?Export a separate kubeconfig for the homework EKS cluster first}"
cd "$(dirname "$0")/.."
# Keep the original minikube deployment intact; target only the homework EKS context.
context=$(kubectl config current-context)
if [[ "$context" != "aws-homework" ]]; then
  printf 'Expected context aws-homework; got %s\n' "$context" >&2
  exit 1
fi
kubectl wait --for=condition=Ready nodes --all --timeout=300s
kubectl apply -f kubernetes/aws-storageclass.yaml
nginx_chart=${NGINX_CHART:-}
if [[ -z "$nginx_chart" ]]; then
  chart_dir=$(mktemp -d)
  trap 'rm -rf -- "$chart_dir"' EXIT
  curl -fsSL --max-time 60 https://github.com/nginx/kubernetes-ingress/archive/refs/tags/v5.6.3.tar.gz -o "$chart_dir/source.tar.gz"
  tar -xzf "$chart_dir/source.tar.gz" -C "$chart_dir" \
    kubernetes-ingress-5.6.3/charts/nginx-ingress kubernetes-ingress-5.6.3/config
  # The Helm client stalled fetching the external schema; keep full validation with a local copy.
  curl -fsSL --max-time 30 https://raw.githubusercontent.com/nginxinc/kubernetes-json-schema/master/v1.37.0/_definitions.json -o "$chart_dir/definitions.json"
  python3 - "$chart_dir" <<'PYTHON'
from pathlib import Path
import sys
folder=Path(sys.argv[1])
p=folder/'kubernetes-ingress-5.6.3/charts/nginx-ingress/values.schema.json'
url='https://raw.githubusercontent.com/nginxinc/kubernetes-json-schema/master/v1.37.0/_definitions.json'
p.write_text(p.read_text().replace(url,(folder/'definitions.json').resolve().as_uri()))
PYTHON
  nginx_chart="$chart_dir/kubernetes-ingress-5.6.3/charts/nginx-ingress"
fi
helm upgrade --install aws-ingress "$nginx_chart" --version 2.7.3 \
  -n ingress-nginx --create-namespace --skip-crds \
  --set controller.nginxplus=false --set controller.service.type=ClusterIP \
  --set controller.enableCustomResources=false --wait --timeout=300s
./kubernetes/deploy.sh \
  --set image.repository=ghcr.io/rajasurya-rjs/devops-heros/ops-notes \
  --set image.tag=e1b3f65fc09b6226b28141fc6748c03ceda87c93 \
  --set storage.className=homework-gp3 --set storage.size=1Gi
./monitoring/deploy.sh
kubectl get pods,svc,pvc,hpa,ingress -n final-homework
