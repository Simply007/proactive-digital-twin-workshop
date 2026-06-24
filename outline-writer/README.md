# Outline Writer

The Claude prompt and presenter profile used to generate the workshop outline in [`../workshop/outline.md`](../workshop/outline.md).

## Files

- **`prompt.md`** — the master prompt. Drives Claude (Sonnet or Opus) to generate either a `talk` outline or a `workshop` outline from a small set of inputs (TITLE, AUDIENCE, DURATION, CORE_MESSAGE, optional TRANSCRIPT / RESOURCES / EXISTING_OUTLINE / DEMO).
- **`presenter.md`** — voice/pace/humor/demo conventions. The prompt reads this before generating, so the output matches Ondřej's actual presentation style (cue-based speaker notes, hook-first openings, no em-dashes, fallback sub-slides for live demos, etc.).

## How to use

In Claude Code, Claude Desktop, or any Claude UI that can read local files:

```
Generate a workshop outline using:
- MODE: workshop
- TITLE: "Your Workshop Title"
- AUDIENCE: "<who's in the room>"
- DURATION: "2h 30min, 2x 75min blocks + break"
- CORE_MESSAGE: "The one sentence attendees should leave with"
- ATTENDEE_LEVEL: "<comfort level with terminal, Docker, etc.>"
- PREREQUISITES: "<what they install / sign up for before walking in>"
- OUTCOME_ARTIFACT: "<what each attendee leaves with>"
- STACK: "<frameworks, hosts, APIs you plan to use>"

Use `prompt.md` in this folder as the system prompt.
```

The prompt's example at the bottom of `prompt.md` shows the exact invocation that produced [`../workshop/outline.md`](../workshop/outline.md).

## Customizing

`presenter.md` is the file to edit if you're forking this for a different presenter:

- Pace (default ~75s per slide, adjusted for heavy/light slides)
- Hook style (personal story or relatable pain — never definitions)
- Humor calibration
- Demo handling (placeholder slide + 3 hidden fallback sub-slides)
- Quote conventions (verbatim + paraphrase + permission tracking)

`prompt.md` handles structure (sections, exercise blocks, schedule tables, checklists) and is mostly stable.
