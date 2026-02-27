# Git Hooks — AI Usage Auto-Logger

Committable git hooks that auto-track AI usage metrics on every commit.
Unlike the Copilot VS Code hooks (`.github/hooks/session-logger/`), these are standard
git hooks that fire on git events — no Copilot dependency required.

**Requirements:** bash + git only. Works on git bash (Windows), macOS, Linux. No Python, no PowerShell.

## Hooks Included

| Hook | Fires | What it does |
|------|-------|--------------|
| `post-commit` | After every `git commit` | Detects ticket ID, reads session logs, writes/updates `docs/ai-usage/{release-branch}/{TICKET-ID}.md` |

## One-Time Setup (per repo clone)

Run this once after cloning the repo:

```bash
git config core.hooksPath .github/hooks/git
```

This tells git to look for hooks in `.github/hooks/git/` instead of `.git/hooks/`.
Because this is a git config setting (not committed), each developer must run it once.

**Add it to your repo's `README.md` or `CONTRIBUTING.md` onboarding steps.**

### Verify it's working

```bash
git config core.hooksPath
# Should output: .github/hooks/git
```

## What the post-commit Hook Does

On every `git commit` where the commit message or branch name contains `ADO-{N}`:

1. **Detects** the ticket ID from commit message or branch name
2. **Reads** session metrics from `logs/copilot/session.log` and `prompts.log`
3. **Reads** git diff stats (files changed, lines added/removed)
4. **Detects** the release branch:
   - If on a `release/*` branch → uses that
   - If on a `feat/*` branch → finds the upstream/closest release branch
   - Fallback → sanitized current branch name
5. **Detects** workflow type:
   - **Local** — if a matching `taskPlan/{TICKET-ID}*.md` exists
   - **Remote** — otherwise (GitHub Actions / Copilot Workspace flow)
6. **Creates** `docs/ai-usage/{release-branch}/{TICKET-ID}.md` on first commit
7. **Appends** an update section on subsequent commits to the same ticket
8. **Stages** the ai-usage file so it can be included in the next commit

## Folder Organisation

Files are grouped by release branch — matching your devops flow:

```
docs/ai-usage/
  release-feat-profile/
    ADO-123.md
    ADO-124.md
  release-feat-onboarding/
    ADO-200.md
  feat-ADO-999-hotfix/           ← fallback if no release branch detected
    ADO-999.md
```

This means every release branch has its own AI usage trail — perfect for release retrospectives
and management reporting per feature/release.

## Privacy & Security

- The hook only logs metadata (ticket ID, file counts, session duration, prompt count)
- No prompt content is ever logged
- No code content is logged
- `logs/` is gitignored — session logs stay local
- `docs/ai-usage/` IS committed — it is your audit trail

## Skip for a Specific Commit

To skip AI usage tracking for a commit (e.g. a hotfix with no ticket):

```bash
SKIP_AI_USAGE=true git commit -m "hotfix: ..."
```

The hook checks for `SKIP_AI_USAGE=true` and exits cleanly.
