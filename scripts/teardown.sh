#!/usr/bin/env bash
# teardown.sh — wipe the DinD sandbox back to a completely fresh state.
#
# Removes, in order:
#   1. the agent-sandbox container + the `nanoclaw-work` named volume (the
#      nanoclaw git clone, .pnpm-store, all agent + Telegram pairing state) via
#      `docker compose down -v`
#   2. the built sandbox image  (proactive-digital-twin-workshop-sandbox)
#
# After this, `docker compose up -d` rebuilds the image from the Dockerfile
# and you start from zero.
#
# Each removal step asks for its own 'yes' so you can keep some state and
# drop the rest. Answer 'yes' to run a step, anything else to skip it.
#
# Usage (from anywhere):
#   ./scripts/teardown.sh         # confirm each step
#   ./scripts/teardown.sh -y      # run every step, no prompts (for scripting)
set -euo pipefail
cd "$(dirname "$0")/.."   # repo root (.env + docker-compose.yml live here)

# Load SANDBOX_CONTAINER from .env if present, else default.
if [ -f .env ]; then
  set -a; . ./.env; set +a
fi
CONTAINER="${SANDBOX_CONTAINER:-agent-sandbox}"

ASSUME_YES=0
[ "${1:-}" = "-y" ] && ASSUME_YES=1

# confirm "prompt text" — true if -y or the user typed 'yes'.
confirm() {
  [ "$ASSUME_YES" = "1" ] && return 0
  read -r -p "$1 [yes/no] " reply
  [ "$reply" = "yes" ]
}

if confirm "Remove container '${CONTAINER}' + the nanoclaw-work volume + local image (docker compose down -v)?"; then
  echo "==> docker compose down -v (remove container + named volume + local image)"
  docker compose down -v --rmi local --remove-orphans || true
else
  echo "  skipped: container + volume + image"
fi

if confirm "Force-remove the sandbox image (proactive-digital-twin-workshop-sandbox:latest)?"; then
  echo "==> removing sandbox image"
  docker image rm -f proactive-digital-twin-workshop-sandbox:latest 2>/dev/null || true
else
  echo "  skipped: image force-remove"
fi

# .env removed last — it was already sourced above for WORKSPACE/CONTAINER.
if [ -f .env ]; then
  if confirm "Delete repo .env (you'll need 'cp .env.example .env' to bring it back)?"; then
    echo "==> removing .env"
    rm -f -- .env
  else
    echo "  skipped: .env"
  fi
fi

echo
echo "Done. Bring the sandbox back with:  docker compose up -d"
