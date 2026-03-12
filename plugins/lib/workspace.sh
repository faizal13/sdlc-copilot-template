#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
#  workspace.sh — Multi-Service Workspace Initialisation Plugin
#
#  Run this ONCE from the root of your workspace config repo
#  (e.g. mortgage-ipa-workspace/) to initialise the shared runtime directories
#  and configuration that all agents across all services depend on.
#
#  This is a DIFFERENT concern from local.sh / remote.sh:
#    local.sh / remote.sh  →  run inside each individual service repo
#    workspace.sh          →  run inside the shared workspace config repo
#
#  What it creates:
#    .copilot/instincts/INDEX.json          ← instinct registry (agents read/write here)
#    .checkpoints/                          ← agent recovery checkpoints (gitignored)
#    docs/agent-telemetry/current-sprint.md ← live telemetry log (agents append here)
#    docs/ai-usage/README.md               ← audit log format reference
#    docs/epic-plans/                       ← @story-refiner writes execution plans here
#    docs/issues/                           ← @story-analyzer writes GitHub Issues here (local mode)
#    evals/sprint-tracker.md               ← @eval-runner writes quality scores here
#    taskPlan/                              ← @task-planner writes task plans here
#    sprintPlan/                            ← @sprint-orchestrator writes sprint status files here
#    .github/copilot/.initialized           ← stamp so re-init is skipped
#
#  Sourced by install.sh. Never run directly.
#
#  Defines three standard functions (required by every plugin):
#    describe()  — printed in help text
#    install()   — called to install the plugin
#    summary()   — printed after successful install
# ═══════════════════════════════════════════════════════════════════════════════

describe() {
  echo "  workspace   Multi-service workspace initialisation"
  echo "              Creates runtime directories and data files in the shared"
  echo "              workspace config repo (e.g. mortgage-ipa-workspace/)."
  echo "              Run once after setting up workspace-manifest.json."
}

install() {
  print_section "Workspace runtime initialisation"

  # ── Validate: workspace-manifest.json must exist ─────────────────────────────
  if [ ! -f "$TARGET_DIR/.github/copilot/workspace-manifest.json" ]; then
    echo "  [WARN] .github/copilot/workspace-manifest.json not found"
    echo "         Create this file first (see docs/solution-design/ for guidance)"
    echo "         Skipping workspace plugin"
    return
  fi

  # ── Read workspace name for display ──────────────────────────────────────────
  local ws_name
  ws_name=$(grep -o '"workspace"[[:space:]]*:[[:space:]]*"[^"]*"' \
    "$TARGET_DIR/.github/copilot/workspace-manifest.json" \
    | sed 's/.*: *"//' | sed 's/"$//' || echo "unknown")

  echo "  Workspace: $ws_name"
  echo ""

  # ── Runtime directories ───────────────────────────────────────────────────────
  # NOTE: Paths here MUST match the paths referenced in .github/copilot/agents/*.md
  # If you rename a dir here you MUST update every agent that references it.

  mkdir -p "$TARGET_DIR/.copilot/instincts"
  echo "  [dir]  .copilot/instincts/"

  mkdir -p "$TARGET_DIR/.checkpoints"
  echo "  [dir]  .checkpoints/"

  mkdir -p "$TARGET_DIR/docs/agent-telemetry"
  echo "  [dir]  docs/agent-telemetry/"

  mkdir -p "$TARGET_DIR/docs/ai-usage"
  echo "  [dir]  docs/ai-usage/"

  mkdir -p "$TARGET_DIR/docs/epic-plans"
  echo "  [dir]  docs/epic-plans/"

  mkdir -p "$TARGET_DIR/docs/issues"
  echo "  [dir]  docs/issues/"

  mkdir -p "$TARGET_DIR/evals/golden-references"
  echo "  [dir]  evals/golden-references/"

  mkdir -p "$TARGET_DIR/taskPlan"
  echo "  [dir]  taskPlan/"

  mkdir -p "$TARGET_DIR/sprintPlan"
  echo "  [dir]  sprintPlan/"

  echo ""

  # ── Runtime data files (only create if absent) ────────────────────────────────

  # Instincts INDEX — agents read this first to discover relevant instincts
  local index_path="$TARGET_DIR/.copilot/instincts/INDEX.json"
  if [ ! -f "$index_path" ]; then
    cat > "$index_path" << 'INDEXEOF'
{
  "_description": "Auto-maintained index of all instinct files learned from merged PRs and developer sessions.",
  "_format_version": "1.0",
  "_last_updated": null,
  "_managed_by": "local-instinct-learner, instinct-extractor",
  "instincts": []
}
INDEXEOF
    echo "  [add]  .copilot/instincts/INDEX.json"
  else
    echo "  [skip] .copilot/instincts/INDEX.json"
  fi

  # Checkpoints .gitkeep (folder tracked in git, checkpoint JSON files are gitignored)
  local gitkeep_path="$TARGET_DIR/.checkpoints/.gitkeep"
  if [ ! -f "$gitkeep_path" ]; then
    touch "$gitkeep_path"
    echo "  [add]  .checkpoints/.gitkeep"
  else
    echo "  [skip] .checkpoints/.gitkeep"
  fi

  # Checkpoints README (explains the checkpoint system)
  copy_file "$TEMPLATE_ROOT/.checkpoints/README.md" \
            "$TARGET_DIR/.checkpoints/README.md"

  # .gitignore — ensure checkpoint JSON files are ignored but README/.gitkeep committed
  local gitignore_path="$TARGET_DIR/.gitignore"
  if [ ! -f "$gitignore_path" ] || ! grep -q "\.checkpoints/\*\.json" "$gitignore_path" 2>/dev/null; then
    cat >> "$gitignore_path" << 'GITIGNEOF'

# Agent checkpoint files — runtime only, not committed
.checkpoints/*.json
GITIGNEOF
    echo "  [add]  .gitignore  (.checkpoints/*.json)"
  else
    echo "  [skip] .gitignore  (checkpoint rule already present)"
  fi

  # Current sprint telemetry file
  local telemetry_path="$TARGET_DIR/docs/agent-telemetry/current-sprint.md"
  if [ ! -f "$telemetry_path" ]; then
    cat > "$telemetry_path" << 'TELEOF'
# Agent Telemetry — Current Sprint

> **Managed by:** `@telemetry-collector`
> Agents append entries here after each invocation.
> At end of sprint, `@telemetry-collector` archives this and generates a summary.

---

<!-- TELEMETRY ENTRIES BELOW — DO NOT MANUALLY EDIT -->

TELEOF
    echo "  [add]  docs/agent-telemetry/current-sprint.md"
  else
    echo "  [skip] docs/agent-telemetry/current-sprint.md"
  fi

  # Copy agent-telemetry docs from template bundle
  copy_file "$TEMPLATE_ROOT/docs/agent-telemetry/README.md" \
            "$TARGET_DIR/docs/agent-telemetry/README.md"
  copy_file "$TEMPLATE_ROOT/docs/agent-telemetry/TEMPLATE.md" \
            "$TARGET_DIR/docs/agent-telemetry/TEMPLATE.md"

  # AI usage README
  local ai_usage_path="$TARGET_DIR/docs/ai-usage/README.md"
  if [ ! -f "$ai_usage_path" ]; then
    cat > "$ai_usage_path" << 'AIEOF'
# AI Usage Audit Log

Story-centric audit trail of all AI-assisted development sessions.
One entry per story, written by the developer after the story is merged.

Format: `## [EPIC-XXX / S-YYY] Story Title — Sprint N`
AIEOF
    echo "  [add]  docs/ai-usage/README.md"
  else
    echo "  [skip] docs/ai-usage/README.md"
  fi

  # Evals sprint tracker
  local tracker_path="$TARGET_DIR/evals/sprint-tracker.md"
  if [ ! -f "$tracker_path" ]; then
    cat > "$tracker_path" << 'TRACKEOF'
# Sprint Quality Tracker

Populated by `@eval-runner` after each story evaluation.

| Score Range | Grade |
|-------------|-------|
| 0.85 – 1.0  | ✅ Excellent |
| 0.70 – 0.84 | 🟡 Good |
| 0.55 – 0.69 | 🟠 Fair |
| < 0.55      | 🔴 Failing |

---

## Sprint 1

_No evaluations yet._
TRACKEOF
    echo "  [add]  evals/sprint-tracker.md"
  else
    echo "  [skip] evals/sprint-tracker.md"
  fi

  # Copy golden references from template bundle
  for ref_file in "$TEMPLATE_ROOT/evals/golden-references/"*.md; do
    if [ -f "$ref_file" ]; then
      local fname
      fname=$(basename "$ref_file")
      copy_file "$ref_file" "$TARGET_DIR/evals/golden-references/$fname"
    fi
  done

  echo ""

  # ── Agents — official path: .github/agents/*.agent.md ────────────────────────
  # Per VSCode docs: https://code.visualstudio.com/docs/copilot/customization/custom-agents
  # Agents MUST be in .github/agents/ with .agent.md extension to appear in Copilot Chat
  print_section "Agents  →  .github/agents/*.agent.md"
  mkdir -p "$TARGET_DIR/.github/agents"
  for agent_file in "$TEMPLATE_ROOT/.github/copilot/agents/"*.md; do
    if [ -f "$agent_file" ]; then
      local fname
      fname=$(basename "$agent_file" .md)          # strip .md
      copy_file "$agent_file" \
        "$TARGET_DIR/.github/agents/${fname}.agent.md"   # add .agent.md
    fi
  done

  echo ""

  # ── Skills — official path: .github/skills/{name}/SKILL.md ──────────────────
  # Per VSCode docs: https://code.visualstudio.com/docs/copilot/customization/agent-skills
  print_section "Skills  →  .github/skills/{name}/SKILL.md"
  for skill_dir in "$TEMPLATE_ROOT/.github/skills/"/*/; do
    if [ -d "$skill_dir" ]; then
      local skill_name
      skill_name=$(basename "$skill_dir")
      mkdir -p "$TARGET_DIR/.github/skills/$skill_name"
      for skill_file in "$skill_dir"*; do
        [ -f "$skill_file" ] && copy_file "$skill_file" \
          "$TARGET_DIR/.github/skills/$skill_name/$(basename "$skill_file")"
      done
    fi
  done

  echo ""

  # ── Auto-instructions — official path: .github/instructions/*.instructions.md
  # Per VSCode docs: https://code.visualstudio.com/docs/copilot/customization/custom-instructions
  print_section "Instructions  →  .github/instructions/*.instructions.md"
  mkdir -p "$TARGET_DIR/.github/instructions"
  for instr_file in "$TEMPLATE_ROOT/.github/instructions/"*.md; do
    if [ -f "$instr_file" ]; then
      local fname
      fname=$(basename "$instr_file")
      copy_file "$instr_file" "$TARGET_DIR/.github/instructions/$fname"
    fi
  done
  # Copy examples if present
  if [ -d "$TEMPLATE_ROOT/.github/instructions/examples" ]; then
    mkdir -p "$TARGET_DIR/.github/instructions/examples"
    for ex_file in "$TEMPLATE_ROOT/.github/instructions/examples/"*; do
      [ -f "$ex_file" ] && copy_file "$ex_file" \
        "$TARGET_DIR/.github/instructions/examples/$(basename "$ex_file")"
    done
  fi

  echo ""

  # ── Hooks — official path: .github/hooks/{name}.json ─────────────────────────
  # Per VSCode docs: https://code.visualstudio.com/docs/copilot/customization/hooks
  # hooks.json must be directly in .github/hooks/ NOT in subdirectories
  # Shell scripts referenced by hooks CAN be in subdirectories
  print_section "Hooks  →  .github/hooks/session-logger.json  +  scripts"
  mkdir -p "$TARGET_DIR/.github/hooks/session-logger"
  # Copy the shell scripts into session-logger subfolder (referenced by hooks json)
  for sh_file in "$TEMPLATE_ROOT/.github/hooks/session-logger/"*.sh; do
    if [ -f "$sh_file" ]; then
      copy_executable "$sh_file" \
        "$TARGET_DIR/.github/hooks/session-logger/$(basename "$sh_file")"
    fi
  done
  # Copy hooks.json to official location: .github/hooks/session-logger.json
  if [ -f "$TEMPLATE_ROOT/.github/hooks/session-logger/hooks.json" ]; then
    copy_file "$TEMPLATE_ROOT/.github/hooks/session-logger/hooks.json" \
              "$TARGET_DIR/.github/hooks/session-logger.json"
  fi

  echo ""

  # ── Scoring rubric from template ──────────────────────────────────────────────
  copy_file "$TEMPLATE_ROOT/evals/scoring-rubric.md" \
            "$TARGET_DIR/evals/scoring-rubric.md"

  echo ""

  # ── Stamp initialisation ──────────────────────────────────────────────────────
  local init_flag="$TARGET_DIR/.github/copilot/.initialized"
  if [ ! -f "$init_flag" ]; then
    echo "{\"workspace\":\"$ws_name\",\"initializedAt\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"plugin\":\"workspace.sh\"}" \
      > "$init_flag"
    echo ""
    echo "  [add]  .github/copilot/.initialized"
  else
    echo ""
    echo "  [skip] Already initialized — re-run with --force to reset"
  fi

  echo ""
}

summary() {
  echo "WORKSPACE — fully initialised:"
  echo ""
  echo "  AGENTS (14):"
  echo "    .github/agents/              All 14 agents ready for Copilot Chat"
  echo ""
  echo "  SKILLS (4):"
  echo "    .github/skills/              Auto-triggered context helpers"
  echo ""
  echo "  AUTO-INSTRUCTIONS:"
  echo "    .github/instructions/        Applied to every Copilot interaction"
  echo ""
  echo "  HOOKS:"
  echo "    .github/hooks/session-logger.json  Prompt + session tracking"
  echo ""
  echo "  RUNTIME DIRS:"
  echo "    .copilot/instincts/          Agents read/write learned patterns here"
  echo "    .checkpoints/               Agent phase recovery checkpoints (gitignored)"
  echo "    docs/agent-telemetry/       Live telemetry log"
  echo "    docs/epic-plans/            @story-refiner execution plans"
  echo "    docs/issues/                @story-analyzer GitHub Issue drafts (local mode)"
  echo "    taskPlan/                   @task-planner task plans"
  echo "    sprintPlan/                 @sprint-orchestrator sprint reference files"
  echo "    evals/                      @eval-runner quality scores + golden references"
  echo ""
  echo "  Next steps:"
  echo "  1. Open *.code-workspace in VSCode"
  echo "  2. Copilot Chat  →  Agent Mode  →  @story-refiner EPIC-001"
  echo "  3. Review execution plan in docs/epic-plans/"
  echo "  4. @sprint-orchestrator EPIC-001  (shows phase status + parallel commands)"
}
