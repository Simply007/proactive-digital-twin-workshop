# Workshop Use Cases — Proactive Digital Twin

Researched 2026-06-25. Free-tier only, developer audience.

## Quick Reference

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

## Workshop recommendation

Best three to demo live (in order):
1. **ntfy.sh** — zero setup, phone lights up in 30 seconds, sets the tone
2. **Dependency Update Watcher** (GitHub Atom) — zero auth, real use case, every dev relates
3. **Smart Email Sender** (Resend) — bridges digital/physical, visually impressive

Zero-account stack (can demo all 7 without anyone creating a new account):
Open-Meteo + HN Algolia + Lobste.rs + GitHub Atom + Frankfurter + DEV.to + ntfy.sh

---

## Detailed use cases

### 1. Morning Dev Briefing
Scheduled 09:00 job fetches top HN + Lobste.rs stories, filters by tags matching your interests, sends Telegram summary.
- **API:** HN Algolia (`https://hn.algolia.com/api/v1/search`), Lobste.rs (`https://lobste.rs/hottest.json`) — no auth, no rate limits
- **Demo:** "What are the top 5 HN stories about TypeScript today?"

### 2. Dependency Update Watcher
Monitors GitHub release Atom feeds for repos you depend on. Alerts on new releases with changelog link and semver bump type.
- **API:** `https://github.com/{owner}/{repo}/releases.atom` — no auth
- **Demo:** "Watch the TypeScript and Vite repos and alert me when they release anything."

### 3. Weather-Aware Commute Assistant
Weekday morning weather + precipitation probability for your city. Plain-English summary.
- **API:** Open-Meteo (`https://api.open-meteo.com/v1/forecast`) — no auth, 10k req/day free
- **Demo:** "What's the weather in Prague for the next 3 days?"

### 4. Currency / Rate Monitor
Watches an exchange rate, alerts when it crosses a threshold. Stores last-seen rate in a file.
- **API:** Frankfurter (`https://api.frankfurter.dev/v2/rates`) — no auth, 201 currencies
- **Demo:** "Alert me when EUR/CZK goes above 25.5."

### 5. GitHub PR / Issue Digest
Evening digest of open PRs and issues across your repos, grouped by urgency.
- **API:** GitHub REST API — free PAT (5,000 req/hr)
- **Demo:** "Show me all PRs in my repos open for more than 5 days."

### 6. Smart Email Sender
Agent sends formatted HTML emails: daily summaries, reports, triggered alerts.
- **API:** Resend — 3,000 emails/month free, no CC. Sign up: https://resend.com
- **Demo:** "Send me an email summary of my GitHub PRs and today's top HN stories."

### 7. DEV.to Article Digest
Weekly digest of top articles tagged with your topics, filtered by minimum reactions.
- **API:** DEV.to Forem API (`https://dev.to/api/articles?tag=typescript&top=7`) — no auth
- **Demo:** "Find the top 5 TypeScript articles on DEV.to from the last week."

### 8. Push Notification Relay
Agent fires native phone push notifications for any event — lock screen alert, not just a chat message.
- **API:** ntfy.sh — no account, POST to `https://ntfy.sh/{topic}`, 250 msg/day free
- **Demo:** "Send a push notification to my phone right now."

### 9. Notion Knowledge Writer
Agent writes structured notes and research into your Notion workspace.
- **API:** Notion API — free plan includes API access, no CC. Integration setup: 2 min.
- **Demo:** "Save the top 3 HN stories today as notes in my Notion reading list."

### 10. AI Research Assistant
Uses OpenRouter free models (Llama 3.3 70B, DeepSeek R1, etc.) for summarization and analysis tasks.
- **API:** OpenRouter free tier — 26+ free models, 200 req/day, no CC
- **Demo:** "Summarize this GitHub issue thread and tell me if it's worth reading."
