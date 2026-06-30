---
name: living-files
description: Use when getting a NanoClaw agent to know you - exploring how the agent stores its memory (the "living files"), then creating context by having the agent interview you and write a profile into its memory, and confirming its replies become personal. This is Preparation 2 of the workshop and the first hands-on "verbalize, don't code" exercise.
---

# Living Files

## Overview

Guide a person through the core idea of the workshop: **you give the agent context by talking
to it, not by writing code.** The agent keeps its memory - its "living files" - that it reads
every time it wakes up. This skill has two halves:

1. **Explore** - ask the agent how its memory is structured and how to inspect it.
2. **Create** - have the agent interview you, write a profile into its memory, then confirm
   its next reply is specific to you.

This is the **Living Files** step (Preparation 2). For the full workshop follow
[`../../../workshop/outline.md`](../../../workshop/outline.md). Do the
[`nanoclaw-install`](../nanoclaw-install/SKILL.md) skill first - you need a running agent you
can DM. The natural next step is the knowledge-capture exercise
([`github-knowledge-capture`](../github-knowledge-capture/SKILL.md)), where the agent saves
approved outputs to a portable GitHub repo.

## How to guide

- **The user drives.** They DM the agent and run any commands; you highlight the exact next
  message to send and read back what the agent replied. You only run read-only checks (file
  reads, `ls`) yourself.
- This exercise happens **in chat** - most of it is messages to the agent, not shell commands.
- Keep it to **about 5 questions** to the agent. The agent's answers can be long; that is fine
  to show, but the attendee only needs a handful of prompts.
- The payoff line to land: **"We didn't write code. We verbalized."**

## Prerequisites

- A **running NanoClaw agent you can DM** (from the `nanoclaw-install` skill).
- Nothing else - no GitHub, no extra keys. This is all conversational.

**Where the agent keeps its memory depends on the provider.** Confirmed in Step 1, but in
short (source: `reference/nanoclaw/docs/provider-migration.md`, upstream `migrate-memory`
skill):

- **Claude** provider (the default install) -> a single flat **`CLAUDE.local.md`** at the group
  root, the agent's per-group memory, auto-loaded by Claude Code every time it wakes. This is
  what you will almost certainly see.
- (**Codex** and other scaffold providers keep a **`memory/` tree** instead - `memory/index.md`,
  `memory/memories/`, `memory/data/` - and have no `CLAUDE.local.md`. The rest of this skill
  notes the Codex variant in parentheses where it differs.)

**Two paths for the same file.** The agent sees its memory at the **in-container** path
`/workspace/agent/CLAUDE.local.md`; on the **host** the same file lives at
`~/nanoclaw/groups/<folder>/CLAUDE.local.md`. Conversation archives are alongside, at
`/workspace/agent/conversations` (host: `~/nanoclaw/groups/<folder>/conversations`).

## Step 1 - Ask the agent how its memory is structured

DM the agent:

> `tell me how structured is your memory`

On the default **Claude** provider the answer is simple: its memory is a single Markdown file,
`CLAUDE.local.md`, at the group root. Everything the agent learns about you gets folded into
that one file, which Claude Code loads automatically on every wake. There is no `memory/` tree,
no `index.md`, no `system/definition.md` - those belong to the scaffold providers.

(On the **Codex** provider the agent instead describes a file-based, hierarchical `memory/`
tree - `index.md` at the top, a `system/definition.md` doctrine file, durable facts under
`memories/` (people, projects, decisions), and `data/` for structured data. That tree is the
agent's current state, not a fixed schema: NanoClaw seeds only `system/`, `memories/`, `data/`,
`index.md`, and `system/definition.md`, and the agent grows the rest as you talk to it.)

## Step 2 - Explore the living file

Ask the agent how you can look at the file yourself:

> `how can I explore it within the environment you run in`

Expect roughly three ways:

1. **Ask in chat** - e.g. `show me your CLAUDE.local.md`, `read your memory file`, `what do you
   remember about me`, `export your memory`.
2. **From a shell in the agent's environment** - the in-container memory path is
   `/workspace/agent/CLAUDE.local.md`. Useful commands the agent suggests:

   ```bash
   cat /workspace/agent/CLAUDE.local.md
   grep -n "keyword" /workspace/agent/CLAUDE.local.md
   ```

   (On Codex the memory is a tree under `/workspace/agent/memory`, so the agent suggests
   `find /workspace/agent/memory -maxdepth 4 -type f | sort` and `cat`-ing individual files.)
3. **Packaged export** - the agent can send the file (or, on Codex, bundle the memory folder
   into a `.zip` / `.tar.gz`) back to you in chat. Conversation archives live under
   `/workspace/agent/conversations`.

(You can also inspect the same file **on the host**, outside the container, at
`~/nanoclaw/groups/<folder>/CLAUDE.local.md` - useful for the presenter.)

## Step 3 - Ask what shapes the memory

Before you put anything *into* memory, see what decides *how* it is organized.

On the **Claude** provider there is no separate rule file - the structure is just the headings
and notes the agent keeps in `CLAUDE.local.md`, which you and the agent both edit freely. Ask:

> `show me how you organize CLAUDE.local.md and the rules you follow for what goes in it`

Expect the agent to describe how it groups what it knows (who you are, what you are working on,
preferences) into sections, keeps notes concise and dated, and edits the file in place as things
change. The lesson: there is no schema to obey - **you shape the agent's memory by talking to
it**, and you can edit `CLAUDE.local.md` directly to change it. You did not write code to get
any of it.

(On the **Codex** provider this structure is governed by an editable doctrine file,
`memory/system/definition.md`, which suggests a `people / projects / organizations / decisions`
taxonomy and calls itself "a starting point, not a contract - reorganize it as the work
demands." Sources: `reference/nanoclaw/container/agent-runner/src/memory-scaffold.ts` and
`memory-templates/definition.md`. The seeded scaffold is idempotent and provider-gated - the
Claude provider gets none of it.)

## Step 4 - Create context: let the agent interview you

Now put something *into* memory. To fill a rounded profile, map one question to each kind of
durable fact. DM the agent:

> `Interview me with exactly 5 short questions so you can build a profile of me in your memory:
> (1) my role, time zone, and communication style; (2) where I work; (3) what I'm working on
> right now; (4) one preference you should remember about how I work; (5) a reusable fact like
> my tech stack or a key link. Ask all 5, then wait for my answers.`

Answer the five in chat, then tell it to save:

> `save what you learned into your memory, then show me what you wrote or changed.`

**General answer to expect:** the agent asks five short questions, then on the **Claude**
provider folds the facts into `CLAUDE.local.md` - typically a profile section plus notes on your
project, preferences, and stack - and prints back what it wrote. (On **Codex** it instead writes
or updates files under `memory/memories/` - `people/<you>.md` and, depending on what you shared,
entries under `projects/`, `organizations/`, `decisions/`, `data/` - and refreshes the nearest
`index.md` files.)

**Do not promise an exact layout.** The agent decides how to organize what you told it, so it
may consolidate everything into a few sections rather than create a slot for each answer. Record
what it actually did; that is the real material.

## Step 5 - Confirm the agent now knows you

This is the payoff. DM the agent:

> `given everything you just saved, what should I focus on this afternoon?`

**General answer to expect:** the reply references real details from your answers - your stack,
role, current project, or stated preference - rather than generic productivity advice. That is
the whole point: the agent read its own memory and personalized the response. No code was
written; you verbalized.

## Gotchas

- **Reply is still generic** even though the file was written. The memory may not have been
  reloaded into context yet. DM `re-read your memory from disk before answering`, then ask
  again.
- **A `memory/` tree instead of `CLAUDE.local.md`.** If you see no `CLAUDE.local.md` and instead
  a `memory/` tree, the agent is on the **Codex** (or another scaffold) provider - that is
  expected, not a bug. The single flat `CLAUDE.local.md` is the default Claude shape.
- **`CLAUDE.local.md` vs `CLAUDE.md`.** Memory goes in `CLAUDE.local.md` (editable, persisted,
  yours and the agent's). `CLAUDE.md` is the composed instructions file, regenerated read-only
  on every spawn - do not put memory there; the agent cannot keep edits to it.

## Checkpoint

> ✅ The agent's memory holds your profile (on Claude, details in `CLAUDE.local.md`; on Codex,
> files under `memory/memories/`), and asking "what should I focus on this afternoon?" gets a
> reply specific to you. Continue into the knowledge-capture exercise (save approved outputs to a
> portable GitHub repo), or take it from here?
