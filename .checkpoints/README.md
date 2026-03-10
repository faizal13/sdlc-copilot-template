# Agent Checkpoints — Failure Recovery System

This directory stores checkpoint files that enable agents to **resume from the last successful phase** instead of restarting from scratch after a failure.

## Why Checkpoints?

Anthropic's guidance: *"Build systems that resume from failure points rather than restart."*

Long-running agents (especially coding agents processing complex stories) can fail mid-execution due to:
- Context window exhaustion
- Network timeouts on MCP calls
- Build failures that exceed retry limits
- Session interruptions

Without checkpoints, all progress is lost. With checkpoints, the agent can resume where it left off.

## How It Works

### Writing Checkpoints
After completing each major phase, an agent writes a checkpoint file:

```
.checkpoints/{agent-name}-{ticket-id}.json
```

### Checkpoint File Format
```json
{
  "agent": "local-rakbank-dev-agent",
  "ticket": "ADO-456",
  "service": "application-service",
  "last_completed_phase": "Phase 3",
  "timestamp": "2026-03-10T14:30:00Z",
  "artifacts_created": [
    "src/main/resources/db/changelog/changes/dev/20260310-001-create-application-table.sql",
    "src/main/java/ae/rakbank/application/entity/ApplicationEntity.java",
    "src/main/java/ae/rakbank/application/repository/ApplicationRepository.java"
  ],
  "next_phase": "Phase 4 — Integration Stubs",
  "build_status": "mvn compile passed after Phase 3",
  "notes": "All compilation checks passed. 3 entities created. Service layer complete."
}
```

### Resuming from a Checkpoint
When an agent starts, it checks for an existing checkpoint:

1. Look for `.checkpoints/{agent-name}-{ticket-id}.json`
2. If found:
   - Read the checkpoint
   - Verify artifacts exist on disk (the files listed in `artifacts_created`)
   - If artifacts are valid: skip to `next_phase`
   - If artifacts are missing: warn and restart from the beginning
3. If not found: start normally from Phase 0

### Checkpoint Lifecycle
```
Agent starts → Check for checkpoint → Resume or start fresh
     ↓
Phase N complete → Write checkpoint
     ↓
Phase N+1 complete → Update checkpoint (overwrite)
     ↓
All phases complete → Delete checkpoint (clean up)
```

## Which Agents Use Checkpoints

| Agent | Checkpoint Trigger | Resume Point |
|-------|-------------------|--------------|
| @local-rakbank-dev-agent | After each implementation phase (1-6) | Skip completed phases |
| @rakbank-backend-dev-agent | After each implementation phase (1-6) | Skip completed phases |
| @story-refiner | After reading each Feature from ADO | Skip already-read features |

## File Naming Convention

```
.checkpoints/{agent-short-name}-{ticket-id}.json
```

Examples:
- `.checkpoints/local-dev-ADO-456.json`
- `.checkpoints/remote-dev-ADO-456.json`
- `.checkpoints/story-refiner-EPIC-100.json`

## Cleanup

Checkpoint files are **temporary**. They should be:
- Deleted after the agent completes successfully
- Deleted when the story's PR is merged
- Ignored by git (add `.checkpoints/*.json` to `.gitignore` — keep only README.md)

## Git Configuration

Add to `.gitignore`:
```
.checkpoints/*.json
```

The README.md is committed. The checkpoint JSON files are local-only and ephemeral.
