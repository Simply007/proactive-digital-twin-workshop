# Presenter Profile: Ondřej Chrastina

> For role, career path, expertise, and reference links, see [`_general/about.md`](../_general/about.md).
> For typography rules (no em dashes, name spellings), see [`_general/typography.md`](../_general/typography.md).

**Known for**: Mixing QA war stories with stealable engineering patterns; talks that feel like a colleague sharing hard-won lessons, not a product pitch.

---

## Pacing

- **Default**: ~75 seconds per slide
- **Heavy slides** (architecture diagrams, code walkthroughs, war stories): 90–120s
- **Light/transition slides** (pillar titles, section openers): 30–60s
- **Rule of thumb**: 25 slides ≈ 30 min; adjust slide count proportionally for other durations
- **Buffer**: keep 2–3 min for audience Q&A or natural overrun

---

## Workshop Pacing (`MODE: workshop` only)

When the prompt runs in workshop mode, slide-second pacing doesn't apply. Use these defaults instead:

- **Exercise length**: 20–35 min each. Anything longer needs a mid-exercise checkpoint.
- **Troubleshooting buffer**: budget ~15% of each block's time for "the one attendee whose VPS region went down". Buffer is per-block, not per-exercise.
- **Mid-session break**: always ≥10 min between blocks. Non-negotiable. Use it for water, restrooms, and 1:1 troubleshooting with stragglers.
- **Demo cue style**: same dry, war-story tone as talks, but with an explicit attendee task right after ("now you try the same thing in your terminal").
- **Checkpoints**: end every exercise with a verifiable signal (output line, file present, message in channel) and the presenter asks for thumbs up before moving on.
- **Cut candidate**: every workshop names one exercise that can be dropped if the room is running slow. Usually the last exercise of Block B.
- **Backup mindset**: assume one of {VPS, API, WiFi} will fail for at least one attendee. Have a screencast or pre-recorded artifact ready so they still see the outcome.

---

## Hook Style

- Opens with a **personal story** or a **relatable pain point** — never with a definition, agenda slide, or "today I'm going to tell you about..."
- The hook should create a "yes, that's me too" moment within the first 60 seconds
- Examples from past talks: "My Thursdays used to be clicking through the same checklist by hand"; "I mean, what's the worst that could happen — it already happened."
- After the hook: one clean statement of the problem, then pivot to the talk structure

---

## Humor Calibration

- **Style**: dry, self-aware, European-developer understated
- **Source**: humor emerges from the war-story framing, not from forced jokes or puns
- **Calibration**: never punches down; self-deprecating about past mistakes is fine
- **Examples**: "we fixed it by adding a `// TODO: revisit this`"; "naturally, this was discovered in production"
- **Avoid**: tech-bro humor, regional idioms that don't travel, AI-generated punchlines

---

## Sourcing Transparency

- Maintains a dedicated early slide (typically slide 2–4) that explicitly credits all interviewees and sources
- Framing: "this talk is based on N interviews with colleagues + repo archaeology + N years of watching CI turn red"
- Builds credibility and sets up the quote-per-pillar structure the audience will see throughout
- Quote permissions are tracked per-person: **quotable on stage** vs. **paraphrase only**

---

## Demo Handling

- Prefers **live demos** over screenshots
- Always prepares a **screencast fallback** — mentioned explicitly on the demo slide ("if WiFi fails, slides Xa/Xb/Xc")
- Demo slides have 3 hidden fallback sub-slides showing the key moments as screenshots or terminal output
- Narrates out loud during demos so the audience can follow even if they can't see the screen clearly
- Demo tag lines are short and repeatable: "Same suite. One flag."

---

## Speaker Notes Style

- **Bullet-list cues** — one bullet per beat; nested bullets for sub-points
- No explicit timing or hand-holding markers — trust the presenter to pace
- Keep it short: 3–6 bullets for a 90s slide; 1–2 for a transition slide
- Last bullet is always the transition: `→ Next topic`

---

## Audience Calibration

- **Primary**: mid–senior JavaScript / web developers
- **Calibration principle**: "no hand-holding on basics, full explanation of architectural decisions"
- After each pillar, explicitly names the audience-specific takeaway: "Here's the thing you can steal for your own project."
- Avoids vendor lock-in framing — patterns should be applicable beyond CKEditor
- Acknowledges when something is CKEditor-specific vs. universally applicable

---

## Quote Usage on Slides

- **One direct colleague quote per pillar** (or per major section), centered on screen
- Slightly larger font weight than body text; attributed clearly (name + role)
- Quotes must be pre-cleared for stage use — tracked as:
  - **Quotable on stage**: can appear verbatim on the slide
  - **Paraphrase only**: rephrase the idea; don't show the person's name on screen
- Quote slides are brief (30–45s) — let the quote land, add one line of context, move on

---

## Closing Pattern

- **Penultimate slide**: 4–6 bullet takeaways — one per pillar + one hygiene/meta lesson
- **Final slide**: links only — repo, personal site, talk recording, and a short URL or QR code
- Invites async follow-up ("find me after, or DM on X/Mastodon — the handle is on the slide")
- Avoids "any questions?" as the last visible slide; questions happen while the links slide is visible

---

## Writing Checklist (for speaker notes)

When writing speaker notes for this presenter, ensure:

- [ ] Bullet-list cues (no prose paragraphs, no hand-holding markers)
- [ ] Concise — 3–6 bullets per 90s slide, 1–2 for transitions
- [ ] Last bullet is always the transition arrow (→ Next topic)
- [ ] Demo narration includes audience-facing commentary ("I'm running this with the `-b` flag to skip rebuilding")
- [ ] Hook slide notes name the personal story without over-scripting it
- [ ] Sourcing slide notes list all credited people (verify against front matter)
- [ ] Takeaway slide notes name the CORE_MESSAGE explicitly

---

## Past Talks for Reference

| Conference | Title | Notes |
|---|---|---|
| JSNation Amsterdam 2026 | "Sleep Better on Release Day: A Modern Testing Strategy for JavaScript SDKs and Components" | 25 slides, ~30 min, 3-pillar structure |
| DrupalCon Chicago 2026 | CKEditor 5 + Drupal vibe-coding session | Live coding demo format |
| CMS Summit 26 Frankfurt | "The real story behind AI in content editing" | Discovery-driven, enterprise AI content patterns, closed Wednesday morning session |
| AI Conference 2025 | CKEditor AI features showcase | Product-demo oriented |
