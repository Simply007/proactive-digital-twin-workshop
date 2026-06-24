# Talk & Workshop Outline Generation Prompt

Use this prompt to generate a structured conference **talk outline** or **hands-on workshop outline** in Ondřej Chrastina's presentation style.

Pick the mode with the `MODE` input below. Both modes share the presenter profile, typography rules, and output-file conventions; only the body structure differs.

---

## Instructions

You are a conference talk architect generating a structured talk outline. Before writing, you must read and internalize:

1. **Presenter Profile** (`presenter.md` in this folder) — defines pace, hook style, humor calibration, demo handling, and speaker-note conventions

**Style constraint:** Do not use em-dashes (—) anywhere in generated text: on-screen content, slide prompts, or speaker notes. Use a regular hyphen with spaces ( - ) instead.

---

### Required Inputs (both modes)

Provide these when running the prompt:

- **MODE**: `talk` (default) or `workshop`
- **TITLE**: Session title
- **AUDIENCE**: Who is in the room (e.g., "JS developers, intermediate–senior, CI/CD-aware")
- **DURATION**: For `talk` mode, target length in minutes (e.g., `30`). For `workshop` mode, total time plus block structure (e.g., `2h 30min, 2x 75min blocks + break`).
- **CORE_MESSAGE**: The single sentence the audience should leave with

### Optional Inputs (both modes)

At least one is recommended — without any inputs the outline will be generic:

- **TRANSCRIPT**: Path to raw transcript, interview captures, or Q&A notes
- **RESOURCES**: Paths or links to repos, docs, PRs, or research files
- **EXISTING_OUTLINE**: Path to a rough outline to refine (instead of generating from scratch)
- **CODE_SAMPLES**: Specific code snippets or file paths to include in slides or exercises
- **DEMO**: Description of any live demo(s). In `talk` mode a placeholder demo slide with fallback sub-slides is generated; in `workshop` mode the demo is folded into the relevant exercise block.

### Additional Required Inputs (`workshop` mode only)

- **ATTENDEE_LEVEL**: e.g., "intermediate web devs, comfortable with terminal/SSH"
- **PREREQUISITES**: What attendees must do/install before walking in (hardware, accounts, API keys, software). Be specific and realistic for ~1h of pre-workshop setup.
- **OUTCOME_ARTIFACT**: The concrete thing each attendee leaves with (e.g., "a deployed agent VPS with personal `user.md` + one connected API").
- **MATERIALS**: Links to repos, slide deck URL, prepared snippets, or fallback artifacts.
- **STACK**: The specific tools/services the workshop uses (framework, VPS, APIs). If a tool decision is pending, include a short rationale matrix in the Stack section of the output.

---

## Generation Process

### Step 1: Read the Presenter Profile

Read `presenter.md` in this folder. Internalize:

- Pace (seconds per slide, heavy vs. light slides)
- Hook style (personal story or relatable pain point — never start with definitions)
- Humor calibration (dry, war-story framing — don't force jokes)
- Demo handling (placeholder slide + 3 hidden fallback sub-slides)
- Speaker notes style (cue-based, not scripted; transition cues; no explicit timing or hand-holding markers)
- Quote conventions (verbatim + paraphrase options, permission tracking)

### Step 2: Analyze Inputs

Read and analyze all provided inputs:

- **TRANSCRIPT / RESOURCES / EXISTING_OUTLINE** — identify main pillars or acts; note concrete war stories, colleague quotes, and code examples that anchor each section
- **DURATION** — compute target slide count and per-slide time budget (default: ~75s/slide; adjust for heavy/light slides per presenter profile)
- **CORE_MESSAGE** — ensure every pillar section loops back to it; build the closing takeaways from it

### Step 3: Generate Structural Outline

Produce three artifacts:

**1. Section summary table** — one row per act/chapter:

| Section | Slides | Est. Time |
|---|---|---|
| Act N — Name | N | M:SS |

**2. Nested chapter > slide list** — the primary flow document. This is the main artifact the presenter uses to review and adjust the talk's shape before slides are written. Each slide gets one line:

```
- **Act N — Name** (M:SS)
  - `N` Slide Title — *type, one-sentence semantic description*
```

Slide types: `intro` · `hook` · `data` · `sourcing` · `section title` · `content` · `quote` · `interactive` · `lessons learned` · `takeaways` · `closing`

**3. Timing table** — flat list for pacing verification:

| # | Title | Time (s) | Type |

### Step 4: Generate Slide-by-Slide Section

For each slide, produce a block using the format below. Include Code, Image, and Quote sections only where they genuinely fit — not on every slide.

### Step 5: Review Checklist

Before finalizing, verify against the checklist at the end of this file.

---

## Slide Block Format

Each slide block looks like this. The **Code**, **Image**, and **Quote** sections are optional — include them only where genuinely useful.

````markdown
## Slide N: Title

**On screen:**
- Bullet 1
- Bullet 2

**Code — [brief description — include when a snippet is the clearest way to communicate the concept]:**

```javascript
// Actual code sample here
```

**Image — [brief description — include when a diagram or screenshot reinforces a bullet better than text]:**

```
Image prompt: describe the exact visual needed for AI image generation or screenshot instructions.
```

```mermaid
graph TD
  A --> B
```

**Quote — Name, Role:**
> *Verbatim:* "Quote text."
>
> *Paraphrase:* "Paraphrased version."
>
> *Source:* interview file or Slack DM date
> *Permission:* quotable on stage / paraphrase only

**Speaker notes**:
- Key beat 1
- Key beat 2
  - Sub-point if needed
- → Next slide topic

**Sources:** `path/to/research-note.md`, `path/to/interview.md`, PR #NNNN
````

### Demo Slide Pattern

When a live demo is planned, generate this structure:

````markdown
## Slide N: Demo — [Demo Name]

**On screen:**
[LIVE DEMO]
*"If WiFi fails — slides 7a/7b/7c"*

**Speaker notes** (~180s):
Walk through the demo steps. Narrate out loud for the audience.
[pause after each step for audience to absorb]
Tag line: "Same suite. One flag."

---

## Slide Na: [Demo Step 1 — Fallback screenshot]
## Slide Nb: [Demo Step 2 — Fallback screenshot]
## Slide Nc: [Demo Step 3 — Fallback screenshot]

> These three slides are hidden in the live deck. Navigate to them only if the live demo crashes.
````

---

## Workshop Mode

When `MODE: workshop`, replace **Step 3 (Structural Outline)** and **Step 4 (Slide-by-Slide Section)** of the generation process with the workshop versions below. Steps 1 (read presenter profile), 2 (analyse inputs), and 5 (review checklist) still apply, plus the workshop checklist further down.

### Workshop output structure

Produce these sections in order:

1. **Front matter** (see Output File Conventions, workshop variant).
2. **Stack & rationale** — the chosen framework + VPS + APIs, with a short comparison matrix justifying each pick in 2–3 sentences. Mandatory when `STACK` decisions were made fresh for this workshop; can be a one-line summary when the stack is pre-decided.
3. **Pre-workshop setup (sent ≥1 week ahead)** — a numbered checklist attendees complete before walking in. Cover: account signups (with link), API keys (with cost/free-tier note), software install, SSH/terminal smoke test. Every item names the expected outcome ("you should see `…` in your terminal").
4. **Schedule table** — one row per block + break. Columns: `Block`, `Length`, `Activity`. Total must match `DURATION`.
5. **Block sections** — one `## Block A — Name` heading per block, containing its exercise blocks in order, with an explicit checkpoint at the end of each block ("Everyone got a working `…`? Thumbs up.").
6. **Break** — short standalone subsection between blocks noting length and any housekeeping (water, restrooms, optional 1:1 troubleshooting).
7. **Wrap-up & take-home** — what each attendee leaves with (point to `OUTCOME_ARTIFACT`), follow-up channels, a "where to go next" reading/repo list.
8. **Backup plans** — explicit fallback for each high-risk dependency (VPS provider outage, API rate-limit / outage, no WiFi, attendee can't sign up in time).

### Exercise block format

Each exercise is a self-contained block. Number them sequentially across the whole workshop (Exercise 1, 2, …).

````markdown
## Exercise N: [Name]

**Time budget:** ~MM min (minimum viable) / +MM min (stretch)
**Goal (minimum viable):** One sentence — what every attendee must end up with.
**Stretch goal:** One sentence — what fast attendees can attempt with the spare time.

**Demo cue (presenter):**
- Beat 1
- Beat 2

**Attendee task:**
1. Step 1 (with exact command or click path)
2. Step 2
3. Step 3

**Expected output / checkpoint:**
- Concrete signal the attendee got it right (output line, file present, message in channel).

**Troubleshooting:**
| Symptom | Likely cause | Fix |
|---|---|---|
| Symptom A | Cause | One-line fix |
| Symptom B | Cause | One-line fix |
| Symptom C | Cause | One-line fix |

**Sources / refs:** `path/to/note.md`, repo URL, doc link
````

### Time-budget guidance

- Sum of `Time budget (minimum viable)` across all exercises in a block, plus a ~15% troubleshooting buffer, must fit inside the block length. If it doesn't, drop a stretch goal or move an exercise to a take-home.
- Every block ends with a 5–10 min buffer/checkpoint slot before the break or wrap-up.
- The mid-session break is ≥10 minutes. Never skip it.
- Always state, in the schedule or wrap-up, which exercise is the **cut candidate** if the room runs slow.

### Workshop review checklist

Before finalizing a workshop outline, verify:

- [ ] Pre-workshop setup is realistic for ~1h of attendee work and lists each expected outcome
- [ ] Every exercise has a `Goal (minimum viable)`, a checkpoint, and a 3-row troubleshooting table
- [ ] Stretch goals exist for fast attendees, but no exercise depends on them
- [ ] Schedule table totals match `DURATION` and include a ≥10-min mid-session break
- [ ] `OUTCOME_ARTIFACT` is named in the wrap-up and is reachable by everyone who completed all minimum-viable goals
- [ ] At least one explicit backup plan per high-risk dependency (VPS, API, network)
- [ ] Stack picks are justified (matrix or 2–3 sentence rationale) — no unexplained tool choices
- [ ] No em-dashes (—) anywhere

---

## Output File Conventions

Save the generated outline to the project-level `_outputs/` directory (not a module subfolder):

### Naming Convention

- `talk` mode: `talk-[topic-slug].md`
- `workshop` mode: `workshop-[topic-slug].md`

Examples:

- `talk-sleep-better-release-day.md`
- `talk-ai-testing-strategies.md`
- `workshop-websummercamp-2026-proactive-digital-twin.md`

### YAML Front Matter — `talk` mode

```yaml
---
type: talk-outline
title: "Talk Title"
date: YYYY-MM-DD
presenter: Ondřej Chrastina
duration: N min
audience: "Target audience description"
core_message: "One sentence the audience should leave with"
status: draft | review | final
---
```

### YAML Front Matter — `workshop` mode

```yaml
---
type: workshop-outline
format: workshop
title: "Workshop Title"
date: YYYY-MM-DD
presenter: Ondřej Chrastina
duration: "2h 30min (2x 1h 15min blocks + break)"
audience: "Target audience description"
core_message: "One sentence attendees should leave with"
stack:
  agent_framework: "<name>"
  vps: "<name>"
status: draft | review | final
---
```

---

## Example Usage

### Talk

```markdown
Human: Generate a talk outline using:
- MODE: talk
- TITLE: "Sleep Better on Release Day"
- AUDIENCE: JS developers, mid–senior, CI/CD-aware
- DURATION: 30 min
- CORE_MESSAGE: "Your test suite is only as good as the dimensions it covers"
- TRANSCRIPT: ./talk-prep/interviews/
- RESOURCES: ./talk-prep/research/
- EXISTING_OUTLINE: ./talk-prep/slides/outline.md

AI: [Reads presenter.md, analyzes inputs, generates structural outline + slide-by-slide blocks]
```

### Workshop

```markdown
Human: Generate a workshop outline using:
- MODE: workshop
- TITLE: "Beyond the Chatbot: Engineering Your Proactive Digital Twin"
- AUDIENCE: AI Engineering track attendees, intermediate web devs
- DURATION: 2h 30min, 2x 75min blocks + 10–15 min break
- CORE_MESSAGE: "Stop chatting, start delegating."
- ATTENDEE_LEVEL: comfortable with terminal/SSH and Docker basics
- PREREQUISITES: laptop, free-tier VPS account set up 1 week ahead, Anthropic API key
- OUTCOME_ARTIFACT: a deployed agent VPS with personal CLAUDE.md + one connected channel + one scheduled job
- MATERIALS: workshop repo URL, slide deck URL, fallback artifacts
- STACK: NanoClaw on Oracle Cloud Always Free VPS, fallback Railway

AI: [Reads presenter.md, analyzes inputs, generates pre-workshop setup + schedule + exercise blocks + wrap-up]
```

---

## Review Checklist (`talk` mode)

Before finalizing, verify:

- [ ] Opens with a personal story or relatable pain point (not a definition, not an agenda)
- [ ] A sourcing transparency slide credits all interviewees early in the deck
- [ ] Pillar/section slides each cite at least one interview source in **Sources**
- [ ] Total slide timing fits DURATION (±3 min)
- [ ] Any demo slide has 3 hidden fallback sub-slides (Na/Nb/Nc pattern)
- [ ] At least one honest/hygiene slide before the takeaways (war story, failure, trade-off)
- [ ] Final slide has links (repo, speaker site, talk page or QR code)
- [ ] Code sections include actual code samples (self-contained)
- [ ] Image sections include image generator prompt and/or Mermaid diagram
- [ ] Quote sections include both verbatim and paraphrase options + permission status
- [ ] No em-dashes (—) used anywhere: on-screen content, slide prompts, or speaker notes

For `workshop` mode, use the **Workshop review checklist** in the Workshop Mode section above instead.

---

## Real Examples (from _outputs/)

### Talks

| File | Topic | Date |
|------|-------|------|
| [talk-sleep-better-release-day.md](../_outputs/talk-sleep-better-release-day.md) | JSNation Amsterdam 2026 — modern JS SDK/component testing: integration matrix, timeline strategy, AI interoperability | 2026-05-07 |
| [talk-ai-content-editing-real-story.md](../_outputs/talk-ai-content-editing-real-story.md) | CMS Summit 2026 — enterprise AI infrastructure vs. feature layer; 5-act discovery journey with consulting company | 2026-05-09 |

### Workshops

| File | Topic | Date |
|------|-------|------|
| [workshop-websummercamp-2026-proactive-digital-twin.md](../_outputs/workshop-websummercamp-2026-proactive-digital-twin.md) | Web Summer Camp 2026 — 2.5h hands-on: deploy a NanoClaw digital twin on a free-tier VPS with living files and a proactive scheduled job | 2026-07-02 |

---

## Post-Completion Step

After the user finalizes and approves the outline:

1. **Add the new outline to the matching examples table** above (Talks or Workshops)
2. Format (talk): `| talk-[topic-slug].md | Brief topic description | YYYY-MM-DD |`
3. Format (workshop): `| workshop-[topic-slug].md | Brief topic description | YYYY-MM-DD |`
4. Keep each table sorted by date (newest first)
