#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
#  local-extras.sh — Local mode additions (on top of core.sh)
#
#  Sourced by install.sh when mode = local or hybrid.
#  Never run directly.
#
#  Installs:
#    - taskPlan/    directory + README  (where @task-planner writes spec files)
#    - sprintPlan/  directory + README  (where @sprint-orchestrator writes status)
#
#  core.sh already installs all 18 agents, skills, hooks, instructions,
#  and all other runtime directories. This file only adds the local-workflow
#  specific planning directories.
#
#  Provides:
#    install_local_extras()  — called by install.sh
# ═══════════════════════════════════════════════════════════════════════════════

install_local_extras() {
  print_section "Local workflow directories"

  # ── taskPlan/ ─────────────────────────────────────────────────────────────
  mkdir -p "$TARGET_DIR/taskPlan"
  echo "  [dir]  taskPlan/"
  copy_file "$TEMPLATE_ROOT/taskPlan/README.md" \
            "$TARGET_DIR/taskPlan/README.md"

  # ── sprintPlan/ ───────────────────────────────────────────────────────────
  mkdir -p "$TARGET_DIR/sprintPlan"
  echo "  [dir]  sprintPlan/"
  if [ ! -f "$TARGET_DIR/sprintPlan/README.md" ]; then
    cat > "$TARGET_DIR/sprintPlan/README.md" << 'SPEOF'
# Sprint Plan

`@sprint-orchestrator` writes sprint reference files here.

## Naming convention

- `EPIC-{id}-sprint-status.md` — Current sprint status for an epic

## Workflow

1. Run `@sprint-orchestrator EPIC-{id}` at the start of each sprint or phase
2. Open the generated file to see which stories are READY
3. For each READY story, run `@task-planner {STORY-ID}`
4. After stories complete, re-run `@sprint-orchestrator` to refresh status
SPEOF
    echo "  [add]  sprintPlan/README.md"
  else
    echo "  [skip] sprintPlan/README.md"
  fi

  echo ""
}
