#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
#  RAKBANK Copilot Workflow Installer  (thin orchestrator)
#
#  Installs the AI-SDLC workflow agents, hooks, and skills into any project repo.
#  Works on git bash (Windows), macOS, Linux — no Python or PowerShell required.
#
#  DO NOT run this script directly. Use bootstrap.sh instead:
#    bash bootstrap.sh local     ← fetches template from GitHub and installs
#    bash bootstrap.sh remote
#    bash bootstrap.sh all
#
#  Or, if you have a local clone of the template:
#    cd /path/to/your-project
#    bash /path/to/template/plugins/install.sh local
#
#  Adding a new plugin:
#    1. Create plugins/lib/{name}.sh with describe(), install(), summary()
#    2. Done — it is auto-discovered. No changes to this file needed.
#
#  Central template:
#    https://github.com/rakbank-internal/platform-backend-copilot-template
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ── Locate paths ──────────────────────────────────────────────────────────────
# SCRIPT_DIR = plugins/
# TEMPLATE_ROOT = repo root (one level up from plugins/)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET_DIR="$(pwd)"

LIB_DIR="$SCRIPT_DIR/lib"

# ── Load shared utilities (must come first) ───────────────────────────────────
# shellcheck source=lib/utils.sh
source "$LIB_DIR/utils.sh"

# ── Discover available plugins ────────────────────────────────────────────────
# Any *.sh in lib/ that is NOT utils.sh or shared.sh is a plugin.
# Each plugin file must define: describe(), install(), summary()
get_plugins() {
  local plugins=()
  for f in "$LIB_DIR"/*.sh; do
    local name
    name=$(basename "$f" .sh)
    if [ "$name" != "utils" ] && [ "$name" != "shared" ]; then
      plugins+=("$name")
    fi
  done
  echo "${plugins[@]:-}"
}

# ── Build help text dynamically from each plugin's describe() ────────────────
print_usage() {
  echo ""
  echo "RAKBANK Copilot Workflow Installer"
  echo "==================================="
  echo ""
  echo "Usage: bash install.sh <plugin> [<plugin2> ...]"
  echo "   or: bash install.sh all"
  echo ""
  echo "Available plugins:"
  echo ""

  for f in "$LIB_DIR"/*.sh; do
    local name
    name=$(basename "$f" .sh)
    if [ "$name" != "utils" ] && [ "$name" != "shared" ]; then
      # Source in a subshell to get describe() without polluting current shell
      (source "$LIB_DIR/utils.sh"; source "$f"; describe)
    fi
  done

  echo ""
  echo "  all       Install all available plugins"
  echo ""
  echo "Run from the ROOT of your project repo."
  echo ""
}

# ── Validate arguments ────────────────────────────────────────────────────────
if [ $# -eq 0 ]; then
  print_usage
  exit 1
fi

# Collect requested plugins, expanding "all"
REQUESTED=()
for arg in "$@"; do
  if [ "$arg" = "all" ]; then
    while IFS= read -r -d ' ' p; do
      [ -n "$p" ] && REQUESTED+=("$p")
    done < <(get_plugins; echo " ")
  else
    REQUESTED+=("$arg")
  fi
done

# Validate each requested plugin has a lib file
for plugin in "${REQUESTED[@]}"; do
  if [ ! -f "$LIB_DIR/${plugin}.sh" ]; then
    echo ""
    echo "ERROR: Unknown plugin '${plugin}'"
    echo "       No lib/${plugin}.sh found in $LIB_DIR"
    print_usage
    exit 1
  fi
done

# ── Validate: must be in a git repo ──────────────────────────────────────────
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo ""
  echo "ERROR: Not inside a git repository."
  echo "cd into your project repo first, then run bootstrap.sh:"
  echo "  bash bootstrap.sh local"
  echo ""
  exit 1
fi

# ── Print header ─────────────────────────────────────────────────────────────
echo ""
echo "RAKBANK Copilot Workflow Installer"
echo "==================================="
echo "Plugin(s):   ${REQUESTED[*]}"
echo "Source:      $TEMPLATE_ROOT"
echo "Target:      $TARGET_DIR"
echo ""

# ── Install shared foundation (always, for every plugin run) ─────────────────
source "$LIB_DIR/shared.sh"
install_shared

# ── Install each requested plugin ────────────────────────────────────────────
for plugin in "${REQUESTED[@]}"; do
  # Source plugin lib (defines describe, install, summary)
  source "$LIB_DIR/${plugin}.sh"
  install
done

# ── Configure git hooks path ─────────────────────────────────────────────────
CURRENT_HOOKS_PATH=$(git config core.hooksPath 2>/dev/null || true)
if [ "$CURRENT_HOOKS_PATH" != ".github/hooks/git" ]; then
  git config core.hooksPath .github/hooks/git
  echo "Git hooks configured: core.hooksPath = .github/hooks/git"
else
  echo "Git hooks already configured: core.hooksPath = .github/hooks/git"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "==================================="
echo "Installation complete!"
echo "==================================="
echo ""

echo "SHARED (installed for all plugins):"
echo "  @context-architect           Map context for any task"
echo "  Post-commit AI usage hook    Auto-logs to docs/ai-usage/{release}/{TICKET}.md"
echo "  Session logger               Tracks Copilot prompts in logs/copilot/"
echo "  Skills (3)                   context-map, what-context-needed, refactor-plan"
echo ""

for plugin in "${REQUESTED[@]}"; do
  # Re-source to get summary() (already sourced above but re-source is safe)
  source "$LIB_DIR/${plugin}.sh"
  summary
  echo ""
done

echo "Next steps:"
echo "  1. Fill in .github/copilot-instructions.md with your project rules"
echo "  2. Fill in docs/solution-design/ with your architecture"
echo "  3. Fill in contexts/ with your domain knowledge"
echo "  4. Open Copilot Chat in VS Code and use @task-planner or @story-analyzer"
echo ""
