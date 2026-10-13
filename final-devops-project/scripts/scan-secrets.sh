#!/usr/bin/env bash
set -euo pipefail
review_root=$(git -C "$(dirname "$0")/../.." rev-parse --show-toplevel)
review_snapshot=$(mktemp -d)
trap 'rm -rf -- "$review_snapshot"' EXIT
# Scan all submitted source, including new files, without copying ignored local passwords/caches.
python3 - "$review_root" "$review_snapshot" <<'PY'
from pathlib import Path
import shutil
import subprocess
import sys

root, snapshot = map(Path, sys.argv[1:])
files = subprocess.check_output(
    ['git', '-C', str(root), 'ls-files', '--cached', '--others', '--exclude-standard',
     '-z', '--', 'final-devops-project'],
).decode().split('\0')
for name in filter(None, files):
    source = root / name
    if not source.is_file():
        continue
    target = snapshot / name
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, target)
PY
"${GITLEAKS_BIN:-gitleaks}" dir "$review_snapshot" --redact --no-banner
# Scan repository history too; the ignore file lists only reviewed classroom examples.
"${GITLEAKS_BIN:-gitleaks}" git "$review_root" --log-opts='--all' \
  --gitleaks-ignore-path "$review_root/.gitleaksignore" --redact --no-banner
