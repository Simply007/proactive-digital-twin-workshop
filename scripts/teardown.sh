#!/usr/bin/env bash
# teardown.sh — tear down sandbox container, optionally wipe agent workspace.
#
# Defaults to ONLY removing the container (workspace state preserved).
# Pass --wipe-workspace to also delete the agent's persistent files.

set -euo pipefail

WIPE=0
if [ "${1:-}" = "--wipe-workspace" ]; then
  WIPE=1
fi

# Source .env if present.
if [ -f "$(dirname "$0")/../.env" ]; then
  set -a
  # shellcheck disable=SC1091
  . "$(dirname "$0")/../.env"
  set +a
fi

: "${SANDBOX_CONTAINER:=agent-sandbox}"
: "${AGENT_WORKSPACE:=${HOME}/nanoclaw-workspace}"

echo "Stopping and removing container ${SANDBOX_CONTAINER}..."
(cd "$(dirname "$0")/.." && docker compose down) || docker rm -f "${SANDBOX_CONTAINER}" 2>/dev/null || true

if [ "${WIPE}" -eq 1 ]; then
  echo "Wiping workspace at ${AGENT_WORKSPACE}..."
  read -r -p "Type 'wipe' to confirm: " confirm
  if [ "${confirm}" = "wipe" ]; then
    rm -rf "${AGENT_WORKSPACE}"
    echo "Workspace removed."
  else
    echo "Aborted (workspace untouched)."
  fi
else
  echo "Workspace at ${AGENT_WORKSPACE} preserved. Pass --wipe-workspace to also delete it."
fi
