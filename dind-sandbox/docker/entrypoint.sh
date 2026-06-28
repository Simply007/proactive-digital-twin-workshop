#!/usr/bin/env bash
# Sandbox entrypoint.
#
# Starts the inner Docker daemon and the socat bridges that let spawned agent
# containers reach OneCLI (which binds to the sandbox's loopback). Then sleeps
# forever so the container stays up for `docker exec` sessions.

set -euo pipefail

log() { printf '[entrypoint] %s\n' "$*"; }

# ─── start inner dockerd ───────────────────────────────────────────────────
# Clear stale runtime state from a previous run. /var/run isn't a tmpfs here, so
# after `docker compose stop/start` the old dockerd pidfile persists and the new
# dockerd refuses to start ("delete /var/run/docker.pid: process ... still
# running") — an infinite restart loop. Remove the stale pidfile (and socket)
# before launching. Safe: a fresh container has none, and nothing else is using
# them at entrypoint time.
log "clearing stale dockerd runtime state"
rm -f /var/run/docker.pid /run/docker.pid /var/run/docker.sock

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

# ─── auto-start the NanoClaw service if it's already installed ──────────────
# On the FIRST `up`, NanoClaw isn't installed yet (the user clones + runs
# nanoclaw.sh afterward), so this is skipped. On every later `stop/start` (or
# `down/up`) it brings the agent back automatically — no manual restart needed.
#
# IMPORTANT: run the service as the `nanoclaw` user (uid 1000), NOT root. The
# spawned agent containers run their agent-runner as `node` (uid 1000) and write
# their session DBs (inbound.db/outbound.db) in DATA_DIR. If the service ran as
# root it would create those files (and groups/, /tmp/onecli-*.pem) root-owned,
# and the uid-1000 agent containers couldn't write them ("attempt to write a
# readonly database"). The named volume's /work is uid-1000-owned, so nanoclaw
# can create sockets/DBs there; nanoclaw is in the docker group, so it can spawn
# agent containers. Keeping everything uid 1000 mirrors a real laptop install.
# (`;` not `&&` after cd so the cd runs in the foreground and `echo $!` writes
# nanoclaw.pid in the right dir with node's real pid.)
if [ -f /work/nanoclaw/dist/index.js ]; then
  log "found NanoClaw install — starting the agent service as nanoclaw"
  runuser -u nanoclaw -- bash -c \
    'cd /work/nanoclaw; nohup node dist/index.js >> logs/agent.log 2>&1 & echo $! > nanoclaw.pid'
else
  log "no NanoClaw install yet — skipping service start (run nanoclaw.sh, then hand-start once)"
fi

log "sandbox ready — sleeping. To enter: docker exec -it -u nanoclaw -w /work agent-sandbox bash"
exec sleep infinity
