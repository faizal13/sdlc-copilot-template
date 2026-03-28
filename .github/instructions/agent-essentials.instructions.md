---
applyTo: '**'
---

## Agent Essentials — Always-On Guardrails

> This instruction file is auto-applied to EVERY file and EVERY agent interaction. It serves as a safety net to ensure critical rules are never skipped — even during agent-to-agent handoffs where context may be truncated.

### 1. Mandatory Context Loading

Before producing any output, EVERY agent MUST read:

```
.github/copilot-instructions.md              ← Java coding standards (ALWAYS)
.github/instructions/*.instructions.md       ← ALL instruction files in this directory
contexts/                                    ← ALL domain context files
docs/solution-design/                        ← ALL architecture and design files
docs/project-changelog.md                    ← Project evolution and requirement drift (if exists)
```

If you are a coding agent (`@local-rakbank-dev-agent`, `@rakbank-backend-dev-agent`):
- You MUST read `.github/copilot-instructions.md` before writing ANY Java code
- You MUST check if `pom.xml` exists at the workspace root BEFORE writing code
- If no `pom.xml`: you are in an **empty repo** — run Phase 1 Bootstrap using the microservice-initializr. Do NOT scaffold code manually.
- If `pom.xml` exists with `ae.rakbank` groupId: this is an existing project — skip bootstrap

### 2. Instruction Files Are Non-Optional

The `.github/instructions/` directory contains these instruction files — ALL must be respected:

| File | Scope | Key Rules |
|------|-------|-----------|
| `coding.instructions.md` | Java source files | Naming, error handling, BigDecimal for money, no hardcoded values |
| `security.instructions.md` | Java source files | Input validation, SQL injection prevention, PII handling |
| `testing.instructions.md` | Test files | Test naming, coverage requirements, mocking patterns |
| `middleware.instructions.md` | Middleware/connector code | ApiCallDetails, RestConnector, ClientConnectionService — NEVER call RestTemplate directly |
| `cross-service.instructions.md` | All files | Cross-service communication rules |
| `mcp-tools.instructions.md` | All files | MCP tool usage limits and rules |
| `review.instructions.md` | All files | Pre-commit review checklist |

### 3. Telemetry Is Mandatory

Every agent MUST append to these files before reporting completion:
- `docs/agent-telemetry/current-sprint.md` — execution metrics
- `docs/project-changelog.md` — what changed and why (append-only, never edit previous entries)

### 4. Banking Domain Rules (Never Violate)

- **Money**: Always `BigDecimal` — never `double` or `float`
- **PII**: Never log customer PII (name, Emirates ID, account number) at INFO level
- **Audit**: All state transitions must be auditable
- **Data isolation**: Personas can only see data they are authorized for (check `user-personas.md`)

### 5. Teams Notifications (When Applicable)

Agents that produce key events (PR created, review verdict, comments resolved, phase complete, story blocked) should send a Teams notification via:

```bash
node .github/hooks/notify-teams.js <type> [key=value ...]
```

See `contexts/notifications.md` for setup and usage. Notifications are optional — if the script is missing or no webhook is configured, the call silently exits. Never let a notification failure block agent execution.
