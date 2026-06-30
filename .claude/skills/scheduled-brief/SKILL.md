---
name: scheduled-brief
description: Use when setting up a recurring scheduled job on a NanoClaw agent - DM the agent to send a daily morning brief at a set time, then list the scheduled tasks and run one once on demand, including the "only ping me if it fails" pattern. This is the workshop exercise that introduces scheduled jobs.
---

# Scheduled Morning Brief

## Overview

Guide a person through their agent's first **scheduled job** - a recurring task the agent runs
for them without being asked each time. The vehicle is a **daily morning brief**: the agent DMs
you a short rundown (for example the top 3 AI headlines plus anything on your calendar) at a set
time every day.

This stays on-message for the workshop ("verbalize, don't code"): you describe the schedule in
plain language and the agent creates it with its `schedule_task` tool. You never write a cron
entry or a script.

This is the **scheduled jobs** exercise. For the full workshop follow the outline in
[`../../../workshop/outline.md`](../../../workshop/outline.md). Do the
[`nanoclaw-install`](../nanoclaw-install/SKILL.md) skill first - you need a running agent you can
DM. It builds naturally on the knowledge-capture exercise
([`github-knowledge-capture`](../github-knowledge-capture/SKILL.md)), and the brief's content is
richer if you have done the research-tool swap from Preparation 3.

## How to guide

- **The user drives.** They DM the agent; you highlight the exact next message and read back the
  reply. You only run read-only checks yourself.
- **The agent does the work.** Creating, listing, and running the task are all the agent's
  `schedule_task` / `list_tasks` tools, driven by plain-language DMs. Go one DM at a time.
- The payoff line to land: **the agent now does something for you on its own clock - you only
  said it once.**

## Prerequisites

- A **running NanoClaw agent you can DM** (from the `nanoclaw-install` skill).
- Optional but nice: the research tool from **Preparation 3**, so the brief can pull real
  headlines rather than a canned list.

## Step 1 - Create the scheduled brief

DM the agent in plain language:

> `every weekday at 8am, send me a brief with the top 3 AI headlines and anything on my calendar
> for the day.`

**Expect:** the agent creates a recurring task and reports a **task id** (for example
`task-1782667354986-...`) along with the schedule it parsed (the cadence and time, in the
agent's configured time zone).

## Step 2 - List your scheduled tasks

Confirm it landed:

> `list my scheduled tasks`

**Expect:** the agent's `list_tasks` output shows the morning brief with its id, cadence, and
next run time.

## Step 3 - Run it once now

You should not have to wait until 8am to see it work:

> `run the morning brief once now`

**Expect:** the brief arrives in chat within a minute. This is a one-off run; the recurring
schedule is unchanged.

## Step 4 - The "only ping me if it fails" pattern

A daily brief is something you want, so you let it through. But for noisier jobs you only want a
message when something breaks. Explain the pattern:

> A scheduled task can carry a `script` hook that runs first and returns `wakeAgent: false` when
> there is nothing worth telling you - so the agent (and your API budget) is only spent when the
> job actually has something to say or fails.

(Source: `reference/nanoclaw/container/agent-runner/src/mcp-tools/scheduling.instructions.md`.)
You can ask the agent: `change it so a clean run stays quiet and only pings me if the brief
fails to build.`

## Gotchas

- **Frequency vs rate limits.** More than a few agent wake-ups a day risks rate limits. A daily
  brief is fine; for anything more frequent, lean on the `script` hook so most runs stay quiet.
- **`Turn timed out after 600000ms`.** A single agent turn has a ~10-minute ceiling. A brief
  that does a lot of research can hit it. Ask the agent `what is the status?` - the work usually
  finished; the timeout is the turn, not the task.
- **Wrong time.** The schedule uses the agent's configured **time zone**, not necessarily yours.
  If the brief arrives at an odd hour, ask the agent what time zone it scheduled in and correct
  it.
- **Nothing arrived at all.** Confirm the task exists (`list my scheduled tasks`) and force a run
  (`run it once now`); if the one-off run works but the recurrence does not, the cadence likely
  parsed differently than you meant - restate it.

## Checkpoint

> ✅ A recurring morning brief is scheduled, shows up in `list my scheduled tasks`, and `run it
> once now` delivers it within a minute. You taught the agent to act on its own clock by saying
> it once. Continue into the use-case exercise, or take it from here?
