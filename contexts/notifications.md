# Teams Notifications — Setup Guide

Agents can send real-time notifications to a Microsoft Teams channel when key events happen (PR created, review verdict, comments resolved, phase complete, story blocked).

**Method:** Teams Incoming Webhook — zero auth, zero tokens, just a URL.

---

## Setup (One-Time — 2 Minutes)

### 1. Create an Incoming Webhook in Teams

1. Open **Microsoft Teams** → go to the target channel (e.g. `#platform-dev`)
2. Click `...` → **Connectors** (or **Manage Channel** → **Connectors**)
3. Search for **Incoming Webhook** → **Configure**
4. Name it: `SDLC Copilot` (or any name)
5. Optionally upload an icon
6. Click **Create** → copy the webhook URL

### 2. Store the Webhook URL

Create a file `.notifications.env` in your **project root** (this file is gitignored — never committed):

```env
# Teams Incoming Webhook URLs
TEAMS_WEBHOOK_URL=https://your-org.webhook.office.com/webhookb2/.../IncomingWebhook/.../...

# Optional: separate channels for different notification types
# TEAMS_WEBHOOK_URL_ALERTS=https://...
# TEAMS_WEBHOOK_URL_SPRINT=https://...
```

### 3. Done

Agents will automatically detect the webhook URL and send notifications. If the file is missing, notifications are silently skipped — no errors, no agent failures.

---

## How It Works

Agents call a shared Node.js helper script via the `execute` tool:

```bash
node .github/hooks/notify-teams.js <type> [key=value ...]
```

The script:
1. Reads the webhook URL from `.notifications.env` (or `TEAMS_WEBHOOK_URL` env var)
2. Builds a rich **Adaptive Card** (formatted Teams message)
3. POSTs to the webhook — fire and forget (never blocks the agent)
4. If no webhook URL found → silently exits (notifications are optional)

---

## Notification Types

| Type | Sent By | When |
|------|---------|------|
| `pr-created` | @git-publisher | PR created on GitHub |
| `review-ready` | @local-reviewer | Review verdict: READY |
| `review-blocked` | @local-reviewer | Review verdict: BLOCKED |
| `comments-resolved` | @address-comments | PR comments addressed + pushed |
| `phase-complete` | @sprint-orchestrator | Execution phase completed |
| `story-blocked` | @sprint-orchestrator | Story blocked by dependency |
| `custom` | Any agent | Free-form notification |

---

## Example Commands

```bash
# PR created
node .github/hooks/notify-teams.js pr-created story=STORY-456 service=fund-transfer pr=https://github.com/org/repo/pull/42 branch=feature/STORY-456-mortgage target=release/2.0.0

# Review passed
node .github/hooks/notify-teams.js review-ready story=STORY-456 service=fund-transfer critical=0 warnings=2 suggestions=5

# Review blocked
node .github/hooks/notify-teams.js review-blocked story=STORY-456 service=fund-transfer critical=3 findings="BigDecimal violation, missing audit trail"

# Comments resolved
node .github/hooks/notify-teams.js comments-resolved pr=#42 fixed=5 flagged=1 branch=feature/STORY-456-mortgage

# Phase complete
node .github/hooks/notify-teams.js phase-complete epic=EPIC-100 phase=2 totalPhases=4 storiesDone=3

# Story blocked
node .github/hooks/notify-teams.js story-blocked story=STORY-789 blockedBy=STORY-456 reason="Depends on entity created in STORY-456"

# Custom
node .github/hooks/notify-teams.js custom title="Deploy Complete" message="Release 2.0.0 deployed to SIT"
```

---

## Multiple Channels

You can configure separate webhook URLs for different notification categories:

```env
TEAMS_WEBHOOK_URL=https://...          # Default channel (all notifications)
TEAMS_WEBHOOK_URL_ALERTS=https://...   # Critical alerts only (blocked reviews, blocked stories)
TEAMS_WEBHOOK_URL_SPRINT=https://...   # Sprint progress (phase complete, sprint summary)
```

To use a specific channel, pass it as an argument:
```bash
node .github/hooks/notify-teams.js review-blocked story=STORY-456 webhook=$TEAMS_WEBHOOK_URL_ALERTS
```

---

## Security

- The webhook URL is the only credential — **never commit it to git**
- `.notifications.env` is in `.gitignore` — safe by default
- The webhook URL allows POST only — no one can read your channel messages with it
- If the URL leaks, delete the connector in Teams and create a new one (30 seconds)
