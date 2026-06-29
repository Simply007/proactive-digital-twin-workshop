#!/usr/bin/env bash
#
# NanoClaw workshop prepare (guided pre-cache)
# --------------------------------------------
# Run this INSIDE your Ubuntu VM, at home on good WiFi, so the workshop-day
# install pulls little or nothing over the conference network.
#
#   sudo apt-get update && sudo apt-get install -y curl ca-certificates && \
#     curl -fsSL https://raw.githubusercontent.com/Simply007/proactive-digital-twin-workshop/main/scripts/prepare.sh | bash
#   # or, from a clone of this kit:  bash scripts/prepare.sh
#
# It asks which stage you want to reach and walks you through it, prompting
# before each heavy download. Re-running is safe - already-done steps are
# skipped. The clone is pinned to NANOCLAW_REF so what you pre-build at home is
# exactly what you install on the day (no drift if NanoClaw ships an update).

set -euo pipefail

NANOCLAW_REF="v2.1.17"
REPO_URL="https://github.com/nanocoai/nanoclaw.git"
CLONE_DIR="${NANOCLAW_DIR:-$HOME/nanoclaw}"   # use this SAME dir on the day

say()  { printf '\n=== %s ===\n' "$*"; }
info() { printf '    %s\n' "$*"; }
step() { printf '\n--> %s\n' "$*"; }
disk() { printf '    [disk] %s used on /\n' "$(df -h --output=used / | tail -1 | tr -d ' ')"; }

cat <<'INTRO'

NanoClaw workshop pre-cache
===========================
Pulls the heavy, unchanging parts of the install now (at home) so the
workshop-day install runs from a warm cache.

  Stage 2  Host packages (Docker, Node, pnpm) + base image, no repo clone.
           Leaves ~1.1-2.0 GB for the day.
  Stage 3  + clone (pinned) + pre-build the agent container image.
           Leaves ~0.45-0.8 GB for the day.
  Stage 4  + host deps + OneCLI/Postgres images.
           Leaves ~0 for the day (only credentials + Telegram pairing).

Each stage includes the ones before it.
INTRO

# Prompt the terminal directly (works even when piped via curl|bash, where
# stdin is the download pipe). Writing to /dev/tty keeps the prompt visible.
STAGE=""
if [ -e /dev/tty ]; then
  printf 'Which stage do you want to reach? [2/3/4] (default 4): ' > /dev/tty
  IFS= read -r STAGE < /dev/tty || STAGE=""
fi
STAGE="${STAGE:-4}"
case "$STAGE" in 2|3|4) ;; *) echo "Please pick 2, 3, or 4."; exit 2 ;; esac
info "Reaching Stage $STAGE."
disk

# --- Stage 2: host toolchain + base image ------------------------------------
say "Stage 2: host packages (Docker, Node 22, pnpm) + base image"
info "Installs Docker, Node 22, pnpm, then pulls the node:22-slim base image."

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

# The docker group must be active in this shell to reach the daemon.
if ! docker info >/dev/null 2>&1; then
  say "Reboot needed"
  info "Docker is installed, but this shell isn't in the 'docker' group yet."
  info "Reboot the VM (or log out and back in), then run this script again."
  info "(Quick alternative for this shell only: run 'newgrp docker', then re-run.)"
  exit 0
fi

step "Pulling the node:22-slim base image"
docker pull node:22-slim
disk

if [ "$STAGE" -lt 3 ]; then
  say "Stage 2 done"
  info "On the workshop day, run:"
  info "  git clone --branch $NANOCLAW_REF $REPO_URL && cd nanoclaw && bash nanoclaw.sh"
  exit 0
fi

# --- Stage 3: clone (pinned) + pre-build the agent image ---------------------
say "Stage 3: clone $NANOCLAW_REF and pre-build the agent container image"
info "Downloads ~0.6-1 GB (Chromium + claude-code + Bun) and takes several minutes."

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

if [ "$STAGE" -lt 4 ]; then
  say "Stage 3 done"
  info "On the workshop day, run:  cd $CLONE_DIR && bash nanoclaw.sh"
  exit 0
fi

# --- Stage 4: host deps + OneCLI/Postgres images -----------------------------
say "Stage 4: host dependencies + OneCLI/Postgres images"
info "Installs host node_modules and pre-pulls the OneCLI + Postgres images."

step "Installing host dependencies (pnpm install)"
pnpm install

# Match the OneCLI gateway version NanoClaw pins (read from the pinned clone),
# so the pre-pulled image is the one the installer will expect.
ONECLI_VERSION="$(grep -m1 onecli-gateway versions.json | grep -oE '[0-9]+(\.[0-9]+)+')"
export ONECLI_VERSION
step "Pre-pulling OneCLI gateway $ONECLI_VERSION + Postgres images"
curl -fsSL onecli.sh/install | sh
disk

say "Stage 4 done"
info "On the workshop day, run:  cd $CLONE_DIR && bash nanoclaw.sh"
info "At the OneCLI prompt, choose 'Use the existing instance'."
