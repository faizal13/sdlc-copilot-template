#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
#  shared.sh — Always-installed components
#
#  Sourced and called by install.sh for EVERY plugin run.
#  These components are the foundation — all workflows depend on them.
#  Never run directly.
#
#  Installs:
#    - @context-architect agent      (shared agent for any workflow)
#    - VS Code skills (3)            (context-map, what-context-needed, refactor-plan)
#    - Copilot session logger hooks  (session + prompt tracking)
#    - Git post-commit AI usage hook (auto-logs docs/ai-usage/ on ADO commits)
#    - Auto-instructions             (coding, security, testing, review)
#    - Folder scaffolding            (docs/ai-usage, logs/copilot)
# ═══════════════════════════════════════════════════════════════════════════════

install_shared() {
  print_section "Shared components (foundation for all plugins)"

  # ── Shared agent ─────────────────────────────────────────────────────────────
  copy_file "$TEMPLATE_ROOT/.github/copilot/agents/context-architect.md" \
            "$TARGET_DIR/.github/copilot/agents/context-architect.md"

  # ── VS Code skills (auto-triggered when chat.useAgentSkills=true) ─────────────
  copy_file "$TEMPLATE_ROOT/.github/skills/context-map/SKILL.md" \
            "$TARGET_DIR/.github/skills/context-map/SKILL.md"
  copy_file "$TEMPLATE_ROOT/.github/skills/what-context-needed/SKILL.md" \
            "$TARGET_DIR/.github/skills/what-context-needed/SKILL.md"
  copy_file "$TEMPLATE_ROOT/.github/skills/refactor-plan/SKILL.md" \
            "$TARGET_DIR/.github/skills/refactor-plan/SKILL.md"

  # ── Copilot VS Code session logger (prompt + session tracking) ────────────────
  copy_file "$TEMPLATE_ROOT/.github/hooks/session-logger/hooks.json" \
            "$TARGET_DIR/.github/hooks/session-logger/hooks.json"
  copy_executable "$TEMPLATE_ROOT/.github/hooks/session-logger/log-session-start.sh" \
                  "$TARGET_DIR/.github/hooks/session-logger/log-session-start.sh"
  copy_executable "$TEMPLATE_ROOT/.github/hooks/session-logger/log-session-end.sh" \
                  "$TARGET_DIR/.github/hooks/session-logger/log-session-end.sh"
  copy_executable "$TEMPLATE_ROOT/.github/hooks/session-logger/log-prompt.sh" \
                  "$TARGET_DIR/.github/hooks/session-logger/log-prompt.sh"

  # ── Git post-commit hook (AI usage auto-logger) ───────────────────────────────
  copy_executable "$TEMPLATE_ROOT/.github/hooks/git/post-commit" \
                  "$TARGET_DIR/.github/hooks/git/post-commit"

  # ── Auto-instructions (applied to every Copilot interaction) ─────────────────
  for instr in coding security testing review; do
    local src="$TEMPLATE_ROOT/.github/instructions/${instr}.instructions.md"
    if [ -f "$src" ]; then
      copy_file "$src" "$TARGET_DIR/.github/instructions/${instr}.instructions.md"
    fi
  done

  # ── Folder scaffolding ────────────────────────────────────────────────────────
  mkdir -p "$TARGET_DIR/docs/ai-usage"
  mkdir -p "$TARGET_DIR/logs/copilot"

  echo ""
}
