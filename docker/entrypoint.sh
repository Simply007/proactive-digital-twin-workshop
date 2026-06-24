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
# host.docker.internal in spawned agent containers resolves to `host-gateway`,
# which Docker sets to the *default bridge* gateway. Docker auto-selects that
# subnet from its address pool — 172.17.0.0/16 if free on the host, otherwise
# 172.18.0.0/16, 172.19, … — so the gateway IP varies by machine (e.g. it is
# 172.18.0.1 when the outer Docker already occupies 172.17). Hardcoding it is
# the #1 silent DinD trap: a mismatch leaves agents hanging on "API retry"
# forever. So we READ it at runtime from the live default bridge instead.
# DOCKER_BRIDGE_IP overrides if you ever need to pin it by hand.
BRIDGE_IP="${DOCKER_BRIDGE_IP:-$(docker network inspect bridge \
    --format '{{(index .IPAM.Config 0).Gateway}}' 2>/dev/null)}"
BRIDGE_IP="${BRIDGE_IP:-172.17.0.1}"

log "starting socat bridges on ${BRIDGE_IP} for OneCLI ports"
nohup socat "TCP-LISTEN:10254,fork,reuseaddr,bind=${BRIDGE_IP}" TCP:127.0.0.1:10254 \
    > /var/log/socat-10254.log 2>&1 &
nohup socat "TCP-LISTEN:10255,fork,reuseaddr,bind=${BRIDGE_IP}" TCP:127.0.0.1:10255 \
    > /var/log/socat-10255.log 2>&1 &

log "sandbox ready — sleeping. To enter: docker exec -it -u nanoclaw -w /work agent-sandbox bash"
exec sleep infinity
