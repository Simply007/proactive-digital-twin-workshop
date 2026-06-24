#!/usr/bin/env bash
# Sandbox entrypoint.
#
# Starts the inner Docker daemon and the socat bridges that let spawned agent
# containers reach OneCLI (which binds to the sandbox's loopback). Then sleeps
# forever so the container stays up for `docker exec` sessions.

set -euo pipefail

log() { printf '[entrypoint] %s\n' "$*"; }

# ─── start inner dockerd ───────────────────────────────────────────────────
log "starting inner dockerd"
nohup dockerd > /var/log/dockerd.log 2>&1 &

# Wait for dockerd to accept connections (up to 30s).
for i in $(seq 1 30); do
  if docker info >/dev/null 2>&1; then
    log "inner dockerd ready (took ${i}s)"
    break
  fi
  sleep 1
done

if ! docker info >/dev/null 2>&1; then
  log "ERROR: inner dockerd did not come up. Last 30 lines of dockerd log:"
  tail -30 /var/log/dockerd.log || true
  exit 1
fi

# ─── socat bridges: 172.18.0.1 → 127.0.0.1 for OneCLI ──────────────────────
# Spawned agent containers reach OneCLI via host.docker.internal:1025x,
# which resolves to the inner bridge gateway (172.18.0.1) inside the inner
# Docker. OneCLI itself binds to the sandbox's 127.0.0.1, unreachable from
# the bridge. socat bridges the gap.
#
# We bind on 172.18.0.1 — the default inner bridge gateway. If the inner
# Docker has assigned a different bridge subnet, adjust DOCKER_BRIDGE_IP.
BRIDGE_IP="${DOCKER_BRIDGE_IP:-172.18.0.1}"

log "starting socat bridges on ${BRIDGE_IP} for OneCLI ports"
nohup socat "TCP-LISTEN:10254,fork,reuseaddr,bind=${BRIDGE_IP}" TCP:127.0.0.1:10254 \
    > /var/log/socat-10254.log 2>&1 &
nohup socat "TCP-LISTEN:10255,fork,reuseaddr,bind=${BRIDGE_IP}" TCP:127.0.0.1:10255 \
    > /var/log/socat-10255.log 2>&1 &

log "sandbox ready — sleeping. To enter: docker exec -it -u nanoclaw -w /work agent-sandbox bash"
exec sleep infinity
