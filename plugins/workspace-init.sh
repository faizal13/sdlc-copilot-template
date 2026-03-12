#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
#  workspace-init.sh — Quick workspace initializer (non-interactive)
#
#  Run this from the ROOT of your workspace config repo to install everything
#  in local mode with workspace target. No prompts — just run and done.
#
#  Unlike install.sh (interactive), this is a one-shot convenience script
#  designed for workspace config repos that may not have git yet.
#
#  Usage:
#    cd /path/to/my-workspace
#    bash /path/to/sdlc-copilot-template/plugins/workspace-init.sh
#
#  For more control (mode selection, service paths, etc.), use install.sh:
#    bash /path/to/sdlc-copilot-template/plugins/install.sh
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET_DIR="$(pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

# Load libraries
source "$LIB_DIR/utils.sh"
source "$LIB_DIR/core.sh"
source "$LIB_DIR/local-extras.sh"
source "$LIB_DIR/workspace.sh"

# Workspace defaults (non-interactive)
export WORKSPACE_NAME="$(basename "$TARGET_DIR")"
export SERVICE_REPOS=""
export REPOS_ARE_SUBDIRS="true"

echo ""
echo "SDLC Copilot — Workspace Initialisation"
echo "========================================"
echo "  Template:  $TEMPLATE_ROOT"
echo "  Target:    $TARGET_DIR"
echo "  Workspace: $WORKSPACE_NAME"
echo ""

# Install: core + local extras + workspace
install_core
install_local_extras
install_workspace

echo "========================================"
echo ""
echo "Workspace initialised: $WORKSPACE_NAME"
echo ""
echo "  Next steps:"
echo "  1. Create contexts/{your-domain}.md"
echo "  2. Create docs/solution-design/ files"
echo "  3. Open ${WORKSPACE_NAME}.code-workspace in VS Code"
echo "  4. Copilot Chat → @story-refiner EPIC-001"
echo ""
