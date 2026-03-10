# Agent Telemetry

This directory tracks **agent-level operational metrics** — how efficiently each agent performs across sprints.

## How It Differs from `docs/ai-usage/`

| Aspect | ai-usage/ | agent-telemetry/ |
|--------|-----------|------------------|
| **Level** | Story-centric | Agent-centric |
| **Metrics** | Prompt count, duration, files changed | MCP calls, tokens, success rate, error types |
| **Tracking** | Automatic (git hook per commit) | Agents self-report after each invocation |
| **Aggregation** | Per story | Per agent + sprint trend analysis |
| **Question** | "What work was done?" | "How well did each agent perform?" |
| **Audience** | Project managers, compliance | Engineers, AI leads |

## Structure

```
docs/agent-telemetry/
├── README.md                 ← You are here
├── TEMPLATE.md               ← Sprint summary template
└── current-sprint.md         ← Live entries (agents append here)
```

## How It Works

### Per-Invocation (Automatic)
Every agent appends a telemetry entry to `current-sprint.md` at the end of each invocation.
Entries include: agent name, timestamp, story/epic ID, outcome, MCP call count, and notes.

### Per-Sprint (Manual or via @telemetry-collector)
At the end of each sprint, run `@telemetry-collector` to:
1. Read all entries from `current-sprint.md`
2. Aggregate per-agent statistics
3. Produce a sprint summary
4. Archive `current-sprint.md` to `sprint-{N}-telemetry.md`
5. Compare against previous sprint (if available)

### Sprint Retrospective
Review the telemetry summary at sprint retro:
- Which agents had the most failures?
- Which agent consumed the most tokens?
- Is first-pass review success rate improving?
- Are MCP call counts decreasing (efficiency)?

## Telemetry Entry Format

Each agent appends this block to `current-sprint.md`:

```markdown
### {agent-name} — {YYYY-MM-DD HH:MM}
| Metric | Value |
|--------|-------|
| Story/Epic | {ID} |
| Duration | {estimated minutes} |
| MCP Calls | {count} |
| Outcome | {success / failure / partial} |
| Error | {description or "none"} |
| Notes | {key observations} |
```

## Who Maintains This

- **Agents**: Self-report by appending to `current-sprint.md`
- **@telemetry-collector**: Summarizes at sprint end
- **Tech Lead / AI Architect**: Reviews at retrospective, updates `evals/sprint-tracker.md`
