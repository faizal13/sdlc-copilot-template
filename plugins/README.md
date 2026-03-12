# SDLC Copilot Template — Plugin Installer

Install the AI-SDLC agents, hooks, skills, and runtime directories into any project.

**Central Template:**
`https://github.com/rakbank-internal/platform-backend-copilot-template`

---

## Folder Structure

```
plugins/
  install.sh          ← Interactive installer (mode + target selection)
  bootstrap.sh        ← Clone template from GitHub + run install.sh
  workspace-init.sh   ← Quick workspace init (non-interactive, local mode)
  README.md           ← This file
  lib/
    utils.sh          ← Shared bash utilities (copy_file, print_section, …)
    core.sh           ← Core components installed for EVERY mode
    local-extras.sh   ← Local mode: taskPlan/, sprintPlan/
    hybrid-extras.sh  ← Hybrid mode: + GitHub Actions workflows + MCP configs
    workspace.sh      ← Workspace target: .code-workspace, manifest, stamp
```

---

## Two Modes

| Mode | What it installs |
|------|-----------------|
| **Local** | All 14 agents, skills, hooks, instructions, runtime dirs, taskPlan/, sprintPlan/ |
| **Hybrid** | Everything in Local + GitHub Actions workflows + MCP configurations |

## Two Targets

| Target | Behavior |
|--------|---------|
| **Single folder** | Install into current directory (simple single-service project) |
| **Workspace** | Multi-service workspace: generates `.code-workspace` + `workspace-manifest.json` |

---

## How to Install

### Option A — Interactive (recommended)

```bash
cd /path/to/your-project
bash /path/to/sdlc-copilot-template/plugins/install.sh
```

Follow the prompts to select mode and target.

### Option B — Non-interactive (CI / scripting)

```bash
# Local mode, single folder
bash install.sh --mode local --target single

# Hybrid mode, workspace with services
bash install.sh --mode hybrid --target workspace --services "svc1,svc2,svc3" --subdirs

# Hybrid mode, workspace with external repo paths
bash install.sh --mode hybrid --target workspace \
  --services "/path/to/svc1,/path/to/svc2" --external
```

### Option C — Bootstrap (clones template from GitHub first)

```bash
# Interactive
bash bootstrap.sh

# Or with shortcut
bash bootstrap.sh local     # local mode, single folder
bash bootstrap.sh hybrid    # hybrid mode, single folder
```

### Option D — Quick workspace init

```bash
cd /path/to/my-workspace
bash /path/to/sdlc-copilot-template/plugins/workspace-init.sh
```

---

## What Gets Installed

### Core (all modes)

| Component | Path | Count |
|-----------|------|-------|
| Agents | `.github/agents/*.agent.md` | 14 |
| Instructions | `.github/instructions/*.instructions.md` | 6 + examples |
| Skills | `.github/skills/{name}/SKILL.md` | 4 |
| Session logger | `.github/hooks/session-logger/` | hooks.json + 3 scripts |
| Git post-commit | `.github/hooks/git/post-commit` | 1 |
| Instincts | `.copilot/instincts/INDEX.json` | 1 (empty index) |
| Checkpoints | `.checkpoints/` | .gitkeep + README |
| Contexts | `contexts/` | README (you create content) |
| Solution design | `docs/solution-design/` | README (you create content) |
| Epic plans | `docs/epic-plans/` | README |
| Telemetry | `docs/agent-telemetry/` | current-sprint.md + README + TEMPLATE |
| AI usage | `docs/ai-usage/` | README |
| Issues | `docs/issues/` | README |
| Evals | `evals/` | scoring-rubric + sprint-tracker + golden refs |
| Logs | `logs/copilot/` | empty dir |

### Local extras (local + hybrid modes)

| Component | Path |
|-----------|------|
| Task plans | `taskPlan/README.md` |
| Sprint plans | `sprintPlan/README.md` |

### Hybrid extras (hybrid mode only)

| Component | Path |
|-----------|------|
| GitHub Actions | `.github/workflows/*.yml` |
| MCP configs | `mcp-configs/*.json` |

### Workspace target

| Component | Path |
|-----------|------|
| VS Code workspace | `{name}.code-workspace` |
| Workspace manifest | `.github/copilot/workspace-manifest.json` |
| Init stamp | `.github/copilot/.initialized` |

---

## Keeping Up to Date

Re-run install.sh — existing files are skipped (your customisations are preserved).
To force-update a specific file, delete it first and re-run.

---

## Requirements

- **bash** — macOS, Linux, or git bash on Windows
- **VS Code** with GitHub Copilot extension
- **No git required** — install works in any directory
- No Python, no PowerShell, no npm, no extra tokens
