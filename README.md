# Proactive Digital Twin — Workshop Kit

A hands-on workshop kit for **"Beyond the Chatbot: Engineering Your Proactive Digital Twin"**. You spin up a Linux Ubuntu VM, install NanoClaw (an autonomous agent framework), pair it to Telegram, and build an agent that wakes up on its own schedule — while you grab a coffee.

Built and validated for **Web Summer Camp 2026, Opatija** (July 2). Every failure mode is captured and the working setup is pinned so you don't debug from scratch.

## Quick start (primary path — Linux VM)

### 1. Spin up a Linux Ubuntu LTS VM

| Host OS | Virtualization tool |
|---------|---------------------|
| macOS | [UTM](https://mac.getutm.app/) (free) |
| Windows | [VirtualBox](https://www.virtualbox.org/) (free) |
| Linux | KVM / `virt-manager` (free) |

Download **Ubuntu 24.04 LTS** (or 22.04). Allocate at least 4 GB RAM and 20 GB disk. Start the VM, complete the Ubuntu setup wizard, and open a terminal.

### 2. Install NanoClaw inside the VM

```bash
# Inside the Ubuntu VM terminal
git clone https://github.com/nanocoai/nanoclaw.git
cd nanoclaw
bash nanoclaw.sh
```

`nanoclaw.sh` installs Node, pnpm, and Docker automatically. It then asks for your AI credentials, time zone, and Telegram bot token.

When it finishes, DM your bot `ping` from your phone — the agent replies within ~60-90 seconds on first start, sub-10s after that.

### 3. What you need before the workshop

- **VM software** — UTM, VirtualBox, or KVM (see above, all free).
- **Ubuntu 24.04 or 22.04 LTS** ISO — download from [ubuntu.com](https://ubuntu.com/download/desktop).
- **AI access** — one of:
  - Claude: [Pro or higher subscription](https://claude.ai) **or** [Anthropic API key](https://console.anthropic.com)
  - OpenAI: [ChatGPT Plus or higher](https://openai.com) **or** [API key](https://platform.openai.com) — install the `/add-codex` skill after setup to switch providers
- **Telegram** on your phone (any account). You'll create a bot via `@BotFather`.

## What's in this repo

```
.
├── workshop/
│   ├── outline.md              # the workshop walkthrough (intro, exercises, schedule, wrap-up)
│   ├── use-cases-relatable.md  # use cases for the "Connecting the Dots" / use-case exercise
│   └── use-cases-untested.md   # extra ideas not yet validated in the flow
├── .agents/skills/
│   └── workshop-walkthrough/   # a Skill that guides you through the workshop step by step
└── dind-sandbox/               # presenter-only Docker-in-Docker sandbox + what we tried and rejected
    ├── README.md               # how the sandbox works and how to run it
    ├── findings.md             # Railway, Oracle, and DinD gotchas (why DinD is problematic)
    └── ...                     # docker-compose.yml, docker/, scripts/, the dind skill, recordings/
```

## The Skill that walks you through it

This kit ships a Claude Code skill, [`.agents/skills/workshop-walkthrough`](.agents/skills/workshop-walkthrough/SKILL.md), that guides a person through the whole workshop one step at a time: spin up the VM, install NanoClaw, pair Telegram, get ping/pong, then Living Files, GitHub memory sync, and a real use case. You drive the commands; the skill highlights the exact next step and runs only read-only checks.

## After the workshop - moving to an always-on host

Your VM pauses when the laptop sleeps, so the agent goes quiet with it. **Once you're confident in the local VM playground**, you can move the agent to something always-on: a VPS (Hetzner, AWS, Oracle, GCP, Azure, Hostinger, Railway) or a home box (Mac Mini, Raspberry Pi). The wrap-up in [`workshop/outline.md`](workshop/outline.md) covers this.

Every migration is the same shape: provision Linux, SSH in, run the same `bash nanoclaw.sh`. The `CLAUDE.md`, scheduled jobs, and integrations you built in the workshop all transfer.

Note: **Docker-in-Docker is problematic** as a host. See [`dind-sandbox/findings.md`](dind-sandbox/findings.md) for the full list of what we tried (Railway, Oracle) and why.

## Presenter sandbox (Docker-in-Docker)

The [`dind-sandbox/`](dind-sandbox/) folder is **presenter-only validation** infrastructure - it runs NanoClaw inside a privileged container so the presenter can test the full flow without touching their host. Attendees on a fresh Ubuntu VM don't need it.

See [`dind-sandbox/README.md`](dind-sandbox/README.md) to run it, [`dind-sandbox/findings.md`](dind-sandbox/findings.md) for the 9 DinD-specific gotchas, and [`dind-sandbox/architecture.md`](dind-sandbox/architecture.md) for the full setup explanation.

## Workshop abstract

> I bet most of you have spent some time chatting with AI, maybe even oneshotting a few websites or proof of concepts. It's cool, right? But constantly babysitting a chat window and approving every single terminal command is starting to feel like more work than it's saving.
>
> The real magic happens when you stop chatting and start delegating.
>
> In this hands-on workshop, we're going to cross the line from reactive AI to proactive autonomy. We'll be using NanoClaw, an autonomous agentic framework that lives on its own. This isn't just another GPT wrapper; it's a system with a "Heartbeat" that can wake up, scan your agenda, and execute tasks while you're grabbing a coffee.
>
> We'll dive into: Deploying the Brain, the "Living Files" paradigm, Connecting the Dots with real-world APIs, and setting up Heartbeats so your agent does its thing even when you're not looking.

Session page: https://websummercamp.com/2026/session/beyond-the-chatbot-engineering-your-proactive-digital-twin

## License

MIT. Take it, fork it, run your own workshop. Credit appreciated, not required.

## Acknowledgements

- **NanoClaw** maintainers — the underlying framework.
- **Web Summer Camp 2026 organizers** — for booking a hands-on slot in the AI Engineering track.
