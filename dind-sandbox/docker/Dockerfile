# Sandbox image for the Proactive Digital Twin workshop.
#
# Bakes in every fix discovered during the 2026-06-09/10 dry runs so a fresh
# attendee gets a working sandbox in one `docker compose up`:
#   - Ubuntu 22.04 base via buildpack-deps:jammy-curl (git+curl+ca-certs pre-installed)
#   - sudo + socat pre-installed (the gotcha that bites bare ubuntu:22.04)
#   - Docker engine inside (for the inner container-per-agent model)
#   - VFS storage driver pre-configured (overlay-on-overlay fails on Docker Desktop)
#   - ONECLI_BIND_HOST=127.0.0.1 baked into /etc/environment AND /etc/bash.bashrc
#     so any process started later inherits it
#   - nanoclaw user with passwordless sudo + docker group
#
# What's NOT baked in: NanoClaw itself. It's installed at first run by cloning
# NanoClaw into /work and running `bash nanoclaw.sh`.

FROM buildpack-deps:jammy-curl

ENV DEBIAN_FRONTEND=noninteractive

# Sandbox prereqs (sudo: required by the agent's setup script; socat: bridges
# OneCLI's host-loopback to the inner Docker bridge so spawned agent containers
# can reach it).
RUN apt-get update \
 && apt-get install -y --no-install-recommends sudo socat \
 && rm -rf /var/lib/apt/lists/*

# Docker engine inside (DinD-style; runs with --privileged via compose).
RUN curl -fsSL https://get.docker.com | sh

# Node 22 baked in (matches NanoClaw's .nvmrc). NanoClaw's setup/install-node.sh
# would install this via NodeSource into the container's writable layer — which
# is wiped on every container recreate (down/up/--build), taking the node
# runtime with it and leaving the /work install unrunnable. Baking it into the
# image makes node survive any restart, lets entrypoint.sh auto-start the agent
# service afterward, and speeds first install (the installer detects node 22 and
# skips). Same "bake the fix in" rationale as sudo/socat above.
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
 && apt-get install -y --no-install-recommends nodejs \
 && rm -rf /var/lib/apt/lists/*

# Force VFS storage driver. Real hosts use overlay2, but Docker Desktop's
# storage is already overlay2 and nesting it inside our container fails on
# BuildKit cache mounts. VFS is slower but always works.
RUN mkdir -p /etc/docker \
 && echo '{"storage-driver":"vfs"}' > /etc/docker/daemon.json

# Bake the OneCLI bind host into both PAM (/etc/environment, picked up by
# login shells) and bash's system rc (/etc/bash.bashrc, picked up by every
# `docker exec -it bash` even though it's a non-login shell). Belt + suspenders
# because docker exec bypasses PAM.
RUN echo 'ONECLI_BIND_HOST=127.0.0.1' >> /etc/environment \
 && echo 'export ONECLI_BIND_HOST=127.0.0.1' >> /etc/bash.bashrc

# Non-root nanoclaw user with passwordless sudo + docker group. NanoClaw's
# installer refuses to run as root (or prompts to create a user); attendees
# on real cloud Ubuntu images would also be non-root from SSH login.
RUN useradd -m -s /bin/bash nanoclaw \
 && usermod -aG sudo,docker nanoclaw \
 && echo 'nanoclaw ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/nanoclaw \
 && chmod 0440 /etc/sudoers.d/nanoclaw

# Bake USER=nanoclaw so `docker compose exec -u nanoclaw sandbox bash` lands with
# $USER set (NanoClaw's installer dies on an unset $USER). The container itself
# still starts as root for dockerd; this only affects exec shells.
ENV USER=nanoclaw

# /work is the bind mount target for the host's agent workspace.
RUN mkdir -p /work && chown -R nanoclaw:nanoclaw /work
WORKDIR /work

# Entrypoint starts inner dockerd + the socat bridges, then sleeps so the
# container stays up for `docker exec` shells.
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
