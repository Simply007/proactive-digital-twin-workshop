---
name: github-memory-sync
description: Use when backing up a NanoClaw agent's memory to a private GitHub repo on a schedule - authenticating with the gh CLI, creating a private repo, writing a sync script that commits the agent's memory files, and scheduling it as a recurring job by DMing the agent. This is Exercise 3 of the workshop and the exercise that introduces scheduled jobs.
---

# GitHub Memory Sync

## Overview

Guide a person through backing up their NanoClaw agent's memory to a private GitHub repo, on a
schedule. The agent's memory lives in files on the host; this exercise version-controls them
off-site so they survive container rebuilds and mistakes - and it is where the workshop
introduces **scheduled jobs** (recurring tasks the agent runs for you).

This is the **memory sync** step. For the full workshop follow the outline in
[`../../../workshop/outline.md`](../../../workshop/outline.md). Do the
[`nanoclaw-install`](../nanoclaw-install/SKILL.md) skill first - you need a running agent you
can DM.

## How to guide

- **The user drives.** They run the commands; you highlight the exact next command and what it
  does. You only run read-only checks (file reads, `ncl ... list/get`, `git log`) yourself.
- Go one step at a time. Confirm the real output before moving on.
- 🔒 **Never write a real secret into any file.** `gh auth login` uses a browser/device flow,
  so no Personal Access Token is ever pasted or stored in the script. Mask any token in
  examples.

## Prerequisites

- A **running NanoClaw agent you can DM** (from the `nanoclaw-install` skill) - you need to
  message it to schedule the job.
- The **`gh` CLI** (GitHub CLI). Install on Ubuntu with `sudo apt install gh` or from
  <https://cli.github.com>.
- A **GitHub account** (free is fine - private repos are free).
- Know your agent's **group folder**. Agents live under `~/nanoclaw/groups/<folder>/`, one dir
  per agent group. List them with `ls -1 ~/nanoclaw/groups/`.

**Where the agent keeps its memory depends on the provider** (confirmed in Step 1):

- **Claude** provider -> a flat **`CLAUDE.local.md`** at the group root.
- **Codex** (and other scaffold providers) -> a **`memory/` tree**: `memory/index.md`,
  `memory/memories/`, `memory/data/`. No `CLAUDE.local.md`.

(Source: `reference/nanoclaw/docs/provider-migration.md` and the upstream `migrate-memory`
skill. The older `~/nanoclaw-workspace/<group>/memory/` path is **wrong** - that directory is
empty.)

## Step 1 - Find the real memory files

<!-- TO BE CAPTURED LIVE: ls ~/nanoclaw/groups/<folder>/ on the VM; capture real output;
identify the provider's store (Codex memory/ tree vs Claude CLAUDE.local.md). This is the fact
that corrects the outline. -->

## Step 2 - Authenticate GitHub from the terminal

<!-- TO BE CAPTURED LIVE: gh auth login (HTTPS, browser/device flow) + gh auth setup-git.
Capture real prompts. No PAT in any file. -->

## Step 3 - Create the private backup repo

<!-- TO BE CAPTURED LIVE: gh repo create <name> --private ... ; capture real output/URL. -->

## Step 4 - Write the sync script

<!-- TO BE CAPTURED LIVE: the real sync script copying the verified memory paths into the repo,
committing only on change, pushing. Capture the script and a real run. -->

## Step 5 - Schedule it by DMing the agent

<!-- TO BE CAPTURED LIVE: NL DM to the agent -> schedule_task; verify with "list my scheduled
tasks" (-> list_tasks); "run it once now" -> commit appears on GitHub. Note rate-limit
guidance (hourly is the safe default; more than a few/day risks limits). -->

## Gotchas

<!-- TO BE CAPTURED LIVE from the real run. -->

## Checkpoint

<!-- TO BE CAPTURED LIVE: blockquote + ✅ once a commit lands on GitHub from a scheduled run. -->
