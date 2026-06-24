# Proactive Digital Twin — Workshop Kit

A reproducible Docker-based environment for running the **"Beyond the Chatbot: Engineering Your Proactive Digital Twin"** workshop. Spins up an isolated sandbox on your laptop that hosts an autonomous agent (NanoClaw by default; designed to swap to OpenClaw / Hermes / Agent-One / Claude Code in Docker), pairs it to Telegram, gives it a credential vault, and lets you build the "agent that wakes up while you grab coffee" without touching your host OS.

Built and validated for **Web Summer Camp 2026, Opatija** (July 2-4). Pre-tested host options, captured every failure mode, and pinned the working setup so attendees don't have to debug it from scratch.

## What's in this repo

```
.
├── docker-compose.yml          # one command spins everything up
├── docker/                     # the privileged sandbox image (Ubuntu + DinD + VFS + OneCLI bind + non-root user)
├── scripts/                    # install-agent.sh, start-agent.sh, enter.sh, teardown.sh
├── workshop/
│   ├── outline.md              # the workshop walkthrough (intro, exercises, schedule, wrap-up)
│   ├── findings.md             # everything we tried and rejected (Railway, Oracle, DinD gotchas)
│   └── recordings/             # screenshots from the validation runs
├── outline-writer/             # git submodule — talk-outline-writer repo (prompt.md + presenter.md)
└── docs/
    ├── architecture.md         # what the sandbox runs and why each piece exists
    └── providers.md            # agent-framework + VPS comparison + verdicts
```

## Prereqs

- **Docker Desktop** (macOS / Windows) or **Docker Engine** (Linux), 8 GB+ RAM, 10 GB+ free disk. See [`workshop/outline.md`](workshop/outline.md) for the full minimum-laptop table.
- A **Claude Pro/Max subscription** OR an **Anthropic API key with $5 credit**. The agent needs one of these — the workshop's pre-workshop email walks attendees through picking which.
- A **Telegram account** (on your phone). You'll create a bot via `@BotFather` during Exercise 1.

## Quick start

```bash
# 0. Clone with the outline-writer submodule (or `git submodule update --init`
#    after a bare clone). On a local-file submodule URL you may also need:
#       git -c protocol.file.allow=always submodule update --init
git clone --recurse-submodules <repo-url>
cd proactive-digital-twin-workshop

# 1. Copy and (optionally) tweak environment
cp .env.example .env

# 2. Spin up the sandbox (builds the image the first time, ~2 min)
docker compose up -d

# 3. Wait ~5s for the inner Docker daemon to come up, then drop in
./scripts/enter.sh

# 4. Inside the sandbox, install the agent
bash /opt/scripts/install-agent.sh
# (or follow the workshop outline step by step)
```

When the install finishes, DM your bot `ping` from your phone — agent replies within ~60-90 seconds on the cold-start, then sub-10s after that.

## Configuration

Everything tunable lives in `.env`. Defaults are safe:

| Var | Default | Purpose |
|---|---|---|
| `AGENT_WORKSPACE` | `~/nanoclaw-workspace` | Where the agent's persistent files live on your host (CLAUDE.local.md, logs, scheduled jobs, etc.). Bind-mounted into the sandbox at `/work`. |
| `AGENT_FRAMEWORK` | `nanoclaw` | Which framework `scripts/install-agent.sh` installs. Stubs exist for `openclaw`, `hermes`, `agentone`, `claude-code` (see [`docs/providers.md`](docs/providers.md)). |
| `ONECLI_BIND_HOST` | `127.0.0.1` | Where OneCLI (the credential vault) binds. The default works because `docker-compose.yml` publishes `127.0.0.1:10254-10255` from the sandbox to your host loopback. |
| `SANDBOX_CONTAINER` | `agent-sandbox` | The Docker container name. Change to run multiple sandboxes side by side. |

## Why the sandbox approach

NanoClaw's `bash nanoclaw.sh` is opinionated — it installs Node, pnpm, and Docker on the host, then runs containers from there. That's fine on a fresh VPS or a dedicated laptop, less fine on a work machine where you don't want a third-party install script with root reach. The sandbox isolates all of that inside a single container you can `docker compose down` when you're done.

The sandbox is **also** what we used to validate the workshop end-to-end on Ondřej's laptop without touching it. Every gotcha we hit (overlay-on-overlay, missing `sudo`, OneCLI bind address, Telegram pairing race) is documented in [`workshop/findings.md`](workshop/findings.md) and baked into the Dockerfile + entrypoint here, so a fresh `docker compose up` skips all of them.

## Pivoting to a different agent framework

The Docker image is provider-agnostic. The only framework-specific bits are:

- `scripts/install-agent.sh` — which install command to run inside the sandbox
- `scripts/start-agent.sh` — which process to launch / supervise

Both already have stubs for `openclaw`, `hermes`, `agentone`, and `claude-code`. Add a case branch with the real install command and you're done. See [`docs/architecture.md`](docs/architecture.md) for what's framework-agnostic vs. specific.

## Pivoting to a real always-on host

The wrap-up section of [`workshop/outline.md`](workshop/outline.md) covers four options:

- **Hetzner CAX11** (€4.51/mo, recommended)
- **AWS `t4g.small`** (free 12 months, then ~$15/mo)
- **Mac Mini / Raspberry Pi at home** (free if you own one)
- ~~Oracle Cloud Always Free~~ (capacity roulette, see [`workshop/findings.md`](workshop/findings.md))

All four follow the same shape: provision Linux, SSH in, run the same `bash nanoclaw.sh`. The CLAUDE.local.md, scheduled jobs, and OpenRouter rule you built locally all transfer.

## The outline-writer submodule

The `outline-writer/` directory is a [git submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules) pointing at the standalone [`talk-outline-writer`](https://github.com/Simply007/talk-outline-writer) repo (currently pinned to a local `file://` path during development). It contains the Claude prompt and presenter profile used to generate [`workshop/outline.md`](workshop/outline.md). Forking it for a different talk or presenter is independent of this kit's lifecycle.

To update the submodule URL once both repos are pushed to GitHub:

```bash
git submodule set-url outline-writer https://github.com/Simply007/talk-outline-writer.git
git submodule sync
git add .gitmodules
git commit -m "point outline-writer submodule at GitHub"
```

## License

MIT. Take it, fork it, run your own workshop. Credit appreciated, not required.

## Acknowledgements

- **NanoClaw** maintainers — the underlying framework.
- **OpenClaw** project — the original "living files" architecture that inspired the workshop's narrative.
- **Web Summer Camp 2026 organizers** — for booking a hands-on slot in the AI Engineering track.
