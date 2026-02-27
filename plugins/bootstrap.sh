#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
#  RAKBANK Copilot Workflow Bootstrap
#
#  This is the ONE script developers copy and run from their project repo.
#  It clones the central template (using their existing git org credentials),
#  runs the full installer, then cleans up. Nothing is left behind.
#
#  Requirements:
#    - git with RAKBANK org access already configured (same as cloning any org repo)
#    - git bash on Windows / bash on macOS / bash on Linux
#    - No Python, no PowerShell, no npm, no tokens to manage
#
#  Usage (run from the ROOT of your project repo):
#    bash bootstrap.sh local     ← local VS Code workflow
#    bash bootstrap.sh remote    ← remote GitHub Actions workflow
#    bash bootstrap.sh all       ← both workflows
#
#  Where to get this file:
#    Copy from: https://github.com/rakbank-internal/platform-backend-copilot-template/blob/main/plugins/bootstrap.sh
#    Save it locally, then run. (Can also be stored in team wiki / Confluence.)
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ── Central template repository ───────────────────────────────────────────────
TEMPLATE_REPO="https://github.com/rakbank-internal/platform-backend-copilot-template.git"
TEMPLATE_BRANCH="main"

# ── Validate argument ─────────────────────────────────────────────────────────
WORKFLOW="${1:-}"

if [ -z "$WORKFLOW" ] || { [ "$WORKFLOW" != "local" ] && [ "$WORKFLOW" != "remote" ] && [ "$WORKFLOW" != "all" ]; }; then
  echo ""
  echo "RAKBANK Copilot Workflow Bootstrap"
  echo "==================================="
  echo ""
  echo "Usage: bash bootstrap.sh <workflow>"
  echo ""
  echo "  local   - Local VS Code workflow"
  echo "            @task-planner, @local-rakbank-dev-agent,"
  echo "            @local-reviewer, @local-instinct-learner"
  echo ""
  echo "  remote  - Remote GitHub Actions workflow"
  echo "            @story-analyzer, @coding-agent, @instinct-extractor"
  echo "            + GitHub Actions: coding-agent, ai-review, learning, ado-sync"
  echo ""
  echo "  all     - Both workflows"
  echo ""
  echo "Run from the ROOT of your project repo."
  echo ""
  exit 1
fi

# ── Validate: must be in a git repo ──────────────────────────────────────────
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo ""
  echo "ERROR: Not inside a git repository."
  echo "cd into your project repo first, then run bootstrap.sh."
  echo ""
  exit 1
fi

TARGET_DIR="$(pwd)"

echo ""
echo "RAKBANK Copilot Workflow Bootstrap"
echo "==================================="
echo "Workflow:  $WORKFLOW"
echo "Target:    $TARGET_DIR"
echo "Source:    $TEMPLATE_REPO"
echo ""

# ── Create temp directory ─────────────────────────────────────────────────────
# mktemp -d works on git bash (Windows) and Unix
TEMP_DIR=$(mktemp -d 2>/dev/null || echo "/tmp/rakbank-copilot-$$")
mkdir -p "$TEMP_DIR"

# Ensure cleanup on exit (success or failure)
cleanup() {
  rm -rf "$TEMP_DIR" 2>/dev/null || true
}
trap cleanup EXIT

# ── Shallow clone the central template ───────────────────────────────────────
echo "Fetching template from GitHub..."
echo "(uses your existing git credentials — same as cloning any org repo)"
echo ""

if ! git clone --depth 1 --branch "$TEMPLATE_BRANCH" "$TEMPLATE_REPO" "$TEMP_DIR" --quiet 2>&1; then
  echo ""
  echo "ERROR: Could not clone from $TEMPLATE_REPO"
  echo ""
  echo "Check that:"
  echo "  1. You have git access to github.com/rakbank-internal (try: git ls-remote $TEMPLATE_REPO)"
  echo "  2. You are connected to the network / VPN if required"
  echo "  3. The branch '$TEMPLATE_BRANCH' exists in the template repo"
  echo ""
  exit 1
fi

echo "Template fetched."
echo ""

# ── Run the installer from the temp clone ────────────────────────────────────
# install.sh uses SCRIPT_DIR to locate TEMPLATE_ROOT automatically.
# TARGET_DIR stays as the developer's project repo (we cd'd back above).
cd "$TARGET_DIR"
bash "$TEMP_DIR/plugins/install.sh" "$WORKFLOW"

# ── Cleanup happens via trap EXIT ─────────────────────────────────────────────
echo ""
echo "Temp files cleaned up."
