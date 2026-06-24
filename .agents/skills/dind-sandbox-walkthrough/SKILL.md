---
name: dind-sandbox-walkthrough
description: Use when running or validating the Proactive Digital Twin workshop in its Docker-in-Docker sandbox (the `docker compose up` in this repo) — building the sandbox, entering it, installing NanoClaw, pairing Telegram, getting ping/pong, then the exercises. Covers DinD-only gotchas (VFS slow build, host.docker.internal gateway, "API retry" hangs, Telegram pairing race, two-surface Claude auth) that do NOT appear on attendee laptop Docker.
---

# DinD Sandbox Walkthrough

## Overview

Guide a person through the **README's 4-step flow** inside this repo's Docker-in-Docker sandbox (the presenter-validation path). The kit bakes in the fixes from `workshop/findings.md`; your job is to verify each layer came up clean, flag the DinD-only gotchas as **expected vs. real**, and stop at ping/pong to ask how they want to continue.

**This is the DinD path, NOT attendee laptop Docker.** On clean laptop Docker the gotchas below don't exist — point laptop users at `README.md` directly.

## When to Use

- "I'm going through the scenario / `docker compose up` here"
- An agent container hangs on `Error: API retry (retryable: true)`
- Telegram won't pair (`Pairing NNNN disappeared`, codes rotating, code never lands)

## The flow (matches README.md)

```bash
docker compose up -d                              # 1. build + start the sandbox
docker compose exec -u nanoclaw sandbox bash      # 2. enter as nanoclaw @ /work
git clone https://github.com/nanocoai/nanoclaw.git && cd nanoclaw && bash nanoclaw.sh   # 3. install
# 4. docker compose down   to stop (agent state in AGENT_WORKSPACE persists)
```

## What's baked in vs. what to watch

| Gotcha (`findings.md` #) | Status |
|---|---|
| 1 Debian-only host | ✅ Ubuntu base |
| 2 `$USER` unset | ✅ `ENV USER=nanoclaw` baked in; enter with `-u nanoclaw` |
| 4 overlay-on-overlay | ✅ VFS in `daemon.json` |
| 6 OneCLI bind | ✅ `ONECLI_BIND_HOST=127.0.0.1` baked in |
| 8 agent→OneCLI bridge | ✅ socat auto-starts, gateway IP read at runtime — verify if agents hang |
| 9 OneCLI URL `127.0.0.1` | ✅ ports published to host |
| 3 no systemd | ⚠️ after `compose stop/start`, restart the agent by hand |
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
- **No systemd:** the wizard tries to start the service via `launchctl`/`systemctl` and fails here (`Couldn't reach the NanoClaw service`). Start it by hand: `cd /work/nanoclaw && nohup node dist/index.js > logs/agent.log 2>&1 &`.

## Telegram pairing in DinD (the hard part)

DinD makes pairing fragile because the codes are managed in a local DB and any second process clobbers them. Symptoms and real causes:

- **`Pairing NNNN disappeared` / codes rotate every few seconds** → more than one pairing-code *generator*. The `setup:auto` flow starts the agent service *before* pairing, and the running `dist/index.js` (or a second setup run) supersedes the wizard's code. **Fix: one generator only** — stop the service and any other setup/pairing process, run a single pairing, send the code promptly. Check with `pgrep -af 'dist/index.js'` and `pgrep -af 'pair-telegram'`.
- **Code sent but nothing happens** (message sits unconsumed) → two `getUpdates` consumers (409), or a stale queue. Confirm one poller; flush the bot's server-side queue from a browser: `https://api.telegram.org/bot<TOKEN>/deleteWebhook?drop_pending_updates=true`.
- **Wrong bot** → confirm you're DMing the exact bot whose token the wizard holds (`https://api.telegram.org/bot<TOKEN>/getMe`); revoke churn leaves stale tokens. `pending_update_count > 0` from `getWebhookInfo` proves messages are arriving at the right bot.
- Once it lands, the pairing record persists in `/work`, so it survives `compose stop/start`.
- **Reality check:** this fragility is a DinD artifact (matches `findings.md`'s "DinD is presenter-only"). On real laptop Docker the wizard pairs cleanly.

## Checkpoint — after ping/pong works, STOP and ask

Do not auto-continue into the exercises. Ask:

> ✅ Ping/pong works. Want me to keep guiding you through the exercises (Living Files → research swap → scheduled brief, in `workshop/outline.md`), or take it from here?

## References

- `README.md` — the canonical 4-step flow.
- `workshop/findings.md` — full reproduction of the 9 DinD gotchas.
- `workshop/outline.md` — the exercise walkthrough (Ex 1-4).
- `docker/entrypoint.sh` — dockerd + the runtime-read socat bridges.
