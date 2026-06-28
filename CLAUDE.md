# Project memory — Proactive Digital Twin Workshop Kit

This file is auto-loaded by Claude Code when working in this repo. It captures the project's purpose, structure, decisions, and current status so a fresh Claude session has the same starting context as the team.

## What this repo is

A reproducible Docker-based environment for running the **"Beyond the Chatbot: Engineering Your Proactive Digital Twin"** workshop at **Web Summer Camp 2026** (Opatija, Croatia, Thursday July 2, AI Engineering track, 14:15-15:30 + 16:00-17:15).

Presenter: Ondřej Chrastina (Developer Advocate at CKEditor).

The kit bundles:

- a Docker Compose sandbox that runs NanoClaw with every dry-run fix baked in
- the workshop walkthrough (`workshop/outline.md`)
- a "what we tried and rejected" record (`workshop/findings.md` + `workshop/recordings/`)
- the author's private content tooling (`ai-library` git submodule — not needed to run the kit)
- host/VPS comparison docs (`docs/`)

## Repo structure

```
.
├── README.md                       # public hero doc
├── LICENSE                         # MIT
├── .env.example                    # AGENT_WORKSPACE, ONECLI_BIND_HOST, SANDBOX_CONTAINER
├── docker-compose.yml              # one command (`docker compose up`) → working sandbox
├── docker/
│   ├── Dockerfile                  # the sandbox image (Ubuntu base, DinD, VFS, OneCLI bind, non-root user)
│   └── entrypoint.sh               # starts inner dockerd + socat bridges, then sleeps
├── workshop/
│   ├── outline.md                  # the walkthrough (intro, exercises, schedule, wrap-up)
│   ├── findings.md                 # Railway + Oracle failures, 9 DinD gotchas, end-to-end validation log
│   └── recordings/                 # 8 screenshots from validation runs
├── scripts/
│   └── teardown.sh                 # wipe sandbox back to fully fresh (container + image + host workspace)
├── ai-library/                     # private git submodule (author tooling; not fetched by a normal clone)
└── docs/
    ├── architecture.md             # what the sandbox runs and why each piece exists
    └── providers.md                # host/VPS comparison + verdicts
```

### Resetting the sandbox

`scripts/teardown.sh` returns the DinD sandbox to a completely fresh state. It
prompts for `yes` on **each** step independently (container+image / image
force-remove / host workspace / repo `.env`), so you can drop only what you
want. `-y` runs all steps unattended. It reads `AGENT_WORKSPACE`/
`SANDBOX_CONTAINER` from `.env` before removing anything, and refuses to `rm` an
unsafe path (`/`, `$HOME`, empty).

```bash
./scripts/teardown.sh        # confirm each step
./scripts/teardown.sh -y     # nuke everything, no prompts
docker compose up -d         # rebuild fresh from the Dockerfile
```

### Starting the agent service (DinD only)

The container has no init system (no systemd/launchd), so NanoClaw's service
never auto-starts: the installer reports "Couldn't reach the NanoClaw service",
skips its ping test, and Telegram pairing can't complete (nothing consumes the
code). Start it from the host with `docker exec -d -u nanoclaw` (a new terminal;
`-d` because a plain `docker exec … 'node … &'` hangs on the inherited pipe;
`-u nanoclaw` — NOT root — so files it creates are uid 1000, matching the agent
containers; see below):

```bash
docker exec -d -u nanoclaw agent-sandbox bash -c 'cd /work/nanoclaw && node dist/index.js >> logs/agent.log 2>&1'
docker exec agent-sandbox tail -n 15 /work/nanoclaw/logs/agent.log   # "NanoClaw running" + "Telegram polling started"
```

Run as `nanoclaw` (uid 1000), never root: the spawned agent containers run their
agent-runner as `node` (uid 1000) and write session DBs (`inbound.db`/
`outbound.db`), `groups/…/container.json`, and `/tmp/onecli-*.pem`. A root-run
service creates those root-owned, so the uid-1000 agent can't write them →
`attempt to write a readonly database` / `EACCES`, agent crashes, no reply. (The
old bind mount masked this via permissive FUSE ownership; the ext4 named volume
enforces it.) If you ever ran it as root and switched: `docker exec agent-sandbox
chown -R nanoclaw:nanoclaw /work && docker exec agent-sandbox rm -f /tmp/onecli-*.pem`.

Timing: start it **after** the Telegram bot token is entered (when the wizard
waits at the pairing-code step), NOT before. The service loads channel adapters
at startup, so starting it early (e.g. to make the ping pass) brings it up with
no Telegram adapter — pairing then silently fails (no "Telegram polling
started", queue piles up). If you started it too early, restart it
(`docker exec -u nanoclaw agent-sandbox pkill -f dist/index.js`, then the `-d`
start) so it picks up Telegram. Then send the code and approve the "Connected to
<agent>" card. **Do not re-run the wizard with the service up** (multi-poller race).

After the initial hand-start, **`stop`/`start` is fully automatic.** `entrypoint.sh`
(a) clears the stale `docker.pid` before launching inner dockerd — `/var/run`
isn't tmpfs, so the old pidfile otherwise makes dockerd refuse to start and the
container crash-loops (`restart: unless-stopped`); (b) auto-starts the service as
nanoclaw if an install exists. Combined with node baked in and `/work` on a named
volume (sockets on ext4 → unlink works), `stop`/`start` brings back inner dockerd,
the OneCLI gateway containers (`onecli` + `onecli-postgres-1`, which persist in the
kept inner Docker), the agent images, and the service — agent replies, no manual
steps.

**`down`/`up`/`--build` does NOT fully survive:** recreating the container wipes
the inner Docker's storage (`/var/lib/docker` is in the container layer, not
`/work`) — the OneCLI gateway + vault secrets, the `onecli` binary, and agent
images are gone → `OneCLIError: fetch failed` → **reinstall required**. `/work`
(clone, DB, pairing) persists in the named volume. So restart with `stop`/`start`,
not `down`/`up`. Iterating on entrypoint.sh without a rebuild/reinstall:
`docker cp docker/entrypoint.sh agent-sandbox:/usr/local/bin/entrypoint.sh`
(writes into the container layer, survives stop/start).

The wizard's final verify may report `SERVICE: not_found` / `STATUS: failed` —
a false negative: it looks for a launchd/systemd service or a `nanoclaw.pid`
file, and a hand-started service has neither. If credentials/channel/groups are
configured and Telegram chat works, it's fine. To make verify green, write the
pid file: `docker exec agent-sandbox sh -c 'for p in $(pgrep -f dist/index.js);
do [ "$(cat /proc/$p/comm)" = node ] && echo $p > /work/nanoclaw/nanoclaw.pid;
done'` (per-run; rewrite if the service restarts).

Also expect a separate `Claude CLI isn't signed in` prompt even though the vault
shows configured: the OneCLI vault token (agent's API calls) is not the local
`claude` CLI sign-in (~/.claude). Answer Yes / complete OAuth — two credential
stores. And note `teardown.sh` does not clear Telegram's server-side message
queue; reusing an old bot may need `deleteWebhook?drop_pending_updates=true`.

Why root, given the nanoclaw user? The nanoclaw user makes the *install* faithful
to attendees (NanoClaw's installer refuses root; real users are non-root + sudo),
but install steps that touch data/ and logs/ run elevated (inner Docker, OneCLI),
leaving those dirs root-owned — so the service must run as root here. Pure DinD
artifact: on a real laptop the install, the init-started service, and data/logs
are all owned by the same normal user, so none of this is needed.

## Key decisions (with rationale)

| Decision | Why |
|---|---|
| **Host = local Docker on attendee laptop** (not VPS) | Railway blocks Docker-in-Docker (no `--privileged`). Oracle Cloud A1 ARM is region-locked + frequently "Out of capacity" in EU regions. Both fail on workshop day. Local Docker is the only path that works for every attendee. See `workshop/findings.md`. |
| **Sandbox uses VFS storage driver** | Overlay-on-overlay (Docker Desktop's outer overlay + inner Docker's overlay2 default) fails on BuildKit cache mounts. VFS is slower but always works. |
| **Ubuntu base** (`buildpack-deps:jammy-curl`) | NanoClaw's `setup/install-node.sh` requires Debian/Ubuntu (NodeSource setup script rejects Alpine, RHEL, Oracle Linux). |
| **`sudo` + `socat` pre-installed in image** | `ubuntu:22.04` Docker image ships without them; the cloud Ubuntu images attendees use elsewhere have them. We bake them in to mirror the latter. |
| **`ONECLI_BIND_HOST=127.0.0.1` in `/etc/environment` AND `/etc/bash.bashrc`** | PAM-based `/etc/environment` is bypassed by `docker exec` non-login shells. Belt-and-suspenders. |
| **`socat` bridges the default-bridge gateway `:10254-10255` → `127.0.0.1:10254-10255`** | Spawned agent containers reach OneCLI via `host.docker.internal`, which resolves to the inner **default-bridge gateway** — auto-assigned by Docker (`172.17.0.1` if free, else `172.18.0.1`, …), so it varies by machine. `entrypoint.sh` reads it at runtime (`DOCKER_BRIDGE_IP` overrides) and binds socat there; OneCLI binds to sandbox loopback `127.0.0.1`. Bridge connects them. |
| **Sandbox publishes `127.0.0.1:10254-10255` to host** | Agent prints `http://127.0.0.1:10254/...` URLs when connecting external services (e.g., OpenAI for voice). Same address resolves to host loopback for the user's Mac browser. |
| **`/work` is a Docker named volume, not a host bind mount** | The agent's unix sockets (`data/cli.sock`, `data/ncl.sock`) live under `DATA_DIR` (project root, not env-configurable). Docker Desktop's macOS bind mount returns `ENOTSUP` on `unlink` of socket files (even root `rm`/`ls` fail), so the service could never rebind on restart. A named volume lives on the Docker VM's ext4 → socket unlink works → service restarts cleanly. Trade-off: state isn't browsable as host files (inspect via `docker compose exec`); still persists across stop/start + down/up; wiped by `down -v`. |
| **Node 22 baked into the image** (NodeSource) | NanoClaw's installer puts node in the container's writable layer, which is wiped on every container recreate (`down/up`/`--build`), leaving the `/work` install unrunnable. Baking node 22 (matches `.nvmrc`) into the image makes it survive restarts, lets `entrypoint.sh` auto-start the service, and speeds first install (installer detects node, skips). |
| **`entrypoint.sh` auto-starts the agent service as `nanoclaw`** | No init system in the container, so the service won't come up on its own. The entrypoint runs `node dist/index.js` via `runuser -u nanoclaw` (uid 1000, NOT root; writes `nanoclaw.pid`) if an install exists — automatic after every restart. Running as nanoclaw keeps all files uid 1000, so the agent containers (`node`, uid 1000) can write their session DBs; a root service would create root-owned files → `readonly database`/`EACCES` in agents. The very first install still needs one hand-start (`-u nanoclaw`), since the container isn't restarted mid-setup. |

## Validation status

End-to-end validation done in DinD sandbox on 2026-06-09/10:

- ✅ Preparation 1: install → Telegram pairing → ping/pong
- ✅ Preparation 2: Living Files (CLAUDE.local.md self-edit, personalization confirmed)
- ✅ Preparation 3 Part A: default web search baseline
- ✅ Preparation 3 Part B: research tool swap (tried OpenRouter Perplexity, then DDG Instant Answers as free fallback — DDG comes up dry on event-specific queries, which is itself a useful demo moment)
- ✅ Preparation 4: scheduled morning brief (create + list + run-once)
- ✅ Bonus voice messages: graceful fallback when no OpenAI key, OneCLI URL flow
- ⏸ Full clean-slate DinD validation with the current Dockerfile (this kit)
- ⏸ `docker compose stop && start` recovery test

## Conventions

- **No em-dashes** anywhere (workshop voice rule).
- **Workshop voice** is cue-based, hook-first, no agenda slides.
- **Bot tokens / API keys are passwords** — never paste them in shared chats, screen shares, or commits. The `.gitignore` covers `.env`.

## DinD gotchas (presenter-side only — attendees on laptop Docker don't hit these)

If validating the workshop in our DinD sandbox (`docker compose up` here), expect these:

1. NanoClaw requires Debian/Ubuntu — Alpine `docker:dind` is rejected by NodeSource's setup script.
2. `$USER` env var unset in `docker exec` sessions — `ENV USER=nanoclaw` is baked into the image; enter via `docker compose exec -u nanoclaw sandbox bash`.
3. No systemd inside the container — agent service won't auto-start; start it manually (`cd /work/nanoclaw && nohup node dist/index.js > logs/agent.log 2>&1 &`).
4. Overlay-on-overlay storage driver failure — pre-configured VFS in the Dockerfile.
5. VFS makes the first agent image build slow (~10-12 min vs ~3-4 min on real overlay2). One-time cost.
6. OneCLI can't auto-detect a bind address inside an unprivileged container — `ONECLI_BIND_HOST=127.0.0.1` is baked in.
7. NanoClaw pairing codes expire fast; if the agent service isn't running when the user sends the code, the queue swallows old codes. Drain Telegram queue with `getUpdates?offset=-1` before retrying.
8. Spawned agent containers can't reach OneCLI by default — socat bridges in entrypoint solve this.
9. OneCLI URLs in agent replies use `127.0.0.1` — the published port in `docker-compose.yml` makes the URL work directly in the host browser.

See `workshop/findings.md` for full reproduction details.

## Pending / open items

- **Pre-workshop email** to attendees (1 week before): not yet drafted. Should cover Docker install + Claude access path (Pro sub or API key) + Telegram phone-app reminder.
- **Slide deck**: not yet started. The author's private content-generation tooling (the `ai-library` submodule) can generate slide-by-slide from the workshop outline if needed.
- **Run sheet for July 2**: cut-candidate ladder is in `workshop/outline.md`; a presenter-friendly minute-by-minute card is still TODO.
- **Push this repo to GitHub.** The `ai-library` submodule is private (author tooling) and isn't fetched by a normal clone, so it won't block a public push.

## How to push to GitHub when ready

```bash
cd ~/projects/proactive-digital-twin-workshop
gh repo create proactive-digital-twin-workshop --public --source=. --remote=origin --push
```
