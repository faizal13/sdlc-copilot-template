#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
#  core.sh — Core components installed for EVERY mode (local / hybrid)
#
#  Sourced by install.sh. Never run directly.
#
#  Installs:
#    - All agents                    → .github/agents/*.agent.md
#    - Auto-instructions (6)        → .github/instructions/*.instructions.md
#    - Instruction examples (4)     → .github/instructions/examples/
#    - VS Code skills (4)           → .github/skills/{name}/SKILL.md
#    - Copilot session logger hooks → .github/hooks/session-logger/ (.sh + .js)
#    - Claude Code hooks registry   → .github/hooks/session-logger.json
#    - Git post-commit AI usage hook→ .github/hooks/git/
#    - Runtime directories + README → contexts/, docs/, evals/, .copilot/, etc.
#
#  This replaces the old shared.sh — it installs EVERYTHING that is common
#  to both local and hybrid modes. Mode-specific extras are in separate files.
#
#  Provides:
#    install_core()  — called by install.sh
# ═══════════════════════════════════════════════════════════════════════════════

install_core() {
  # ════════════════════════════════════════════════════════════════════════════
  #  AGENTS — .github/agents/*.agent.md
  # ════════════════════════════════════════════════════════════════════════════
  print_section "Agents  →  .github/agents/*.agent.md"
  mkdir -p "$TARGET_DIR/.github/agents"

  # Copy all 14 agents from template .github/copilot/agents/*.md
  # to target .github/agents/*.agent.md (correct VS Code path)
  for agent_file in "$TEMPLATE_ROOT/.github/copilot/agents/"*.md; do
    if [ -f "$agent_file" ]; then
      local fname
      fname=$(basename "$agent_file" .md)          # strip .md
      copy_file "$agent_file" \
        "$TARGET_DIR/.github/agents/${fname}.agent.md"   # add .agent.md
    fi
  done

  echo ""

  # ════════════════════════════════════════════════════════════════════════════
  #  AUTO-INSTRUCTIONS — .github/instructions/*.instructions.md
  # ════════════════════════════════════════════════════════════════════════════
  print_section "Instructions  →  .github/instructions/*.instructions.md"
  mkdir -p "$TARGET_DIR/.github/instructions"

  for instr_file in "$TEMPLATE_ROOT/.github/instructions/"*.md; do
    if [ -f "$instr_file" ]; then
      local fname
      fname=$(basename "$instr_file")
      copy_file "$instr_file" "$TARGET_DIR/.github/instructions/$fname"
    fi
  done

  # Instruction examples (reference implementations for teams)
  if [ -d "$TEMPLATE_ROOT/.github/instructions/examples" ]; then
    mkdir -p "$TARGET_DIR/.github/instructions/examples"
    for ex_file in "$TEMPLATE_ROOT/.github/instructions/examples/"*; do
      if [ -f "$ex_file" ]; then
        copy_file "$ex_file" \
          "$TARGET_DIR/.github/instructions/examples/$(basename "$ex_file")"
      fi
    done
  fi

  # copilot-instructions.md — workspace-level Copilot code generation instructions
  if [ -f "$TEMPLATE_ROOT/.github/copilot-instructions.md" ]; then
    copy_file "$TEMPLATE_ROOT/.github/copilot-instructions.md" \
              "$TARGET_DIR/.github/copilot-instructions.md"
  fi

  echo ""

  # ════════════════════════════════════════════════════════════════════════════
  #  SKILLS — .github/skills/{name}/SKILL.md
  # ════════════════════════════════════════════════════════════════════════════
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

  # ════════════════════════════════════════════════════════════════════════════
  #  HOOKS — session logger + git post-commit
  # ════════════════════════════════════════════════════════════════════════════
  print_section "Hooks  →  session-logger + git post-commit"

  # Session logger scripts (.sh + .js) and README
  mkdir -p "$TARGET_DIR/.github/hooks/session-logger"
  for script in "$TEMPLATE_ROOT/.github/hooks/session-logger/"*.sh \
                "$TEMPLATE_ROOT/.github/hooks/session-logger/"*.js; do
    if [ -f "$script" ]; then
      copy_executable "$script" \
        "$TARGET_DIR/.github/hooks/session-logger/$(basename "$script")"
    fi
  done
  if [ -f "$TEMPLATE_ROOT/.github/hooks/session-logger/README.md" ]; then
    copy_file "$TEMPLATE_ROOT/.github/hooks/session-logger/README.md" \
              "$TARGET_DIR/.github/hooks/session-logger/README.md"
  fi
  # session-logger.json → .github/hooks/session-logger.json (Claude Code hooks registry)
  if [ -f "$TEMPLATE_ROOT/.github/hooks/session-logger.json" ]; then
    copy_file "$TEMPLATE_ROOT/.github/hooks/session-logger.json" \
              "$TARGET_DIR/.github/hooks/session-logger.json"
  fi

  # Git post-commit hook (AI usage auto-logger)
  mkdir -p "$TARGET_DIR/.github/hooks/git"
  if [ -f "$TEMPLATE_ROOT/.github/hooks/git/post-commit" ]; then
    copy_executable "$TEMPLATE_ROOT/.github/hooks/git/post-commit" \
                    "$TARGET_DIR/.github/hooks/git/post-commit"
  fi
  if [ -f "$TEMPLATE_ROOT/.github/hooks/git/README.md" ]; then
    copy_file "$TEMPLATE_ROOT/.github/hooks/git/README.md" \
              "$TARGET_DIR/.github/hooks/git/README.md"
  fi

  echo ""

  # ════════════════════════════════════════════════════════════════════════════
  #  RUNTIME DIRECTORIES + README files
  # ════════════════════════════════════════════════════════════════════════════
  print_section "Runtime directories"

  # ── .copilot/instincts/ ───────────────────────────────────────────────────
  mkdir -p "$TARGET_DIR/.copilot/instincts"
  echo "  [dir]  .copilot/instincts/"
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

  # ── .checkpoints/ ────────────────────────────────────────────────────────
  mkdir -p "$TARGET_DIR/.checkpoints"
  echo "  [dir]  .checkpoints/  ⚠  hidden folder — enable 'Show hidden items' on Windows"
  if [ ! -f "$TARGET_DIR/.checkpoints/.gitkeep" ]; then
    touch "$TARGET_DIR/.checkpoints/.gitkeep"
    echo "  [add]  .checkpoints/.gitkeep"
  else
    echo "  [skip] .checkpoints/.gitkeep"
  fi
  copy_file "$TEMPLATE_ROOT/.checkpoints/README.md" \
            "$TARGET_DIR/.checkpoints/README.md"

  # ── discovery/ ────────────────────────────────────────────────────────────
  mkdir -p "$TARGET_DIR/discovery"
  echo "  [dir]  discovery/"
  copy_file "$TEMPLATE_ROOT/templates/discovery/README.md" \
            "$TARGET_DIR/discovery/README.md"

  # ── contexts/ ─────────────────────────────────────────────────────────────
  mkdir -p "$TARGET_DIR/contexts"
  echo "  [dir]  contexts/"
  if [ ! -f "$TARGET_DIR/contexts/README.md" ]; then
    cat > "$TARGET_DIR/contexts/README.md" << 'CTXEOF'
# Contexts

Create domain context files here. Each file provides background knowledge
that agents read before generating code or plans.

## What to create

- `banking.md` — Banking terminology, regulatory rules, data sensitivity
- `{your-domain}.md` — Domain-specific terminology and business rules

## Format

Plain markdown. Write in a way that an AI agent can read and apply.
Include: terminology glossary, business rules, data sensitivity levels,
regulatory constraints, naming conventions.

## Referenced by

- `@task-planner` — reads context before producing task plans
- `@story-refiner` — reads context for technical analysis
- `@local-rakbank-dev-agent` — reads context before writing code
- `@story-analyzer` — reads context for GitHub Issue creation
CTXEOF
    echo "  [add]  contexts/README.md"
  else
    echo "  [skip] contexts/README.md"
  fi

  # ── docs/solution-design/ ─────────────────────────────────────────────────
  mkdir -p "$TARGET_DIR/docs/solution-design"
  echo "  [dir]  docs/solution-design/"
  if [ ! -f "$TARGET_DIR/docs/solution-design/README.md" ]; then
    cat > "$TARGET_DIR/docs/solution-design/README.md" << 'SDEOF'
# Solution Design

Create solution design documents here. These are the primary reference
for all agents when making architectural decisions.

## Required files

| File | Purpose |
|------|---------|
| `architecture-overview.md` | System architecture, microservices, state machines |
| `user-personas.md` | User roles, permissions, data isolation rules |
| `business-rules.md` | Business logic, validation rules, constraints |
| `integration-map.md` | External system integrations, API contracts |
| `data-model.md` | Entity relationships, field types, constraints |

## Referenced by

- `@story-refiner` — cross-references stories against architecture
- `@task-planner` — loads context for task plan generation
- `@local-rakbank-dev-agent` — reads before writing code
- `@local-reviewer` — validates code against design decisions
SDEOF
    echo "  [add]  docs/solution-design/README.md"
  else
    echo "  [skip] docs/solution-design/README.md"
  fi

  # ── docs/epic-plans/ ──────────────────────────────────────────────────────
  mkdir -p "$TARGET_DIR/docs/epic-plans"
  echo "  [dir]  docs/epic-plans/"
  if [ ! -f "$TARGET_DIR/docs/epic-plans/README.md" ]; then
    cat > "$TARGET_DIR/docs/epic-plans/README.md" << 'EPEOF'
# Epic Plans

`@story-refiner` writes execution plans here.
Also used as fallback for epic/story data when ADO MCP is unavailable.

## Naming convention

- `EPIC-{id}-execution-plan.md` — Full phased execution plan for an epic

## Referenced by

- `@sprint-orchestrator` — reads execution plans to determine phase status
- `@task-planner` — checks for dependency context before creating task plans
EPEOF
    echo "  [add]  docs/epic-plans/README.md"
  else
    echo "  [skip] docs/epic-plans/README.md"
  fi

  # ── docs/api-specs/ ───────────────────────────────────────────────────────
  mkdir -p "$TARGET_DIR/docs/api-specs/common/schemas"
  mkdir -p "$TARGET_DIR/docs/api-specs/common/parameters"
  mkdir -p "$TARGET_DIR/docs/api-specs/common/responses"
  echo "  [dir]  docs/api-specs/"
  if [ ! -f "$TARGET_DIR/docs/api-specs/README.md" ]; then
    cat > "$TARGET_DIR/docs/api-specs/README.md" << 'APIEOF'
# API Specifications

OpenAPI 3.1 specifications generated by `@api-architect`.

## Structure

```
api-specs/
├── common/                    # Shared schemas, parameters, responses
│   ├── schemas/
│   │   ├── errors.yaml        # RFC 9457 Problem Details
│   │   ├── pagination.yaml    # Cursor & offset pagination
│   │   └── audit.yaml         # Created/updated timestamps
│   ├── parameters/
│   │   └── common.yaml        # limit, cursor, request headers
│   └── responses/
│       └── errors.yaml        # 400, 401, 403, 404, 422, 500
├── {service-name}/
│   └── openapi.yaml           # Full spec for one service
└── README.md
```

## How to use

**View in Swagger Editor:**
```
npx @redocly/cli preview-docs docs/api-specs/{service}/openapi.yaml
```

**Validate all specs:**
```
npx @stoplight/spectral-cli lint docs/api-specs/**/*.yaml
```

**Generate server stubs:**
```
npx @openapitools/openapi-generator-cli generate -i docs/api-specs/{service}/openapi.yaml -g spring -o generated/
```

## Generated by

- `@api-architect` — creates and updates these specs from execution plans
- Run after `@story-refiner` completes, before coding begins
APIEOF
    echo "  [add]  docs/api-specs/README.md"
  else
    echo "  [skip] docs/api-specs/README.md"
  fi

  # ── docs/test-cases/ ──────────────────────────────────────────────────────
  mkdir -p "$TARGET_DIR/docs/test-cases"
  echo "  [dir]  docs/test-cases/"
  if [ ! -f "$TARGET_DIR/docs/test-cases/README.md" ]; then
    cat > "$TARGET_DIR/docs/test-cases/README.md" << 'TCEOF'
# QA Test Cases

Test cases generated by `@test-architect` for QA review and execution.

## Structure

```
docs/test-cases/
└── EPIC-{id}/
    ├── README.md                              ← coverage summary + test index
    ├── {STORY-id}-test-cases.md               ← functional test cases per story
    ├── {service-name}-api-contract-tests.md   ← API contract tests per service
    ├── integration-scenarios.md               ← cross-service E2E scenarios
    └── business-rule-tests.md                 ← business rule edge cases
```

## Workflow

1. `@test-architect EPIC-{id}` → generates test cases from ACs + API specs + business rules
2. QA Lead reviews and flags gaps
3. Development proceeds independently (devs write their own unit tests)
4. After development completes → QA executes test cases against deployed environment
5. Re-run `@test-architect EPIC-{id} --update` if requirements change

TCEOF
    echo "  [add]  docs/test-cases/README.md"
  else
    echo "  [skip] docs/test-cases/README.md"
  fi

  # ── docs/project-changelog.md ──────────────────────────────────────────────
  copy_file "$TEMPLATE_ROOT/docs/project-changelog.md" \
            "$TARGET_DIR/docs/project-changelog.md"

  # ── docs/agent-telemetry/ ─────────────────────────────────────────────────
  mkdir -p "$TARGET_DIR/docs/agent-telemetry"
  echo "  [dir]  docs/agent-telemetry/"
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
  copy_file "$TEMPLATE_ROOT/docs/agent-telemetry/README.md" \
            "$TARGET_DIR/docs/agent-telemetry/README.md"
  copy_file "$TEMPLATE_ROOT/docs/agent-telemetry/TEMPLATE.md" \
            "$TARGET_DIR/docs/agent-telemetry/TEMPLATE.md"

  # ── docs/ai-usage/ ───────────────────────────────────────────────────────
  mkdir -p "$TARGET_DIR/docs/ai-usage"
  echo "  [dir]  docs/ai-usage/"
  if [ ! -f "$TARGET_DIR/docs/ai-usage/README.md" ]; then
    cat > "$TARGET_DIR/docs/ai-usage/README.md" << 'AIEOF'
# AI Usage Audit Log

Story-centric audit trail of all AI-assisted development sessions.
One entry per story, written by the developer after the story is merged.

Format: `## [EPIC-XXX / S-YYY] Story Title — Sprint N`
AIEOF
    echo "  [add]  docs/ai-usage/README.md"
  else
    echo "  [skip] docs/ai-usage/README.md"
  fi

  # ── docs/issues/ ──────────────────────────────────────────────────────────
  mkdir -p "$TARGET_DIR/docs/issues"
  echo "  [dir]  docs/issues/"
  if [ ! -f "$TARGET_DIR/docs/issues/README.md" ]; then
    cat > "$TARGET_DIR/docs/issues/README.md" << 'ISSEOF'
# Issues

`@story-analyzer` writes GitHub Issue drafts here when GitHub MCP is unavailable.

## Naming convention

- `{ADO-ID}-{service-name}-issue.md` — Issue draft for a specific story

## Workflow

1. `@story-analyzer` creates the file here (local fallback mode)
2. Developer reviews the draft
3. Developer manually creates the GitHub Issue from the draft
ISSEOF
    echo "  [add]  docs/issues/README.md"
  else
    echo "  [skip] docs/issues/README.md"
  fi

  # ── docs/reviews/ ────────────────────────────────────────────────────────
  mkdir -p "$TARGET_DIR/docs/reviews"
  echo "  [dir]  docs/reviews/"
  if [ ! -f "$TARGET_DIR/docs/reviews/README.md" ]; then
    cat > "$TARGET_DIR/docs/reviews/README.md" << 'REVEOF'
# Code Reviews

`@local-reviewer` saves review reports here after each review run.

Each file is named after the branch: `{branch-name}-review.md`

These files persist across sessions so other agents can reference past reviews.
REVEOF
    echo "  [add]  docs/reviews/README.md"
  else
    echo "  [skip] docs/reviews/README.md"
  fi

  # ── evals/ ────────────────────────────────────────────────────────────────
  mkdir -p "$TARGET_DIR/evals/golden-references"
  echo "  [dir]  evals/golden-references/"
  copy_file "$TEMPLATE_ROOT/evals/scoring-rubric.md" \
            "$TARGET_DIR/evals/scoring-rubric.md"
  # Sprint tracker
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
  # Golden references
  for ref_file in "$TEMPLATE_ROOT/evals/golden-references/"*.md; do
    if [ -f "$ref_file" ]; then
      local fname
      fname=$(basename "$ref_file")
      copy_file "$ref_file" "$TARGET_DIR/evals/golden-references/$fname"
    fi
  done

  # ── docs/agent-feedback/ ─────────────────────────────────────────────────
  mkdir -p "$TARGET_DIR/docs/agent-feedback"
  echo "  [dir]  docs/agent-feedback/"
  if [ -f "$TEMPLATE_ROOT/docs/agent-feedback/TEMPLATE.md" ]; then
    copy_file "$TEMPLATE_ROOT/docs/agent-feedback/TEMPLATE.md" \
              "$TARGET_DIR/docs/agent-feedback/TEMPLATE.md"
  fi
  if [ ! -f "$TARGET_DIR/docs/agent-feedback/README.md" ]; then
    cat > "$TARGET_DIR/docs/agent-feedback/README.md" << 'FBEOF'
# Agent Feedback

Fill in `TEMPLATE.md` after each story to capture what the agents got right or wrong.
Over time this drives improvements to agent definitions.

## Naming convention

Copy `TEMPLATE.md` and rename it: `{ADO-ID}-feedback.md`

## Referenced by

- `@local-instinct-learner` — reads feedback files when learning new patterns
FBEOF
    echo "  [add]  docs/agent-feedback/README.md"
  else
    echo "  [skip] docs/agent-feedback/README.md"
  fi

  # ── logs/copilot/ ─────────────────────────────────────────────────────────
  mkdir -p "$TARGET_DIR/logs/copilot"
  echo "  [dir]  logs/copilot/"

  echo ""

  # ════════════════════════════════════════════════════════════════════════════
  #  .gitignore — ensure runtime files are ignored
  # ════════════════════════════════════════════════════════════════════════════
  print_section "Gitignore rules"
  local gitignore_path="$TARGET_DIR/.gitignore"
  local needs_checkpoint=true
  local needs_logs=true

  if [ -f "$gitignore_path" ]; then
    grep -q '\.checkpoints/\*\.json' "$gitignore_path" 2>/dev/null && needs_checkpoint=false
    grep -q 'logs/copilot/' "$gitignore_path" 2>/dev/null && needs_logs=false
  fi

  if [ "$needs_checkpoint" = true ] || [ "$needs_logs" = true ]; then
    {
      echo ""
      echo "# Agent runtime files — not committed"
      if [ "$needs_checkpoint" = true ]; then
        echo ".checkpoints/*.json"
      fi
      if [ "$needs_logs" = true ]; then
        echo "logs/copilot/"
      fi
    } >> "$gitignore_path"
    echo "  [add]  .gitignore (runtime ignore rules)"
  else
    echo "  [skip] .gitignore (rules already present)"
  fi

  # ════════════════════════════════════════════════════════════════════════════
  #  Git hooks path — configure if git is available
  # ════════════════════════════════════════════════════════════════════════════
  if git rev-parse --git-dir >/dev/null 2>&1; then
    local current_hooks_path
    current_hooks_path=$(git config core.hooksPath 2>/dev/null || true)
    if [ "$current_hooks_path" != ".github/hooks/git" ]; then
      git config core.hooksPath .github/hooks/git
      echo "  [set]  git core.hooksPath = .github/hooks/git"
    else
      echo "  [skip] git core.hooksPath (already set)"
    fi
  else
    echo "  [info] git not initialized — skipping hooks path config"
  fi

  echo ""
}
