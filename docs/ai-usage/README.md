# AI Usage Evidence — [Your Project Name]

This folder is the proof of AI-assisted SDLC for this project.
It is populated automatically as part of the PR process — no manual effort required.

## How It Works
Every PR must include an update to this folder in `sprint-{N}/[TICKET-ID].md`.
The AI review workflow checks for this file and flags PRs that don't include it.
The git history of this folder is your timestamped audit trail.

## Structure
```
ai-usage/
  sprint-01/
    TICKET-123.md    ← one file per story
    TICKET-124.md
  sprint-02/
    TICKET-125.md
```

## What Each File Contains
- Story/ticket ID and title
- Which prompt file was used from `prompts/`
- Summary of what Copilot generated
- What the developer modified or rejected
- Link to the PR

## For Management Review
The `ai-usage/` folder tells the complete story:
- What AI generated (prompt → output)
- What humans accepted, modified, or rejected
- Timestamped via git history — auditable and immutable
- What humans verified and changed
- Timeline from story to PR via git history
- Coverage across all services and sprints
