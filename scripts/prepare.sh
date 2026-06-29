#!/usr/bin/env bash
#
# NanoClaw workshop prepare (full pre-cache)
# ------------------------------------------
# Run this INSIDE your Ubuntu VM, at home on good WiFi, so the workshop-day
# install pulls little or nothing over the conference network.
#
#   sudo apt-get update && sudo apt-get install -y curl ca-certificates && \
#     curl -fsSL https://raw.githubusercontent.com/Simply007/proactive-digital-twin-workshop/main/scripts/prepare.sh | bash
#   # or, from a clone of this kit:  bash scripts/prepare.sh
#
# Runs the full pre-cache: host packages + base image + the agent container
# image + host deps + OneCLI/Postgres images. On the workshop day only
# credentials and Telegram pairing remain. No prompts. Safe to re-run -
# already-done steps are skipped. The clone is pinned to NANOCLAW_REF so what
# you pre-build at home is exactly what you install on the day.

set -euo pipefail

NANOCLAW_REF="v2.1.17"
REPO_URL="https://github.com/nanocoai/nanoclaw.git"
CLONE_DIR="${NANOCLAW_DIR:-$HOME/nanoclaw}"   # use this SAME dir on the day

say()  { printf '\n=== %s ===\n' "$*"; }
info() { printf '    %s\n' "$*"; }
step() { printf '\n--> %s\n' "$*"; }
disk() { printf '    [disk] %s used on /\n' "$(df -h --output=used / | tail -1 | tr -d ' ')"; }

cat <<'INTRO'

NanoClaw workshop pre-cache (full)
==================================
Pulls the entire install now (at home) so the workshop-day install pulls
essentially nothing - only credentials and Telegram pairing remain.

  - host packages: Docker, Node 22, pnpm
  - the Claude Code CLI (default runtime) + Codex CLI (alternative)
  - node:22-slim base image
  - the agent container image (pre-built)
  - host dependencies + OneCLI/Postgres images

No prompts; safe to re-run (already-done steps are skipped).
INTRO

disk

# --- Host toolchain ----------------------------------------------------------
say "Host packages (Docker, Node 22, pnpm)"

step "Updating apt and installing base tools (git, curl, ...)"
sudo apt-get update
sudo apt-get install -y util-linux-extra git curl ca-certificates

if command -v docker >/dev/null 2>&1; then
  info "Docker already installed - skipping."
else
  step "Installing Docker (get.docker.com)"
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker "$USER"
fi

if command -v node >/dev/null 2>&1; then
  info "Node already installed ($(node --version)) - skipping."
else
  step "Installing Node 22 (NodeSource)"
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi

step "Enabling pnpm (corepack)"
sudo corepack enable

# Claude Code CLI - host CLI for the default (Claude) runtime. The subscription
# sign-in needs it; the API-key path does not. (Codex users instead need
# `npm install -g @openai/codex`.) Installs to ~/.local/bin.
if command -v claude >/dev/null 2>&1 || [ -x "$HOME/.local/bin/claude" ]; then
  info "Claude Code CLI already installed - skipping."
else
  step "Installing Claude Code CLI (claude.ai/install.sh)"
  curl -fsSL https://claude.ai/install.sh | bash
fi

# Codex CLI - host CLI for the alternative (OpenAI/Codex) runtime's ChatGPT-
# subscription sign-in. nanoclaw.sh tells you to install it but doesn't do it
# for you. (The in-container Codex provider is pinned separately in
# container/cli-tools.json and baked into the agent image.)
if command -v codex >/dev/null 2>&1; then
  info "Codex CLI already installed - skipping."
else
  step "Installing Codex CLI (npm i -g @openai/codex)"
  sudo npm install -g @openai/codex
fi

# The docker group must be active in this shell to reach the daemon.
if ! docker info >/dev/null 2>&1; then
  say "Reboot needed"
  info "Docker is installed, but this shell isn't in the 'docker' group yet."
  info "Reboot the VM, then run this script again."
  info "(Quick alternative for this shell only: run 'newgrp docker', then re-run.)"
  exit 0
fi

# --- Base image --------------------------------------------------------------
step "Pulling the node:22-slim base image"
docker pull node:22-slim
disk

# --- Clone (pinned) + pre-build the agent container image --------------------
say "Agent container image"
if [ -d "$CLONE_DIR/.git" ]; then
  info "Repo already at $CLONE_DIR - skipping clone."
else
  step "Cloning NanoClaw $NANOCLAW_REF into $CLONE_DIR"
  git clone --branch "$NANOCLAW_REF" "$REPO_URL" "$CLONE_DIR"
fi
cd "$CLONE_DIR"
step "Building the agent container image (Docker build, several minutes)"
./container/build.sh
disk

# --- Host deps + OneCLI/Postgres images --------------------------------------
say "Host dependencies + OneCLI/Postgres images"

step "Installing host dependencies (pnpm install)"
pnpm install

# Match the OneCLI gateway version NanoClaw pins (read from the pinned clone),
# so the pre-pulled image is the one the installer will expect.
ONECLI_VERSION="$(grep -m1 onecli-gateway versions.json | grep -oE '[0-9]+(\.[0-9]+)+')"
export ONECLI_VERSION
step "Pre-pulling OneCLI gateway $ONECLI_VERSION + Postgres images"
curl -fsSL onecli.sh/install | sh
disk

say "Pre-cache complete"
info "On the workshop day, run:  cd $CLONE_DIR && bash nanoclaw.sh"
info "At the OneCLI prompt, choose 'Use the existing instance'."
