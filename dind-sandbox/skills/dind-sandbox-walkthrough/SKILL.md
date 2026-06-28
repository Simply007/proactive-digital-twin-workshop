---
name: dind-sandbox-walkthrough
description: Use when running or validating the Proactive Digital Twin workshop in its Docker-in-Docker sandbox (the `docker compose up` in this repo) — building the sandbox, entering it, installing NanoClaw, pairing Telegram, getting ping/pong, then the exercises. Covers DinD-only gotchas (VFS slow build, host.docker.internal gateway, "API retry" hangs, Telegram pairing race, two-surface Claude auth) that do NOT appear on attendee laptop Docker.
---

# DinD Sandbox Walkthrough

## Overview

Guide a person through the **4-step flow** in [`../README.md`](../README.md) inside this repo's Docker-in-Docker sandbox (the presenter-validation path). The kit bakes in the fixes from [`../../findings.md`](../../findings.md); your job is to verify each layer came up clean, flag the DinD-only gotchas as **expected vs. real**, and stop at ping/pong to ask how they want to continue.

**This is the DinD path, NOT the attendee VM/laptop.** On a clean VM or laptop Docker the gotchas below don't exist - point those users at the root [`../../README.md`](../../README.md) and the `workshop-walkthrough` skill directly.

## When to Use

- "I'm going through the scenario / `docker compose up` here"
- An agent container hangs on `Error: API retry (retryable: true)`
- Telegram won't pair (`Pairing NNNN disappeared`, codes rotating, code never lands)

## The flow (matches [`../README.md`](../README.md))

```bash
docker compose up -d                              # 1. build + start the sandbox
docker compose exec -u nanoclaw sandbox bash      # 2. enter as nanoclaw @ /work
ls -al nanoclaw                                   # 3a. check first — does it already exist?
git clone https://github.com/nanocoai/nanoclaw.git && cd nanoclaw && bash nanoclaw.sh   # 3b. install
# 4. docker compose down   to stop (agent state in AGENT_WORKSPACE persists)
```

**Check before cloning.** `git clone` aborts with `destination path 'nanoclaw' already exists and is not an empty directory` when a prior install is still in `/work` (state persists across `compose down/up`). Run `ls -al nanoclaw` first: if it has a populated `.git` and a `.env`, it's a previous install — **skip the clone**, just `cd nanoclaw && bash nanoclaw.sh` to re-run the wizard (or `git pull` first to update).

## What's baked in vs. what to watch

| Gotcha (`findings.md` #) | Status |
|---|---|
| 1 Debian-only host | ✅ Ubuntu base |
| 2 `$USER` unset | ✅ `ENV USER=nanoclaw` baked in; enter with `-u nanoclaw` |
| 4 overlay-on-overlay | ✅ VFS in `daemon.json` |
| 6 OneCLI bind | ✅ `ONECLI_BIND_HOST=127.0.0.1` baked in |
| 8 agent→OneCLI bridge | ✅ socat auto-starts, gateway IP read at runtime — verify if agents hang |
| 9 OneCLI URL `127.0.0.1` | ✅ ports published to host |
| 3 no systemd | ⚠️ on **initial** install the service won't auto-start — hand-start it as root *before* pairing can finish (see "Start the agent service"). After that, `entrypoint.sh` auto-starts it on every `compose stop/start` / `down/up` (needs baked node + named-volume `/work`, both in this kit). |
| 5 VFS slow build | ⚠️ first agent image build **~10-12 min** — not a hang |
| 7 Telegram pairing | ⚠️ fragile in DinD — see below |

## Verify the sandbox before installing

```bash
docker exec agent-sandbox docker info --format 'driver={{.Driver}}'    # want: vfs
docker exec agent-sandbox sh -c 'pgrep -a socat'                       # want: two procs
# the #1 silent trap: socat bind IP must equal the live default-bridge gateway
docker exec agent-sandbox docker network inspect bridge --format '{{(index .IPAM.Config 0).Gateway}}'
```
The gateway is auto-assigned by Docker (`172.17.0.1` if free, else `172.18.0.1`, …), so it varies per machine — the entrypoint reads it at runtime. If an agent later hangs on `API retry`, that's gotcha 8: recheck socat bind == gateway (`DOCKER_BRIDGE_IP` overrides).

## Install notes (`bash nanoclaw.sh`)

- **Standard vs Advanced → Standard.** Advanced only adds config that isn't needed to reach ping/pong.
- Prompts, in order: **Claude sign-in**, a **timezone** (IANA, e.g. `Europe/Prague` — sets where the Ex 4 09:00 brief fires), **Telegram bot token**.
- First agent image build is **~10-12 min under VFS** — expected. Past ~15 min with no progress, check `docker exec agent-sandbox tail -20 /var/log/dockerd.log`.
- **Two separate Claude auths.** The token saved to the **OneCLI vault** (agent's `api.anthropic.com` calls) is NOT the local **`claude` CLI sign-in** (`~/.claude`). If it prompts `Claude CLI isn't signed in`, complete that too (browser OAuth) or `export CLAUDE_CODE_OAUTH_TOKEN=<token>`. Manage/revoke the subscription token at <https://claude.ai/new#settings/claude-code> → **Authorization tokens**.
- **No systemd → you must hand-start the service.** See the next section — in DinD this is **required, every run**, not just after a restart.

## Start the agent service (DinD: required, before pairing can finish)

**This is normal DinD flow, not something the user broke.** The wizard tries to start the service via `launchctl`/`systemctl`; neither exists in the container, so the service never comes up on its own. Consequences, all expected:

- The wizard's **own ping test is skipped** — `Couldn't reach the NanoClaw service` / `isn't listening on its local socket`. Its suggested `systemctl --user restart …` / `launchctl kickstart …` **cannot work here** — ignore it.
- **Pairing cannot complete** until the service runs: the agent service is the only thing that *consumes* the Telegram message and matches the code. Until it's up, the code sits unconsumed (`telegram-pairings.json` stays `status: pending`; `getWebhookInfo` shows `pending_update_count > 0` with **no 409** and no `dist/index.js` process — that combination means "no consumer," not the multi-poller race).
- `pnpm run chat hi` also fails (`daemon not reachable at …/data/cli.sock`) for the same reason — symptom, not cause.

**Start it with `docker exec -d -u nanoclaw`** from the host (a new terminal). Use `-d` (detached) — a plain `docker exec … 'node … &'` *hangs the call*, because the backgrounded node inherits the exec's pipe and the exec never returns. Use `-u nanoclaw` (uid 1000) — **not root** — so the session DBs and `groups/` it creates are uid-1000-owned, matching the agent containers' `node` user (root-owned files cause `attempt to write a readonly database` in the agent). The named volume's `/work` is uid-1000-owned, so nanoclaw can create the sockets/DBs:

```bash
docker exec -d -u nanoclaw agent-sandbox bash -c 'cd /work/nanoclaw && node dist/index.js >> logs/agent.log 2>&1'   # start (detached, as nanoclaw)
docker exec agent-sandbox tail -n 15 /work/nanoclaw/logs/agent.log                                                  # check: want "NanoClaw running" + "Telegram polling started"
```

**Timing matters — start it AFTER the Telegram bot token is entered, NOT before.** The service loads its channel adapters *at startup* from the config that exists then. If you start it earlier (e.g. before the first-chat ping, to make the ping pass), it comes up with **no Telegram adapter** — it handles CLI/ping fine but never polls Telegram, so pairing silently fails: the code piles up unconsumed (`pending_update_count` climbs, no `Telegram polling started` in the log). The right window is when the wizard sits at **"Waiting for you to send the code"** — the token is configured by then. If you *did* start it too early, just **restart it** (`docker exec -u nanoclaw agent-sandbox pkill -f dist/index.js`, then the `-d -u nanoclaw` start above) so it picks up the Telegram adapter; confirm `Telegram polling started` appears.

**Do NOT re-run `bash nanoclaw.sh` with the service up** — the wizard's `setup:auto` starts its own poller and triggers the multi-generator race (see Telegram pairing below). Once the service runs you don't need the wizard; pairing + chat go through the service directly. After `compose stop/start`, `entrypoint.sh` auto-starts it (as nanoclaw); you only hand-start during the initial install.

**Run as `nanoclaw` (uid 1000), never root — this is the subtle one.** The spawned agent containers run their agent-runner as `node` (uid 1000) and write their session DBs (`inbound.db`/`outbound.db` under `DATA_DIR/v2-sessions/…`) plus `groups/…/container.json` and `/tmp/onecli-*.pem`. If the service runs as **root**, it creates all those root-owned, and the uid-1000 agent containers can't write them → `Fatal error: attempt to write a readonly database` / `EACCES`, so the agent crashes and never replies. (The old host bind mount *masked* this — Docker Desktop's FUSE made everything appear writable; the ext4 named volume enforces real uid/perms.) The named volume's `/work` is uid-1000-owned, so nanoclaw can create sockets/DBs there, and nanoclaw is in the `docker` group so it can spawn agent containers. Keep **everything** uid 1000 — it also matches how a real laptop runs (one user throughout). If you ever started the service as root and switched, fix the leftovers: `docker exec agent-sandbox chown -R nanoclaw:nanoclaw /work && docker exec agent-sandbox rm -f /tmp/onecli-*.pem`, then restart as nanoclaw.

The moment it starts polling it drains the queued code: `Pairing consumed code="NNNN"` → `Telegram pairing accepted — chat registered … promotedToOwner=true`. (The `Failed to chmod … ncl.sock EINVAL` warning is harmless — bind mount, "continuing".)

Then there's **one more Telegram step**: the bot shows a `💬 New direct message` / channel-registration card asking how to handle the DM. Tap the option that connects the chat to the existing agent group (e.g. **"Connected to Terminal Agent"**), *not* Ignore. Log confirms `Channel registration approved — wiring created`, then `Message routed … agentGroupName="Terminal Agent"` → `Message delivered … channelType="telegram"` = ping/pong.

**Reality check:** none of this happens on attendee laptop Docker — launchd/systemd starts the service automatically, the wizard's ping test passes inline, and pairing + first chat complete inside the wizard. It's purely a DinD artifact.

### After `docker compose stop/start` (or `down/up`) — auto-restarts

After the **initial** install + first hand-start, **`stop`/`start` is fully automatic**. Four pieces make this work, all in this kit:

1. **Node is baked into the image** (`docker/Dockerfile`, NodeSource node 22) — so it survives container recreation, which would otherwise wipe the node runtime (NanoClaw installs it into the container layer).
2. **`/work` is a Docker named volume, not a host bind mount** (`docker-compose.yml`). The agent's unix sockets (`data/cli.sock`, `data/ncl.sock`) live under `DATA_DIR` (= project root, not env-configurable). Docker Desktop's **macOS bind mount returns `ENOTSUP` on `unlink` of socket files** — even root `rm`/`ls` fail — so on the bind mount the service could never rebind on restart (`listen ENOTSUP`). The named volume lives on the Docker VM's ext4, where socket unlink works, so NanoClaw's startup socket-cleanup succeeds and it rebinds cleanly.
3. **`entrypoint.sh` clears the stale `docker.pid` before starting inner dockerd.** `/var/run` isn't a tmpfs here, so after `stop`/`start` the previous dockerd's pidfile persists and the new dockerd refuses to start (`delete /var/run/docker.pid: process … still running`) → the entrypoint exits → `restart: unless-stopped` **crash-loops forever**. The `rm -f /var/run/docker.pid /run/docker.pid /var/run/docker.sock` fixes it.
4. **`entrypoint.sh` auto-starts the service** (as `nanoclaw`) if `/work/nanoclaw/dist/index.js` exists, and writes the node pid to `nanoclaw.pid`.

On `stop`/`start` the inner Docker is **kept**, so the OneCLI gateway containers (`onecli` + `onecli-postgres-1`, `restart: unless-stopped`) and the built agent images all come back on their own once dockerd starts — the agent replies fast.

**`down`/`up`/`--build` is a different story — it does NOT fully survive.** Recreating the container wipes the **inner Docker's storage** (`/var/lib/docker` is in the container layer, not `/work`): the **OneCLI gateway + its vault secrets**, the `onecli` binary, and all agent images are gone → the service comes up but hits `OneCLIError: fetch failed`, and you must **reinstall**. `/work` (clone, DB, pairing, agent groups) still persists in the named volume. Making `down/up` non-destructive would require putting `/var/lib/docker` on its own volume too (deferred — VFS storage is large/slow). **So: restart with `stop`/`start`, never `down`/`up`, unless you intend to reinstall.** (Iterating on `entrypoint.sh`? `docker cp docker/entrypoint.sh agent-sandbox:/usr/local/bin/entrypoint.sh` writes it into the container layer — survives `stop`/`start`, no rebuild/reinstall.)

## Telegram pairing in DinD (the hard part)

DinD makes pairing fragile because the codes are managed in a local DB and any second process clobbers them. Symptoms and real causes:

- **`Pairing NNNN disappeared` / codes rotate every few seconds** → more than one pairing-code *generator*. The `setup:auto` flow starts the agent service *before* pairing, and the running `dist/index.js` (or a second setup run) supersedes the wizard's code. **Fix: one generator only** — stop the service and any other setup/pairing process, run a single pairing, send the code promptly. Check with `pgrep -af 'dist/index.js'` and `pgrep -af 'pair-telegram'`.
- **Code sent but nothing happens** (message sits unconsumed) → three sub-cases, distinguish them:
  - **No consumer at all** (most common here): `getWebhookInfo` shows `pending_update_count > 0`, a manual `getUpdates` returns the message with **no 409**, and **no `dist/index.js` is running**. The agent service simply isn't up — see "Start the agent service". Flushing the queue won't help; starting the service drains it instantly.
  - **Two `getUpdates` consumers** → 409 conflict, neither drains. Confirm exactly one poller (`pgrep -af 'dist/index.js'`).
  - **Stale queue** → flush from a browser: `https://api.telegram.org/bot<TOKEN>/deleteWebhook?drop_pending_updates=true`. **Teardown does NOT clear this** — `teardown.sh` wipes local state, but old codes/messages from a prior install linger in Telegram's *server-side* queue (reusing the same bot token). On a fresh install with an old bot, flush before pairing, or the service will consume a backlog of stale DMs on first poll.
- **Wrong bot** → confirm you're DMing the exact bot whose token the wizard holds (`https://api.telegram.org/bot<TOKEN>/getMe`); revoke churn leaves stale tokens. `pending_update_count > 0` from `getWebhookInfo` proves messages are arriving at the right bot.
- Once it lands, the pairing record persists in `/work`, so it survives `compose stop/start`.
- **Reality check:** this fragility is a DinD artifact (matches `findings.md`'s "DinD is presenter-only"). On real laptop Docker the wizard pairs cleanly.

## Setup verification reports `SERVICE: not_found` / `STATUS: failed` (false negative)

The wizard's final verify (`setup/verify.ts`) detects the service three ways: `launchctl list` (macOS), `systemctl is-active` (Linux), then a fallback **`nanoclaw.pid` file** in the project root. In DinD all three miss a hand-started service (no init system; our `node dist/index.js` writes no pid file), so it logs `Service status service="not_found"` → `STATUS: failed`. **It's cosmetic** — if `CREDENTIALS: configured`, `CHANNEL_AUTH … configured`, `REGISTERED_GROUPS: 1`, and you can chat over Telegram, everything works.

To make verify report green, give it the pid file (single line, the `dist/index.js` node pid):

```bash
docker exec agent-sandbox sh -c 'for p in $(pgrep -f dist/index.js); do [ "$(cat /proc/$p/comm)" = node ] && echo $p > /work/nanoclaw/nanoclaw.pid; done; cat /work/nanoclaw/nanoclaw.pid'
```

Note the pid is per-run — it goes stale if the service restarts (rewrite it then). Don't re-run `bash nanoclaw.sh` just to re-verify (multi-poller race); verify is cosmetic.

## Two separate Claude auths (the `Claude CLI isn't signed in` prompt)

Saving the subscription token to the **OneCLI vault** (`claude setup-token` → "Anthropic", `api.anthropic.com`) only covers the **agent's outbound API calls**. It does **not** sign in the local **`claude` CLI** (`~/.claude`), which setup/tooling invokes directly. So the wizard can show `CREDENTIALS: configured` *and* still prompt `Claude CLI isn't signed in` — answer **Yes** and complete the browser OAuth (or `export CLAUDE_CODE_OAUTH_TOKEN=<token>`). Two different credential stores, both needed.

## Checkpoint — after ping/pong works, STOP and ask

Do not auto-continue into the exercises. Ask:

> ✅ Ping/pong works. Want me to keep guiding you through the exercises (Living Files → research swap → scheduled brief, in [`../../../workshop/outline.md`](../../../workshop/outline.md)), or take it from here?

## References

- [`../README.md`](../README.md) — the canonical 4-step flow + sandbox operations.
- [`../../findings.md`](../../findings.md) — full reproduction of the 9 DinD gotchas.
- [`../../../workshop/outline.md`](../../../workshop/outline.md) — the exercise walkthrough (Ex 1-4).
- [`../../docker/entrypoint.sh`](../../docker/entrypoint.sh) — dockerd + the runtime-read socat bridges.
