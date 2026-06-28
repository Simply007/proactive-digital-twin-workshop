---
name: github-memory-sync
description: Use when backing up a NanoClaw agent's memory to a private GitHub repo on a schedule - connecting GitHub to OneCLI via an OAuth app, then having the agent sync its memory files to the repo through the GitHub API and schedule it as a recurring job by DM. This is Exercise 3 of the workshop and the exercise that introduces scheduled jobs.
---

# GitHub Memory Sync

## Overview

Guide a person through backing up their NanoClaw agent's memory to a **private GitHub repo, on
a schedule.** The agent's memory lives in files; this exercise version-controls them off-site
so they survive container rebuilds and mistakes - and it is where the workshop introduces
**scheduled jobs** (recurring tasks the agent runs for you).

The key shape, and what makes this on-message for the workshop ("verbalize, don't code"): you
do **not** write a sync script or run `git` yourself. You **connect GitHub to OneCLI** (the
credential vault) once, then **ask the agent** to sync its memory. The agent writes the sync
script, pushes through the **GitHub API** (credentials injected by OneCLI), and schedules the
recurring job itself.

> **OneCLI OAuth is the primary path; a host-side `gh` CLI is the alternative.** The agent runs
> **inside a container** where `git push` cannot prompt for credentials and raw `git`/Node
> `fetch` calls do not carry the vault's auth - so the *agent-driven* sync has to route through
> OneCLI's GitHub OAuth connection + the GitHub API (this skill). If you would rather not create
> an OAuth app, the alternative is fully **host-side**: `gh auth login` on the host, a small
> `~/sync-memory.sh` that copies `~/nanoclaw/groups/<folder>/memory` into a repo and pushes, and
> a host **cron** entry to run it - see "Alternative" at the end. The OneCLI path keeps the
> secret in the vault and is more "verbalize, don't code," which is why it leads.

This is the **memory sync** step. For the full workshop follow the outline in
[`../../../workshop/outline.md`](../../../workshop/outline.md). Do the
[`nanoclaw-install`](../nanoclaw-install/SKILL.md) skill first - you need a running agent you
can DM. It pairs with the Living Files exercise, which is what populates the memory you back up
here.

## How to guide

- **The user drives.** They click through the OneCLI UI and GitHub, and DM the agent; you
  highlight the exact next action and confirm the real output. You only run read-only checks
  (file reads, `ncl ... list/get`, `sudo docker ps`) yourself.
- **The agent does the heavy lifting.** Once GitHub is connected, the sync script, the push,
  and the schedule are all the agent's work, driven by plain-language DMs. Go one DM at a time
  and read its reply back before the next.
- 🔒 **Never write a real secret into any file.** The GitHub OAuth **Client Secret** and any
  token are secrets - paste the secret only into the OneCLI connection form, never into chat, a
  script, or a commit. Mask any value in examples (`Iv1.xxxx`, `ghp_xxxx`). OneCLI keeps the
  real credential in the vault and injects it at request time.

## Prerequisites

- A **running NanoClaw agent you can DM** (from the `nanoclaw-install` skill), with the **OneCLI
  vault** running (the installer sets it up).
- A **GitHub account** (free is fine - private repos are free). You will create a GitHub
  **OAuth App** under it and authorize it.
- Ability to open the **OneCLI web UI** from the VM's browser (it listens on port `10254`).
- Know your agent's **group folder**. Agents live under `~/nanoclaw/groups/<folder>/`, one dir
  per group. List them with `ls -1 ~/nanoclaw/groups/`.

**Where the agent keeps its memory depends on the provider:**

- **Claude** provider -> a flat **`CLAUDE.local.md`** at the group root.
- **Codex** (and other scaffold providers) -> a **`memory/` tree**: `memory/index.md`,
  `memory/memories/`, `memory/data/`. No `CLAUDE.local.md`.

(Source: `reference/nanoclaw/docs/provider-migration.md` and the upstream `migrate-memory`
skill. The older `~/nanoclaw-workspace/<group>/memory/` path is **wrong** - that directory is
empty.)

## Step 1 - Confirm what gets backed up

The agent sees its memory at the **in-container** path `/workspace/agent/memory`; on the
**host** the same files are at `~/nanoclaw/groups/<folder>/memory`. Confirm it on the host:

```bash
ls -R ~/nanoclaw/groups/<folder>/memory
```

On Codex you will see the `memory/` tree (`index.md`, `memories/...`, `data/`); on Claude the
memory is the single `CLAUDE.local.md` at the group root instead. **That `memory/` tree (or
`CLAUDE.local.md`) is what you are backing up.** Conversation archives live alongside under
`conversations/` - out of scope here (the agent keeps them out of the backup by default).

## Step 2 - Connect GitHub to OneCLI (OAuth app)

This is the one piece of setup you do by hand. You create a GitHub OAuth App, then paste its
Client ID / Secret into OneCLI so the vault can authenticate the agent's GitHub calls.

**a. Find the OneCLI URL.** It listens on port `10254`. Find the address:

```bash
sudo docker ps   # look for the OneCLI container's published 10254 port
```

Open it in the VM's browser - `http://127.0.0.1:10254` normally, or the docker-bridge address
shown by `docker ps` (for example `http://172.17.0.1:10254`). Go to **Connections** (Apps) and
pick **GitHub OAuth**. It shows a **callback URL** - copy it.

**b. Create the GitHub OAuth App.** On GitHub: **Settings -> Developer settings -> OAuth Apps
-> New OAuth App**. Set the **Authorization callback URL** to the one OneCLI showed; you can
reuse that same URL for the **Homepage URL**. Save, then copy the **Client ID** and **generate
a Client Secret**.

**c. Connect.** Back in OneCLI's GitHub OAuth form, paste the **Client ID** and **Client
Secret**, set the callback, and **log in / authorize**. OneCLI stores the secret in the vault.

> 🔒 The **Client Secret** is a password. Paste it only into the OneCLI form. If it leaks,
> rotate it from the GitHub OAuth App page.

**Mind which account you authorize.** The agent will act on GitHub as **whichever account you
sign in with here** - which may not be your everyday account. Note it now; you will confirm it
in Step 4.

## Step 3 - Create the private backup repo

Create an **empty private repo** on GitHub (web UI is fine) under the account you authorized in
Step 2 - for example `my-agent-memory`. Leave it empty (no README); the agent fills it.

A brand-new repo may not appear in the agent's `/user/repos` listing immediately (GitHub
listing/propagation delay). That is expected - direct access by name, or GitHub search, finds
it right away.

## Step 4 - Ask the agent to sync its memory

Now hand it to the agent. First confirm GitHub auth actually reached the agent's runtime:

> `do you have GitHub access now? Tell me which GitHub user you are authenticated as, your
> scopes, and which repos you can see.`

**Expect:** the agent confirms auth is active, lists scopes (for example `repo, user,
workflow`), and names the connected user and visible repos. If it instead reports `401 Requires
authentication`, see Gotchas - it is almost always a raw `fetch` bypassing the OneCLI proxy, not
a real auth failure.

Then ask for the sync:

> `keep your memory in sync with <owner>/<repo>. Local /workspace/agent/memory is the source of
> truth. Copy it into the repo under memory/, commit, and push. Do not include conversation
> archives.`

**General answer to expect:** the agent clones the (empty) repo, copies `/workspace/agent/memory/`
into `memory/`, and pushes the first snapshot. Because `git push` cannot prompt for credentials
in the container, **the agent pushes via the GitHub commit/tree API** (auth injected by OneCLI),
then verifies a remote file exists (for example `memory/memories/people/<you>.md`). It typically
writes a small reusable script under `/workspace/agent/scripts/` for the scheduled job to reuse.

## Step 5 - Schedule the recurring sync (by DM)

Scheduling is the agent's `schedule_task` tool, created in plain language - not an `ncl`
command. Ask:

> `schedule this sync to run every hour. Only wake me if the sync fails - if there is nothing to
> commit or it succeeds, stay quiet.`

**General answer to expect:** the agent creates an hourly task and reports a **task id** (for
example `task-1782667354986-...`). The "only wake me on failure" maps to the scheduled-task
**`script` hook**: the script runs first and returns `wakeAgent: false` when the sync is clean,
so the agent (and your API budget) is only spent when something breaks. (Source:
`reference/nanoclaw/container/agent-runner/src/mcp-tools/scheduling.instructions.md`.)

Verify and force a run:

> `list my scheduled tasks` -> the hourly sync appears (-> the agent's `list_tasks`).
> `run the sync once now` -> a new commit appears on GitHub within a minute.

**Frequency note (from upstream):** more than a few wake-ups a day risks rate limits; hourly
with a `script` hook (no wake unless it fails) is the safe default.

## Gotchas

- **`401 Requires authentication` even though GitHub is connected.** The agent tried a raw
  `fetch`/`git` call that bypassed the OneCLI proxy. OneCLI injects auth **at the proxy level**,
  so the request has to go through it (the agent's own `curl`/API path works; raw Node `fetch`
  does not). Ask the agent to retry through its authenticated GitHub path. (Same failure mode as
  `add-gcal-tool`'s "OneCLI isn't injecting" note.)
- **`git push` does nothing / cannot ask for credentials.** Expected inside the container -
  there is no interactive credential prompt. The agent should push via the **GitHub API**
  (commit/tree), which uses the injected token.
- **The agent acts as the wrong GitHub user.** It acts as the account you authorized in the
  OneCLI OAuth connection, which may differ from your main account. Confirm with `who are you on
  GitHub?` and re-authorize with the right account if needed.
- **A new repo is not listed yet.** `/user/repos` can lag for a freshly created repo; direct
  access by `owner/repo` or GitHub search finds it. Not an error.
- **`Turn timed out after 600000ms`.** A single agent turn has a ~10-minute ceiling. A long
  first sync (clone + copy + API push), or doing it alongside other work, can hit it. Ask the
  agent for a short status (`what is the status?`) - the work usually completed; the timeout is
  the turn, not the task. Keep the sync its own focused request.
- **Scheduled job runs but nothing commits.** Expected when memory has not changed since the
  last run - the script detects no diff and stays quiet.

## Checkpoint

> ✅ GitHub is connected in OneCLI, the agent pushed your memory to a private repo (verified: a
> file like `memory/memories/people/<you>.md` exists on GitHub), and an hourly sync task is
> scheduled that only wakes the agent on failure. Asking `run the sync once now` lands a new
> commit within a minute. Continue into the use-case exercise, or take it from here?

## Alternative - host-side `gh` CLI + cron (no OAuth app)

If you would rather not create a GitHub OAuth app, run the whole backup **on the host**, outside
the agent's container. This trades the "agent does it" elegance for a plain script you control,
and it sidesteps the container's no-credential-prompt limit because `gh` is authenticated on the
host.

```bash
# On the host (the VM), once:
gh auth login          # HTTPS, browser/device flow
gh auth setup-git      # so git push uses the gh credential
gh repo create my-agent-memory --private

# A sync script that commits only when memory changed:
cat > ~/sync-memory.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
SRC=~/nanoclaw/groups/<folder>/memory      # Claude provider: back up CLAUDE.local.md instead
REPO=~/my-agent-memory
git -C "$REPO" pull --quiet || true
rsync -a --delete "$SRC/" "$REPO/memory/"
git -C "$REPO" add -A
git -C "$REPO" diff --cached --quiet && exit 0   # nothing changed
git -C "$REPO" commit -qm "memory sync $(date -u +%FT%TZ)"
git -C "$REPO" push --quiet
EOF
chmod +x ~/sync-memory.sh

# Schedule it with host cron (hourly):
( crontab -l 2>/dev/null; echo "0 * * * * ~/sync-memory.sh" ) | crontab -
```

Here the **host's cron** runs the job, not the agent's `schedule_task` - the agent's scheduled
tasks run inside its container and cannot reach a host script. Use this path when OAuth-app setup
is unwanted; use the OneCLI path (above) when you want the agent to own the sync.
