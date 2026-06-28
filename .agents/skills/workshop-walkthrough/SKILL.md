---
name: workshop-walkthrough
description: Use when guiding someone through the "Beyond the Chatbot - Engineering Your Proactive Digital Twin" workshop on their own machine - spinning up the Ubuntu VM playground, installing NanoClaw, pairing Telegram, getting ping/pong, then the Living Files, GitHub memory sync, and use-case exercises in workshop/outline.md. Host-agnostic (the VM playground, a laptop, or a VPS). For the presenter's Docker-in-Docker validation sandbox specifically, use dind-sandbox-walkthrough instead.
---

# Workshop Walkthrough

## Overview

Guide a person through the workshop in `workshop/outline.md`, step by step, on **their own
machine** - the canonical path is an Ubuntu Linux VM on their laptop (the "playground in a
virtual environment"). The goal is: a personal NanoClaw agent that knows who they are and
messages them on Telegram, on a schedule, without being asked.

This skill is host-agnostic. It works for the VM playground, for plain laptop Docker, or
later for a VPS. **For the presenter-only Docker-in-Docker sandbox** (`docker compose up`
in `dind-sandbox/`, with its VFS-build / socat-bridge / pairing-race gotchas), use the
[`dind-sandbox-walkthrough`](../../dind-sandbox/skills/dind-sandbox-walkthrough/SKILL.md)
skill instead.

## How to guide (read this first)

- **The user drives.** They run the commands. You highlight the exact command to run next,
  in a copy-pasteable block, and explain what it does in one line.
- **You only run read-only checks yourself** (status, logs, file reads) - and only when it
  helps diagnose. Never run install/pairing/scheduling commands on their behalf.
- Go one step at a time. Confirm each step landed before moving to the next.
- Flag expected waits out loud (first-message cold start, container build) so nothing looks
  broken.

## The arc (maps to the abstract and the outline)

1. **Deploying the Brain** - spin up the VM, install NanoClaw, pair Telegram, ping/pong.
2. **The Living Files paradigm** - verbalize who you are into `CLAUDE.md` so the agent knows
   how you think.
3. **Connecting the Dots** - GitHub memory sync and free/trial APIs.
4. **Proactive Logic (Heartbeats)** - scheduled jobs so the agent acts when you are not
   looking; run one real use case.

## Step 1 - Deploying the Brain

**Prereqs (should be done before the workshop):** a virtualization tool (UTM on macOS,
VirtualBox on Windows, KVM / virt-manager on Linux), an Ubuntu 24.04 or 22.04 LTS ISO
booted into a VM, Claude access (a Claude Pro/Max subscription or an Anthropic API key), and
Telegram on their phone with a bot token from `@BotFather`.

Inside the Ubuntu VM terminal:

```bash
git clone https://github.com/nanocoai/nanoclaw.git
cd nanoclaw
bash nanoclaw.sh
```

`nanoclaw.sh` installs Docker, Node, and pnpm, then asks for AI credentials, time zone, and
the Telegram bot token. When it finishes, the user DMs their bot `ping` from their phone.

- **First reply takes ~60-90s** (agent container cold-starts on the first message); under
  10s after that. Tell them to send `ping` once and wait quietly - repeated pings queue up.
- **Read-only check you can offer** if it stalls: have them show recent agent logs, or you
  read the workspace state. Do not re-pair for them.

**Checkpoint - STOP here.** Once ping/pong works, ask:

> Ping/pong works. Want me to keep guiding you through the exercises (Living Files -> GitHub
> memory sync -> run a use case, in `workshop/outline.md`), or take it from here?

## Step 2 - The Living Files paradigm

The agent self-edits its own context file so it knows who you are. Have the user DM the bot:

```
ask me 5 short questions to learn the basics about me - role, stack, time zone, what I'm
working on this week, communication style.
```

Then, after they answer in chat:

```
update CLAUDE.md with what you learned. Then show me the new file.
```

Verify: `given what you now know about me, what should I focus on this afternoon?` - the
reply should reference their actual stack/role, not generic advice. The point to make: "we
didn't write code, we verbalized." See Preparation 2 in `workshop/outline.md` for the full
script and troubleshooting.

## Step 3 - Connecting the Dots (GitHub memory sync)

Back the agent's memory up to a private GitHub repo on a schedule. The full TODO (gh auth,
create repo, sync script, schedule) is Exercise 3 in `workshop/outline.md`. Walk them
through it one block at a time; the sync script and `schedule an hourly job` DM are the
heart of it. This is also where scheduled jobs (Heartbeats) get introduced naturally.

## Step 4 - Proactive Logic (run a use case)

Pick one use case from `workshop/use-cases-relatable.md` and set it up in a single DM.
Confirm it scheduled: `list my scheduled jobs`. If it can fire soon, time it so the user
sees a notification arrive on its own - that is the whole payoff of the workshop.

## Where to go next (keep it neutral)

The VM playground pauses when the laptop sleeps. To make the agent always-on, the user can
later move it to an always-on host - a VPS (Hetzner, AWS, Oracle, GCP, Azure, Hostinger,
Railway) or a home box (Mac Mini, Raspberry Pi). **Only suggest this after they are
confident in the local VM playground.** Name the options, do not push one. Every migration
is the same shape: `git clone nanoclaw && bash nanoclaw.sh` on the destination, and the
`CLAUDE.md` and scheduled jobs transfer. Docker-in-Docker is problematic - see
[`../../dind-sandbox/findings.md`](../../dind-sandbox/findings.md).

## References

- `workshop/outline.md` - the full workshop (intro, exercises, schedule, wrap-up).
- `workshop/use-cases-relatable.md` - use cases for Step 4.
- `dind-sandbox/` - presenter-only Docker-in-Docker validation sandbox and the findings log.
