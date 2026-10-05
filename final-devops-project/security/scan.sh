#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 -m unittest discover -s application/tests -v
bandit -r application -x application/tests
pip-audit -r application/requirements.txt
gitleaks dir . --redact --no-banner
trivy image --scanners vuln --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 "${1:-ops-notes:local}"
