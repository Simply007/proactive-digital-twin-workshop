#!/usr/bin/env bash
# install-agent.sh — installs the configured agent framework inside the sandbox.
#
# Runs INSIDE the sandbox container as the nanoclaw user. Wraps the upstream
# install command so swapping providers later is a single switch here.
#
# Usage (from your Mac terminal, after `docker compose up -d`):
#   docker exec -it -u nanoclaw -w /work -e USER=nanoclaw agent-sandbox \
#     bash /opt/scripts/install-agent.sh

set -euo pipefail

: "${AGENT_FRAMEWORK:=nanoclaw}"

case "${AGENT_FRAMEWORK}" in
  nanoclaw)
    if [ -d /work/nanoclaw ]; then
      echo "[install-agent] /work/nanoclaw already exists — skipping clone"
    else
      echo "[install-agent] cloning NanoClaw"
      git clone https://github.com/nanocoai/nanoclaw.git /work/nanoclaw
    fi
    echo "[install-agent] running bash nanoclaw.sh"
    cd /work/nanoclaw
    bash nanoclaw.sh
    ;;
  openclaw)
    echo "[install-agent] OpenClaw is not yet implemented in this kit."
    echo "[install-agent] OpenClaw expects a Hostinger one-click install or"
    echo "[install-agent] a manual install per docs.openclaw.ai. Not a drop-in"
    echo "[install-agent] for this sandbox. See docs/providers.md."
    exit 2
    ;;
  hermes)
    echo "[install-agent] Hermes is not yet implemented (hosted via OpenRouter,"
    echo "[install-agent] no local install). See docs/providers.md."
    exit 2
    ;;
  agentone|agent-one)
    echo "[install-agent] Agent-One is not yet implemented. See docs/providers.md."
    exit 2
    ;;
  claude-code)
    echo "[install-agent] Claude Code in a container is not yet implemented."
    echo "[install-agent] Would skip the framework layer and run \`claude\` directly."
    echo "[install-agent] See docs/providers.md."
    exit 2
    ;;
  *)
    echo "[install-agent] unknown AGENT_FRAMEWORK='${AGENT_FRAMEWORK}'."
    echo "[install-agent] Set AGENT_FRAMEWORK in .env to one of: nanoclaw, openclaw, hermes, agentone, claude-code"
    exit 1
    ;;
esac
