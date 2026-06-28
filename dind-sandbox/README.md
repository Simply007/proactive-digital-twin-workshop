# DinD Sandbox (presenter-only validation)

This folder is the **Docker-in-Docker (DinD) validation sandbox** for the "Beyond the Chatbot: Engineering Your Proactive Digital Twin" workshop. It is presenter-only infrastructure. Attendees never need it - they run the workshop inside an Ubuntu VM on their own laptop, where none of the DinD gotchas below exist. The sandbox exists so the presenter can test the full NanoClaw flow (install, Telegram pairing, ping/pong, the exercises) end to end without touching their host, and to keep the record of the hosting paths that were tried and rejected (Railway, Oracle Cloud). The kit bakes in every fix from `findings.md`, so a `docker compose up` here reproduces a working sandbox in one command.

For the Claude-guided version of this walkthrough, see `skills/dind-sandbox-walkthrough/SKILL.md`.

## The 4-step flow

```bash
docker compose up -d                              # 1. build + start the sandbox
docker compose exec -u nanoclaw sandbox bash      # 2. enter as nanoclaw @ /work
ls -al nanoclaw                                   # 3a. check first - does it already exist?
git clone https://github.com/nanocoai/nanoclaw.git && cd nanoclaw && bash nanoclaw.sh   # 3b. install
# 4. docker compose down   to stop (agent state in AGENT_WORKSPACE persists)
```

**Check before cloning.** `git clone` aborts with `destination path 'nanoclaw' already exists and is not an empty directory` when a prior install is still in `/work` (state persists across `compose down/up`). Run `ls -al nanoclaw` first: if it has a populated `.git` and a `.env`, it is a previous install - skip the clone, just `cd nanoclaw && bash nanoclaw.sh` to re-run the wizard (or `git pull` first to update).

Install notes for `bash nanoclaw.sh`:

- **Standard vs Advanced -> Standard.** Advanced only adds config that is not needed to reach ping/pong.
- Prompts, in order: **Claude sign-in**, a **timezone** (IANA, e.g. `Europe/Prague` - sets where the scheduled-brief exercise fires), **Telegram bot token**.
- The first agent image build is **~10-12 min under VFS** - expected, not a hang. Past ~15 min with no progress, check `docker exec agent-sandbox tail -20 /var/log/dockerd.log`.

## Starting the agent service

The container has no init system (no systemd/launchd), so NanoClaw's service never auto-starts on the **first** install: the installer reports "Couldn't reach the NanoClaw service", skips its ping test, and Telegram pairing cannot complete (nothing consumes the code). Start it from the host with `docker exec -d -u nanoclaw` (a new terminal):

```bash
docker exec -d -u nanoclaw agent-sandbox bash -c 'cd /work/nanoclaw && node dist/index.js >> logs/agent.log 2>&1'
docker exec agent-sandbox tail -n 15 /work/nanoclaw/logs/agent.log   # want: "NanoClaw running" + "Telegram polling started"
```

Use `-d` (detached): a plain `docker exec … 'node … &'` hangs on the inherited pipe and never returns. Use `-u nanoclaw` (uid 1000), **not root** (see below).

**Timing: start it after the Telegram bot token is entered, NOT before.** The service loads its channel adapters at startup, so starting it early (e.g. to make the ping pass) brings it up with no Telegram adapter - pairing then silently fails (no "Telegram polling started", the queue piles up). The right window is when the wizard sits at the pairing-code step ("Waiting for you to send the code") - the token is configured by then. If you started it too early, restart it (`docker exec -u nanoclaw agent-sandbox pkill -f dist/index.js`, then the `-d -u nanoclaw` start above) so it picks up the Telegram adapter. Then send the code and approve the "Connected to <agent>" card.

**Do not re-run the wizard with the service up** - the wizard starts its own poller and triggers a multi-poller race. Once the service runs, pairing and chat go through it directly.

### Run as nanoclaw (uid 1000), never root

The spawned agent containers run their agent-runner as `node` (uid 1000) and write session DBs (`inbound.db`/`outbound.db`), `groups/…/container.json`, and `/tmp/onecli-*.pem`. A root-run service creates those root-owned, so the uid-1000 agent cannot write them -> `attempt to write a readonly database` / `EACCES`, the agent crashes, no reply. (The old host bind mount masked this via permissive FUSE ownership; the ext4 named volume enforces real uid/perms.) If you ever ran the service as root and switched, fix the leftovers:

```bash
docker exec agent-sandbox chown -R nanoclaw:nanoclaw /work && docker exec agent-sandbox rm -f /tmp/onecli-*.pem
```

**Why root is used elsewhere, given the nanoclaw user?** The nanoclaw user makes the *install* faithful to attendees (NanoClaw's installer refuses root; real users are non-root + sudo), but install steps that touch `data/` and `logs/` run elevated (inner Docker, OneCLI), leaving those dirs root-owned. The service itself must therefore run as nanoclaw to write into them as uid 1000. This is a pure DinD artifact: on a real laptop the install, the init-started service, and data/logs are all owned by the same normal user, so none of this is needed.

### After `docker compose stop/start` - auto-restarts

After the initial install + first hand-start, **`stop`/`start` is fully automatic.** `entrypoint.sh` (a) clears the stale `docker.pid` before launching inner dockerd - `/var/run` is not tmpfs, so the old pidfile otherwise makes dockerd refuse to start and the container crash-loops (`restart: unless-stopped`); (b) auto-starts the service as nanoclaw if an install exists. Combined with node baked into the image and `/work` on a named volume (sockets on ext4 -> unlink works), `stop`/`start` brings back inner dockerd, the OneCLI gateway containers (`onecli` + `onecli-postgres-1`, which persist in the kept inner Docker), the agent images, and the service - the agent replies, no manual steps.

### `down`/`up`/`--build` does NOT fully survive

Recreating the container wipes the inner Docker's storage (`/var/lib/docker` is in the container layer, not `/work`) - the OneCLI gateway + vault secrets, the `onecli` binary, and agent images are gone -> `OneCLIError: fetch failed` -> **reinstall required**. `/work` (clone, DB, pairing) persists in the named volume. So restart with `stop`/`start`, not `down`/`up`, unless you intend to reinstall.

Iterating on `entrypoint.sh` without a rebuild/reinstall:

```bash
docker cp docker/entrypoint.sh agent-sandbox:/usr/local/bin/entrypoint.sh   # writes into the container layer, survives stop/start
```

### Verify reports `SERVICE: not_found` / `STATUS: failed` (false negative)

The wizard's final verify looks for a launchd/systemd service or a `nanoclaw.pid` file. A hand-started service has neither, so it reports `STATUS: failed`. This is cosmetic - if credentials/channel/groups are configured and Telegram chat works, everything is fine. To make verify report green, write the pid file (the `dist/index.js` node pid):

```bash
docker exec agent-sandbox sh -c 'for p in $(pgrep -f dist/index.js); do [ "$(cat /proc/$p/comm)" = node ] && echo $p > /work/nanoclaw/nanoclaw.pid; done'
```

The pid is per-run; rewrite it if the service restarts. Do not re-run the wizard just to re-verify (multi-poller race).

### Two separate Claude auths

Expect a `Claude CLI isn't signed in` prompt even though the vault shows configured. The OneCLI vault token (the agent's outbound `api.anthropic.com` calls) is **not** the local `claude` CLI sign-in (`~/.claude`), which setup/tooling invokes directly. Answer Yes and complete the browser OAuth (or `export CLAUDE_CODE_OAUTH_TOKEN=<token>`). Two different credential stores, both needed.

### Telegram queue note

`teardown.sh` does not clear Telegram's server-side message queue. Reusing an old bot may need a flush from a browser before pairing, or the service consumes a backlog of stale DMs on first poll:

```
https://api.telegram.org/bot<TOKEN>/deleteWebhook?drop_pending_updates=true
```

## Resetting the sandbox

`scripts/teardown.sh` returns the DinD sandbox to a completely fresh state. It prompts for `yes` on **each** step independently (container + volume / sandbox image), so you can drop only what you want. `-y` runs all steps unattended. It reads `SANDBOX_CONTAINER` from `.env` before removing anything, and refuses to `rm` an unsafe path.

```bash
./scripts/teardown.sh        # confirm each step
./scripts/teardown.sh -y     # nuke everything, no prompts
docker compose up -d         # rebuild fresh from the Dockerfile
```

## DinD gotchas

These hit only the presenter validating in this sandbox. Attendees on laptop Docker do not see them. See `findings.md` for full reproduction details.

1. NanoClaw requires Debian/Ubuntu - Alpine `docker:dind` is rejected by NodeSource's setup script.
2. `$USER` env var is unset in `docker exec` sessions - `ENV USER=nanoclaw` is baked into the image; enter via `docker compose exec -u nanoclaw sandbox bash`.
3. No systemd inside the container - the agent service will not auto-start on first install; start it manually (see "Starting the agent service").
4. Overlay-on-overlay storage driver failure - pre-configured VFS in the Dockerfile.
5. VFS makes the first agent image build slow (~10-12 min vs ~3-4 min on real overlay2). One-time cost.
6. OneCLI cannot auto-detect a bind address inside an unprivileged container - `ONECLI_BIND_HOST=127.0.0.1` is baked in.
7. NanoClaw pairing codes expire fast; if the agent service is not running when the user sends the code, the queue swallows old codes. Drain the Telegram queue with `getUpdates?offset=-1` before retrying.
8. Spawned agent containers cannot reach OneCLI by default - socat bridges in the entrypoint solve this.
9. OneCLI URLs in agent replies use `127.0.0.1` - the published port in `docker-compose.yml` makes the URL work directly in the host browser.

## More

- [`findings.md`](findings.md) - full reproduction of the 9 DinD gotchas plus the Railway and Oracle Cloud rejection log.
- [`architecture.md`](architecture.md) - what the sandbox runs and why each piece exists.
- [`../workshop/providers.md`](../workshop/providers.md) - host/VPS provider comparison (general deployment reference, not DinD-specific).
- [`skills/dind-sandbox-walkthrough/SKILL.md`](skills/dind-sandbox-walkthrough/SKILL.md) - the Claude-guided walkthrough of this same flow.
