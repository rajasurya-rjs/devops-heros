#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ ! -f .env ]]; then
  umask 077
  printf 'DB_PASSWORD=%s\n' "$(openssl rand -hex 24)" > .env
fi
docker compose -p ops-notes-capstone up -d --build --wait "$@"
