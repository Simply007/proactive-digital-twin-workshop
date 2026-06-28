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
├── docker-compose.yml          # presenter sandbox (Docker-in-Docker) — not the primary attendee path
├── docker/                     # sandbox image (Ubuntu + DinD + VFS + OneCLI bind)
├── workshop/
│   ├── outline.md              # the workshop walkthrough (intro, exercises, schedule, wrap-up)
│   ├── findings.md             # everything we tried and rejected (Railway, Oracle, DinD gotchas)
│   ├── use-cases.md            # 10 free-tier integration ideas for the "Connecting the Dots" exercise
│   └── recordings/             # screenshots from validation runs
└── docs/
    ├── architecture.md         # what NanoClaw runs and why each piece exists
    └── providers.md            # host comparison + verdicts
```

## After the workshop — moving to a real always-on host

The wrap-up section of [`workshop/outline.md`](workshop/outline.md) covers four options for making your agent permanent:

- **Hetzner CAX11** (€4.51/mo, recommended)
- **AWS `t4g.small`** (free 12 months, then ~$15/mo)
- **Mac Mini / Raspberry Pi at home** (free if you own one)
- ~~Oracle Cloud Always Free~~ (capacity roulette, see [`workshop/findings.md`](workshop/findings.md))

All four: provision Linux, SSH in, run the same `bash nanoclaw.sh`. The `CLAUDE.local.md`, scheduled jobs, and integrations you built in the workshop all transfer — just copy your agent workspace.

## Presenter sandbox (Docker-in-Docker)

The `docker-compose.yml` here is for **presenter-side validation** — it runs NanoClaw inside a privileged container so the presenter can test the full flow without touching their host. Attendees on a fresh Ubuntu VM don't need this.

See [`workshop/findings.md`](workshop/findings.md) for the 9 DinD-specific gotchas baked into the Dockerfile, and [`docs/architecture.md`](docs/architecture.md) for the full setup explanation.

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
