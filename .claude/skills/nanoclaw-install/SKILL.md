---
name: nanoclaw-install
description: Use when installing NanoClaw on a fresh machine (the Ubuntu VM playground, a laptop, or a VPS) - cloning the repo, running `bash nanoclaw.sh`, choosing the right answers at each installer prompt, and reaching the first ping/pong. Host-agnostic.
---

# NanoClaw Install

## Overview

Guide a person through installing NanoClaw and reaching their first ping/pong reply. This
covers the `bash nanoclaw.sh` wizard and the choices to make at each prompt. It is
host-agnostic: the canonical target is an Ubuntu Linux VM on the laptop, but the same flow
works on a plain laptop or a VPS.

This is the **install** step only. For the full workshop (Living Files, memory sync, use
cases) follow the outline in [`../../../workshop/outline.md`](../../../workshop/outline.md).

## How to guide

- **The user drives.** They run the commands; you highlight the exact next command and what
  it does. You only run read-only checks (status, logs, file reads) yourself.
- Go one prompt at a time. Tell them which answer to pick and why before they hit enter.
- Flag expected waits out loud (first image build, first-message cold start) so nothing
  looks broken.

## Prerequisites

- An Ubuntu Linux LTS VM (or laptop / VPS) with a terminal open.
- Claude access: a Claude Pro/Max subscription or an Anthropic API key (`sk-ant-...`).
- A Telegram bot token from `@BotFather`.

(See [`../../../work.md`](../../../workshop/abstract.md) for the prerequisite list and
[`../../../workshop/providers.md`](../../../workshop/providers.md) for host options.)

## Step 1 - Clone and run the installer

```bash
git clone https://github.com/nanocoai/nanoclaw.git
cd nanoclaw
bash nanoclaw.sh
```

`nanoclaw.sh` installs Docker, Node, and pnpm, then walks through a series of prompts.

## Step 2 - What to select during the installer

<!--
TODO (user to fill in): the exact prompts and the recommended answer for each.
Skeleton of what this section should cover, in installer order:

- Install mode: Standard vs Advanced -> (recommended answer + why)
- Claude / AI credentials: subscription OAuth vs API key -> (which to pick, what to paste)
- Time zone: (IANA format, what it controls - e.g. when scheduled jobs fire)
- Channel: Telegram -> (paste the BotFather token, name the agent)
- (any other prompts the wizard asks)

Fill each with: the prompt text the user will see, the answer to choose, and a one-line why.
-->

_To be filled in: the prompt-by-prompt choices. Each entry = the prompt as it appears, the
answer to pick, and a one-line reason._

## Step 3 - First contact (ping/pong)

From the phone, DM the bot `ping`.

- The **first reply takes ~60-90s** (the agent container cold-starts on the first message);
  under 10s after that. Send `ping` once and wait - repeated pings queue up.
- The first agent image build can take several minutes. This is expected, not a hang.

## Gotchas

On a normal Ubuntu VM or laptop the install is clean. The usual hiccups: a Docker
group/permission error on first run (`sudo usermod -aG docker $USER && newgrp docker`, then
re-run), a wrong or expired Telegram bot token, or mistaking the first-message cold start
for a hang. See the troubleshooting tables in `workshop/outline.md` (Preparation 1) for the
full list.

## Checkpoint - after ping/pong works, STOP and ask

> ✅ NanoClaw is installed and ping/pong works. Want me to continue into the workshop
> exercises (Living Files -> memory sync -> a use case, following
> `workshop/outline.md`), or take it from here?
