---
name: living-files
description: Use when getting a NanoClaw agent to know you - exploring how the agent stores its memory (the "living files"), then creating context by having the agent interview you and write a profile into its memory, and confirming its replies become personal. This is Preparation 2 of the workshop and the first hands-on "verbalize, don't code" exercise.
---

# Living Files

## Overview

Guide a person through the core idea of the workshop: **you give the agent context by talking
to it, not by writing code.** The agent keeps a set of "living files" - its memory - that it
reads every time it wakes up. This skill has two halves:

1. **Explore** - ask the agent how its memory is structured and how to inspect it.
2. **Create** - have the agent interview you, write a profile into its memory, then confirm
   its next reply is specific to you.

This is the **Living Files** step (Preparation 2). For the full workshop follow
[`../../../workshop/outline.md`](../../../workshop/outline.md). Do the
[`nanoclaw-install`](../nanoclaw-install/SKILL.md) skill first - you need a running agent you
can DM. The natural next step is the GitHub memory sync exercise, which backs these same
memory files up to GitHub.

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

- **Claude** provider -> a flat **`CLAUDE.local.md`** at the group root, the agent's per-group
  memory.
- **Codex** (and other scaffold providers) -> a **`memory/` tree**: `memory/index.md`,
  `memory/memories/` (durable facts - people, projects, decisions), `memory/data/` (structured
  data). No `CLAUDE.local.md`.

**Two paths for the same files.** The agent sees its memory at the **in-container** path
`/workspace/agent/memory`; on the **host** the same files live at
`~/nanoclaw/groups/<folder>/memory`. Conversation archives are alongside, at
`/workspace/agent/conversations` (host: `~/nanoclaw/groups/<folder>/conversations`).

## Step 1 - Ask the agent how its memory is structured

DM the agent:

> `tell me how structured is your memory`

On the **Codex** provider the agent describes a file-based, hierarchical `memory/` tree, for
example:

```
memory/
  index.md                 # top-level map of memory
  system/
    definition.md          # rules for how it stores / uses memory
  memories/                # durable facts: people, projects, decisions, preferences
    index.md
    imported-agent-memory.md
    people/
      index.md
      ondrej.md            # your profile / preferences
  data/                    # structured reusable data (often empty at first)
```

This is **the agent's current state, not a fixed schema.** What NanoClaw actually creates at
boot is a small scaffold - three empty dirs (`system/`, `memories/`, `data/`) plus two seeded
files (`index.md`, `system/definition.md`). Everything else (the `people/` subfolder,
`ondrej.md`, the indexes) grows as the agent applies its doctrine to your conversation. So the
tree differs per agent and over time. (On the **Claude** provider the answer is simpler: its
memory is the single `CLAUDE.local.md` file - no `memory/` tree.) Step 3 shows where the
taxonomy comes from.

## Step 2 - Explore the living files

Ask the agent how you can look at the files yourself:

> `how can I explore it within the environment you run in`

Expect roughly three ways:

1. **Ask in chat** - e.g. `show memory tree`, `read my profile memory`, `search memory for
   projects`, `export memory files`.
2. **From a shell in the agent's environment** - the in-container memory path is
   `/workspace/agent/memory`. Useful commands the agent suggests:

   ```bash
   find /workspace/agent/memory -maxdepth 4 -type f | sort
   cat /workspace/agent/memory/index.md
   cat /workspace/agent/memory/memories/people/ondrej.md
   grep -R "keyword" /workspace/agent/memory
   ```

3. **Packaged export** - the agent can bundle the memory folder into a `.zip` / `.tar.gz` and
   send it back to you in chat. Conversation archives live under
   `/workspace/agent/conversations`.

(You can also inspect the same files **on the host**, outside the container, at
`~/nanoclaw/groups/<folder>/memory` - useful for the presenter.)

## Step 3 - Ask what defines the structure (`system/definition.md`)

Before you put anything *into* memory, see what decides *how* memory is organized. Ask the
agent to show you its memory definition:

> `read your memory definition file at system/definition.md and explain, in your own words,
> the rules you follow for storing memory`

Expect the agent to read `memory/system/definition.md` and describe rules like: start every
memory task at `memory/index.md` and follow the narrowest index; every folder of durable
memory has its own `index.md`; group an index into subfolders once it grows past ~20 entries;
keep notes concise and dated; update the nearest index when memory changes.

**Where the structure actually comes from - three layers** (so attendees do not mistake the
tree for a hard schema):

1. **Baked-in scaffold.** At container boot NanoClaw seeds only `system/`, `memories/`,
   `data/`, plus `index.md` and `system/definition.md`. It is idempotent (never clobbers the
   agent's own edits) and **provider-gated** - scaffold providers like Codex get it; the Claude
   provider does not (it uses flat `CLAUDE.local.md`).
   (Source: `reference/nanoclaw/container/agent-runner/src/memory-scaffold.ts`.)
2. **Editable doctrine.** `system/definition.md` is where the `people / projects /
   organizations / decisions` taxonomy is *suggested*. The file itself says it is **"a starting
   point, not a contract - reorganize it as the work demands."**
   (Source: `reference/nanoclaw/container/agent-runner/src/memory-templates/definition.md`.)
3. **Agent-created.** The concrete subfolders and files (`memories/people/ondrej.md` and its
   index) are written by the agent applying that doctrine to what you tell it - which is
   exactly what Step 4 does.

This is the heart of the lesson: **you shape the agent's memory by talking to it**, and you can
even edit `definition.md` to change the rules. You did not write code to get any of it.

## Step 4 - Create context: let the agent interview you

Now put something *into* memory. To fill more than just your profile, map one question to each
memory category. DM the agent:

> `Interview me with exactly 5 short questions, one per memory category, so you can populate
> your whole memory tree: (1) people - my role, time zone, and communication style;
> (2) organizations - where I work; (3) projects - what I'm working on right now;
> (4) decisions - one preference you should remember about how I work; (5) data - a reusable
> fact like my tech stack or a key link. Ask all 5, then wait for my answers.`

Answer the five in chat, then tell it to save:

> `save what you learned into the matching memory files, update the indexes, then show me the
> memory tree and the contents of each file you wrote or changed.`

**General answer to expect:** the agent asks five short questions, then (on Codex) writes or
updates files under `memory/memories/` - typically `people/<you>.md`, and depending on what you
shared, entries under `projects/`, `organizations/`, `decisions/`, and a record under `data/` -
and refreshes the nearest `index.md` files. On the **Claude** provider it folds the same facts
into `CLAUDE.local.md`. It then prints the tree and the file contents.

**Do not promise an exact layout.** `system/definition.md` is "a starting point, not a
contract," so the agent may consolidate (for example fold the decision into `people/<you>.md`)
rather than create every folder. Record what it actually did; that is the real material.

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
- **Provider mismatch.** If you see no `memory/` tree and only a `CLAUDE.local.md`, the agent
  is on the **Claude** provider - that is expected, not a bug. The `memory/` tree is the
  Codex/scaffold-provider shape.
- **The tree is not a fixed schema.** Two agents (or the same agent over time) will not have
  identical trees. Only `system/`, `memories/`, `data/`, `index.md`, and `system/definition.md`
  are seeded; everything else is grown by the agent.
- **Nothing lands in `data/`** unless you give the agent something structured - that is why
  question 5 in Step 4 asks for a stack or a link.

## Checkpoint

> ✅ The agent's memory holds your profile (on Codex, files under `memory/memories/`; on Claude,
> details in `CLAUDE.local.md`), and asking "what should I focus on this afternoon?" gets a
> reply specific to you. Continue into the GitHub memory sync exercise (back these files up to a
> private repo on a schedule), or take it from here?
