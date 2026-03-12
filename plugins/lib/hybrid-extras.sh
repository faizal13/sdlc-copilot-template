#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
#  hybrid-extras.sh — Hybrid mode additions (on top of core.sh + local-extras)
#
#  Sourced by install.sh when mode = hybrid.
#  Never run directly.
#
#  Installs:
#    - GitHub Actions workflows     → .github/workflows/*.yml
#    - MCP configuration files      → mcp-configs/*.json
#
#  Hybrid mode = Local + Remote. The local-extras.sh is always run first,
#  then this file adds the remote pipeline components.
#
#  Provides:
#    install_hybrid_extras()  — called by install.sh
# ═══════════════════════════════════════════════════════════════════════════════

install_hybrid_extras() {
  print_section "Hybrid additions — GitHub Actions + MCP configs"

  # ── GitHub Actions workflows ────────────────────────────────────────────────
  local found_wf=0
  mkdir -p "$TARGET_DIR/.github/workflows"
  for wf_file in "$TEMPLATE_ROOT/.github/workflows/"*.yml; do
    if [ -f "$wf_file" ]; then
      local fname
      fname=$(basename "$wf_file")
      copy_file "$wf_file" "$TARGET_DIR/.github/workflows/$fname"
      found_wf=1
    fi
  done
  if [ "$found_wf" -eq 0 ]; then
    echo "  [info] No workflow YAML files found in template — skipping"
  fi

  # ── MCP configuration files ─────────────────────────────────────────────────
  local found_mcp=0
  for cfg in "$TEMPLATE_ROOT"/mcp-configs/*.json; do
    if [ -f "$cfg" ]; then
      local fname
      fname=$(basename "$cfg")
      mkdir -p "$TARGET_DIR/mcp-configs"
      copy_file "$cfg" "$TARGET_DIR/mcp-configs/$fname"
      found_mcp=1
    fi
  done
  if [ "$found_mcp" -eq 0 ]; then
    echo "  [info] No MCP config JSON files found in template — skipping"
  fi

  echo ""
}
