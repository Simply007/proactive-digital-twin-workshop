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
# What's NOT baked in: the agent framework itself (NanoClaw / OpenClaw / etc.).
# That's installed at first run via scripts/install-agent.sh, mounted at /work.
# Keeps the image provider-agnostic.

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

# /work is the bind mount target for the host's agent workspace.
RUN mkdir -p /work && chown -R nanoclaw:nanoclaw /work
WORKDIR /work

# In-container helper scripts: install-agent.sh + start-agent.sh.
# Available as /opt/scripts/install-agent.sh once the container is running.
COPY scripts/install-agent.sh scripts/start-agent.sh /opt/scripts/
RUN chmod +x /opt/scripts/*.sh

# Entrypoint starts inner dockerd + the socat bridges, then sleeps so the
# container stays up for `docker exec` shells.
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
