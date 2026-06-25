---
type: workshop-outline
format: workshop
title: "Beyond the Chatbot: Engineering Your Proactive Digital Twin"
date: 2026-07-02
presenter: Ondřej Chrastina
duration: "2h 30min (2x 1h 15min blocks + 10–15 min break)"
audience: "AI Engineering track, Web Summer Camp 2026 - intermediate web devs comfortable with terminal/SSH and Docker basics"
core_message: "Stop chatting, start delegating - an always-on agent with verbalized context outperforms any chat window."
stack:
  agent_framework: NanoClaw (MIT, container-per-agent, Anthropic Agents SDK native)
  host: Local Docker on attendee's laptop (Docker Desktop on macOS/Windows, Docker Engine on Linux). No VPS, no signup, no credit card.
  llm_provider: Anthropic API (Sonnet 4.5 default; Opus 4.6 for stretch exercises)
  messaging_channel: Telegram (lowest friction for live demo - long-polls Telegram's servers, no public webhook required, works behind NAT)
  post_workshop_upgrades: "Hetzner CAX11 (€4.51/mo ARM, real Docker, recommended) or AWS t4g.small (free 12 months) for always-on; Mac Mini / Raspberry Pi at home if you own one; provider swap via NanoClaw skills (/add-codex, /add-opencode, /add-ollama-provider) for non-Anthropic models"
status: draft
session_url: https://websummercamp.com/2026/session/beyond-the-chatbot-engineering-your-proactive-digital-twin
---

# Beyond the Chatbot: Engineering Your Proactive Digital Twin

Web Summer Camp 2026, Opatija, Croatia. AI Engineering track. 2h 30min hands-on workshop.

> **This is the public version of the outline.** The author's working copy with drafts, alternative phrasings, and pre-decision notes lives in the [ai-library DevRel monorepo](https://github.com/Simply007/ai-library/blob/main/_outputs/workshop-websummercamp-2026-proactive-digital-twin.md) (private repo). The version you're reading is the canonical published outline that ships with this workshop kit.

---

## Stack & Rationale

The reference architecture for this space (the OpenClaw video that kicked off this workshop) walks through a 9-file living-files setup (`AGENTS.md`, `SOUL.md`, `USER.md`, `HEARTBEAT.md`, `MEMORY.md`, `TOOLS.md`, `IDENTITY.md`, `BOOT.md`, `BOOTSTRAP.md`) on a Hostinger VPS with a paid plan. See the [OpenClaw agent-workspace docs](https://github.com/openclaw/openclaw/blob/main/docs/concepts/agent-workspace.md) for the verbatim file-by-file purpose. We deliberately picked a lighter, free-tier-friendly stack so attendees walk out with something running, not something costing. NanoClaw intentionally collapses those nine files into **one `CLAUDE.md` per agent + the agent's memory + installable skills**. Same mental model, fewer moving parts to teach in 2.5h.

### Agent framework: NanoClaw

| Criterion | OpenClaw | **NanoClaw** | Hermes Agent | Agent Zero |
|---|---|---|---|---|
| Install model | VPS-native (Hostinger one-click) | Docker container per agent | Hosted via OpenRouter (no install) | Python framework, build-your-own |
| License | Source-available | **MIT** | Open weights | MIT |
| Native LLM SDK | Custom gateway | **Anthropic Agents SDK** (drop-in skills for OpenAI / OpenRouter / Ollama; `ANTHROPIC_BASE_URL` for any Claude-compatible endpoint) | Nous Hermes 3 (any provider) | Provider-agnostic |
| "Living files" analog | 9 files: `AGENTS.md`, `SOUL.md`, `USER.md`, `HEARTBEAT.md`, `MEMORY.md`, `TOOLS.md`, `IDENTITY.md`, `BOOT.md`, `BOOTSTRAP.md` ([docs](https://github.com/openclaw/openclaw/blob/main/docs/concepts/agent-workspace.md)) | **Per-agent `CLAUDE.md` + memory + skills** | Built-in persistent memory | Roll your own |
| Scheduled / proactive loop | Heartbeat + cron jobs | **Scheduled jobs via natural language** | Self-improving skills | Custom |
| Multi-channel messaging | WhatsApp, Telegram, etc. | WhatsApp, Telegram, Discord, Slack, Microsoft Teams, iMessage, Matrix, Google Chat, Webex, Linear, GitHub, WeChat, email (Resend); Signal planned via `/add-signal` (community-requested skill, not shipped yet) | API-only | Custom |
| Codebase size | Large microservices | ~35k tokens total | n/a (managed) | Medium |
| Workshop fit | Heavier | **Light, clear, self-contained** | No infra to teach | Too low-level for 2.5h |

**Pick: NanoClaw.** It is the same mental model as OpenClaw (verbalize context, schedule proactive jobs, message channels) but with a smaller blast radius and a saner per-agent boundary. Importantly, it runs natively on the Anthropic Agents SDK, so the "what's actually happening" is teachable in the time we have. Container-per-agent gives attendees a safety story they can take back to their team.

> **Note for organizers:** NanoClaw is not Anthropic-locked. Drop-in provider skills exist for OpenAI (`/add-codex`), OpenRouter / Google / DeepSeek (`/add-opencode`), local Ollama (`/add-ollama-provider`), and any Claude-compatible endpoint via `ANTHROPIC_BASE_URL`. We picked Anthropic for the unified walkthrough to keep the workshop simple - the swap is presented as a "where to go next" item in the wrap-up, not a mid-session choice.

### Host: Local Docker on the attendee's laptop

| Option | Workshop-day friction | Capacity reliability | Always-on after workshop | Workshop verdict |
|---|---|---|---|---|
| **Local Docker (laptop)** | **Docker install pre-workshop, ~15 min at home** | **100%** (your own laptop) | No - laptop sleeps. Migration recipes in wrap-up. | **Picked.** Only path that works for every attendee on day-of. |
| Railway | None (no CC, web shell) | n/a | n/a | **Excluded.** Tested 2026-06-09: blocks Docker-in-Docker (no privileged mode). NanoClaw cannot run. |
| Oracle Cloud Always Free | $1 CC hold, signup ~15 min | **Unreliable** - A1 ARM is region-locked to home region and frequently "Out of capacity" in EU regions (Amsterdam confirmed dead 2026-06-09) | Yes (when capacity exists) | **Excluded.** Capacity roulette can block any attendee on workshop day. Forever-free promise not worth the day-of risk. |
| AWS Free Tier | $1 CC hold, signup ~15 min | Reliable | Yes, for 12 months; then ~$15/mo | Demoted to wrap-up "where to go next" option for attendees who want always-on. |
| Hetzner CAX11 | CC required, ~3 min signup, €4.51/mo | Reliable | Yes, paid | Demoted to wrap-up as the recommended **paid** always-on option. |
| Hostinger (OpenClaw bundles) | Paid 24-month commitment | Reliable | Yes, paid | Demoted to wrap-up as the "different framework, zero setup, pre-loaded AI credits" easy-button option. |

**Pick: Local Docker, no branching.** Every attendee runs NanoClaw on their own machine. Docker Desktop (macOS/Windows) or Docker Engine (Linux). No VPS signup, no credit card for hosting, no capacity blockers. Docker-in-Docker works on local Docker because local containers have access to privileged mode (the exact thing Railway refused to grant). Telegram works without any tunnel because the bot **long-polls** Telegram's servers - it doesn't need a public webhook URL.

**The honest trade-off:** local Docker dies when the laptop sleeps. The "wake up at 09:00, scan your calendar, DM you a brief while you grab coffee" magic only fires while the laptop is awake. During the 2.5h workshop this is fine - laptops stay open. For the take-home story, the wrap-up gives attendees three concrete recipes to migrate the agent to always-on (Hetzner, AWS, Mac Mini / Raspberry Pi at home).

> **Why not a VPS?** Tested on 2026-06-09: Railway blocks Docker-in-Docker outright (privileged mode denied; `dockerd` crashes on cgroup mount with "Permission denied"). Oracle Cloud Always Free A1 is region-locked to your signup region and frequently "Out of capacity" - confirmed dead in Amsterdam, community reports same in other EU regions. Both paths can leave attendees stranded on workshop day with no recourse. Local Docker is the only "works for everyone, no signup, no CC" path we've found that NanoClaw can actually run on. See `findings.md` in the workshop repo for the full verification log.

### Hostinger + OpenClaw (the reference architecture, for context)

The video that kicked off this workshop walks through Hostinger's one-click OpenClaw setup. We're not using it - attendees would have to pay and commit to 24 months - but it's worth knowing what it offers since it's the "easy button" answer in the space right now:

| Plan | Price (promo / renewal) | Specs | What's pre-installed |
|---|---|---|---|
| **Managed OpenClaw** | $5.99/mo intro, $11.99/mo renewal (24-mo term) | Hosted, no root access | OpenClaw CLI, Telegram + WhatsApp pairing, web search, agentic email, **AI credits pre-loaded** (no API key needed). Zero maintenance. |
| **OpenClaw on VPS (KVM2)** | $8.99/mo intro, $14.99/mo renewal (24-mo term) | 2 vCPU, 8 GB RAM, 100 GB NVMe, 8 TB bandwidth | Full root + terminal, OpenClaw Docker template pre-installed, AI credits pre-loaded |

Both include a 30-day money-back guarantee. Sources: [hostinger.com/vps/openclaw-hosting](https://www.hostinger.com/vps/openclaw-hosting), [docs.openclaw.ai/install/hostinger](https://docs.openclaw.ai/install/hostinger).

**Why we skipped it:** introductory price needs a 24-month commitment, which is a tough ask in a 2.5h session. Worth flagging in the wrap-up as the "different framework, zero setup, pre-loaded AI credits" path for attendees who don't want to maintain anything and are happy to pay.

---

## Pre-workshop setup (sent ≥1 week ahead)

Email subject: **"Beyond the Chatbot - 20 min of prep before Friday"**

There are **two hard pre-requirements** (one technical, one account-based) plus a quick in-workshop credential. Tackle them at home; do NOT leave them for conference WiFi.

### 1. Install Docker and verify it works

- **macOS**: Install [Docker Desktop](https://www.docker.com/products/docker-desktop/). Pick the right build for your chip - Apple Silicon (M-series) or Intel.
- **Windows 10/11**: Install [Docker Desktop](https://www.docker.com/products/docker-desktop/). It will guide you through enabling WSL2 if needed.
- **Linux**: One-liner: `curl -fsSL https://get.docker.com | sh && sudo usermod -aG docker $USER && newgrp docker`

**Verify** by running this in a terminal:

```bash
docker run --rm hello-world
```

You should see a "Hello from Docker!" message. If you don't, fix it before you walk in - we can't troubleshoot Docker installs over Opatija's hotel WiFi in a 2.5h session.

### 2. Decide how you'll connect to Claude (pick ONE of two paths)

NanoClaw uses Claude (Anthropic) as the agent's brain. Before the workshop, set up **one** of these access paths so you can paste credentials when the script asks:

| Path | What you need | Cost | Best for |
|---|---|---|---|
| **A. Claude Pro / Max subscription** (recommended if you already pay for Claude) | Active Claude.ai Pro ($20/mo) or Max subscription. OAuth login at workshop time. | $0 incremental (covered by your sub) | The fastest, smoothest path. No credit card friction beyond your existing subscription. |
| **B. Anthropic API key + credit top-up** | Account at https://console.anthropic.com/, an API key starting `sk-ant-...`, $5 of credit loaded. Credit card required. | $5 lasts most attendees weeks. Actual workshop usage is <$1. | Anyone without a Claude subscription. |

**You only need one of A / B.** Pick whichever matches your situation. Both give full Claude quality at speeds adequate for the workshop. Non-Anthropic alternatives (OpenRouter, local Ollama, etc.) can be swapped in **after** the workshop via NanoClaw's `/add-opencode` and `/add-ollama-provider` skills — covered in the wrap-up.

### 3. Telegram bot — quick, can be done in the workshop intro

Install Telegram on your phone. DM [@BotFather](https://t.me/botfather): send `/newbot`, pick a name, save the token. You'll need this token in Exercise 1. Takes ~2 min, no pre-workshop urgency.

### Minimum laptop requirements

| Resource | Minimum (will work, will be tight) | Recommended (comfortable) |
|---|---|---|
| **RAM** | 8 GB | 16 GB or more |
| **Free disk space** | 10 GB | 20 GB+ |
| **CPU** | Any 64-bit CPU from ~2018 onward (Intel Core i5+, AMD Ryzen 5+, Apple Silicon M1+, ARM64) | Same |
| **OS** | macOS 11+ / Windows 10 build 2004+ with WSL2 / Linux kernel 4.x+ | macOS 13+ / Windows 11 / recent Ubuntu LTS |
| **Admin rights** | Required (to install Docker) | Required |
| **Network** | Stable WiFi, ~1 Mbps for the workshop | Same; conference WiFi is fine for the session itself |
| **Phone** | With Telegram installed, to DM the bot | Same |
| **Power** | Charger plugged in - Docker + LLM calls drain battery fast over 2.5h | Same |

**Why 8 GB RAM is the floor:** Docker Desktop on macOS/Windows runs everything inside a Linux VM that wants ~2 GB just to exist. NanoClaw + one agent container is another ~1 GB. Add your OS, browser, terminal, maybe an IDE, and you're already past 6 GB. With less than 8 GB, the laptop will swap and exercises will feel sluggish.

**If your laptop is borderline (8 GB exactly):** close everything you don't need during the workshop (Slack, Zoom, Spotify, Chrome tabs you're not using). Bump Docker Desktop's memory allocation to 4 GB in **Settings → Resources**.

### Known blockers, please DM Ondrej before the workshop if any apply

- **Corporate laptop where you can't install software** - bring a personal device or pair with a neighbor.
- **Docker Desktop blocked by IT** - same advice. (Docker Desktop is free for individuals + small biz; some companies block it for licensing reasons.)
- **Less than 8 GB RAM on your laptop** - the workshop will work but it'll be tight. Close other apps during the session.

If anything breaks during setup, message #ai-engineering-workshop on the conference Discord or DM Ondrej directly. Better to fix it before Friday than during.

---

## Schedule

Aligned to Web Summer Camp's published format: **two 1h 15min blocks separated by a 30-min break** (total 2h 30min content + 30 min break = 3h wall clock). Slot booked Thursday July 2 (14:15-15:30 + 16:00-17:15).

Updated 2026-06-10 after end-to-end walkthrough validation. Times reflect what actually happened in the dry run, with explicit buffer for the install step (which is the most variable).

**Goal: every attendee reaches ping/pong by 1:00.** Block B can then go deep on what the agent actually IS rather than burning the second half on more install firefighting.

| Block | Length | Activity |
|---|---|---|
| **Block A – Foundations** (1h 15min) | 0:00 – 1:15 | Intro + ping/pong + first taste of Living Files |
| Break (off-clock, 30 min) | between blocks | Water, restrooms, hallway track, 1:1 troubleshooting with stragglers |
| **Block B – Memory Architecture + GitHub Sync + Where It Scales** (1h 15min) | 1:15 – 2:30 | Living Files debrief, GitHub memory sync hands-on, memory backend options, wrap-up |

### Block A breakdown (75 min)

| Time | Length | What |
|---|---|---|
| 0:00 – 0:20 | 20 min | **Intro** — hook, framing, stack overview, Telegram bot setup (Claude access already done pre-workshop). 20 min buffers late arrivals + tech check. |
| 0:20 – 1:00 | 40 min | **Exercise 1** — install NanoClaw + Telegram pairing + first ping/pong reply |
| 1:00 – 1:15 | 15 min | **Exercise 2 (first taste)** — agent self-edits `CLAUDE.local.md` with 5-question profile; verify personalization. Sets up Block B's deep dive. |

### Block B breakdown (75 min)

The shift: from install to understanding. What did you just build, how does memory actually work, and where does it go next?

| Time | Length | What |
|---|---|---|
| 1:15 – 1:35 | 20 min | **Living Files debrief** — what you gave the agent (5 answers), what you got (`CLAUDE.local.md` profile). Walk the memory architecture: `CLAUDE.md` (always loaded) → memory files (recalled when relevant) → conversation history. Live: open the files, show the diff, ask the agent to re-read and prove it remembers. |
| 1:35 – 2:00 | 25 min | **Exercise 3: GitHub memory sync** — back up your agent's memory to a GitHub repo. Attendees use `gh auth login` in the Linux terminal (no external credential vault). TODO steps: create repo, write sync script, schedule hourly job. Agent memory becomes version-controlled and survives container rebuilds. |
| 2:00 – 2:20 | 20 min | **Memory backends — where this scales** — flat markdown files are the floor. Three paths: **Obsidian** (human-readable vault, same markdown, browseable on phone), **PostgreSQL + pgvector** (semantic search, "what did I work on last quarter similar to this?"), **MCP memory server** (structured recall via Model Context Protocol). Frame: "you pick the right store for the trust level you need." |
| 2:20 – 2:30 | 10 min | **Wrap-up** — what they have, 3 always-on migration recipes, where to go next, QR + follow-up |

### Time estimates per exercise (from the 2026-06-10 walkthrough)

| Exercise | Smooth-path | With buffer | What the walkthrough actually showed |
|---|---|---|---|
| **Ex 1 — Install + ping/pong** | 25 min | 40 min | Container build 3-5 min on laptop overlay2 (was 12 min in DinD VFS). Telegram pairing 2-3 min. First-message cold start 60-90s. Pad for Docker-not-started, wrong-token attendees. |
| **Ex 2 — Living Files first taste** | 10 min | 15 min | Agent does most of the work. Five questions + answers + diff + verification took ~7 min including reads. |
| **Living Files debrief** | 15 min | 20 min | Show the diff from Exercise 2, open `CLAUDE.local.md` and memory files live, ask agent to re-read and prove it remembers a detail. |
| **Ex 3 — GitHub memory sync** | 20 min | 25 min | `gh auth login` → create repo → write sync script → `schedule hourly`. Covers scheduled jobs naturally. Pad for attendees without a GitHub account. |
| **Memory backends talk** | 15 min | 20 min | Obsidian / pgvector / MCP memory server. No hands-on — concept + screenshots. |
| **CKEditor cameo** *(optional)* | 5 min | 5 min | Pure presenter demo. Cut if running behind — works as a one-liner in wrap-up instead. |
| **Wrap-up** | 5 min | 10 min | Always-on migration table (Hetzner / AWS / Pi), the "where to next" list, QR. |

### Cut candidates (in order, if running slow)

1. **CKEditor cameo** — optional by design. Skip the live demo, mention as a "same pattern" closing line in wrap-up.
2. **Exercise 3 attendee task** — keep as presenter demo only; skip the hands-on schedule create from attendees.
3. **Memory backends talk shortened** — drop pgvector + MCP, cover only Obsidian as the immediate take-home option.

If the room is **still stuck on Exercise 1 at 1:00**, push Exercise 2 entirely into Block B and start Block B with "we'll do the personalization that catches everyone up" — 15 min slack for stragglers, no one feels left behind.

---

## Intro (10 min)

**Hook (3 min):** "I bet most of you have spent some time chatting with AI, maybe even one-shotting a few websites. Cool, right? But constantly babysitting a chat window and approving every terminal command is starting to feel like more work than it's saving. The real magic happens when you stop chatting and start delegating."

**Framing in 3 beats (2 min):**
1. Reactive AI (today): you type, it answers, you copy.
2. Proactive AI (today, but rare): an always-on process with verbalized context wakes up, checks something, acts.
3. The gap between (1) and (2) is not a model upgrade. It is a deployment shape - container, files, schedule, channel.

**Credentials setup, in parallel (3 min):** Claude access should already be sorted from pre-workshop (Pro subscription, Anthropic API key, or OpenRouter free key). Confirm with attendees that they have it; help anyone who didn't get it set up. Then everyone does the one quick credential left:

- On phone, open Telegram → DM @BotFather → `/newbot` → pick a name → save the token. You'll paste it during Exercise 1.

**Stack overview (narrated while attendees do credentials):** Local Docker on your laptop. NanoClaw as the agent framework. Anthropic Sonnet 4.5 as the model. Telegram as the channel. Why local Docker? Because we tested the VPS options and they don't work for everyone on day-of (see the findings doc). Local is the only path where every attendee walks out with something running.

**Set expectations:** "By the break you will have a personal agent running on your laptop that knows who you are. By the end you will have it message you on Telegram, on a schedule, without you asking. That's the digital twin we're shipping today. Your laptop has to stay awake for the schedule to fire - I'll show you how to make it always-on after the workshop in the wrap-up."

---

## Block A - Foundations (1h 5min)

### Exercise 1: Deploying the Brain

**Time budget:** ~30 min (minimum viable) / +5 min (stretch)
**Goal (minimum viable):** NanoClaw running in a Docker container on your laptop, paired to your Telegram bot, answering "ping" with "pong".
**Stretch goal:** add a second channel (Discord or Slack) via `/add-discord`.

**Demo cue (presenter):**
- Open a terminal on the presenter laptop, run the install commands, walk through what `nanoclaw.sh` does (verifies Docker, installs Node + pnpm if missing, registers your Anthropic credential, builds the agent container, pairs your first channel).
- Show the Telegram pairing handshake live - the token flow.
- Say "pong" out loud after the bot replies.

**Attendee task:**
1. Verify Docker is running. Open a terminal and run:
   ```bash
   docker run --rm hello-world
   ```
   If this prints "Hello from Docker!", continue. If it fails, raise your hand - we'll pair you with a neighbor while you fix it.
2. Clone and bootstrap NanoClaw on your laptop (as your normal user, not root):
   ```bash
   git clone https://github.com/nanocoai/nanoclaw.git nanoclaw-v2
   cd nanoclaw-v2
   bash nanoclaw.sh
   ```
3. When prompted, paste your **Anthropic API key** (from the intro).
4. When prompted for a channel, choose **Telegram**, paste your **BotFather token** (from the intro), name the agent (suggest your first name).
5. From your phone, DM the bot: `ping`.

> ⚠️ **If `nanoclaw.sh` warns "you are running as root"** (only happens on a fresh VPS, a DinD sandbox, or anywhere your shell is root by default - it should NOT happen on a normal macOS/Windows/Linux laptop session):
>
> 1. Pick **option 1** ("Show me instructions for creating a new Linux user") - this is the recommended path.
> 2. **On a minimal Ubuntu image** (Docker `ubuntu:22.04`, Hetzner/AWS "Minimal" images, etc.), the `sudo` package is not pre-installed. You must install it before the script's instructions will work:
>    ```bash
>    apt update && apt install -y sudo curl git ca-certificates
>    ```
>    Cloud Ubuntu Server images (the default Hetzner/AWS Ubuntu) have these pre-installed; only minimal images need this step. Don't forget on workshop day.
> 3. Follow the script's printed instructions verbatim (`adduser nanoclaw`, `usermod -aG sudo nanoclaw`, the sudoers `echo`).
> 4. Log out (`exit`), then log back in as the new user:
>    - On a real VPS: `ssh nanoclaw@your-server`
>    - In a Docker sandbox: `docker exec -it -u nanoclaw -w /work -e USER=nanoclaw <container-name> bash` (the `-e USER=nanoclaw` is required — NanoClaw's installer dies with `unbound variable: $USER` otherwise)
> 5. Clone the repo again and re-run `bash nanoclaw.sh`.
>
> **Sandbox-only extras** (do NOT do these on a real host):
> - Set `ONECLI_BIND_HOST=127.0.0.1` in `/etc/environment` AND `/etc/bash.bashrc` before running. OneCLI can't auto-detect a bind address inside an unprivileged container.
> - Force the inner dockerd's storage driver to `vfs` (overlay-on-overlay fails). Pre-write `/etc/docker/daemon.json` as `{"storage-driver":"vfs"}`.
> - Manually `nohup node dist/index.js &` to start the agent service — no systemd to do it for you.
> - Bridge OneCLI ports from the sandbox loopback to the inner bridge gateway with `socat` so spawned agent containers can reach it. See [`./findings.md`](./findings.md) for the full recipe; this repo's `docker compose up` bakes all of these into the sandbox image automatically.

**Expected output / checkpoint:**
- Telegram replies with a contextual greeting within **~60-90 seconds of the first message** (the agent container has to cold-start on the first DM; subsequent messages reply in <10s).
- Presenter asks for thumbs up. Aim for 80% before moving on.

**Heads-up on first-message latency:** the very first DM after install triggers an agent container spawn (~30s) + a cold-start LLM call (~30-60s). Tell attendees to send `ping` and **wait quietly** — repeated `ping`s will queue up and the agent will reply to all of them in one go later. Set this expectation out loud or the room will think it's broken.

**Troubleshooting:**

| Symptom | Likely cause | Fix |
|---|---|---|
| `docker run --rm hello-world` fails with "Cannot connect to the Docker daemon" | Docker Desktop not running (macOS/Win) or daemon not started (Linux) | Start Docker Desktop from Applications/Start Menu; on Linux: `sudo systemctl start docker` |
| `docker` command not found | Docker not installed | Pair with a neighbor for this session, install Docker tonight |
| `bash nanoclaw.sh` fails on Docker permission step (Linux) | User not in `docker` group | `sudo usermod -aG docker $USER && newgrp docker`, re-run script |
| Telegram bot never responds (first message, within 60s) | Cold-start delay — agent container is spawning + first LLM call | Wait up to 90s before retrying. Don't send a second `ping` until the first reply lands. |
| Telegram bot never responds (>2 min, no reply) | Pairing race — agent service started after the code expired, queue swallowed an old code | DM the bot `/start` again from your phone. If still silent, presenter runs the bundled `pair-telegram-recover.sh` (drains queue + restarts pair-telegram step). |
| Anthropic API returns 401 | Key not saved, or wrong region | Re-paste key, confirm it starts with `sk-ant-`, check Anthropic console for org region |
| Container exits immediately after `bash nanoclaw.sh` | Not enough RAM allocated to Docker Desktop (default 2 GB on macOS) | Docker Desktop → Settings → Resources → bump Memory to 4-6 GB, restart Docker |
| Agent container logs show `API retry (retryable: true)` forever | Agent container can't reach OneCLI vault (network issue) | Should not happen on a normal laptop Docker — `host.docker.internal` is wired by Docker Desktop. If it does, restart Docker Desktop. If you're inside a sandboxed/nested Docker setup, see `findings.md` for the socat bridge fix. |

**Sources / refs:** https://github.com/nanocoai/nanoclaw , https://core.telegram.org/bots#how-do-i-create-a-bot

---

### Exercise 2: Living Files

> **Heads-up on the file shape.** Where OpenClaw splits context across 9 files (`soul.md`, `user.md`, `heartbeat.md`, `tools.md`, `identity.md`, ...), NanoClaw uses **one `CLAUDE.md` per agent**, plus the agent's memory, plus installable skills. Same mental model, one file to learn first. Tone, identity, rules, and API references all live as sections inside `CLAUDE.md`; long-term recall lives in the agent's memory; new capabilities arrive as skills (`/add-*`). The file name is a Claude Code convention - if you swap the provider via `/add-codex` or `/add-opencode`, the file stays `CLAUDE.md` (NanoClaw reads it regardless of provider).

**Time budget:** ~25 min (minimum viable) / +5 min (stretch)
**Goal (minimum viable):** your agent's `CLAUDE.md` (and a per-agent `personal/` folder) contains enough about you that when you message "what should I focus on this afternoon?", the reply references your actual stack, role, and current project - not generic advice.
**Stretch goal:** add a `business/goals.md` and `personal/goals.md`, then have the agent self-edit `CLAUDE.md` to link to them.

**Demo cue (presenter):**
- Open the agent's workspace folder, show the freshly-created `CLAUDE.md`.
- DM the bot: `ask me 5 questions to get to know me, then write a draft user profile into CLAUDE.md`.
- Read the questions out loud, answer 2 of them on stage, show the diff in `CLAUDE.md`.
- "Notice what just happened. We didn't write code. We verbalized."

**Attendee task:**
1. From Telegram, send: `show me the current contents of CLAUDE.md`.
2. Send: `ask me 5 short questions to learn the basics about me - role, stack, time zone, what I'm working on this week, communication style.`
3. Answer them in chat.
4. Send: `update CLAUDE.md with what you learned. Then show me the new file.`
5. Test: send `given what you now know about me, what should I focus on this afternoon?` - check that the reply is specific to you.

**Expected output / checkpoint:**
- `CLAUDE.md` shows your name, role, stack, and current focus, written in the agent's voice.
- The "what should I focus on" reply mentions at least one detail from your answers (not generic).

**Troubleshooting:**

| Symptom | Likely cause | Fix |
|---|---|---|
| Agent says it can't edit files | Workspace mount missing or read-only | Check `docker inspect <container>` for the workspace mount, re-run `bash nanoclaw.sh` if missing |
| `CLAUDE.md` change doesn't persist between messages | Per-session container, no volume | NanoClaw mounts a per-agent volume by default; if persistence fails, the install picked a transient container - re-bootstrap and pick "keep state" when prompted |
| Reply is generic despite saved context | Context not loaded into the system prompt | DM `re-read your CLAUDE.md from disk before answering` once, then retry |

**Sources / refs:** NanoClaw per-agent workspace docs, the OpenClaw "living files" framing (https://www.youtube.com/watch?v=cod50CWlZeU)

---

### Bonus: voice messages (~5 min, optional, can run during checkpoint)

NanoClaw + Telegram bots accept voice notes out of the box, but transcription requires an OpenAI API key (Whisper).

**Demo cue (presenter):**

- Send a voice note from your phone to the bot: "Can you hear what I'm saying?"
- Agent replies with a graceful fallback message + a one-click URL to connect OpenAI in OneCLI (`http://127.0.0.1:10254/connections/...`).
- Walk through clicking the URL, pasting an OpenAI API key, and re-sending the voice note. Show it transcribed and answered.

**Attendee task (optional, only if they have an OpenAI key):**

1. Send a voice note to your bot.
2. Click the OneCLI link the bot replies with.
3. Paste an OpenAI API key (`sk-...`), confirm.
4. Re-send the voice note. Confirm it gets transcribed and answered.

**Workshop framing line:** "Same pattern as everything else we've done — the agent doesn't have a capability, it tells you exactly how to grant it, you say yes once, it has it forever. No coding."

### Block A checkpoint (10 min buffer)

Presenter walks the room. Anyone stuck on Exercise 1 gets a 1:1; anyone past Exercise 2 starts on a stretch goal. Last bullet before the break: **"Don't close your laptop or let it sleep during the break - the container dies with the host. Plug into power. If your laptop must sleep, the bot will go silent and you'll need to restart the container after."**

---

## Break (15 min)

Water, restrooms, hallway track. Presenter stays in the room for 1:1 troubleshooting with anyone whose container didn't come up.

---

## Block B - Memory Architecture + GitHub Sync + Where It Scales (75 min)

### Living Files debrief (20 min)

**Goal:** attendees understand what they just built and why it works.

**Demo cue (presenter):**
- Open the agent's workspace in the terminal: `ls` the files, `cat CLAUDE.local.md`, open the memory folder.
- Show the diff from Exercise 2 — these are the actual words the agent will carry into every future conversation.
- DM the agent: `re-read your CLAUDE.local.md and tell me one specific thing you remember about me that you didn't know before this workshop.`
- Point at the structure: `CLAUDE.md` (always loaded — identity, rules, skills) vs `CLAUDE.local.md` (per-agent memory — who you are, what you care about) vs memory files (longer-term recall, recalled when relevant) vs conversation history (searchable transcripts).

**Framing line:** "This is just text. Text you wrote in a chat window. The agent reads it every time it wakes up. That's the whole trick — verbalized context beats clever prompting."

---

### Exercise 3: GitHub Memory Sync (25 min)

**Time budget:** ~20 min (minimum viable) / +5 min (stretch)
**Goal (minimum viable):** agent memory backed up to a private GitHub repo, syncing on a schedule. Memory survives container rebuilds and is version-controlled.
**Stretch goal:** add a second scheduled job that auto-commits the conversation history folder too.

**Why this exercise:** the agent's memory lives in files on the container. If the container is rebuilt, the files survive (named volume), but a version-controlled off-site backup adds a safety net — and it shows scheduled jobs in a real-world use case rather than a toy example.

**No external credential vault needed.** Attendees authenticate with GitHub directly from the Linux terminal using the `gh` CLI. No OneCLI, no OAuth app setup.

**Demo cue (presenter):**
- Show the memory files live: `ls ~/nanoclaw-workspace/<group>/memory/`
- Create a repo on GitHub (via the UI or `gh repo create`), run `gh auth login` in the terminal to authenticate.
- Write a sync script live (or paste from the workshop repo's `scripts/` folder), run it once, verify the files appear on GitHub.
- DM the agent: `schedule an hourly job to run the sync script at ~/sync-memory.sh`.
- Show the scheduled job in the agent's list.

**Attendee TODO steps:**

```bash
# 1. Authenticate with GitHub
gh auth login   # pick HTTPS, browser-based auth

# 2. Create a memory backup repo
gh repo create my-agent-memory --private --confirm

# 3. Clone it and copy in your current memory files
git clone https://github.com/<you>/my-agent-memory ~/my-agent-memory
cp -r ~/nanoclaw-workspace/<group>/memory/. ~/my-agent-memory/memory/
cp ~/nanoclaw-workspace/<group>/CLAUDE.local.md ~/my-agent-memory/

# 4. First commit
cd ~/my-agent-memory
git add -A && git commit -m "Initial memory snapshot" && git push

# 5. Write the sync script
cat > ~/sync-memory.sh << 'EOF'
#!/bin/bash
set -e
REPO=~/my-agent-memory
cp -r ~/nanoclaw-workspace/<group>/memory/. "$REPO/memory/"
cp ~/nanoclaw-workspace/<group>/CLAUDE.local.md "$REPO/"
cd "$REPO"
git add -A
git diff --cached --quiet && exit 0
git commit -m "Sync $(date -u +%Y-%m-%dT%H:%M:%SZ)"
git push
EOF
chmod +x ~/sync-memory.sh

# 6. Test it
bash ~/sync-memory.sh
```

**Then DM your agent:**
> `schedule a recurring job: every hour, run the script at ~/sync-memory.sh`

**Expected output / checkpoint:**
- The repo on GitHub shows the memory files.
- `list my scheduled jobs` shows an hourly sync job.
- DM: `run that job now, once` — a new commit appears on GitHub within ~60 seconds.

**Troubleshooting:**

| Symptom | Likely cause | Fix |
|---|---|---|
| `gh auth login` fails | `gh` CLI not installed | `sudo apt install gh` or download from https://cli.github.com |
| `git push` asks for credentials | gh auth not wired to git | Run `gh auth setup-git` |
| Script can't find the memory folder | Wrong `<group>` path | `ls ~/nanoclaw-workspace/` to find the correct group folder name |
| Scheduled job runs but nothing commits | No changes since last run | Expected — the script exits cleanly when there's nothing new |

---

### Memory backends — where this scales (20 min)

Presenter talk, no attendee hands-on. Goal: show that what they built today is the floor, not the ceiling.

**Three paths forward:**

**1. Obsidian** — same markdown files, human-readable vault, sync to phone via iCloud/Obsidian Sync. The agent writes files it reads; you browse the same files in Obsidian on your phone. Zero migration — the files you just pushed to GitHub are already valid Obsidian notes. Good for: personal knowledge management, you want to read/edit memory yourself.

**2. PostgreSQL + pgvector** — store memory as vector embeddings. Instead of "load all memory files into context," the agent runs a semantic search: "what did I work on last quarter similar to this?" Returns the 3 most relevant notes, not all 50. Good for: large memory sets, "find similar" queries, sharing a memory store across multiple agents.

**3. MCP memory server** — a Model Context Protocol server that exposes structured memory tools: `remember(key, value)`, `recall(query)`, `forget(key)`. The agent calls these tools instead of reading files directly. Swappable backend (SQLite, Postgres, cloud), no file management. Good for: production setups, multi-agent memory sharing, audit trails.

**Framing line:** "Today you learned the mental model. Markdown files make it transparent — you can read exactly what the agent knows. When you outgrow that, swap the store. The agent's behavior doesn't change. Only the backend does."

---

### CKEditor cameo *(optional — cut if running behind)*

Pure presenter demo, no attendee task. Skip to wrap-up if the room is at 2:15 or later.

**Goal:** show one realistic API integration as a closing demo.

- DM the demo agent: `take the bullets from this morning's brief and post them into the WSC weekly notes CKEditor doc (https://...) as a new section dated today.`
- The agent calls CKEditor's REST API (token pre-loaded in `CLAUDE.md` under an "Available APIs" section), creates a new section, replies with the document URL.
- One-line takeaway: "Same shape as the Telegram channel. Same shape as the GitHub sync. Any API your day-job touches plugs in the same way."

---

## Wrap-up & take-home (5 min)

**What you have right now:**
- A NanoClaw container running on your laptop.
- A `CLAUDE.md` (and `personal/` folder) that describes the actual you.
- A web-research tool wired to OpenRouter.
- A scheduled morning brief on Telegram - **as long as your laptop is awake**.
- A working mental model for the next 10 integrations you'll add.

### Make your agent always-on (3 named recipes)

Your laptop sleeps. The agent dies with it. To get the "wakes up while you grab coffee" magic, migrate the container to something that's always on:

| Option | Cost | Friction | Setup time |
|---|---|---|---|
| **Hetzner CAX11** (Germany or Finland) | **€4.51/mo** | CC required, instant signup | ~10 min: provision ARM VM, SSH in, run the same `bash nanoclaw.sh`. Recommended path. |
| **AWS t4g.small** | **Free 12 months**, then ~$15/mo | CC required, $1 hold | ~15 min: EC2 wizard, ARM Graviton instance, security group for SSH, run `bash nanoclaw.sh`. Pick this for the "free for the workshop year" path. |
| **Mac Mini / Raspberry Pi at home** | **Free** (if owned) | None | ~20 min if you have one running: SSH from anywhere, run `bash nanoclaw.sh`. Best home-lab option. |
| ~~Oracle Cloud Always Free~~ | Forever-free | CC, ~15 min signup | **Capacity roulette.** A1 ARM is region-locked and frequently "Out of capacity" (see `findings.md`). Tempting on paper but not reliable enough to recommend. Try it if you must, have a backup. |

All four migrations follow the same shape: `git clone nanoclaw && bash nanoclaw.sh` on the destination host. The `CLAUDE.md` you built today, the OpenRouter rule, the scheduled jobs - all of it transfers (the install script asks if you want to import an existing agent workspace).

### Other things to do next

- **Swap LLM provider.** Don't want to pay Anthropic forever? Inside the agent run `/add-codex` for OpenAI (ChatGPT subscription or API key), `/add-opencode` for OpenRouter / Google / DeepSeek, or `/add-ollama-provider` for local open-weight models. The `CLAUDE.md` you built today works as-is - it's a Claude Code convention, not a hard provider lock.
- **Add a second channel.** Slack for work, Discord for community, WhatsApp for friends. `/add-slack`, `/add-discord`, etc.
- **Connect Google Calendar.** Pick up the calendar-webhook stretch from Exercise 3.
- **Write a `personal/playbooks/` folder** with one SOP per recurring task you do.
- **Want the "easy button" instead?** Hostinger ships a one-click **Managed OpenClaw** ($5.99/mo intro, AI credits pre-loaded) or **OpenClaw on VPS** ($8.99/mo intro, 2 vCPU / 8 GB / 100 GB NVMe). Different framework, different file model (9 files vs `CLAUDE.md`), but zero setup and a 30-day money-back to try it.

**Follow-up:**
- Workshop repo: https://github.com/<placeholder> (issues welcome, especially "I tried X and Y broke")
- Verification log of the host paths we tried and why we picked local Docker: `findings.md` in the workshop repo (Railway DinD failure + Oracle Amsterdam capacity failure, with screenshots).
- Ondrej on LinkedIn / Bluesky - find me after for a 1:1
- Slide deck + this outline live at https://ondrej.chrastina.dev/
- QR on the last slide

---

## Backup plans

| Dependency | Failure mode | Backup |
|---|---|---|
| Attendee Docker install | Didn't install pre-workshop, or install fails on-site | Pair with a neighbor (read-only follow-along), 1:1 install help during the break, take-home recipe for post-workshop |
| Attendee Docker Desktop | Crashes / out-of-memory mid-session | Restart Docker Desktop, bump RAM allocation to 4-6 GB in Settings → Resources, re-run last command |
| Attendee laptop too low-spec | Can't allocate enough RAM to Docker, exercises feel unusable | Pair with a neighbor; presenter offers their spare laptop or a screen-share session as fallback |
| Anthropic API | Outage or 529 | Presenter runs `/add-codex` (OpenAI) or `/add-opencode` (OpenRouter) on the demo agent to keep the live walkthrough moving; attendees pair with someone whose region is unaffected |
| Telegram | Banned country / phone issues | Discord via `/add-discord` - same flow, different token; attendee pairs with someone who has Telegram for the demo and switches at home |
| Venue WiFi | Down or unusable | Presenter hotspots from phone; attendees pair to share. Critical because Anthropic API + Telegram + OpenRouter all need outbound HTTPS. Worst case, present from a pre-recorded screencast of Exercise 1-4 and let attendees follow along offline-then-deploy |
| NanoClaw repo down | Rare but happens | Pre-mirrored tarball on a USB stick + on the workshop repo |

---

## Sources

- **Verification log of the host paths we tried and rejected:** [`./findings.md`](./findings.md) - records Railway DinD failure (Permission denied on cgroup mount, 2026-06-09) and Oracle Cloud Amsterdam capacity failure (Out of capacity for `VM.Standard.A1.Flex`, 2026-06-09). Screenshots in [`./recordings/`](./recordings/).
- OpenClaw walkthrough video (reference architecture): https://www.youtube.com/watch?v=cod50CWlZeU
- OpenClaw agent-workspace docs (9-file system, verbatim purposes): https://github.com/openclaw/openclaw/blob/main/docs/concepts/agent-workspace.md
- OpenClaw bootstrapping docs: https://docs.openclaw.ai/start/bootstrapping
- OpenClaw default AGENTS.md reference: https://docs.openclaw.ai/reference/AGENTS.default
- NanoClaw repo: https://github.com/nanocoai/nanoclaw
- Docker Desktop download (macOS/Windows): https://www.docker.com/products/docker-desktop/
- Docker Engine install for Linux (one-liner): https://get.docker.com
- Hetzner Cloud (CAX11 ARM): https://www.hetzner.com/cloud
- AWS EC2 Free Tier (t4g.small ARM): https://aws.amazon.com/free/
- Oracle Cloud Always Free (not recommended, capacity roulette): https://www.oracle.com/cloud/free/
- Hostinger OpenClaw hosting (Managed + VPS plans, "easy button" paid option): https://www.hostinger.com/vps/openclaw-hosting
- OpenClaw on Hostinger install guide: https://docs.openclaw.ai/install/hostinger
- OpenRouter Sonar Pro Search: https://openrouter.ai/perplexity/sonar-pro-search
- Web Summer Camp 2026 AI track: https://websummercamp.com/2026/program/ai
- User's working outline (Notion, private): "Beyond the Chatbot: Engineering Your Proactive Digital Twin"
