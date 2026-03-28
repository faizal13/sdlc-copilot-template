#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
#  SDLC Copilot Template Installer  (interactive)
#
#  Clone the template repo, then run this script from your project directory:
#
#    cd /path/to/your-project
#    bash /path/to/sdlc-copilot-template/plugins/install.sh
#
#  Or run non-interactively with flags:
#
#    bash install.sh --mode local --target single
#    bash install.sh --mode hybrid --target workspace --services "svc1,svc2"
#
#  What it does:
#    1. Asks you to pick a mode (local / hybrid)
#    2. Asks you to pick a target (single folder / workspace)
#    3. Installs core components (agents, skills, hooks, instructions, dirs)
#    4. Installs mode-specific extras (local: taskPlan/, hybrid: + workflows)
#    5. If workspace: generates .code-workspace + workspace-manifest.json
#
#  No git required — works in any directory.
#
#  Central template:
#    https://github.com/rakbank-internal/platform-backend-copilot-template
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ── Locate paths ──────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET_DIR="$(pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

# ── Load libraries ────────────────────────────────────────────────────────────
# shellcheck source=lib/utils.sh
source "$LIB_DIR/utils.sh"
# shellcheck source=lib/core.sh
source "$LIB_DIR/core.sh"
# shellcheck source=lib/local-extras.sh
source "$LIB_DIR/local-extras.sh"
# shellcheck source=lib/hybrid-extras.sh
source "$LIB_DIR/hybrid-extras.sh"
# shellcheck source=lib/workspace.sh
source "$LIB_DIR/workspace.sh"

# ── CLI flags (for non-interactive use) ───────────────────────────────────────
CLI_MODE=""
CLI_TARGET=""
CLI_SERVICES=""
CLI_REPOS_SUBDIRS=""
CLI_NO_SERVICES="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      CLI_MODE="$2"; shift 2 ;;
    --target)
      CLI_TARGET="$2"; shift 2 ;;
    --services)
      CLI_SERVICES="$2"; shift 2 ;;
    --no-services)
      CLI_NO_SERVICES="true"; shift ;;
    --subdirs)
      CLI_REPOS_SUBDIRS="true"; shift ;;
    --external)
      CLI_REPOS_SUBDIRS="false"; shift ;;
    --help|-h)
      echo ""
      echo "SDLC Copilot Template Installer"
      echo ""
      echo "Usage: bash install.sh [OPTIONS]"
      echo ""
      echo "  Run with no options for interactive mode."
      echo ""
      echo "Options:"
      echo "  --mode local|hybrid        Installation mode"
      echo "  --target single|workspace  Installation target"
      echo "  --services \"svc1,svc2\"     Comma-separated service repo paths (workspace only)"
      echo "  --subdirs                  Service repos are subdirectories (default)"
      echo "  --external                 Service repos are at external paths"
      echo "  -h, --help                 Show this help"
      echo ""
      exit 0
      ;;
    *)
      echo "Unknown option: $1 (use --help for usage)"
      exit 1
      ;;
  esac
done

# ── Header ────────────────────────────────────────────────────────────────────
echo ""
echo "╔═══════════════════════════════════════════════════╗"
echo "║     SDLC Copilot Template Installer              ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""
echo "  Template:  $TEMPLATE_ROOT"
echo "  Target:    $TARGET_DIR"
echo ""

# ══════════════════════════════════════════════════════════════════════════════
#  STEP 1 — Select Mode
# ══════════════════════════════════════════════════════════════════════════════
MODE=""
if [ -n "$CLI_MODE" ]; then
  MODE="$CLI_MODE"
else
  echo "┌─ Select mode ───────────────────────────────────┐"
  echo "│  1) Local   — All agents run locally in VS Code  │"
  echo "│  2) Hybrid  — Local + GitHub Actions pipeline    │"
  echo "└──────────────────────────────────────────────────┘"
  echo ""
  while true; do
    read -rp "  Mode [1/2]: " mode_choice
    mode_choice="${mode_choice//$'\r'/}"   # strip \r (Windows Git Bash CRLF)
    case "$mode_choice" in
      1|local)  MODE="local";  break ;;
      2|hybrid) MODE="hybrid"; break ;;
      *) echo "  Please enter 1 or 2" ;;
    esac
  done
  echo ""
fi

# ══════════════════════════════════════════════════════════════════════════════
#  STEP 2 — Select Target
# ══════════════════════════════════════════════════════════════════════════════
TARGET=""
if [ -n "$CLI_TARGET" ]; then
  TARGET="$CLI_TARGET"
else
  echo "┌─ Select target ─────────────────────────────────────────┐"
  echo "│  1) Single folder  — Install into current directory      │"
  echo "│  2) Workspace      — Multi-service workspace setup       │"
  echo "└─────────────────────────────────────────────────────────┘"
  echo ""
  while true; do
    read -rp "  Target [1/2]: " target_choice
    target_choice="${target_choice//$'\r'/}"   # strip \r (Windows Git Bash CRLF)
    case "$target_choice" in
      1|single)    TARGET="single";    break ;;
      2|workspace) TARGET="workspace"; break ;;
      *) echo "  Please enter 1 or 2" ;;
    esac
  done
  echo ""
fi

# ══════════════════════════════════════════════════════════════════════════════
#  STEP 3 — Workspace configuration (if workspace target)
# ══════════════════════════════════════════════════════════════════════════════
WORKSPACE_NAME="$(basename "$TARGET_DIR")"
SERVICE_REPOS=""
REPOS_ARE_SUBDIRS="true"

if [ "$TARGET" = "workspace" ]; then
  if [ "$CLI_NO_SERVICES" = "true" ] || [ -n "$CLI_SERVICES" ]; then
    SERVICE_REPOS="${CLI_SERVICES:-}"
    REPOS_ARE_SUBDIRS="${CLI_REPOS_SUBDIRS:-true}"
  else
    echo "┌─ Workspace configuration ─────────────────────────────┐"
    echo "│  Workspace name: $WORKSPACE_NAME"
    echo "└────────────────────────────────────────────────────────┘"
    echo ""
    echo "  How are your microservice repos organized?"
    echo "    1) All repos are subdirectories of this folder"
    echo "    2) Repos are in separate locations (I'll provide paths)"
    echo ""
    while true; do
      read -rp "  Repo layout [1/2]: " repo_choice
      repo_choice="${repo_choice//$'\r'/}"   # strip \r (Windows Git Bash CRLF)
      case "$repo_choice" in
        1) REPOS_ARE_SUBDIRS="true";  break ;;
        2) REPOS_ARE_SUBDIRS="false"; break ;;
        *) echo "  Please enter 1 or 2" ;;
      esac
    done
    echo ""

    if [ "$REPOS_ARE_SUBDIRS" = "true" ]; then
      echo "  Enter service directory names (comma-separated, relative to workspace):"
      echo "  Example: orchestrator-service,notification-service,bff-service"
    else
      echo "  Enter service repo paths (comma-separated, absolute paths):"
      echo "  Example: /path/to/orchestrator,/path/to/notification,/path/to/bff"
    fi
    echo ""
    read -rp "  Services: " SERVICE_REPOS
    SERVICE_REPOS="${SERVICE_REPOS//$'\r'/}"   # strip \r (Windows Git Bash CRLF)
    echo ""
  fi
fi

# Export for workspace.sh
export WORKSPACE_NAME SERVICE_REPOS REPOS_ARE_SUBDIRS

# ══════════════════════════════════════════════════════════════════════════════
#  CONFIRMATION
# ══════════════════════════════════════════════════════════════════════════════
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Mode:      $MODE"
echo "  Target:    $TARGET"
if [ "$TARGET" = "workspace" ]; then
  echo "  Workspace: $WORKSPACE_NAME"
  if [ -n "$SERVICE_REPOS" ]; then
    echo "  Services:  $SERVICE_REPOS"
  fi
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ══════════════════════════════════════════════════════════════════════════════
#  INSTALL
# ══════════════════════════════════════════════════════════════════════════════

# Step A — Core (always)
install_core

# Step B — Local extras (local and hybrid both get these)
install_local_extras

# Step C — Hybrid extras (only hybrid)
if [ "$MODE" = "hybrid" ]; then
  install_hybrid_extras
fi

# Step D — Workspace setup (only workspace target)
if [ "$TARGET" = "workspace" ]; then
  install_workspace
fi

# ══════════════════════════════════════════════════════════════════════════════
#  SUMMARY
# ══════════════════════════════════════════════════════════════════════════════
echo ""
echo "╔═══════════════════════════════════════════════════╗"
echo "║     Installation complete!                        ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""
echo "  AGENTS (17):"
echo "    .github/agents/              All 17 agents ready for Copilot Chat"
echo ""
echo "  SKILLS (4):"
echo "    .github/skills/              context-map, what-context-needed,"
echo "                                 refactor-plan, instinct-lookup"
echo ""
echo "  AUTO-INSTRUCTIONS (8):"
echo "    .github/instructions/        coding, security, testing, review,"
echo "                                 cross-service, mcp-tools, middleware,"
echo "                                 agent-essentials + examples"
echo ""
echo "  HOOKS:"
echo "    .github/hooks/               session-logger + git post-commit"
echo "                                 + Teams notifications (notify-teams.js)"
echo ""
echo "  RUNTIME DIRS:"
echo "    .copilot/instincts/          Learned patterns from merged PRs"
echo "    .checkpoints/                Agent phase recovery (gitignored)"
echo "    contexts/                    Domain context files (you create these)"
echo "    docs/solution-design/        Architecture docs (you create these)"
echo "    docs/epic-plans/             @story-refiner execution plans"
echo "    docs/agent-feedback/         Per-story feedback → agent improvement"
echo "    docs/agent-telemetry/        Live telemetry log"
echo "    docs/ai-usage/               AI usage audit trail"
echo "    docs/issues/                 @story-analyzer local issue drafts"
echo "    evals/                       @eval-runner quality scores"
echo "    logs/copilot/                Session logger output"
echo "    taskPlan/                    @task-planner task plans"
echo "    sprintPlan/                  @sprint-orchestrator sprint status"

if [ "$MODE" = "hybrid" ]; then
  echo ""
  echo "  HYBRID ADDITIONS:"
  echo "    .github/workflows/           GitHub Actions pipeline"
  echo "    mcp-configs/                 MCP server configurations"
fi

if [ "$TARGET" = "workspace" ]; then
  echo ""
  echo "  WORKSPACE:"
  echo "    ${WORKSPACE_NAME}.code-workspace   VS Code multi-root workspace"
  echo "    .github/copilot/workspace-manifest.json"
  echo "    GETTING-STARTED.md               Developer onboarding guide"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Next steps:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  1. Create contexts/{your-domain}.md with domain knowledge"
echo "  2. Create docs/solution-design/ files (architecture, personas, etc.)"
if [ "$TARGET" = "workspace" ]; then
  echo "  3. Open ${WORKSPACE_NAME}.code-workspace in VS Code"
else
  echo "  3. Open this folder in VS Code"
fi
echo "  4. Copilot Chat → Agent Mode → @story-refiner EPIC-001"
echo "  5. @sprint-orchestrator EPIC-001 → see phase status + commands"
echo ""

if [ "$MODE" = "hybrid" ]; then
  echo "  For HYBRID workflow:"
  echo "    1. Add repo secrets: ADO_TOKEN, ADO_ORG, ADO_PROJECT"
  echo "    2. Enable GitHub Actions in your repo settings"
  echo "    3. Set Copilot Workspace permissions (write: pull-requests, issues)"
  echo ""
fi
