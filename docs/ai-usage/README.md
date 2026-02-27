# AI Usage Evidence — [Your Project Name]

This folder is the proof of AI-assisted SDLC for this project.
It is populated **automatically** by the `post-commit` git hook — no manual effort required.

## How It Works

Every `git commit` with an ADO ticket ID (`ADO-{N}`) triggers the post-commit hook.
The hook extracts session metrics and creates/updates a markdown file here.

The git history of this folder is your timestamped, immutable audit trail.

## Structure

Files are organised by **release branch** — matching your devops flow:

```
ai-usage/
  release-feat-profile/
    ADO-123.md       ← one file per ticket
    ADO-124.md
  release-feat-onboarding/
    ADO-200.md
    ADO-201.md
```

## What Each File Contains (auto-generated)

| Field | Source |
|-------|--------|
| Ticket ID | Extracted from commit message or branch name |
| Developer name | From `git config user.name` |
| Date | Commit timestamp |
| Release branch | Detected from git branch hierarchy |
| Workflow type | Local (VS Code) or Remote (GitHub Actions) — auto-detected |
| Session duration | From `logs/copilot/session.log` |
| Prompt count | From `logs/copilot/prompts.log` |
| Files changed | From `git diff --stat` |
| Lines added/removed | From `git diff --stat` |

Subsequent commits to the same ticket append update sections to the same file.

## Workflow Detection

The hook auto-detects which workflow was used:

- **Local** — if a matching `taskPlan/{TICKET-ID}*.md` file exists
- **Remote** — otherwise (GitHub Actions / Copilot Workspace pipeline)

## For Management Review

The `ai-usage/` folder tells the complete story:

| Question | Where to look |
|----------|---------------|
| What AI generated? | Prompt count + files changed per ticket |
| How long did it take? | Session duration per ticket |
| Which workflow was used? | Workflow type field (local vs remote) |
| What was the developer's role? | AI Acceptance Rate checkbox (manual) |
| Timeline from story to commit? | Git history of this folder |
| Coverage per release? | Each release branch subfolder |

## Setup

The post-commit hook is already included in the template.
Each developer runs this once per clone:

```bash
git config core.hooksPath .github/hooks/git
```
