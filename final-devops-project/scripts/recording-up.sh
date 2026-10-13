#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
kubeconfig_path=${1:-$HOME/.local/share/devops-homework/capstone/kubeconfig}
runtime_dir=$HOME/.local/share/devops-homework/capstone/recording
python3 scripts/aws-guard.py --kubeconfig "$kubeconfig_path"
kube=(kubectl --kubeconfig "$kubeconfig_path" --context devops-homework-eks)
status=$("${kube[@]}" get application operations-notes -n argocd -o 'jsonpath={.status.sync.status}{" "}{.status.health.status}')
[[ "$status" == 'Synced Healthy' ]] || { printf 'Recording is not ready: Argo CD is %s\n' "$status" >&2; exit 1; }
# Fail before starting anything if a required port belongs to an existing listener.
for port_number in 28080 49091 43001 48080; do
  if lsof -tiTCP:"$port_number" -sTCP:LISTEN >/dev/null 2>&1; then
    printf 'Port %s is occupied. Stop only the old capstone forwarding process before retrying.\n' "$port_number" >&2
    exit 1
  fi
done
umask 077
mkdir -p "$runtime_dir"
pid_file=$runtime_dir/pids
: > "$pid_file"
cleanup_forwards() {
  while read -r forward_pid; do kill "$forward_pid" 2>/dev/null || true; done < "$pid_file"
}
trap cleanup_forwards EXIT
trap 'exit 0' INT TERM
forward() {
  nohup "${kube[@]}" port-forward -n "$1" "$2" "$3" > "$runtime_dir/$4.log" 2>&1 < /dev/null &
  printf '%s\n' "$!" >> "$pid_file"
}
forward ingress-nginx svc/aws-ingress-nginx-ingress-controller 28080:80 ingress
forward project-monitoring svc/prometheus 49091:9090 prometheus
forward project-monitoring svc/grafana 43001:3000 grafana
forward argocd svc/argocd-server 48080:80 argocd
python3 - <<'PY'
import json,time,urllib.request
endpoints=[('http://127.0.0.1:28080/api/config', {'Host':'notes.aws.project.local'}),
           ('http://127.0.0.1:49091/-/ready', {}),
           ('http://127.0.0.1:43001/api/health', {}),
           ('http://127.0.0.1:48080/api/version', {})]
for url,headers in endpoints:
    for attempt in range(30):
        try:
            with urllib.request.urlopen(urllib.request.Request(url,headers=headers),timeout=3) as response:
                assert response.status==200
            break
        except Exception:
            if attempt==29:raise SystemExit('Forwarded endpoint did not become ready: '+url)
            time.sleep(1)
print('All four recording endpoints returned HTTP 200.')
PY
printf 'Ready: Ingress 28080, Prometheus 49091, Grafana 43001, Argo CD 48080.\n'
printf 'Run python3 scripts/recording-browser.py to open the isolated recording browser.\n'
printf 'Keep this terminal running while recording. Ctrl-C stops only these four forwards.\n'
while true; do
  while read -r forward_pid; do
    kill -0 "$forward_pid" 2>/dev/null || { printf 'A recording forward stopped. Restart this helper.\n' >&2; exit 1; }
  done < "$pid_file"
  sleep 5
done
