# Use Cases — Untested / Backlog

These are researched but not yet validated in the workshop. Kept for reference and future iterations.

Use `use-cases-relatable.md` as the primary source of truth for Block B.

---

## Batch 1 — Monitoring / Informational (developer audience)

Researched 2026-06-25. Pull-based, mostly zero-auth.

| # | Name | Free Tool | Auth? | Difficulty | Wow | New Account? |
|---|------|-----------|-------|------------|-----|--------------|
| 1 | Morning Dev Briefing | HN Algolia + Lobste.rs | None | Easy | Medium | No |
| 2 | Dependency Update Watcher | GitHub Atom RSS | None | Easy | **High** | No |
| 3 | Weather-Aware Assistant | Open-Meteo | None | Easy | Medium | No |
| 4 | Currency Rate Monitor | Frankfurter | None | Easy | Medium | No |
| 5 | GitHub PR Digest | GitHub REST API | Free PAT | Medium | **High** | No |
| 6 | Smart Email Sender | Resend | API key | Easy | **High** | Yes (free) |
| 7 | DEV.to Article Digest | DEV.to Forem API | None | Easy | Medium | No |
| 8 | Push Notification Relay | ntfy.sh | None | Easy | **High** | No |
| 9 | Notion Knowledge Writer | Notion API | Integration token | Medium | **High** | Yes (free) |
| 10 | AI Research Assistant | OpenRouter free models | API key | Medium | **High** | Yes (free) |

### Details

**1. Morning Dev Briefing** — Scheduled 09:00 job fetches top HN + Lobste.rs stories, filters by tags, sends Telegram summary. API: HN Algolia + Lobste.rs — no auth.

**2. Dependency Update Watcher** — Monitors GitHub release Atom feeds. Alerts on new releases with changelog link. API: `https://github.com/{owner}/{repo}/releases.atom` — no auth.

**3. Weather-Aware Commute Assistant** — Weekday morning weather + precipitation for your city. API: Open-Meteo — no auth, 10k req/day free.

**4. Currency / Rate Monitor** — Watches an exchange rate, alerts on threshold cross. API: Frankfurter — no auth, 201 currencies.

**5. GitHub PR / Issue Digest** — Evening digest of open PRs and issues, grouped by urgency. API: GitHub REST API — free PAT.

**6. Smart Email Sender** — Agent sends formatted HTML emails: summaries, alerts. API: Resend — 3,000 emails/month free, no CC.

**7. DEV.to Article Digest** — Weekly digest of top articles by tag. API: `https://dev.to/api/articles?tag=typescript&top=7` — no auth.

**8. Push Notification Relay** — Native phone push notifications for any event. API: ntfy.sh — no account, POST to `https://ntfy.sh/{topic}`, 250 msg/day free.

**9. Notion Knowledge Writer** — Agent writes structured notes to Notion. API: Notion API — free plan, no CC.

**10. AI Research Assistant** — Uses OpenRouter free models for summarization. API: OpenRouter free tier — 26+ free models, 200 req/day, no CC.

---

## Batch 2 — Action-Oriented (developer audience)

Researched 2026-06-26. Agent creates or modifies something in an external system.

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

### Details

**1. PR Auto-Reviewer** — Fetches PR diff, posts inline review comments via LLM. API: GitHub REST API `POST /repos/.../pulls/{id}/reviews` — free PAT.

**2. Voice → Calendar** — Transcribes voice clip via Whisper, creates Google Calendar event. API: OpenAI Whisper ($0.006/min) + Google Calendar API (free).

**3. Auto-Bluesky Publisher** — Watches for `publish: true` frontmatter, posts to Bluesky. API: AT Protocol — no API key, session token from username/password.

**4. Standup Scribe** — Fetches Todoist completed tasks, formats standup, posts to Slack. API: Todoist REST API v1 (free) + Slack Web API (free).

**5. GitHub Issue → Task Auto-Triage** — Classifies new issues via LLM, applies labels, creates Todoist task. API: GitHub Webhooks + GitHub REST + Todoist (all free). Needs public webhook endpoint.

**6. Time-Tracker Whisperer** — Hooks into git commits to start/stop Toggl timers automatically. API: Toggl Track API — free plan, HTTP Basic Auth.

**7. Deploy-Failure Postmortem Writer** — On failed CI run, fetches logs, opens GitHub issue with postmortem. API: GitHub Actions `GITHUB_TOKEN` (built-in, free).

**8. Personal Finance Intake** — Parses forwarded receipts, creates rows in Airtable. API: Airtable REST API — free: 1,000 records/base, 100 calls/min.

**9. Voice Memo → GitHub Issue** — Transcribes voice bug report, files structured GitHub issue. API: OpenAI Whisper + GitHub REST API (free PAT).

**10. Meeting Notes Auto-Publisher** — Detects meeting end via Google Calendar, structures notes, creates Notion page. API: Google Calendar + Notion API (both free). Hard: two OAuth flows.
