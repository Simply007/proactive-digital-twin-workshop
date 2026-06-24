# Project memory — Proactive Digital Twin Workshop Kit

This file is auto-loaded by Claude Code when working in this repo. It captures the project's purpose, structure, decisions, and current status so a fresh Claude session has the same starting context as the team.

## What this repo is

A reproducible Docker-based environment for running the **"Beyond the Chatbot: Engineering Your Proactive Digital Twin"** workshop at **Web Summer Camp 2026** (Opatija, Croatia, Thursday July 2, AI Engineering track, 14:15-15:30 + 16:00-17:15).

Presenter: Ondřej Chrastina (Developer Advocate at CKEditor).

The kit bundles:

- a Docker Compose sandbox that runs NanoClaw with every dry-run fix baked in
- the workshop walkthrough (`workshop/outline.md`)
- a "what we tried and rejected" record (`workshop/findings.md` + `workshop/recordings/`)
- the Claude prompt + presenter profile that generated the outline (`outline-writer/` — git submodule)
- comparison docs for agent frameworks and VPS providers (`docs/`)

## Repo structure

```
.
├── README.md                       # public hero doc
├── LICENSE                         # MIT
├── .env.example                    # AGENT_WORKSPACE, AGENT_FRAMEWORK, ONECLI_BIND_HOST, SANDBOX_CONTAINER
├── docker-compose.yml              # one command (`docker compose up`) → working sandbox
├── docker/
│   ├── Dockerfile                  # the sandbox image (Ubuntu base, DinD, VFS, OneCLI bind, non-root user)
│   └── entrypoint.sh               # starts inner dockerd + socat bridges, then sleeps
├── scripts/
│   ├── install-agent.sh            # in-container: clone + bash nanoclaw.sh (stubs for openclaw/hermes/agentone/claude-code)
│   ├── start-agent.sh              # in-container: start the agent process
│   ├── enter.sh                    # host: docker exec into sandbox as nanoclaw user
│   └── teardown.sh                 # host: docker compose down + optional workspace wipe
├── workshop/
│   ├── outline.md                  # the walkthrough (intro, exercises, schedule, wrap-up)
│   ├── findings.md                 # Railway + Oracle failures, 9 DinD gotchas, end-to-end validation log
│   └── recordings/                 # 8 screenshots from validation runs
├── outline-writer/                 # git submodule → talk-outline-writer repo
└── docs/
    ├── architecture.md             # what runs where + framework-agnostic swap points
    └── providers.md                # framework comparison (NanoClaw/OpenClaw/Hermes/Agent-One/Claude Code) + VPS comparison
```

## Key decisions (with rationale)

| Decision | Why |
|---|---|
| **Host = local Docker on attendee laptop** (not VPS) | Railway blocks Docker-in-Docker (no `--privileged`). Oracle Cloud A1 ARM is region-locked + frequently "Out of capacity" in EU regions. Both fail on workshop day. Local Docker is the only path that works for every attendee. See `workshop/findings.md`. |
| **Sandbox uses VFS storage driver** | Overlay-on-overlay (Docker Desktop's outer overlay + inner Docker's overlay2 default) fails on BuildKit cache mounts. VFS is slower but always works. |
| **Ubuntu base** (`buildpack-deps:jammy-curl`) | NanoClaw's `setup/install-node.sh` requires Debian/Ubuntu (NodeSource setup script rejects Alpine, RHEL, Oracle Linux). |
| **`sudo` + `socat` pre-installed in image** | `ubuntu:22.04` Docker image ships without them; the cloud Ubuntu images attendees use elsewhere have them. We bake them in to mirror the latter. |
| **`ONECLI_BIND_HOST=127.0.0.1` in `/etc/environment` AND `/etc/bash.bashrc`** | PAM-based `/etc/environment` is bypassed by `docker exec` non-login shells. Belt-and-suspenders. |
| **`socat` bridges from `172.18.0.1:10254-10255` → `127.0.0.1:10254-10255`** | Spawned agent containers reach OneCLI via `host.docker.internal` (inner bridge gateway = `172.18.0.1`), but OneCLI binds to sandbox loopback `127.0.0.1`. Bridge connects them. |
| **Sandbox publishes `127.0.0.1:10254-10255` to host** | Agent prints `http://127.0.0.1:10254/...` URLs when connecting external services (e.g., OpenAI for voice). Same address resolves to host loopback for the user's Mac browser. |
| **`AGENT_FRAMEWORK=nanoclaw` default; stubs for openclaw/hermes/agentone/claude-code** | NanoClaw is implemented; the others have stub case-branches in `scripts/install-agent.sh` that exit with informative messages until someone wires them up. Image is framework-agnostic. |

## Validation status

End-to-end validation done in DinD sandbox on 2026-06-09/10:

- ✅ Exercise 1: install → Telegram pairing → ping/pong
- ✅ Exercise 2: Living Files (CLAUDE.local.md self-edit, personalization confirmed)
- ✅ Exercise 3 Part A: default web search baseline
- ✅ Exercise 3 Part B: research tool swap (tried OpenRouter Perplexity, then DDG Instant Answers as free fallback — DDG comes up dry on event-specific queries, which is itself a useful demo moment)
- ✅ Exercise 4: scheduled morning brief (create + list + run-once)
- ✅ Bonus voice messages: graceful fallback when no OpenAI key, OneCLI URL flow
- ⏸ CKEditor cameo: pending (needs API choice + token + doc ID from presenter)
- ⏸ Full clean-slate DinD validation with the current Dockerfile + scripts (this kit)
- ⏸ `docker compose stop && start` recovery test

## Conventions

- **No em-dashes** anywhere (workshop voice rule, see `outline-writer/presenter.md`).
- **Workshop voice** is cue-based, hook-first, no agenda slides — see `outline-writer/presenter.md`.
- **Bot tokens / API keys are passwords** — never paste them in shared chats, screen shares, or commits. The `.gitignore` covers `.env`.

## DinD gotchas (presenter-side only — attendees on laptop Docker don't hit these)

If validating the workshop in our DinD sandbox (`docker compose up` here), expect these:

1. NanoClaw requires Debian/Ubuntu — Alpine `docker:dind` is rejected by NodeSource's setup script.
2. `$USER` env var unset in `docker exec` sessions — pass `-e USER=nanoclaw` (the `scripts/enter.sh` wrapper does this).
3. No systemd inside the container — agent service won't auto-start; use `scripts/start-agent.sh`.
4. Overlay-on-overlay storage driver failure — pre-configured VFS in the Dockerfile.
5. VFS makes the first agent image build slow (~10-12 min vs ~3-4 min on real overlay2). One-time cost.
6. OneCLI can't auto-detect a bind address inside an unprivileged container — `ONECLI_BIND_HOST=127.0.0.1` is baked in.
7. NanoClaw pairing codes expire fast; if the agent service isn't running when the user sends the code, the queue swallows old codes. Drain Telegram queue with `getUpdates?offset=-1` before retrying.
8. Spawned agent containers can't reach OneCLI by default — socat bridges in entrypoint solve this.
9. OneCLI URLs in agent replies use `127.0.0.1` — the published port in `docker-compose.yml` makes the URL work directly in the host browser.

See `workshop/findings.md` for full reproduction details.

## Pending / open items

- **CKEditor cameo** (workshop Exercise / wrap-up demo): needs concrete CKEditor API endpoint, auth token, and target document ID to wire into the agent's `CLAUDE.local.md`.
- **Pre-workshop email** to attendees (1 week before): not yet drafted. Should cover Docker install + Claude access path (Pro sub or API key) + Telegram phone-app reminder.
- **Slide deck**: not yet started. The `outline-writer/prompt.md` `talk` mode can generate slide-by-slide from the workshop outline if needed.
- **Run sheet for July 2**: cut-candidate ladder is in `workshop/outline.md`; a presenter-friendly minute-by-minute card is still TODO.
- **Push both repos to GitHub** + flip submodule URL from `file://` to `https://github.com/Simply007/talk-outline-writer.git`. See README "outline-writer submodule" section for the exact commands.
- **Wire OpenClaw / Hermes / Agent-One / Claude Code branches** in `scripts/install-agent.sh` when there's a reason to swap. Stubs already in place.

## How to push to GitHub when ready

```bash
# This repo
cd ~/projects/proactive-digital-twin-workshop
gh repo create proactive-digital-twin-workshop --public --source=. --remote=origin --push

# Submodule repo
cd ~/projects/talk-outline-writer
gh repo create talk-outline-writer --public --source=. --remote=origin --push

# Flip submodule URL
cd ~/projects/proactive-digital-twin-workshop
git submodule set-url outline-writer https://github.com/Simply007/talk-outline-writer.git
git submodule sync
git add .gitmodules
git commit -m "point outline-writer submodule at GitHub"
git push
```
