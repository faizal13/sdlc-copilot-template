#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
#  remote.sh — Remote GitHub Actions Workflow Plugin
#
#  Installs agents and GitHub Actions workflows for the fully automated
#  remote pipeline:
#    @story-analyzer → Coding Agent (Actions) → AI Review (Actions)
#                    → Learning Agent (Actions) → ADO Sync (Actions)
#
#  Sourced by install.sh. Never run directly.
#
#  Defines three standard functions (required by every plugin):
#    describe()  — printed in help text
#    install()   — called to install the plugin
#    summary()   — printed after successful install
# ═══════════════════════════════════════════════════════════════════════════════

describe() {
  echo "  remote    Remote GitHub Actions workflow"
  echo "            @story-analyzer         ADO story → GitHub Issue + label"
  echo "            Coding Agent            Auto-triggered on 'ai-generated' label"
  echo "            AI Review               Auto-triggered on PR open"
  echo "            Learning Agent          Auto-triggered on PR merge"
  echo "            ADO Sync                Auto-triggered on PR merge"
}

install() {
  print_section "Remote GitHub Actions workflow"

  # ── Agents ────────────────────────────────────────────────────────────────────
  copy_file "$TEMPLATE_ROOT/.github/copilot/agents/story-analyzer.md" \
            "$TARGET_DIR/.github/copilot/agents/story-analyzer.md"
  copy_file "$TEMPLATE_ROOT/.github/copilot/agents/coding-agent.md" \
            "$TARGET_DIR/.github/copilot/agents/coding-agent.md"
  copy_file "$TEMPLATE_ROOT/.github/copilot/agents/instinct-extractor.md" \
            "$TARGET_DIR/.github/copilot/agents/instinct-extractor.md"

  # ── GitHub Actions workflows ──────────────────────────────────────────────────
  for wf in agent2-coding-agent agent5-learning agent6-ado-sync ai-code-review; do
    local src="$TEMPLATE_ROOT/.github/workflows/${wf}.yml"
    if [ -f "$src" ]; then
      copy_file "$src" "$TARGET_DIR/.github/workflows/${wf}.yml"
    else
      echo "  [miss] .github/workflows/${wf}.yml (source not found — skipping)"
    fi
  done

  # ── MCP configs (GitHub Copilot Workspace model configuration) ────────────────
  local found_mcp=0
  for cfg in "$TEMPLATE_ROOT"/mcp-configs/*.json; do
    if [ -f "$cfg" ]; then
      local fname
      fname=$(basename "$cfg")
      copy_file "$cfg" "$TARGET_DIR/mcp-configs/$fname"
      found_mcp=1
    fi
  done
  if [ "$found_mcp" -eq 0 ]; then
    echo "  [miss] mcp-configs/ (no .json files found in template — skipping)"
  fi

  echo ""
}

summary() {
  echo "REMOTE WORKFLOW — pipeline triggered automatically by GitHub:"
  echo "  @story-analyzer            @story-analyzer ADO-456"
  echo "  Coding Agent               Triggered when 'ai-generated' label added to Issue"
  echo "  AI Review                  Triggered when PR is opened"
  echo "  Learning Agent             Triggered when PR is merged"
  echo "  ADO Sync                   Triggered when PR is merged"
  echo ""
  echo "  Next steps for REMOTE workflow:"
  echo "    1. Add repo secrets: ADO_TOKEN, ADO_ORG, ADO_PROJECT"
  echo "    2. Enable GitHub Actions in your repo settings"
  echo "    3. Set GitHub Copilot Workspace permissions (write: pull-requests, issues)"
}
