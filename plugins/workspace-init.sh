#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
#  workspace-init.sh — Standalone workspace config repo initialiser
#
#  Run this from the ROOT of your workspace config repo
#  (e.g. mortgage-ipa-workspace/) to create runtime directories and data files.
#
#  Unlike install.sh, this does NOT require a git repository — workspace
#  config repos may be set up before git is initialised.
#
#  Usage (run from your workspace config repo root):
#    bash /path/to/template/plugins/workspace-init.sh
#
#  Or via bootstrap (once your workspace repo has git):
#    bash install.sh workspace
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET_DIR="$(pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

# Load utilities and workspace plugin
source "$LIB_DIR/utils.sh"
source "$LIB_DIR/workspace.sh"

echo ""
echo "RAKBank SDLC — Workspace Initialisation"
echo "========================================"
echo "Template:  $TEMPLATE_ROOT"
echo "Target:    $TARGET_DIR"
echo ""

install

echo "========================================"
echo ""
summary
