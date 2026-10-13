#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mode=${1:---plan}
[[ "$mode" == --plan || "$mode" == --execute ]] || { echo 'Use --plan or --execute.' >&2; exit 1; }
private_dir=$HOME/.local/share/devops-homework/capstone
inputs_path=${2:-$private_dir/terraform-inputs.json}
kubeconfig_path=$private_dir/kubeconfig
[[ -f "$inputs_path" ]] || { echo 'Private Terraform inputs are missing.' >&2; exit 1; }
python3 scripts/aws-guard.py
python3 - "$inputs_path" <<'PY'
import json,sys
j=json.load(open(sys.argv[1]))
assert j['region']=='ap-southeast-2'
assert j['bucket_name']=='rajasurya-24bcs10086-final-20261005'
PY
mkdir -p "$private_dir"
if [[ "$mode" == --plan ]]; then
  AWS_PROFILE=devops-homework terraform -chdir=terraform plan -destroy -input=false -no-color \
    -var-file="$inputs_path" -out="$private_dir/destroy.tfplan"
  echo 'Plan only. No resources were removed. Run --execute only after recording/evaluation.'
  exit 0
fi
# --execute permanently removes homework data. Keep any desired database backup privately first.
python3 scripts/aws-guard.py --kubeconfig "$kubeconfig_path"
kube=(kubectl --kubeconfig "$kubeconfig_path" --context devops-homework-eks)
# Remove controllers before workloads, and PVCs while EBS CSI still runs.
"${kube[@]}" delete namespace argocd hw-gitops --ignore-not-found --wait=true --timeout=300s
"${kube[@]}" delete namespace project-three-tier project-monitoring final-homework ingress-nginx \
  --ignore-not-found --wait=true --timeout=300s
remaining_volumes=$("${kube[@]}" get pv -o json)
python3 - "$remaining_volumes" <<'PY'
import json,sys
names={'project-three-tier','final-homework','project-monitoring'}
remaining=[p['metadata']['name'] for p in json.loads(sys.argv[1])['items']
           if p['spec'].get('claimRef',{}).get('namespace') in names]
if remaining:raise SystemExit('STOP: wait for homework PV/EBS cleanup before destroying CSI: '+', '.join(remaining))
PY
python3 scripts/aws-guard.py
AWS_PROFILE=devops-homework terraform -chdir=terraform destroy -auto-approve -input=false -no-color -var-file="$inputs_path"
AWS_PROFILE=devops-homework terraform -chdir=terraform state list
printf 'Capture the real Destroy complete output and verify no capstone resources remain.\n'
