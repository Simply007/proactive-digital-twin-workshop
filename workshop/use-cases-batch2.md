# Workshop Use Cases — Batch 2: Action-Oriented

Researched 2026-06-26. These complement batch 1 (monitoring/digest use cases).
Key distinction: every use case here creates or modifies something in an external system — the agent acts, not just reports.

## Quick Reference

| # | Name | Tool / API | Auth | Difficulty | Wow | New Account? |
|---|------|------------|------|------------|-----|--------------|
| 1 | PR Auto-Reviewer | GitHub REST API | Free PAT | Easy | **High** | No |
| 2 | Voice → Calendar | Whisper + Google Calendar | Free account | Medium | **High** | Maybe |
| 3 | Auto-Bluesky Publisher | Bluesky AT Protocol | Free account | Easy | Medium | Yes |
| 4 | Standup Scribe | Todoist + Slack API | Free accounts | Medium | **High** | Yes |
| 5 | GitHub Issue → Task Auto-Triage | GitHub Webhooks + Todoist | Free accounts | Medium | **High** | Yes |
| 6 | Time-Tracker Whisperer | Toggl Track API | Free account | Medium | **High** | Yes |
| 7 | Deploy-Failure Postmortem Writer | GitHub Actions + GitHub API | Free (GITHUB_TOKEN) | Medium | **High** | No |
| 8 | Personal Finance Intake | Airtable API | Free account | Easy | Medium | Yes |
| 9 | Voice Memo → GitHub Issue | Whisper + GitHub API | Free account | Easy | **High** | No |
| 10 | Meeting Notes Auto-Publisher | Google Calendar + Notion API | Free accounts | Hard | **High** | Yes |

## Design principle

Every use case produces an observable output — a calendar event, a post, an issue, a Notion page, a Slack message — that appears on screen during the demo. The agent creates or modifies something external. That is what separates these from batch 1.

---

## Detailed use cases

### 1. PR Auto-Reviewer
When a new pull request is opened, the agent fetches the diff via the GitHub REST API, runs it through an LLM, and posts inline review comments.
- **API:** GitHub REST API — `POST /repos/{owner}/{repo}/pulls/{pull_number}/reviews` — free with any PAT (`repo` scope)
- **Demo:** "Watch — I just opened a PR with a bug in it. My agent is already reading the diff… and there it is: an inline comment pointing at the exact line."

### 2. Voice → Calendar
Agent transcribes a voice clip via Whisper, parses the natural-language result ("lunch with Maria next Tuesday at 1pm"), and creates a Google Calendar event.
- **API:** OpenAI Whisper ($0.006/min, ~$5 credit covers hundreds of demos) + Google Calendar API (free within quota)
- **Demo:** "I'll say this once: 'Schedule a team retrospective for Friday at 4pm.' Done — look at the calendar. The event is there."

### 3. Auto-Bluesky Publisher
Agent watches for files with `publish: true` frontmatter, formats a post, and calls the Bluesky AT Protocol API to publish — no API key, just username/password session auth.
- **API:** Bluesky AT Protocol — `POST /xrpc/com.atproto.repo.createRecord` — free, no API key, ~1,666 posts/hour limit
- **Demo:** "I saved a markdown file with `publish: true`. The agent parsed it, trimmed it, and posted it to Bluesky. No dashboard, just a file save."

### 4. Standup Scribe
Every weekday at 9:00 AM the agent fetches Todoist tasks completed since yesterday, formats a standup, and posts to Slack — without the developer doing anything.
- **API:** Todoist REST API v1 (free forever) + Slack Web API `chat.postMessage` (free)
- **Demo:** "It's 9am. My agent checked what I closed in Todoist yesterday, wrote my standup, and posted it. My team already replied. I didn't type a word."

### 5. GitHub Issue → Task Auto-Triage
On new GitHub issue, agent classifies severity/category via LLM, applies labels via GitHub API, and creates a linked Todoist task — all in under 3 seconds.
- **API:** GitHub Webhooks (free) + GitHub REST API (free) + Todoist API (free). Webhook needs public endpoint — use Cloudflare Workers free tier for demo.
- **Demo:** "I just created a GitHub issue titled 'Login fails on Safari.' Watch Todoist — there: a task, labeled 'bug / high priority', linked to the issue."

### 6. Time-Tracker Whisperer
Agent hooks into git commit events. On commit: starts a Toggl timer tagged with repo/branch. On push or 20-min idle: stops it. Automatic time tracking with no manual logging.
- **API:** Toggl Track API — `POST /api/v9/time_entries` / `PUT /api/v9/time_entries/{id}/stop` — free plan, HTTP Basic Auth
- **Demo:** "I'll make a commit… switch to Toggl Track — timer started, tagged with this repo and branch. I didn't click anything."

### 7. Deploy-Failure Postmortem Writer
On failed GitHub Actions deploy, agent fetches run logs, identifies root cause via LLM, opens a GitHub issue with a pre-filled postmortem — labeled `postmortem`, assigned to the last committer.
- **API:** GitHub Actions + GitHub REST API — uses `GITHUB_TOKEN` automatically, no extra setup. Free for public repos; 2,000 min/month free for private.
- **Demo:** "This deploy just failed. Look at Issues — the agent already opened a postmortem: failing step, probable cause, assigned to me. Five seconds after the failure."

### 8. Personal Finance Intake
Agent receives forwarded receipt emails, extracts vendor/amount/date/category via LLM, and creates a row in Airtable. End-of-month summary on demand.
- **API:** Airtable REST API — `POST /v0/{baseId}/{tableIdOrName}` — free: unlimited bases, 1,000 records/base, 100 calls/min
- **Demo:** "I'll forward this restaurant receipt to my agent… and in Airtable, the row appeared: date, vendor, amount, category 'Meals'. No spreadsheet, no manual entry."

### 9. Voice Memo → GitHub Issue
Developer records a voice bug report. Agent transcribes with Whisper, extracts title/steps-to-reproduce/expected vs actual, files a structured GitHub issue with labels.
- **API:** OpenAI Whisper + GitHub REST API `POST /repos/{owner}/{repo}/issues` (free PAT)
- **Demo:** [Records 15-second voice note] "Watch GitHub — the issue just appeared. Proper title, steps to reproduce, labeled 'bug'. Spoken, not typed."

### 10. Meeting Notes Auto-Publisher
After a Google Meet ends, agent detects via Google Calendar API, structures the notes via LLM (decisions, action items, owners), creates a Notion page with a database row linking to the event.
- **API:** Google Calendar API (free) + Notion API (free for personal integrations). Difficulty caveat: two OAuth flows + Notion block structure is verbose.
- **Demo:** "This calendar event ended 2 minutes ago. Look at Notion — the page is already there: decisions, action items with owners. The agent wrote it while we were saying goodbye."

---

## Verification notes
- Bluesky API: genuinely free, no API key needed, confirmed via official docs
- GitHub PR reviews: free with PAT, confirmed
- Toggl free plan API access: assumed from public docs — verify before demo
- Whisper: $0.006/min, not free forever, but $5 credit covers hundreds of demo clips
- Airtable free tier: 1,000 records/base, 100 API calls/min, confirmed
- Notion API: free for personal integrations, confirmed
