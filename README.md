# Proactive Digital Twin — Workshop Kit

A reproducible Docker-based environment for running the **"Beyond the Chatbot: Engineering Your Proactive Digital Twin"** workshop. Spins up an isolated sandbox on your laptop that hosts an autonomous agent (NanoClaw), pairs it to Telegram, gives it a credential vault, and lets you build the "agent that wakes up while you grab coffee" without touching your host OS.

Built and validated for **Web Summer Camp 2026, Opatija** (July 2-4). Pre-tested host options, captured every failure mode, and pinned the working setup so attendees don't have to debug it from scratch.

## What's in this repo

```
.
├── docker-compose.yml          # one command spins everything up
├── docker/                     # the privileged sandbox image (Ubuntu + DinD + VFS + OneCLI bind + non-root user)
├── workshop/
│   ├── outline.md              # the workshop walkthrough (intro, exercises, schedule, wrap-up)
│   ├── findings.md             # everything we tried and rejected (Railway, Oracle, DinD gotchas)
│   └── recordings/             # screenshots from the validation runs
└── docs/
    ├── architecture.md         # what the sandbox runs and why each piece exists
    └── providers.md            # agent-framework + VPS comparison + verdicts
```

## Prereqs

- **Docker Desktop** (macOS / Windows) or **Docker Engine** (Linux), 8 GB+ RAM, 10 GB+ free disk. See [`workshop/outline.md`](workshop/outline.md) for the full minimum-laptop table.
- A **Claude Pro/Max subscription** OR an **Anthropic API key with $5 credit**. The agent needs one of these.
- A **Telegram account** (on your phone/laptop). You'll create a bot via `@BotFather` to communicate with your twin.

## Quick start

Four steps. The only thing you configure is `.env`, at the start.

```bash
# 1. Clone
git clone https://github.com/Simply007/proactive-digital-twin-workshop
cd proactive-digital-twin-workshop
cp .env.example .env          # optional — defaults are safe

# 2. Build + start the sandbox (first build ~2 min)
docker compose up -d

# 3. Enter the sandbox (lands you in /work as the nanoclaw user)
docker compose exec -u nanoclaw sandbox bash

# 4. Inside the sandbox, install NanoClaw
git clone https://github.com/nanocoai/nanoclaw.git
cd nanoclaw
bash nanoclaw.sh
```

`nanoclaw.sh` asks everything it needs up front (Claude sign-in, time zone, Telegram bot token). When it finishes, DM your bot `ping` from your phone — the agent replies within ~60-90 seconds on the cold start, then sub-10s after that.

To stop: `docker compose down` (your agent state in `AGENT_WORKSPACE` persists). To reset completely, also delete that directory.

## Configuration

Everything tunable lives in `.env`. Defaults are safe:

| Var | Default | Purpose |
|---|---|---|
| `AGENT_WORKSPACE` | `~/nanoclaw-workspace` | Where the agent's persistent files live on your host (CLAUDE.local.md, logs, scheduled jobs, etc.). Bind-mounted into the sandbox at `/work`. |
| `ONECLI_BIND_HOST` | `127.0.0.1` | Where OneCLI (the credential vault) binds. The default works because `docker-compose.yml` publishes `127.0.0.1:10254-10255` from the sandbox to your host loopback. |
| `SANDBOX_CONTAINER` | `agent-sandbox` | The Docker container name. Change to run multiple sandboxes side by side. |

## Why the sandbox approach

NanoClaw's `bash nanoclaw.sh` is opinionated — it installs Node, pnpm, and Docker on the host, then runs containers from there. That's fine on a fresh VPS or a dedicated laptop, less fine on a work machine where you don't want a third-party install script with root reach. The sandbox isolates all of that inside a single container you can `docker compose down` when you're done.

The sandbox is **also** what we used to validate the workshop end-to-end on Ondřej's laptop without touching it. Every gotcha we hit (overlay-on-overlay, missing `sudo`, OneCLI bind address, Telegram pairing race) is documented in [`workshop/findings.md`](workshop/findings.md) and baked into the Dockerfile + entrypoint here, so a fresh `docker compose up` skips all of them.

## Pivoting to a real always-on host

The wrap-up section of [`workshop/outline.md`](workshop/outline.md) covers four options:

- **Hetzner CAX11** (€4.51/mo, recommended)
- **AWS `t4g.small`** (free 12 months, then ~$15/mo)
- **Mac Mini / Raspberry Pi at home** (free if you own one)
- ~~Oracle Cloud Always Free~~ (capacity roulette, see [`workshop/findings.md`](workshop/findings.md))

All four follow the same shape: provision Linux, SSH in, run the same `bash nanoclaw.sh`. The CLAUDE.local.md, scheduled jobs, and OpenRouter rule you built locally all transfer.

> The repo declares one private git submodule (the author's content tooling). It isn't needed to run the kit and isn't fetched by a normal `git clone`.

## License

MIT. Take it, fork it, run your own workshop. Credit appreciated, not required.

## Acknowledgements

- **NanoClaw** maintainers — the underlying framework.
- **OpenClaw** project — the original "living files" architecture that inspired the workshop's narrative.
- **Web Summer Camp 2026 organizers** — for booking a hands-on slot in the AI Engineering track.
