# Workshop Use Cases — Block B Focus

Version 3 — 2026-06-26

## Context

Block B starts with attendees who already have:
- NanoClaw running in Docker
- Agent personalized via CLAUDE.local.md (Exercise 2)
- 75 minutes left

Block B's narrative arc: **you built an agent that knows you → make that memory persist → watch it act without you asking**

The use cases below map directly onto Block B's time slots. They are demonstrations of the "comes to you / runs without you / remembers you" thesis, not standalone API tutorials.

---

## Block B use case map

| Time slot | Activity | Use case woven in |
|-----------|----------|-------------------|
| 1:15 – 1:35 | Living Files debrief | #5 Growing personal context (narrative, no hands-on) |
| 1:35 – 2:00 | Exercise 3: GitHub memory sync | #1 Scheduled message (bonus task after sync job is set up) |
| 2:00 – 2:20 | Exercise 4: Run your use case | Attendees pick the poll winner from #1–#10 and set it up |
| 2:20 – 2:30 | Wrap-up | #2 Deadline follow-up / #3 Weekly recap (show, don't build) |

---

## The 10 use cases for Exercise 4

### 1. Scheduled Message *(Preparation 3 bonus — 5 min add-on)*

After attendees set up the hourly sync job, have them immediately schedule one more job — a message to themselves, delivered during the wrap-up section of the workshop.

**Why here:** Preparation 3 teaches `schedule_task`. The sync job is functional but dry. The scheduled message makes the concept click emotionally — the notification arrives on their phone while they're still in the room.

**What to DM:**
> `schedule a message to me in 45 minutes: "You built a proactive agent today. Here's what to try this week: [paste 3 ideas from the wrap-up]"`

**Presenter timing:** schedule it during Preparation 3. It fires during the wrap-up. No coordination needed — it just arrives.

**Difficulty:** Easy — literally the same `schedule_task` call they just learned.

**Wow:** High — because the notification arrives while they're in the room. They feel it instead of imagining it.

---

### 2. Deadline Follow-Up Guardian *(wrap-up demo — 2 min show)*

Presenter tells the agent live: "I'm waiting on a reply from the Web Summer Camp organizers about my speaker dinner. If I haven't confirmed by tomorrow morning, remind me and draft a follow-up."

**Why here:** Shows the "agent monitors time without you asking" concept. One message, one scheduled behavior. The gap from ChatGPT is obvious — no chat UI can do this.

**What to DM (presenter, live on stage):**
> `if I haven't mentioned hearing back from Ivo by tomorrow 9am, send me a reminder and draft a follow-up email for me`

**Don't build this as an attendee task** — too little time. Show it as a 90-second demo during wrap-up. The audience gets it instantly.

**Difficulty:** Easy

**Wow:** High — most relatable "I always forget to follow up" moment. Every person in the room has this problem.

---

### 3. Weekly Recap *(wrap-up demo — 2 min show)*

Show a pre-prepared example: a Telegram message the agent sent on a Friday afternoon, listing what happened that week — based on conversation history and completed tasks.

**Why here:** Closes the "memory builds over time" story. Block B just showed how memory persists. The weekly recap is the payoff — the agent reads back what happened in your week because it was there for it.

**What to show:** A screenshot or live message of a recap. Don't build it live — show the outcome.

**DM to set it up (show, don't run):**
> `every Friday at 17:00, review our conversation history from this week and send me a summary: what did I work on, who did I talk to, what's open`

**Difficulty:** Easy

**Wow:** Medium — best as a narrative closer. "The longer you use it, the more it knows. A week from now, it'll send you this."

---

### 4. Async Research Delivery *(memory backends talk — live demo, 3 min)*

During the "memory backends" section, kick off a research task live. Ask the agent to research something and deliver a report while the talk continues. The report arrives before the section ends.

**Why here:** The memory backends talk is currently a slide/concept section with no hands-on. This adds a live moment. It also demonstrates the "background agent" capability — the agent works while the presenter is talking.

**What to DM (at the start of the memory backends section):**
> `research the best free PostgreSQL hosting options for a side project in Europe — I want self-hosted vs managed, pricing, and a one-line verdict. Send me the report when you're done.`

Then keep talking. The report arrives 3-4 minutes later, during the pgvector slide.

**Presenter line:** "I started that 4 minutes ago. I didn't watch it work. It just sent me the result. That's what I mean by async — you delegate, not babysit."

**Difficulty:** Easy for the presenter

**Wow:** High — because it's invisible, then it arrives. Perfect demo of the "background agent" concept.

---

### 5. Growing Personal Context *(Living Files debrief — narrative, no hands-on)*

During the debrief, show the CLAUDE.local.md file and the memory folder side by side. Point out: "This file didn't exist when you arrived. You didn't write it — you answered 5 questions. The agent wrote it."

Then fast-forward: "Come back next week. Tell it you just had a difficult client call. Tell it you're prepping for a talk. Tell it what you shipped on Friday. It accumulates. A month from now, when you ask 'what should I prioritize today?', the answer will be different than it is right now — because it will know your month."

**Why here:** This is a narrative beat, not a demo. The concept of persistent growing context is what separates a digital twin from a chat assistant. Block B's debrief is the right moment to state this clearly.

**No hands-on needed.** The attendees already built it in Exercise 2.

**Wow:** Medium — but it's the moment the concept clicks at a deeper level. The "month from now" framing is the takeaway they'll remember.

---

## What to cut if running behind

| Cut | Impact |
|-----|--------|
| #3 Weekly recap | Low — wrap-up can skip this, mention in the QR/follow-up list |
| #4 Async research (live demo) | Low — mention it as a capability without the live kick-off |
| #1 Scheduled message bonus task | Medium — keep as a presenter-only demo if time is short; attendees see the notification but don't build it |
| #2 Deadline follow-up (wrap-up demo) | Low — 2 min show, easy to cut |
| **Never cut** | Living Files debrief + Exercise 3 (GitHub sync) — these are the workshop's core |

---

## The one live moment that must happen

**Schedule something that fires during the workshop itself.**

Whether it's #1 (scheduled message), or just "watch me schedule a reminder for 20 minutes from now" — the audience needs to feel it arrive. That's the moment that converts the idea into a belief. Everything else is explainable. That moment is undeniable.

---

---

### 6. Price / Change Watcher *(Exercise 4 option)*

Tell the agent to watch any URL for changes and alert you when something shifts.

**What to DM:**
> `every morning at 9am, check https://nanoclaw.sh and tell me if anything on the page has changed since yesterday. If yes, summarize what's new.`

**Why NanoClaw wins here:** ChatGPT can't check a URL tomorrow morning — it closes when you close the tab.

**Difficulty:** Easy

**Wow:** High — visual payoff when the alert arrives.

---

### 7. Pre-Meeting Brief *(Exercise 4 option)*

Agent sends a short brief before any meeting based on what it knows about the people you're meeting.

**What to DM:**
> `every weekday at 8am, check if I have any meetings today and send me a brief: who I'm meeting, what I know about them from memory, and one suggested talking point.`

**Why NanoClaw wins here:** it knows what you've told it about that person — context a generic assistant can't have.

**Difficulty:** Easy (works as a narrative brief even without calendar integration)

**Wow:** Medium — lands harder once you've talked to the agent a few times and it recalls real context.

---

### 8. Proactive Learning Nudge *(Exercise 4 option)*

Agent nudges you to practice a skill based on what you're working on.

**What to DM:**
> `every Monday at 9am, remind me to practice TypeScript for 20 minutes and suggest one specific thing to try based on what I've told you about my current project.`

**Why NanoClaw wins here:** the suggestion is personalised to your stack and current project — not a generic "learn TypeScript" link.

**Difficulty:** Easy

**Wow:** Medium — works better the more context the agent has about you.

---

### 9. Multi-Step Event Chain *(Exercise 4 option)*

One trigger, a chain of actions spread across time.

**What to DM:**
> `when I say "shipped": send me a Telegram message saying the feature is live, then in 2 hours remind me to check the error logs, then tomorrow morning ask me for a one-sentence retro on what went well.`

**Why NanoClaw wins here:** a ChatGPT session can't follow up 2 hours later or tomorrow.

**Difficulty:** Easy

**Wow:** High — the delayed follow-up is the moment the "it remembers" concept clicks.

---

### 10. Escalating Reminder *(Exercise 4 option)*

Agent starts gentle and gets louder if you don't act.

**What to DM:**
> `I need to write a blog post about last week's talk. Remind me today at 5pm. If I haven't mentioned it by tomorrow 9am, remind me again with more urgency. If still nothing by Thursday, send me a draft outline so I have something to react to.`

**Why NanoClaw wins here:** ChatGPT forgets the moment you close the tab. This one keeps coming back until the task is done — or does the first draft for you.

**Difficulty:** Easy

**Wow:** High — the escalation story is instantly relatable. Everyone has the task they keep avoiding.

---

*v4 — 10 use cases for Exercise 4 voting — iterate from here*
