#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
#  local.sh — Local VS Code Workflow Plugin
#
#  Installs agents and folders for the full local development workflow:
#    @task-planner → @local-rakbank-dev-agent → @local-reviewer → @local-instinct-learner
#
#  Sourced by install.sh. Never run directly.
#
#  Defines three standard functions (required by every plugin):
#    describe()  — printed in help text
#    install()   — called to install the plugin
#    summary()   — printed after successful install
# ═══════════════════════════════════════════════════════════════════════════════

describe() {
  echo "  local     Local VS Code workflow"
  echo "            @task-planner         ADO story or description → taskPlan/ file"
  echo "            @local-coding-agent   Task plan → scaffolded code in VS Code"
  echo "            @local-reviewer       Pre-commit structured code review"
  echo "            @local-instinct-learner  Capture explicit learnings as instincts"
}

install() {
  print_section "Local VS Code workflow"

  # ── Agents ────────────────────────────────────────────────────────────────────
  copy_file "$TEMPLATE_ROOT/.github/copilot/agents/task-planner.md" \
            "$TARGET_DIR/.github/copilot/agents/task-planner.md"
  copy_file "$TEMPLATE_ROOT/.github/copilot/agents/local-coding-agent.md" \
            "$TARGET_DIR/.github/copilot/agents/local-coding-agent.md"
  copy_file "$TEMPLATE_ROOT/.github/copilot/agents/local-reviewer.md" \
            "$TARGET_DIR/.github/copilot/agents/local-reviewer.md"
  copy_file "$TEMPLATE_ROOT/.github/copilot/agents/local-instinct-learner.md" \
            "$TARGET_DIR/.github/copilot/agents/local-instinct-learner.md"

  # ── taskPlan folder (where @task-planner writes spec files) ──────────────────
  mkdir -p "$TARGET_DIR/taskPlan"
  copy_file "$TEMPLATE_ROOT/taskPlan/README.md" \
            "$TARGET_DIR/taskPlan/README.md"

  # ── Instincts folder (where @local-instinct-learner writes learnings) ─────────
  mkdir -p "$TARGET_DIR/.copilot/instincts"

  echo ""
}

summary() {
  echo "LOCAL WORKFLOW — agents ready in Copilot Chat:"
  echo "  @task-planner              @task-planner ADO-456"
  echo "  @local-coding-agent        @local-coding-agent taskPlan/ADO-456-service.md"
  echo "  @local-reviewer            @local-reviewer"
  echo "  @local-instinct-learner    @local-instinct-learner \"this is a learning\""
}
