#!/usr/bin/env bash
# start-agent.sh — starts the agent's main process inside the sandbox.
#
# Use when the sandbox container is up but the agent service isn't running
# (e.g., after `docker compose stop && docker compose start`, or after a
# `bash nanoclaw.sh` install that aborted before the service start).
#
# Runs INSIDE the sandbox as the nanoclaw user.

set -euo pipefail

: "${AGENT_FRAMEWORK:=nanoclaw}"

case "${AGENT_FRAMEWORK}" in
  nanoclaw)
    if [ ! -f /work/nanoclaw/dist/index.js ]; then
      echo "[start-agent] /work/nanoclaw/dist/index.js not found — run scripts/install-agent.sh first"
      exit 1
    fi
    if pgrep -f "node /work/nanoclaw/dist/index.js" >/dev/null 2>&1; then
      echo "[start-agent] NanoClaw is already running."
      exit 0
    fi
    cd /work/nanoclaw
    nohup node dist/index.js > logs/agent.log 2>&1 &
    sleep 3
    if pgrep -f "node /work/nanoclaw/dist/index.js" >/dev/null 2>&1; then
      echo "[start-agent] NanoClaw started. Tail logs: tail -f /work/nanoclaw/logs/agent.log"
    else
      echo "[start-agent] NanoClaw failed to start. Last log lines:"
      tail -20 /work/nanoclaw/logs/agent.log || true
      exit 1
    fi
    ;;
  *)
    echo "[start-agent] start logic for AGENT_FRAMEWORK='${AGENT_FRAMEWORK}' not yet implemented."
    exit 2
    ;;
esac
