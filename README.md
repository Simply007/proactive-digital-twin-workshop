# Proactive Digital Twin — Workshop Kit

A hands-on workshop kit for **"Beyond the Chatbot: Engineering Your Proactive Digital Twin"**. You spin up a Linux Ubuntu VM, install NanoClaw (an autonomous agent framework), pair it to Telegram, and build an agent that wakes up on its own schedule — while you grab a coffee.

## Prerequisites

Set these up at home before the workshop, not on conference WiFi.

### 1. A booted Linux VM (Ubuntu 24.04 or 22.04 LTS) — the hard prerequisite

Install a free virtualization tool, then download and boot an Ubuntu LTS ISO inside it.

| Host OS | Virtualization tool                              |
| ------- | ------------------------------------------------ |
| macOS   | [UTM](https://mac.getutm.app/) (free)            |
| Windows | [VirtualBox](https://www.virtualbox.org/) (free) |
| Linux   | KVM / `virt-manager` (free)                      |

Download **Ubuntu 24.04 LTS** (or 22.04) from [ubuntu.com](https://ubuntu.com/download/desktop). Create the VM (allocate at least 4 GB RAM and 20 GB disk), complete the Ubuntu setup wizard, and boot it to the desktop at least once.

### 2. AI access — one of

- Claude: [Pro or higher subscription](https://claude.ai) **or** [Anthropic API key](https://console.anthropic.com)
- OpenAI: [ChatGPT Plus or higher](https://openai.com) **or** [API key](https://platform.openai.com) — install the `/add-codex` skill after setup to switch providers

### 3. Telegram

Telegram on your phone (any account). You'll create a bot via [@BotFather](https://t.me/botfather).

## Quick start — install NanoClaw

In one pass, you'll:

1. **Install NanoClaw** — clone the repo and run the installer (it sets up Docker, Node, and pnpm).
2. **Add your AI key** — paste your Claude subscription login or Anthropic API key when prompted.
3. **Hook up Telegram** — paste your bot token and pair the bot so you can DM your agent.

Open a terminal inside your Ubuntu VM and run:

```bash
git clone https://github.com/nanocoai/nanoclaw.git
cd nanoclaw
bash nanoclaw.sh
```

`nanoclaw.sh` installs Node, pnpm, and Docker automatically. It then asks for your AI credentials, time zone, and Telegram bot token.

When it finishes, DM your bot `ping` from your phone — the agent replies within ~60-90 seconds on first start, sub-10s after that.

For a guided, prompt-by-prompt install, use the [`nanoclaw-install`](.agents/skills/nanoclaw-install/SKILL.md) skill.

## What's in this repo

```
.
├── workshop/
│   ├── outline.md              # the workshop walkthrough (intro, exercises, schedule, wrap-up)
│   ├── abstract.md             # session title, abstract, prerequisites, takeaways
│   ├── providers.md            # host/VPS comparison - which providers were tested and how they fared
│   ├── use-cases-relatable.md  # use cases for the "Connecting the Dots" / use-case exercise
│   └── use-cases-untested.md   # extra ideas not yet validated in the flow
├── .agents/skills/
│   └── nanoclaw-install/       # a Skill that walks you through installing NanoClaw
└── dind-sandbox/               # presenter-only Docker-in-Docker sandbox + what we tried and rejected
    ├── README.md               # how the sandbox works and how to run it
    ├── findings.md             # Railway, Oracle, and DinD gotchas (why DinD is problematic)
    └── ...                     # docker-compose.yml, docker/, scripts/, the dind skill, recordings/
```

## The Skill that walks you through it

This kit ships Claude Code skills under [`.agents/skills/`](.agents/skills/) that guide a person through the workshop one step at a time. The first is [`nanoclaw-install`](.agents/skills/nanoclaw-install/SKILL.md), which walks you through installing NanoClaw and reaching your first ping/pong (more skills for the later exercises are being split out). You drive the commands; the skill highlights the exact next step and runs only read-only checks.

## After the workshop - moving to an always-on host

Your VM pauses when the laptop sleeps, so the agent goes quiet with it. **Once you're confident in the local VM playground**, you can move the agent to something always-on: a VPS (Hetzner, AWS, Oracle, GCP, Azure, Hostinger, Railway) or a home box (Mac Mini, Raspberry Pi). The wrap-up in [`workshop/outline.md`](workshop/outline.md) covers this.

Every migration is the same shape: provision Linux, SSH in, run the same `bash nanoclaw.sh`. The `CLAUDE.md`, scheduled jobs, and integrations you built in the workshop all transfer.

For a comparison of the providers we tested and how each fared, see [`workshop/providers.md`](workshop/providers.md). Note: **Docker-in-Docker is problematic** as a host - see [`dind-sandbox/findings.md`](dind-sandbox/findings.md) for the crash details.

## Presenter sandbox (Docker-in-Docker)

> warning TL;DR; - Do not try to run the Docker-in-docker setup of the NanoClaw. I wen through the pain, so that you don't need you.

See [`dind-sandbox/README.md`](dind-sandbox/README.md) to run it, [`dind-sandbox/findings.md`](dind-sandbox/findings.md) for the 9 DinD-specific issues, and [`dind-sandbox/architecture.md`](dind-sandbox/architecture.md) for the full setup explanation.

## License

MIT. Take it, fork it, run your own workshop. Credit appreciated, not required.

## Acknowledgements

- **NanoClaw** maintainers — the underlying framework.
- **Web Summer Camp 2026 organizers** — for booking a hands-on slot in the AI Engineering track.
