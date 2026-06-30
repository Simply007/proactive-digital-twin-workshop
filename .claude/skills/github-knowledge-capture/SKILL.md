---
name: github-knowledge-capture
description: Use when capturing a NanoClaw agent's approved outputs into a private GitHub repo as portable Markdown notes - connecting GitHub to OneCLI via an OAuth app, then saying a trigger phrase so the agent drafts a note (title/summary/tags/type + body), you approve, and it pushes the file and updates the repo index. This is Exercise 3 of the workshop; on-demand capture, no scheduled job.
---

# GitHub Knowledge Capture

## Overview

Guide a person through capturing an agent's **approved outputs** into a **private GitHub repo**
as portable Markdown notes. You do not back up the whole memory and you do not sync on a timer.
You do something with the agent, like the result, say a **trigger phrase**, and the agent drafts
a note - Markdown with frontmatter - that you approve before it pushes. Over time you build a
reusable, version-controlled knowledge base you can pull into other tools (Obsidian, a static
site, another agent).

The key shape, and what keeps it on-message for the workshop ("verbalize, don't code"): you do
**not** write a sync script or run `git` yourself. You **connect GitHub to OneCLI** (the
credential vault) once, then **ask the agent** to save the output. The agent drafts the note,
you approve, and it pushes through the **GitHub API** (credentials injected by OneCLI) and
updates the repo's index.

> **Why capture instead of sync the whole memory?** On the default **Claude** provider the
> agent's memory is a single `CLAUDE.local.md` that already lives on the host
> (`~/nanoclaw/groups/<folder>/`), so it already survives container rebuilds - a wholesale
> "back up the memory" job adds little. What is genuinely useful is a curated, portable,
> version-controlled record of the outputs **you** decided were worth keeping. The agent only
> saves what you approve, and the notes are tool-agnostic so they reuse anywhere.

> **OneCLI OAuth is the primary path; a host-side `gh` CLI is the alternative.** The agent runs
> **inside a container** where `git push` cannot prompt for credentials and raw `git`/Node
> `fetch` calls do not carry the vault's auth - so the *agent-driven* capture has to route
> through OneCLI's GitHub OAuth connection + the GitHub API (this skill). If you would rather not
> create an OAuth app, the alternative is fully **host-side**: `gh auth login` on the host and a
> small script that appends one note - see "Alternative" at the end. The OneCLI path keeps the
> secret in the vault and is more "verbalize, don't code," which is why it leads.

This is the **knowledge capture** step (Exercise 3). For the full workshop follow the outline in
[`../../../workshop/outline.md`](../../../workshop/outline.md). Do the
[`nanoclaw-install`](../nanoclaw-install/SKILL.md) skill first - you need a running agent you can
DM. It pairs with the Living Files exercise, which is what populates the memory the agent draws
on when it writes a note.

## How to guide

- **The user drives.** They click through the OneCLI UI and GitHub, and DM the agent; you
  highlight the exact next action and confirm the real output. You only run read-only checks
  (file reads, `ncl ... list/get`, `sudo docker ps`) yourself.
- **The agent does the heavy lifting.** Once GitHub is connected, drafting the note, the push,
  and the index update are all the agent's work, driven by plain-language DMs. Go one DM at a
  time and read its reply back before the next.
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

## Step 1 - Connect GitHub to OneCLI (OAuth app)

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
in Step 3.

## Step 2 - Create the private knowledge repo

Create an **empty private repo** on GitHub (web UI is fine) under the account you authorized in
Step 1 - for example `my-knowledge`. Leave it empty (no README); the agent fills it.

A brand-new repo may not appear in the agent's `/user/repos` listing immediately (GitHub
listing/propagation delay). That is expected - direct access by name, or GitHub search, finds
it right away.

## Step 3 - Confirm GitHub auth reached the agent

Before the first capture, confirm GitHub auth actually reached the agent's runtime:

> `do you have GitHub access now? Tell me which GitHub user you are authenticated as, your
> scopes, and which repos you can see.`

**Expect:** the agent confirms auth is active, lists scopes (for example `repo, user`), and
names the connected user and visible repos. If it instead reports `401 Requires authentication`,
see Gotchas - it is almost always a raw `fetch` bypassing the OneCLI proxy, not a real auth
failure.

## Step 4 - Capture an output (the trigger phrase)

Now the core flow. First, do something with the agent that produces an output you like - a
snippet, a research summary, a decision, a draft. Then say the trigger phrase:

> `save this to my knowledge repo <owner>/<repo>`

**What the agent should do:** grab the relevant output, **draft** a portable note, and show you
the draft before pushing - proposing a `title`, `summary`, `tags`, and `type`, plus a preview of
the body. It then asks for your confirmation. Approve with something like `yes, push it`.

**The file format** that lands in the repo:

```markdown
---
title: Dockerfile for the NanoClaw VM
summary: Minimal Ubuntu + Docker setup that boots NanoClaw
tags: [docker, nanoclaw, vm]
date: 2026-06-30
source: nanoclaw/<agent> via Telegram
type: snippet
---

<the approved output, verbatim>
```

- **Portable on purpose.** The frontmatter is tool-agnostic (`title / summary / tags / date /
  source / type`), so the note reads cleanly in Obsidian, a static-site generator, or another
  agent. It is **not** tied to NanoClaw's internal memory vocabulary.
- **`type` drives categorization, not folders.** It is freeform but the agent keeps it
  consistent - for example `snippet`, `note`, `reference`, `decision`. You group and find notes
  by `type`, so there is no folder taxonomy to maintain.
- **Repo layout:** notes land at `knowledge/<slug>.md` (the agent derives the slug from the
  title), and the agent maintains an `index.md` that lists the notes grouped by `type` - the
  same spirit as NanoClaw's own `index.md` memory indexes, but in the portable format above.

**How the push happens is the agent's job.** This skill stays "verbalize, don't code" - it does
not hand you a script. Because `git push` cannot prompt for credentials in the container, the
agent pushes via the **GitHub commit/tree API** (auth injected by OneCLI). If the agent chooses
to write itself a small helper to reuse, that is fine; you never have to.

**Verify:** ask the agent to confirm the file exists on GitHub (for example
`knowledge/dockerfile-for-the-nanoclaw-vm.md`) and that `index.md` now lists it. Open the repo
in the browser to see the note and its frontmatter.

## Gotchas

- **`401 Requires authentication` even though GitHub is connected.** The agent tried a raw
  `fetch`/`git` call that bypassed the OneCLI proxy. OneCLI injects auth **at the proxy level**,
  so the request has to go through it (the agent's own `curl`/API path works; raw Node `fetch`
  does not). Ask the agent to retry through its authenticated GitHub path.
- **`git push` does nothing / cannot ask for credentials.** Expected inside the container -
  there is no interactive credential prompt. The agent should push via the **GitHub API**
  (commit/tree), which uses the injected token.
- **The agent acts as the wrong GitHub user.** It acts as the account you authorized in the
  OneCLI OAuth connection, which may differ from your main account. Confirm with `who are you on
  GitHub?` and re-authorize with the right account if needed.
- **A new repo is not listed yet.** `/user/repos` can lag for a freshly created repo; direct
  access by `owner/repo` or GitHub search finds it. Not an error.
- **`Turn timed out after 600000ms`.** A single agent turn has a ~10-minute ceiling. A first
  push that also has to create the repo structure can hit it. Ask the agent for a short status
  (`what is the status?`) - the work usually completed; the timeout is the turn, not the task.

## Checkpoint

> ✅ GitHub is connected in OneCLI, you said the trigger phrase, reviewed the agent's drafted
> note, and approved it - a portable `knowledge/<slug>.md` with correct frontmatter now exists
> on GitHub and is listed in `index.md`. Capture a second output of a different `type` to see
> the index group them. Continue into the scheduled morning brief exercise
> ([`scheduled-brief`](../scheduled-brief/SKILL.md)), or take it from here?

## Alternative - host-side `gh` CLI (no OAuth app)

If you would rather not create a GitHub OAuth app, append the note **on the host**, outside the
agent's container. This trades the "agent does it" elegance for a plain script you control, and
it sidesteps the container's no-credential-prompt limit because `gh` is authenticated on the
host.

```bash
# On the host (the VM), once:
gh auth login          # HTTPS, browser/device flow
gh auth setup-git      # so git push uses the gh credential
gh repo create my-knowledge --private
git clone https://github.com/<owner>/my-knowledge.git ~/my-knowledge
mkdir -p ~/my-knowledge/knowledge

# Append one note (run per capture, filling title/body yourself):
cat > ~/my-knowledge/knowledge/$(date -u +%Y%m%d-%H%M%S).md <<'EOF'
---
title: Dockerfile for the NanoClaw VM
summary: Minimal Ubuntu + Docker setup that boots NanoClaw
tags: [docker, nanoclaw, vm]
date: 2026-06-30
source: manual
type: snippet
---

<paste the output here>
EOF
git -C ~/my-knowledge add -A
git -C ~/my-knowledge commit -qm "capture: dockerfile for the nanoclaw vm"
git -C ~/my-knowledge push --quiet
```

Here you write each note by hand and `gh` does the push. Use this path when OAuth-app setup is
unwanted; use the OneCLI path (above) when you want the agent to draft and push for you.
