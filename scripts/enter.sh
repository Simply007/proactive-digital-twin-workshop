#!/usr/bin/env bash
# enter.sh — drop into the sandbox as the nanoclaw user.
#
# Runs on your HOST (Mac/Linux). Wraps the common `docker exec` invocation
# so you don't have to remember the -u, -w, -e flags every time.

set -euo pipefail

# Source .env if present so $SANDBOX_CONTAINER is honored.
if [ -f "$(dirname "$0")/../.env" ]; then
  set -a
  # shellcheck disable=SC1091
  . "$(dirname "$0")/../.env"
  set +a
fi

: "${SANDBOX_CONTAINER:=agent-sandbox}"

if ! docker ps --format '{{.Names}}' | grep -qx "${SANDBOX_CONTAINER}"; then
  echo "Sandbox '${SANDBOX_CONTAINER}' is not running. Start it with: docker compose up -d"
  exit 1
fi

exec docker exec -it -u nanoclaw -w /work -e USER=nanoclaw "${SANDBOX_CONTAINER}" bash
