#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
#  SDLC Copilot Workflow Bootstrap
#
#  This is the ONE script developers copy and run from their project repo.
#  It clones the central template (using their existing git org credentials),
#  runs the full installer, then cleans up. Nothing is left behind.
#
#  Requirements:
#    - git with org access already configured (same as cloning any org repo)
#    - bash on macOS / Linux / git bash on Windows
#    - No Python, no PowerShell, no npm, no tokens to manage
#
#  Usage (run from the ROOT of your project repo):
#    bash bootstrap.sh                ← interactive mode (recommended)
#    bash bootstrap.sh local          ← local mode, single folder
#    bash bootstrap.sh hybrid         ← hybrid mode (local + GitHub Actions)
#
#  Where to get this file:
#    Copy from: https://github.com/rakbank-internal/platform-backend-copilot-template/blob/main/plugins/bootstrap.sh
#    Save it locally, then run. (Can also be stored in team wiki / Confluence.)
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ── Central template repository ───────────────────────────────────────────────
TEMPLATE_REPO="https://github.com/rakbank-internal/platform-backend-copilot-template.git"
TEMPLATE_BRANCH="main"

# ── Parse argument (optional shortcut) ────────────────────────────────────────
SHORTCUT="${1:-}"
INSTALL_ARGS=()

case "$SHORTCUT" in
  local)
    INSTALL_ARGS=(--mode local --target single)
    ;;
  hybrid|remote|all)
    INSTALL_ARGS=(--mode hybrid --target single)
    ;;
  --help|-h)
    echo ""
    echo "SDLC Copilot Workflow Bootstrap"
    echo "================================"
    echo ""
    echo "Usage: bash bootstrap.sh [SHORTCUT]"
    echo ""
    echo "Shortcuts (non-interactive):"
    echo "  local   - Local VS Code workflow (single folder)"
    echo "  hybrid  - Local + GitHub Actions workflow (single folder)"
    echo ""
    echo "Run with no arguments for interactive mode (recommended)."
    echo ""
    echo "Run from the ROOT of your project repo."
    echo ""
    exit 0
    ;;
  "")
    # No argument — install.sh will run interactively
    ;;
  *)
    echo "Unknown shortcut: $SHORTCUT (use --help for usage)"
    exit 1
    ;;
esac

TARGET_DIR="$(pwd)"

echo ""
echo "SDLC Copilot Workflow Bootstrap"
echo "================================"
echo "Target:    $TARGET_DIR"
echo "Source:    $TEMPLATE_REPO"
echo ""

# ── Create temp directory ─────────────────────────────────────────────────────
TEMP_DIR=$(mktemp -d 2>/dev/null || echo "/tmp/sdlc-copilot-$$")
mkdir -p "$TEMP_DIR"

# Ensure cleanup on exit (success or failure)
cleanup() {
  rm -rf "$TEMP_DIR" 2>/dev/null || true
}
trap cleanup EXIT

# ── Shallow clone the central template ────────────────────────────────────────
echo "Fetching template from GitHub..."
echo "(uses your existing git credentials — same as cloning any org repo)"
echo ""

if ! git clone --depth 1 --branch "$TEMPLATE_BRANCH" "$TEMPLATE_REPO" "$TEMP_DIR" --quiet 2>&1; then
  echo ""
  echo "ERROR: Could not clone from $TEMPLATE_REPO"
  echo ""
  echo "Check that:"
  echo "  1. You have git access to the org (try: git ls-remote $TEMPLATE_REPO)"
  echo "  2. You are connected to the network / VPN if required"
  echo "  3. The branch '$TEMPLATE_BRANCH' exists in the template repo"
  echo ""
  exit 1
fi

echo "Template fetched."
echo ""

# ── Run the installer from the temp clone ─────────────────────────────────────
cd "$TARGET_DIR"
bash "$TEMP_DIR/plugins/install.sh" "${INSTALL_ARGS[@]}"

# ── Cleanup happens via trap EXIT ─────────────────────────────────────────────
echo ""
echo "Temp files cleaned up."
