# Project memory — Proactive Digital Twin Workshop Kit

This file is auto-loaded by Claude Code when working in this repo. It captures the project's purpose, structure, decisions, and current status so a fresh Claude session has the same starting context as the team.

## What this repo is

The kit for running the **"Beyond the Chatbot: Engineering Your Proactive Digital Twin"** workshop at **Web Summer Camp 2026** (Opatija, Croatia, Thursday July 2, AI Engineering track, 14:15-15:30 + 16:00-17:15).

Presenter: Ondřej Chrastina (Developer Advocate at CKEditor).

The repo is, first and foremost, **the workshop, its outline, and a Skill that walks you through it**:

- the workshop walkthrough (`workshop/outline.md`) and its use cases (`workshop/use-cases-*.md`)
- a Claude Code skill, `.agents/skills/workshop-walkthrough/`, that guides a person through the workshop step by step
- the author's private content tooling (`ai-library` git submodule - not needed to run the kit)

The canonical playground for the workshop is **an Ubuntu Linux VM on the attendee's laptop** (UTM / VirtualBox / KVM). Inside the VM, `bash nanoclaw.sh` installs Docker, Node, and pnpm. VPS deployment is an after-you're-confident step.

Everything Docker-in-Docker (DinD) and the hosting-provider trials (Railway, Oracle) are **isolated in [`dind-sandbox/`](dind-sandbox/)** - presenter-only validation infrastructure, not the core of the workshop. See [`dind-sandbox/README.md`](dind-sandbox/README.md).

## Repo structure

```
.
├── README.md                       # public hero doc
├── CLAUDE.md                       # this file
├── LICENSE                         # MIT
├── workshop/
│   ├── outline.md                  # the walkthrough (intro, exercises, schedule, wrap-up)
│   ├── abstract.md                 # session title, abstract, prerequisites, takeaways
│   ├── providers.md                # host/VPS comparison (which providers were tested)
│   ├── use-cases-relatable.md      # use cases for the use-case exercise
│   └── use-cases-untested.md       # extra ideas not yet validated in the flow
├── .agents/skills/
│   └── workshop-walkthrough/       # the core Skill that guides you through the workshop
├── ai-library/                     # private git submodule (author tooling; not fetched by a normal clone)
└── dind-sandbox/                   # ISOLATED, presenter-only - not core
    ├── README.md                   # how the DinD sandbox works + all the operational notes
    ├── docker-compose.yml          # `docker compose up` → working sandbox
    ├── .env.example                # ONECLI_BIND_HOST, SANDBOX_CONTAINER
    ├── docker/                     # Dockerfile (Ubuntu, DinD, VFS, OneCLI bind, non-root) + entrypoint.sh
    ├── scripts/teardown.sh         # wipe sandbox back to fully fresh
    ├── skills/dind-sandbox-walkthrough/   # presenter-only DinD walkthrough skill
    ├── findings.md                 # Railway + Oracle failures, 9 DinD gotchas, validation log
    ├── recordings/                 # 8 screenshots from validation runs
    └── architecture.md             # what the sandbox runs and why each piece exists
```

## The DinD sandbox

The presenter-only Docker-in-Docker sandbox and all its operational guidance (starting the agent service as `nanoclaw`, stop/start vs down/up behavior, Telegram pairing in DinD, verify false-negatives, the 9 gotchas, reset) now live in **[`dind-sandbox/README.md`](dind-sandbox/README.md)** and **[`dind-sandbox/findings.md`](dind-sandbox/findings.md)**. Do not duplicate that detail here - update it there.

Attendees never need the sandbox; they run the workshop in an Ubuntu VM on their own laptop.

## Key decisions (with rationale)

| Decision | Why |
|---|---|
| **Playground = an Ubuntu Linux VM on the attendee's laptop** (not a VPS, not DinD) | The VM is isolated and disposable, needs no signup or credit card, and works for every attendee on day-of. VPS paths (Railway, Oracle) failed or were unreliable on workshop day; Docker-in-Docker is problematic. See `dind-sandbox/findings.md`. |
| **VPS deployment is an after-you're-confident step, named not recommended** | The workshop ships a working agent in the local VM first. The wrap-up names always-on options (Hetzner, AWS, Oracle, GCP, Azure, Hostinger, Railway, home Mac Mini / Pi) without recommending one. |
| **NanoClaw as the agent framework** | MIT, container-per-agent, native Anthropic Agents SDK, collapses OpenClaw's 9 living files into one `CLAUDE.md` per agent. Light and teachable in 2.5h. See `workshop/outline.md`. |
| **DinD sandbox isolated in `dind-sandbox/`** | It is presenter-only validation, not the core of the workshop. Its many implementation decisions (VFS storage, Ubuntu base, baked node, socat bridges, named volume, entrypoint auto-start) are documented in `dind-sandbox/`. |

## Validation status

End-to-end validation done in the DinD sandbox on 2026-06-09/10:

- ✅ Preparation 1: install → Telegram pairing → ping/pong
- ✅ Preparation 2: Living Files (CLAUDE.local.md self-edit, personalization confirmed)
- ✅ Preparation 3 Part A: default web search baseline
- ✅ Preparation 3 Part B: research tool swap (OpenRouter Perplexity, then DDG Instant Answers as free fallback)
- ✅ Preparation 4: scheduled morning brief (create + list + run-once)
- ✅ Bonus voice messages: graceful fallback when no OpenAI key, OneCLI URL flow
- ⏸ Full clean-slate DinD validation with the current Dockerfile (this kit)
- ⏸ `docker compose stop && start` recovery test

## Conventions

- **No em-dashes** anywhere (workshop voice rule). Use a spaced hyphen " - " instead.
- **Workshop voice** is cue-based, hook-first, no agenda slides.
- **Bot tokens / API keys are passwords** - never paste them in shared chats, screen shares, or commits. The `.gitignore` covers `.env`.

## Pending / open items

- **Pre-workshop email** to attendees (1 week before): not yet drafted. Should cover the VM + Ubuntu ISO setup, Claude access path (Pro sub or API key), and the Telegram phone-app reminder.
- **Slide deck**: not yet started. The `ai-library` submodule can generate slide-by-slide from the workshop outline if needed.
- **Run sheet for July 2**: cut-candidate ladder is in `workshop/outline.md`; a presenter-friendly minute-by-minute card is still TODO.
- **Push this repo to GitHub.** The `ai-library` submodule is private and isn't fetched by a normal clone, so it won't block a public push.

## How to push to GitHub when ready

```bash
cd ~/projects/proactive-digital-twin-workshop
gh repo create proactive-digital-twin-workshop --public --source=. --remote=origin --push
```
