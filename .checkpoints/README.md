# Agent Checkpoints — Run History & Failure Recovery

This directory stores checkpoint files that serve two purposes:
1. **Resume from failure** — agents pick up from the last successful phase instead of restarting
2. **Run history** — completed checkpoints persist as records of what each agent did, enabling instinct learning and continuous improvement

## Why Checkpoints?

Long-running agents can fail mid-execution due to:
- Context window exhaustion
- Network timeouts on MCP calls
- Build failures that exceed retry limits
- Session interruptions

Without checkpoints, all progress is lost. With checkpoints, the agent resumes where it left off.

## Checkpoint Lifecycle

```
Agent starts → Check for checkpoint
     │
     ├─ No checkpoint → start from Phase 0 / Step 1
     │
     ├─ status: "in-progress" → verify artifacts → resume from next_phase
     │
     ├─ status: "complete" → ask developer: "Re-run or skip?"
     │
     └─ status: "failed" → show failure reason → ask: "Resume or start fresh?"

During execution:
     Phase N complete → write/update checkpoint (overwrite full file)

On completion:
     status → "complete", completed_at → timestamp
     ⚠  NEVER delete — completed checkpoints are valuable run history

On error:
     status → "failed", failure_reason → description
```

## Checkpoint File Format

```json
{
  "agent": "local-rakbank-dev-agent",
  "ticket": "ADO-456",
  "service": "application-service",
  "status": "complete",
  "started_at": "2026-03-10T14:00:00Z",
  "updated_at": "2026-03-10T14:45:00Z",
  "completed_at": "2026-03-10T14:45:00Z",
  "last_completed_phase": "Phase 5",
  "artifacts_created": [
    "src/main/resources/db/changelog/changes/dev/20260310-001-create-application-table.sql",
    "src/main/java/ae/rakbank/application/entity/ApplicationEntity.java",
    "src/main/java/ae/rakbank/application/repository/ApplicationRepository.java"
  ],
  "next_phase": null,
  "build_status": "mvn verify passed",
  "phases_summary": {
    "Phase 1": {"status": "done", "artifacts": 3, "duration_estimate": "2 min"},
    "Phase 2": {"status": "done", "artifacts": 5, "duration_estimate": "4 min"},
    "Phase 3": {"status": "done", "artifacts": 4, "duration_estimate": "3 min"},
    "Phase 4": {"status": "done", "artifacts": 2, "duration_estimate": "2 min"},
    "Phase 5": {"status": "done", "artifacts": 6, "duration_estimate": "5 min"}
  },
  "notes": "All phases complete. 20 files created/modified. Full test suite passed."
}
```

## Status Values

| Status | Meaning | What Happens Next |
|--------|---------|-------------------|
| `in-progress` | Agent was running, may have been interrupted | Resume from `next_phase` after verifying artifacts |
| `complete` | All phases finished successfully | Ask developer before re-running. Kept as run history. |
| `failed` | Agent hit an unrecoverable error | Show `failure_reason`, offer resume or fresh start |

## Which Agents Use Checkpoints

| Agent | Checkpoint File | Trigger | Resume Point |
|-------|----------------|---------|--------------|
| `@local-rakbank-dev-agent` | `local-dev-{ticket-id}.json` | After each implementation phase (1-5) | Skip completed phases |
| `@rakbank-backend-dev-agent` | `remote-dev-{ticket-id}.json` | After each implementation phase (1-5) | Skip completed phases |
| `@story-refiner` | `story-refiner-EPIC-{id}.json` | After reading each Feature from ADO | Skip already-read features |

## How Checkpoints Enable Learning

Completed checkpoints are NOT deleted because they contain valuable data for:

- **`@local-instinct-learner`** — reads `phases_summary` and `artifacts_created` to understand what patterns the agent used and how long each phase took
- **`@instinct-extractor`** — correlates checkpoint data with PR diffs to identify which implementations worked well
- **`@eval-runner`** — uses `build_status` and phase data to score agent effectiveness
- **Manual review** — developers can see exactly what each agent run produced

## File Naming Convention

```
.checkpoints/{agent-short-name}-{ticket-id}.json
```

Examples:
- `.checkpoints/local-dev-ADO-456.json`
- `.checkpoints/remote-dev-ADO-456.json`
- `.checkpoints/story-refiner-EPIC-100.json`

## Git Configuration

Checkpoint JSON files are **local-only** — they contain machine-specific paths and are gitignored:
```
.checkpoints/*.json
```

This README.md is committed and tracked. The checkpoint files stay on the developer's machine.

> **Windows users:** This is a hidden folder (starts with `.`). Enable "Show hidden items" in File Explorer to see it.
