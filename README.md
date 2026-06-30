# Proactive Digital Twin — Workshop Kit

A hands-on workshop kit for **"Beyond the Chatbot: Engineering Your Proactive Digital Twin"**. You spin up a Linux Ubuntu VM, install NanoClaw (an autonomous agent framework), pair it to Telegram, and build an agent that wakes up on its own schedule — while you grab a coffee.

> **This is an Anthropic / Claude-first repository.** It's built around Claude (Claude Code, the `claude` CLI, and skills in `.claude/skills/`). Codex / OpenAI works as an alternative throughout — wherever you see a Claude command, there's a Codex equivalent.

## Contents

- [Getting started](#getting-started)
  - [1. Install NanoClaw](#1-install-nanoclaw)
  - [2. Living files](#2-living-files)
  - [3. GitHub knowledge capture](#3-github-knowledge-capture)
  - [4. Scheduled morning brief](#4-scheduled-morning-brief)
- [What's in this repo](#whats-in-this-repo)
- [After the workshop](#after-the-workshop---moving-to-an-always-on-host)
- [Gotchas](#gotchas)
- [License](#license)
- [Acknowledgements](#acknowledgements)

## Getting started

Work through these in order: set up your machine, install the agent, then the two hands-on exercises. Each step has a Claude Code skill that walks you through it one prompt at a time - you drive the commands, the skill highlights the exact next step.

### Prerequisites

Set these up at home before the workshop, not on conference WiFi.

#### 1. A booted Linux VM (Ubuntu 26.04 / 24.04 / 22.04 LTS) — the hard prerequisite

Install a free virtualization tool, then download and boot an Ubuntu LTS ISO inside it.

| Host OS | Virtualization tool                              |
| ------- | ------------------------------------------------ |
| macOS   | [UTM](https://mac.getutm.app/) (free)            |
| Windows | [VirtualBox](https://www.virtualbox.org/) (free) |
| Linux   | KVM / `virt-manager` (free)                      |

Download **Ubuntu 26.04 LTS** (24.04 / 22.04 also work) from [ubuntu.com](https://ubuntu.com/download/desktop). Create the VM and **allocate at least 8 GB RAM** and **at least 30 GB disk (40 GB comfortable)**. The installer warns below ~4 GB RAM, and 8 GB keeps the host plus the agent container comfortable (so plan on a **16 GB laptop**). A full install plus the Docker images fills ~20 GB, so do **not** use the default ~20 GB disk - it fills up mid-setup (~90% full). Complete the Ubuntu setup wizard, and boot it to the desktop at least once.

> **Recommended: run the VM natively, not emulated.** For the smoothest experience, the Ubuntu image that matches your computer's CPU architecture is the better pick, so the VM runs on the native CPU rather than emulating a different one (emulation works, but it's several times slower). On **Apple Silicon (M-series) Macs** that's the **ARM64** image; on **Intel/AMD** machines, the **x86_64 / amd64** image (with VT-x / AMD-V enabled in BIOS).

#### 2. AI access — one of

- Claude: [Pro or higher subscription](https://claude.ai) **or** [Anthropic API key](https://console.anthropic.com)
- OpenAI: [ChatGPT Plus or higher](https://openai.com) **or** [API key](https://platform.openai.com) — install the `/add-codex` skill after setup to switch providers

#### 3. Telegram (on your phone)

Install [Telegram](https://telegram.org) on your phone - it's the channel you'll DM your agent on. You can create the bot now or during the workshop intro: message [@BotFather](https://t.me/botfather), send `/newbot`, pick a name, and **save the token** (you paste it during install). Takes ~2 minutes.

#### 4. Pre-cache the install on the VM (recommended - saves conference WiFi)

The workshop-day install pulls roughly **2 GB** (Docker images, the agent container build, apt/npm packages). Pull the heavy, unchanging parts **at home on good WiFi** so the day-of install pulls little or nothing.

Run the pre-cache script - [`scripts/prepare.sh`](scripts/prepare.sh) - **inside your Ubuntu VM**. It runs the full pre-cache with no prompts (and is safe to re-run):

```bash
sudo apt-get update && sudo apt-get install -y curl ca-certificates && curl -fsSL https://raw.githubusercontent.com/Simply007/proactive-digital-twin-workshop/main/scripts/prepare.sh | bash
```

It installs the toolchain (Docker, Node, pnpm, and the Claude + Codex CLIs), pulls the base image, pre-builds the agent container image, and pre-pulls the host deps + OneCLI/Postgres images - so on the workshop day only your credentials and Telegram pairing remain (essentially **0 download**). On a fresh VM it stops once after installing Docker and asks you to reboot the VM, then re-run the same command.

> **Why it pins a version.** NanoClaw may release an update between your prep and the workshop. The script pins the clone to `v2.1.17`, and you use the same pin on the day, so you install exactly what you pre-cached - no surprise re-download or behavior change on conference WiFi.

### 1. Install NanoClaw

In one pass, you'll:

1. **Install NanoClaw** — clone the repo and run the installer (it sets up Docker, Node, and pnpm).
2. **Add your AI key** — paste your Claude subscription login or Anthropic API key when prompted.
3. **Hook up Telegram** — create a bot with [@BotFather](https://t.me/botfather), paste its token, and pair the bot so you can DM your agent. (Have Telegram on your phone.)

Open a terminal inside your Ubuntu VM and run:

```bash
git clone --branch v2.1.17 https://github.com/nanocoai/nanoclaw.git
cd nanoclaw
bash nanoclaw.sh
```

`nanoclaw.sh` installs Node, pnpm, and Docker automatically. It then asks for your AI credentials, time zone, and Telegram bot token.

When it finishes, DM your bot `ping` from your phone — the agent replies within ~60-90 seconds on first start, sub-10s after that.

For a guided, prompt-by-prompt install, use the [`nanoclaw-install`](.claude/skills/nanoclaw-install/SKILL.md) skill from the cloned repo:

```bash
# Claude Code (auto-discovers skills in .claude/skills/)
claude "/nanoclaw-install"

# Codex (alternative) - point it at the skill file
codex   # then type:  Follow .claude/skills/nanoclaw-install/SKILL.md and walk me through installing NanoClaw step by step.
```

### 2. Living files

Teach the agent who you are. Ask it how its memory is structured, look at the `system/definition.md` that defines that structure, then have it interview you and write a profile into its memory - so its replies become specific to you, not generic. This is the "verbalize, don't code" core of the workshop.

```bash
# Claude Code (auto-discovers skills in .claude/skills/)
claude "/living-files"

# Codex (alternative) - point it at the skill file
codex   # then type:  Follow .claude/skills/living-files/SKILL.md and walk me through giving my agent its memory.
```

See the [`living-files`](.claude/skills/living-files/SKILL.md) skill for the full walkthrough.

### 3. GitHub knowledge capture

Capture the outputs you approve into a **private GitHub repo** as portable Markdown notes. You connect GitHub to OneCLI once (via an OAuth app), then say a trigger phrase - the agent drafts a note (frontmatter + body), you approve, and it pushes to the repo.

```bash
# Claude Code (auto-discovers skills in .claude/skills/)
claude "/github-knowledge-capture"

# Codex (alternative) - point it at the skill file
codex   # then type:  Follow .claude/skills/github-knowledge-capture/SKILL.md and walk me through capturing my agent's outputs to GitHub.
```

See the [`github-knowledge-capture`](.claude/skills/github-knowledge-capture/SKILL.md) skill for the full walkthrough.

### 4. Scheduled morning brief

Teach the agent its first **scheduled job**: a daily morning brief it sends on its own clock. You describe the schedule in plain language; the agent creates it with `schedule_task`, and you confirm with `list my scheduled tasks` and `run it once now`.

```bash
# Claude Code (auto-discovers skills in .claude/skills/)
claude "/scheduled-brief"

# Codex (alternative) - point it at the skill file
codex   # then type:  Follow .claude/skills/scheduled-brief/SKILL.md and walk me through scheduling a daily morning brief.
```

See the [`scheduled-brief`](.claude/skills/scheduled-brief/SKILL.md) skill for the full walkthrough.

## What's in this repo

```plain
.
├── workshop/
│   ├── outline.md              # the workshop walkthrough (intro, exercises, schedule, wrap-up)
│   ├── abstract.md             # session title, abstract, prerequisites, takeaways
│   ├── providers.md            # host/VPS comparison - which providers were tested and how they fared
│   ├── use-cases-relatable.md  # use cases for the "Connecting the Dots" / use-case exercise
│   └── use-cases-untested.md   # extra ideas not yet validated in the flow
├── .claude/skills/
│   ├── nanoclaw-install/       # walks you through installing NanoClaw (Preparation 1)
│   ├── living-files/           # walks you through the agent's memory (Preparation 2)
│   ├── github-knowledge-capture/  # capture approved outputs to GitHub as portable notes (Exercise 3)
│   └── scheduled-brief/        # schedule a recurring morning brief (Exercise 4)
└── dind-sandbox/               # presenter-only Docker-in-Docker sandbox + what we tried and rejected
    ├── README.md               # how the sandbox works and how to run it
    ├── findings.md             # Railway, Oracle, and DinD gotchas (why DinD is problematic)
    └── ...                     # docker-compose.yml, docker/, scripts/, the dind skill, recordings/
```

### The Skill that walks you through it

This kit ships Claude Code skills under [`.claude/skills/`](.claude/skills/) that guide a person through the workshop one step at a time: [`nanoclaw-install`](.claude/skills/nanoclaw-install/SKILL.md) (install + first ping/pong), [`living-files`](.claude/skills/living-files/SKILL.md) (give the agent its memory), [`github-knowledge-capture`](.claude/skills/github-knowledge-capture/SKILL.md) (capture approved outputs to a portable GitHub repo), and [`scheduled-brief`](.claude/skills/scheduled-brief/SKILL.md) (schedule a recurring morning brief). Claude Code auto-discovers them; Codex can use the same `SKILL.md` files by path. You drive the commands; the skill highlights the exact next step and runs only read-only checks.

## After the workshop - moving to an always-on host

Your VM pauses when the laptop sleeps, so the agent goes quiet with it. **Once you're confident in the local VM playground**, you can move the agent to something always-on: a VPS (Hetzner, AWS, Oracle, GCP, Azure, Hostinger, Railway) or a home box (Mac Mini, Raspberry Pi). The wrap-up in [`workshop/providers.md`](workshop/providers.md) covers this.

Every migration is the same shape: provision Linux, SSH in, run the same `bash nanoclaw.sh`. The `CLAUDE.md`, scheduled jobs, and integrations you built in the workshop all transfer.

## Gotchas

### NOGO Docker-in-Docker setup

> [!CAUTION]
> **TL;DR:** Do not try to run the [Docker-in-Docker setup](https://www.docker.com/resources/docker-in-docker-containerized-ci-workflows-dockercon-2023/) of NanoClaw. I went through the pain so that you don't have to.

See [`dind-sandbox/README.md`](dind-sandbox/README.md) to run it, [`dind-sandbox/findings.md`](dind-sandbox/findings.md) for the 9 DinD-specific issues, and [`dind-sandbox/architecture.md`](dind-sandbox/architecture.md) for the full setup explanation.

## License

MIT. Take it, fork it, run your own workshop. Credit appreciated, not required.

## Acknowledgements

- **NanoClaw** maintainers — the underlying framework.
- **Web Summer Camp 2026 organizers** — for booking a hands-on slot in the AI Engineering track.
