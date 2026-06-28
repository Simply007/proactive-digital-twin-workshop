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

- **VM RAM: at least 4 GB (8 GB comfortable, 16 GB if you can spare it).** This is the very
  first thing `nanoclaw.sh` checks - see the RAM check below.
- **VM disk: at least 30 GB (40 GB comfortable).** A full Ubuntu install plus the Docker
  images fills ~20 GB; provider rebuilds add more. Don't use the default ~20 GB - you'll hit
  a full disk mid-setup (observed: 19 GB used of 23 GB = 90% after install with both
  providers built).
- An Ubuntu Linux LTS VM (or laptop / VPS) with a terminal open.
- Claude access: a Claude Pro/Max subscription or an Anthropic API key (`sk-ant-...`).
- A Telegram bot token from `@BotFather`.

(See [main `README.md`](../../../README.md) for the prerequisite list and
[`../../../workshop/providers.md`](../../../workshop/providers.md) for host options.)

**RAM check (the installer runs this first).** If the VM has less than ~4 GB, `nanoclaw.sh`
warns:

```
Warning: this machine likely cannot run NanoClaw.
  NanoClaw recommends a 4 GB+ RAM machine. Below this, the host + agent
  container will run out of memory under most workloads. A stronger
  machine is strongly recommended.
    · Detected RAM: 3379 MB
```

The reading is the **guest VM's** RAM, not your laptop's. A VM configured for "4 GB" often
reports a bit less inside the guest (firmware / reserved memory), so give it headroom above
4 GB. If you see this, shut the VM down, raise its memory in your virtualization tool's
settings (8 GB comfortable; 16 GB if your laptop can spare it), reboot, and re-run.

## Step 1 - Install git and clone the repo

A **Minimal** Ubuntu install ships without several tools this install needs. So far the gaps
are: **`git`** (to clone), **`curl`** (the installer's `setup/install-node.sh` calls it), and
**`newgrp`** (to activate the `docker` group without a full re-login; it lives in the
`util-linux-extra` package). Install them up front:

```bash
sudo apt install util-linux-extra git curl
```

(Tip: choosing the **Normal/full** Ubuntu installation instead of **Minimal** avoids most of
these gaps.)

Then clone NanoClaw and run the installer:

```bash
git clone https://github.com/nanocoai/nanoclaw.git
cd nanoclaw
bash nanoclaw.sh
```

`nanoclaw.sh` installs Docker, Node, and pnpm, then walks through a series of prompts.

**Have your sudo password ready and stay at the keyboard.** Early on, the "Installing the
basics" step uses `sudo` to install Docker and Node. Enter your password promptly - if you
walk away, `sudo` times out (the step has a ~300s budget) and it fails with `Couldn't
install the basics` / `STATUS: node_missing`. Running `sudo -v` just before `bash
nanoclaw.sh` pre-caches your credentials and avoids the timeout.

## Step 2 - What to select during the installer

The installer is a guided wizard (`Basics ready` once Docker/Node are in). The prompts, in
order, with the answer to pick:

1. **"How would you like to begin?"** -> **Standard setup.** Advanced only adds config you
   do not need to reach ping/pong.
2. **System check** - "Your system looks good" - no input.
3. **Sandbox build** - it pulls a base image (**`docker.io/library/node:22-slim`**) and
   installs a few tools (bun, pnpm) into the agent image `nanoclaw-agent-v2-...`; "on a fresh
   machine this usually takes 3-10 minutes" (observed ~3m 7-20s). No input. (Check sizes
   afterward with `docker images`.)
   - With `util-linux-extra` installed (Step 1), if your shell does not yet have the `docker`
     group NanoClaw auto-recovers: "Docker socket not accessible in current group.
     Re-executing under `sg docker`." and the build proceeds - **no manual relogin needed**.
   - ⚠️ Without `sg`/`newgrp` available (i.e. `util-linux-extra` not installed) it instead
     **fails** with **"Couldn't prepare the sandbox" / `ERROR: docker_group_not_active`**.
     Fix: install `util-linux-extra` (Step 1), or log out and back in / reboot the VM, then
     re-run. Just re-running in the same un-grouped shell repeats the error. See Gotchas.
4. **OneCLI vault setup** - "Your assistant never gets your API keys directly. The vault adds
   them to approved requests as they leave the sandbox." No input; it initializes
   ("OneCLI vault ready", observed **~1m 6s**). On a **re-run** it detects the existing vault
   ("Found an existing OneCLI at http://...:10254. What would you like to do?") -> **Use the
   existing instance**.
5. **"Which agent runtime should power your assistant?"** Two options:
   - **Claude (default - Anthropic subscription or API key)** - this Claude-first kit's
     default.
   - **Codex (OpenAI - ChatGPT subscription or API key - installs now)** - the alternative.
     Selecting it **rebuilds the agent container image with the new provider baked in**
     ("Rebuilding the container image with the new provider..."). The agent image is
     provider-specific, so switching providers triggers a rebuild - fast when layers are
     cached (~35s seen after a prior Claude build), otherwise the 3-10 min first build.
     (The option label says "installs now", but the ChatGPT-subscription connect path still
     needs the Codex CLI present - see 6b.)

   Pick the one matching the AI access you set up. The credential sub-steps differ per
   runtime (captured below).
6a. **Claude runtime - CLI install + sign-in:** installs Claude Code to
   `~/.local/bin/claude` (version 2.1.195 seen), then **"Claude CLI isn't signed in. Sign in
   now? (a browser will open)"** -> **Yes** for the Pro/Max subscription path. A browser
   opens for OAuth; complete it and return to the terminal. The sign-in mints a **long-lived
   OAuth token valid for 1 year** (`sk-ant-oat01-...`) and saves it to the **OneCLI vault** as
   `Anthropic` (host `api.anthropic.com`). That vault is the only place it is stored (you
   won't see the token again); you can also inject it manually with
   `export CLAUDE_CODE_OAUTH_TOKEN=<token>`. Ends with "Claude account connected."
   - **Manage / revoke credentials later:**
     - Subscription logins (OAuth): <https://claude.ai/new#settings/claude-code>
     - API keys: <https://console.anthropic.com/settings/keys>
   - **API-key path** (instead of the subscription): TODO - confirm the exact prompt when we
     test it; you supply an `sk-ant-...` key, stored in the same OneCLI vault entry.
6b. **Codex runtime - connect:** prompt **"How would you like to connect Codex?"**
   - **Sign in with my ChatGPT subscription** -> requires the **Codex CLI** to be installed.
     If it isn't, you get: *"The Codex CLI is not installed on this machine. Install it with
     `npm install -g @openai/codex`, then re-run setup - or choose the API key option
     instead."* Fix: **`sudo npm install -g @openai/codex`** (the global install needs sudo),
     then re-run `bash nanoclaw.sh`, pick Codex, and choose this option again. With the CLI
     present it shows "Opening the Codex sign-in flow...", starts a local login server on
     `http://localhost:1455`, and opens a ChatGPT OAuth in the browser (a benign
     `Refusing to create helper binaries under /tmp` PATH warning may print). After login:
     `Successfully logged in` -> **"OpenAI account connected - credentials live in your OneCLI
     vault, never in the container."** -> "Checking the Codex provider install..." ->
     "Codex installed properly." (Once the CLI is installed, the runtime option also drops the
     "installs now" suffix - it reads just "Codex (OpenAI - ChatGPT subscription or API
     key)".)
   - **API key** -> paste your OpenAI `sk-...` key; stored in the OneCLI vault (like the
     Anthropic entry). [Manage URL - TODO: confirm.]
   - **OAuth from another machine? Hand the callback back to the VM.** Both the Claude and
     Codex browser sign-ins finish on a **localhost callback served by the VM** (Codex:
     `http://localhost:1455/auth/callback?code=...&state=...`). If you complete the login in a
     browser on a *different* machine (e.g. your host, where you're already signed in), copy
     the **final redirect URL** it lands on and open it **inside the VM** (paste into the VM's
     own browser, or `curl` it there) so the VM's local callback server receives the `code`.
     That `code` is a one-time secret - do not share or paste it anywhere public. **For a
     remote/headless VM the cleaner path is `codex login --device-auth`** (the Codex flow even
     suggests it: "On a remote or headless machine? Use `codex login --device-auth` instead.")
     - it gives you a short code to enter in any browser, with no localhost callback to forward.
7. **"Access rules set." / "NanoClaw is running."** - no input; the agent service starts
   (observed ~4s).
8. **"What should your assistant call you?"** -> a free personal choice (first name,
   nickname, etc.); used only for personalization. -> "Assistant wired up."
9. **Automatic ping/pong test** - the installer itself sends a test `ping` and waits for
   `pong` to confirm the agent responds ("First startup typically takes 30-60 seconds while
   the sandbox warms up") -> "Your assistant is ready." (~29s). No input; you do *not* have to
   message the bot yourself - the installer verifies it for you.
10. **"What next?"** -> **Continue with setup**.
11. **Time zone** -> **auto-detected** from your computer: "I detected `Europe/Prague` from
    your computer settings. Is that right?" -> **Yes** (or correct it). Sets when scheduled
    jobs / Heartbeats fire.
12. **"Want to chat with your assistant from your phone?"** -> **Yes, connect Telegram**. A
    panel explains how to make a bot: message [@BotFather](https://t.me/botfather), send
    `/newbot`, copy the `<digits>:<chars>` token (for group chats, set `/mybots` -> Bot
    Settings -> Group Privacy -> OFF). Then **"Ready to paste your bot token?"** -> **Yes,
    paste it on the next prompt** -> paste the token.

> **Credentials are passwords.** Your AI credentials (Claude OAuth / Anthropic API key, or
> OpenAI subscription / API key) and the Telegram bot token are secrets. Paste them only into
> the installer prompt - never into chat, screen shares, or commits. If one leaks, rotate it:
> Claude OAuth at <https://claude.ai/new#settings/claude-code>, Anthropic API keys at
> <https://console.anthropic.com/settings/keys>, OpenAI keys at the OpenAI dashboard, and a
> Telegram bot token via `@BotFather` -> `/revoke`.

13. **Telegram pairing** -> the installer pairs ("Telegram paired."), then asks:
    - **"How should this Telegram account be registered?"** -> **Owner** (you are the account
      that controls the agent).
    - **"What should your assistant be called?"** -> free choice, the agent/bot name
      (e.g. `ondrejbot`).
14. **Done.** "`<name>` is ready. Check Telegram for a welcome message." -> "Everything's
    connected." -> "You're set." The installer prints a few handy commands and an always-on
    note (see Step 3).

## Step 3 - First contact

When the installer finishes ("You're set.") it prints a few commands:

```
Try these
  Chat in the terminal:  pnpm run chat hi
  See what's happening:  tail -f logs/nanoclaw.log
  Open Claude Code:      claude
```

and your **assistant sends a welcome message on Telegram automatically** ("Go say hi ->
Check your Telegram"). Open Telegram (desktop or phone) and reply, e.g. `ping`.

- The **first reply can take ~60-90s** (the agent container cold-starts on the first
  message); under 10s after that. Send once and wait - repeated messages queue up.
- You can also chat from the terminal (`pnpm run chat hi`) or watch activity
  (`tail -f logs/nanoclaw.log`).

**Always-on note (shown by the installer):** NanoClaw only runs while this machine is on and
connected to the internet. For always-on availability, move it to a cloud VM or keep the
machine awake - see [`../../../workshop/providers.md`](../../../workshop/providers.md).

## Agents and how they're organized

NanoClaw is **container-per-agent**. Agents are **agent groups** under
`~/nanoclaw/groups/<name>/` - each with its own workspace, memory, `CLAUDE.md`, container,
and personality. They are **isolated siblings; there is no "boss"/main agent over the
others.**

- **`groups/main`** - the **default** agent.
- **`groups/global`** - shared base config every agent inherits (each agent's `CLAUDE.md`
  starts with `@./.claude-global.md`). It is config, **not** an agent.
- **`groups/dm-with-<you>`** - the agent wired to your Telegram owner DM, created at pairing.
  This is the one you actually chat with on Telegram.

Channels (a Telegram chat, the terminal, etc.) are decoupled from agents and wired
many-to-many, with three isolation levels (shared session / same-agent-separate-sessions /
separate agents) - see `reference/nanoclaw/docs/isolation-model.md`. Inspect your setup:

```bash
ls -1 ~/nanoclaw/groups/                 # one dir per agent group
docker ps --format '{{.Names}}'          # one nanoclaw-v2-<group>-... container per active agent
```

## Gotchas

On a normal Ubuntu VM or laptop the install is clean. The usual hiccups:

- **`Couldn't install the basics` / `STATUS: node_missing`** (in `logs/setup-steps/01-bootstrap.log`). Two common causes, often together: (1) `curl: command not found` - clean Ubuntu has no curl, so `setup/install-node.sh` can't fetch Node; fix by installing it (`sudo apt install curl`, see Step 1). (2) `sudo: timed out` - the sudo password prompt expired because nobody answered it; run `sudo -v` first and stay at the keyboard. Recovery: install `git curl`, run `sudo -v`, then re-run `bash nanoclaw.sh`.
- **`Couldn't prepare the sandbox` / `ERROR: docker_group_not_active`** (fresh install, very common): the installer added you to the `docker` group but your shell does not have it yet, so the Docker socket is not accessible. **Re-running `bash nanoclaw.sh` in the same terminal fails identically** - you must first start a session that has the group. `newgrp docker` spawns such a shell; **logging out and back in (or rebooting the VM) is the most reliable**, especially in a desktop session. Note that on a **Minimal Ubuntu install `newgrp` is not even present** (`Command 'newgrp' not found` - it lives in `util-linux-extra`), so logout/reboot is the path of least resistance there. Confirm with `docker ps` (no `sudo`, no permission error), then re-run the installer.
- **Disk fills up (root near 90%).** A full install + Docker uses ~19 GB (measured: agent
  image ~3.4 GB, OneCLI ~0.7 GB, Postgres ~0.4 GB, build cache ~2.9 GB). Provider switches
  **reuse the same image tag**, so dangling images do *not* pile up - on a real run almost
  nothing is reclaimable (`docker system df` showed ~34 MB). Pruning won't rescue you here;
  **the real fix is sizing the VM disk to 30-40 GB up front** (see Prerequisites). Use
  `docker system df` to see what's using space.
- A **wrong or expired Telegram bot token**, or mistaking the first-message cold start for a hang.

See the troubleshooting tables in `workshop/outline.md` (Preparation 1) for the full list.

## Checkpoint - after ping/pong works, STOP and ask

> ✅ NanoClaw is installed and ping/pong works. Want me to continue into the workshop
> exercises (Living Files -> memory sync -> a use case, following
> `workshop/outline.md`), or take it from here?
