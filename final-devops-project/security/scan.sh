#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 -m pytest -c backend/pytest.ini backend/tests -v
bandit -r backend/app
pip-audit -r backend/requirements.txt
./scripts/scan-secrets.sh
for image in "${1:-ops-notes-backend:local}" "${2:-ops-notes-frontend:local}"; do
  trivy image --scanners vuln --severity HIGH,CRITICAL --exit-code 1 "$image"
done
