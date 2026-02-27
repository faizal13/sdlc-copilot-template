# RAKBANK Copilot Workflow Plugins

Install the AI-SDLC agents, hooks, and skills into any project repo — from the central template.

**Central Template:**
`https://github.com/rakbank-internal/platform-backend-copilot-template`

---

## Folder Structure

```
plugins/
  bootstrap.sh        ← The ONE file developers copy and run (entry point)
  install.sh          ← Thin orchestrator — auto-discovers plugins in lib/
  README.md           ← This file
  lib/
    utils.sh          ← Shared bash utilities (copy_file, print_section, …)
    shared.sh         ← Foundation components installed for EVERY plugin
    local.sh          ← Plugin: local VS Code workflow
    remote.sh         ← Plugin: remote GitHub Actions workflow
    # future:
    # analytics.sh    ← Plugin: AI usage dashboard
    # jira.sh         ← Plugin: Jira integration
```

Adding a new plugin = **one file in `lib/`**. Zero changes to `install.sh`.

---

## Available Plugins

| Plugin | Agents installed | Best for |
|--------|-----------------|----------|
| `local` | `@task-planner`, `@local-rakbank-dev-agent`, `@local-reviewer`, `@local-instinct-learner` | Working locally in VS Code |
| `remote` | `@story-analyzer`, `@coding-agent`, `@instinct-extractor` + GitHub Actions (4) | GitHub Copilot Workspace + Actions pipeline |
| `all` | Everything above | Teams wanting both options |

---

## How to Install (Developer Steps)

### Step 1 — Get `bootstrap.sh`

Copy `bootstrap.sh` from the central template. You only need to do this once per machine.

Options:
- **Browser:** Go to `https://github.com/rakbank-internal/platform-backend-copilot-template/blob/main/plugins/bootstrap.sh` → click **Raw** → Save As
- **Copy from a colleague** who already has it
- **Clone the template once** and keep it:
  ```bash
  git clone https://github.com/rakbank-internal/platform-backend-copilot-template.git ~/rakbank-copilot-template
  ```

> **Why not curl?** The template is in a private org repo — curl requires token auth. Git uses your existing org credentials automatically. No extra setup needed.

### Step 2 — Run from your project repo

```bash
# cd into your project repo root
cd /path/to/your-project

# Run bootstrap.sh — it fetches the latest template and installs
bash /path/to/bootstrap.sh local
# or
bash /path/to/bootstrap.sh remote
# or
bash /path/to/bootstrap.sh all
```

**That's it.** The script:
1. Shallow-clones the template from `rakbank-internal/platform-backend-copilot-template` using your existing git credentials
2. Copies only the files for the chosen plugin(s) into your project
3. Skips files that already exist (safe to re-run — your customisations are preserved)
4. Configures `git config core.hooksPath` for the AI usage hook
5. Cleans up the temp clone automatically

### Step 3 — Verify

```bash
# Check agents are available
ls .github/copilot/agents/

# Check git hook is configured
git config core.hooksPath
# Expected: .github/hooks/git

# Open VS Code and test
# @task-planner (local) or @story-analyzer (remote)
```

---

## What Gets Installed

### Always Installed (every plugin)

| Component | Path | Purpose |
|-----------|------|---------|
| `@context-architect` | `.github/copilot/agents/context-architect.md` | Context mapping for any change |
| Skills (3) | `.github/skills/` | Auto-triggered: context-map, what-context-needed, refactor-plan |
| Session logger | `.github/hooks/session-logger/` | Copilot prompt + session tracking |
| Post-commit hook | `.github/hooks/git/post-commit` | Auto-logs AI usage on every ADO commit |
| Instructions | `.github/instructions/` | Auto-applied coding, security, testing, review rules |
| AI usage folder | `docs/ai-usage/` | Created empty — populated by hook on commits |
| Logs folder | `logs/copilot/` | Created empty — populated by session logger |

### Local Plugin (`local`)

| Component | Path |
|-----------|------|
| `@task-planner` | `.github/copilot/agents/task-planner.md` |
| `@local-rakbank-dev-agent` | `.github/copilot/agents/local-rakbank-dev-agent.md` |
| `@local-reviewer` | `.github/copilot/agents/local-reviewer.md` |
| `@local-instinct-learner` | `.github/copilot/agents/local-instinct-learner.md` |
| Task plans folder | `taskPlan/` |
| Instincts folder | `.copilot/instincts/` |

### Remote Plugin (`remote`)

| Component | Path |
|-----------|------|
| `@story-analyzer` | `.github/copilot/agents/story-analyzer.md` |
| `@coding-agent` | `.github/copilot/agents/coding-agent.md` |
| `@instinct-extractor` | `.github/copilot/agents/instinct-extractor.md` |
| GitHub Actions (4 workflows) | `.github/workflows/` |
| MCP configs | `mcp-configs/` |

---

## Keeping Up to Date

When the central template is updated (new agent versions, improved hooks), re-run bootstrap:

```bash
bash bootstrap.sh local    # or remote / all
```

Files that already exist are skipped (your customisations are safe).
To force-overwrite a specific file, delete it first and re-run.

---

## Adding a New Plugin

1. Create `plugins/lib/{name}.sh` with exactly three functions:

```bash
#!/bin/bash
# {name}.sh — Brief description

describe() {
  echo "  {name}    One-line description of what this plugin does"
  echo "            Detail line 1"
  echo "            Detail line 2"
}

install() {
  print_section "{Name} — description"

  copy_file "$TEMPLATE_ROOT/path/to/source.md" \
            "$TARGET_DIR/path/to/dest.md"
  # ... more copy_file / copy_executable / mkdir -p calls ...

  echo ""
}

summary() {
  echo "{NAME} — ready to use:"
  echo "  Usage example 1"
  echo "  Usage example 2"
}
```

2. `install.sh` discovers it automatically — **no other files need to change**.

3. Test locally:
   ```bash
   cd /your-project
   bash /path/to/template/plugins/install.sh {name}
   ```

---

## Team Onboarding Recommendation

Add this to your project `README.md` or `CONTRIBUTING.md`:

```markdown
## AI Workflow Setup

This project uses the RAKBANK Copilot AI-SDLC workflow.

1. Clone the team template (once per machine):
   ```
   git clone https://github.com/rakbank-internal/platform-backend-copilot-template.git ~/rakbank-copilot-template
   ```

2. From this project repo, run:
   ```
   bash ~/rakbank-copilot-template/plugins/bootstrap.sh local
   ```

3. Done — open VS Code and use `@task-planner` to start a story.
```

---

## Requirements

- **git** with RAKBANK org access (same credentials used for cloning any org repo)
- **VS Code** with GitHub Copilot extension
- **git bash** on Windows — or any bash on macOS/Linux
- No Python, no PowerShell, no npm, no extra tokens
