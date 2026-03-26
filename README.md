# SDLC Copilot Template

> **AI-powered SDLC workflow for Java/Spring Boot backend projects.**
> Structured agents that take you from ADO Epic → execution plan → API contracts → task plans → production-ready code.

---

## What You Get

| Component | What it does |
|-----------|-------------|
| **17 Agents** | `@story-refiner`, `@api-architect`, `@test-architect`, `@sprint-orchestrator`, `@task-planner`, `@local-rakbank-dev-agent`, `@local-reviewer`, `@git-publisher`, `@local-instinct-learner`, `@story-analyzer`, `@rakbank-backend-dev-agent`, `@address-comments`, `@instinct-extractor`, `@eval-runner`, `@telemetry-collector`, `@tech-debt-planner`, `@context-architect` |
| **4 Skills** | Auto-activated in Copilot Chat: context-map, what-context-needed, refactor-plan, instinct-lookup |
| **8 Instructions** | Auto-applied to every Copilot interaction: coding, security, testing, review, cross-service, mcp-tools, middleware, agent-essentials |
| **Node.js Hooks** | Session logger (start/stop/prompt tracking) + git post-commit AI usage tracker — Windows & macOS compatible |
| **Checkpoint System** | Phase-level recovery for long-running agents — never restart from scratch; completed runs preserved as learning history |
| **Runtime dirs** | `taskPlan/`, `sprintPlan/`, `docs/epic-plans/`, `docs/api-specs/`, `docs/reviews/`, `docs/agent-telemetry/`, `evals/`, `.copilot/instincts/`, `.checkpoints/` |

---

## The Development Flow

```
ADO Epic
  └── @story-refiner EPIC-001
        Reads all features + stories from ADO (batch mode — no truncation)
        Produces: docs/epic-plans/EPIC-001-execution-plan.md
        (dependency graph, phased execution plan, gap report, technical child stories with full Description + ACs)
        Checkpoint: .checkpoints/story-refiner-EPIC-001.json

@api-architect EPIC-001                          ← NEW — run before coding begins
  Reads the execution plan contract handoffs + solution design
  Produces: docs/api-specs/{service-name}.yaml   (one per service, OpenAPI 3.1)
            docs/api-specs/common/               (RFC 9457 errors, pagination, audit headers)
  The spec is the contract — all coding agents follow it exactly

@test-architect EPIC-001                         ← NEW — run in parallel with development
  Reads ACs from story-refiner + API specs from api-architect + business rules
  Produces: docs/test-cases/EPIC-001/            (functional, API contract, integration, business rule tests)
  QA reviews test cases while development proceeds independently

@sprint-orchestrator EPIC-001
  Reads the execution plan + checks ADO story status
  Checks: are API specs ready? are test cases ready? (prompts if missing)
  Produces: sprintPlan/EPIC-001-sprint-status.md
  (which stories are READY, which are BLOCKED, parallel commands)
  Delegates: @task-planner → @local-rakbank-dev-agent → @local-reviewer (local workflow)
          OR @story-analyzer → GitHub Issues (remote workflow)

@task-planner STORY-456
  Reads the ADO story + cross-references solution design + api-specs
  Produces: taskPlan/STORY-456-service-name.md
  (data model, API changes aligned to spec operationId, test cases, DoD, exact class names)

@local-rakbank-dev-agent taskPlan/STORY-456-service-name.md
  Reads the task plan + docs/api-specs/{service-name}.yaml
  Produces: working code + Liquibase migrations + unit + integration tests
  Runs: mvn clean verify
  Checkpoint: .checkpoints/local-dev-STORY-456.json (resumes if interrupted)

@local-reviewer
  Reviews the PR diff against solution design + API contract + instincts
  Writes: docs/reviews/{branch-name}-review.md  (machine-parseable JSON block)

@local-instinct-learner
  Captures learnings from the merged PR into .copilot/instincts/
```

---

## Setup Guide

### Prerequisites

- **VS Code** with **GitHub Copilot** extension (Copilot Business or Enterprise)
- **Agent Mode** enabled in VS Code: `chat.agent.enabled: true`
- **Node.js** — for cross-platform hooks (Windows + macOS compatible)
- **MCP servers** configured for Azure DevOps and GitHub (see Step 3)

> **No git required to install** — the installer works in any directory. Git init is your responsibility.

---

### Step 1 — Install the template

Clone the template repo (or have it available locally):

```bash
git clone https://github.com/rakbank-internal/platform-backend-copilot-template.git ~/sdlc-copilot-template
```

Then go to **your project folder** and run the installer:

```bash
cd /path/to/your-project
bash ~/sdlc-copilot-template/plugins/install.sh
```

The installer will prompt you:

```
╔═══════════════════════════════════════════════════╗
║     SDLC Copilot Template Installer              ║
╚═══════════════════════════════════════════════════╝

┌─ Select mode ────────────────────────────────────┐
│  1) Local   — All agents run locally in VS Code  │
│  2) Hybrid  — Local + GitHub Actions pipeline    │
└──────────────────────────────────────────────────┘

  Mode [1/2]: 1

┌─ Select target ─────────────────────────────────────────┐
│  1) Single folder  — Install into current directory      │
│  2) Workspace      — Multi-service workspace setup       │
└─────────────────────────────────────────────────────────┘

  Target [1/2]: 1
```

**Which mode to choose:**
- **Local** — You write code in VS Code with Copilot agents. All 16 agents work locally. Start here.
- **Hybrid** — Same as local + GitHub Actions pipeline for automated coding/review/ADO-sync. Add this later when ready.

**Which target to choose:**
- **Single folder** — One microservice project. Most common.
- **Workspace** — Multi-service setup (e.g. orchestrator + notification + BFF). Creates a `.code-workspace` file and links all services.

What gets installed for **Local + Single folder**:
```
.github/agents/              ← 15 agents as *.agent.md
.github/instructions/        ← 8 auto-instructions + examples
.github/skills/              ← 4 skills
.github/hooks/               ← session-logger.json + Node.js scripts + git post-commit
.copilot/instincts/          ← INDEX.json (grows as agents learn)
.checkpoints/                ← agent recovery checkpoints + README
contexts/                    ← README (you add domain knowledge here)
docs/solution-design/        ← README (you add architecture here)
docs/api-specs/              ← @api-architect writes OpenAPI 3.1 specs here
docs/api-specs/common/       ← shared schemas: RFC 9457 errors, pagination, audit headers
docs/epic-plans/             ← @story-refiner writes here
docs/reviews/                ← @local-reviewer writes structured review reports here
docs/agent-telemetry/        ← 7-source sprint telemetry (agents + sessions + prompts + reviews + changelog + checkpoints + plans)
docs/ai-usage/               ← git hook logs AI usage here
docs/issues/                 ← @story-analyzer local fallback
evals/                       ← @eval-runner quality scores
logs/copilot/                ← session logger output
taskPlan/                    ← @task-planner writes spec files here
sprintPlan/                  ← @sprint-orchestrator writes status here
```

> **Idempotent:** Run the installer multiple times safely — existing files are never overwritten.

---

### Step 2 — Fill in your domain knowledge

The installer creates two empty directories with README guidance. Fill these in before running any agents — they are the foundation everything else reads from.

#### 2a. `contexts/` — Domain knowledge

Create a file describing your domain. Agents read this before every task.

Example: `contexts/banking.md`
```markdown
# Banking Domain Context

## Terminology
- **Mortgage Application** — A customer's request for a home loan
- **LTV** — Loan-to-Value ratio (loan amount / property value)
- **Underwriter** — Staff who approve/reject mortgage applications

## Business Rules
- All monetary fields must use BigDecimal (never double or float)
- Applications cannot skip states — must follow the state machine
- PII fields (NID, salary) must not appear in logs

## Regulatory Constraints
- All decisions must be logged with timestamp and actor
```

#### 2b. `docs/solution-design/` — Architecture

Create these files (agents reference them for every task plan and code generation):

| File | What to put in it |
|------|------------------|
| `architecture-overview.md` | Microservices list, state machines, technology stack |
| `user-personas.md` | User roles, what each can see/do, data isolation rules |
| `business-rules.md` | Validation logic, eligibility rules, calculation formulas |
| `integration-map.md` | External systems, API contracts, event schemas |
| `data-model.md` | Entities, fields, relationships, enums |

> **Reference:** See `docs/solution-design/examples/` for a complete example of every file.

---

### Step 3 — Configure MCP servers

Agents connect to Azure DevOps and GitHub via MCP. Configure them in VS Code:

Open VS Code → `Cmd+Shift+P` → **Preferences: Open User Settings (JSON)** → add:

```json
{
  "mcp": {
    "servers": {
      "microsoft/azure-devops-mcp": {
        "command": "npx",
        "args": ["-y", "@microsoft/azure-devops-mcp"],
        "env": {
          "AZURE_DEVOPS_ORG_URL": "https://dev.azure.com/YOUR-ORG",
          "AZURE_DEVOPS_AUTH_METHOD": "pat",
          "AZURE_DEVOPS_TOKEN": "YOUR-ADO-PAT-TOKEN"
        }
      },
      "github": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-github"],
        "env": {
          "GITHUB_PERSONAL_ACCESS_TOKEN": "YOUR-GITHUB-TOKEN"
        }
      }
    }
  }
}
```

> **On-prem ADO:** If your Azure DevOps is self-hosted, set `AZURE_DEVOPS_ORG_URL` to your on-prem URL (e.g. `https://ado.yourcompany.com/YOUR-ORG`). Write operations (comments, story creation) require a full-access PAT.

**Getting tokens:**
- **ADO PAT**: ADO → User Settings → Personal Access Tokens → New Token (scopes: Work Items Read/Write, Code Read)
- **GitHub PAT**: GitHub → Settings → Developer settings → Personal access tokens → Classic (scopes: `repo`, `issues`)

**Verify MCP is working:** Open Copilot Chat in VS Code → click the tools icon → you should see `microsoft/azure-devops-mcp` and `github` listed.

> **Important:** The MCP server name `microsoft/azure-devops-mcp` must match exactly what VS Code registers. Agents use `microsoft/azure-devops-mcp/*` as the tool reference in their frontmatter.

---

### Step 4 — Enable Agent Mode in VS Code

Ensure these VS Code settings are active (auto-set by installer if `.vscode/settings.json` exists):

```json
{
  "chat.agent.enabled": true,
  "chat.useAgentSkills": true,
  "github.copilot.chat.codeGeneration.useInstructionFiles": true
}
```

---

### Step 5 — Verify agents are available

Open Copilot Chat → type `@` → you should see all 16 agents in the dropdown:

```
@address-comments
@api-architect
@context-architect
@eval-runner
@instinct-extractor
@test-architect
@local-instinct-learner
@local-rakbank-dev-agent
@local-reviewer
@rakbank-backend-dev-agent
@sprint-orchestrator
@story-analyzer
@story-refiner
@task-planner
@tech-debt-planner
@telemetry-collector
```

If agents don't appear: make sure files are in `.github/agents/*.agent.md` (not `.github/copilot/agents/`).

---

## Using the Agents

### Sprint Planning

```
@story-refiner EPIC-001
```
→ Reads your entire epic tree from ADO in batches (no truncation), produces `docs/epic-plans/EPIC-001-execution-plan.md` with execution phases, dependency graph, and technical child stories (full Description + ACs auto-populated). Checkpoint saved after each Feature batch — resumes if interrupted.

```
@api-architect EPIC-001
```
→ **Run this after `@story-refiner`, before `@sprint-orchestrator`.**
Reads the execution plan contract handoffs and solution design docs, produces industry-standard OpenAPI 3.1 specs:
- `docs/api-specs/{service-name}.yaml` — per-service spec (RFC 9457 errors, cursor pagination, read/write model separation, no `nullable` keyword)
- `docs/api-specs/common/` — shared schemas reused across services

All coding agents (`@task-planner`, `@local-rakbank-dev-agent`, `@rakbank-backend-dev-agent`) and `@local-reviewer` will automatically load and follow these specs as the contract.

```
@test-architect EPIC-001
```
→ **Run after `@story-refiner` and `@api-architect` — in parallel with development, NOT after it.**
Generates comprehensive QA test cases from acceptance criteria, API specs, and business rules:
- `docs/test-cases/EPIC-001/{STORY-id}-test-cases.md` — functional test cases per story (positive, negative, boundary)
- `docs/test-cases/EPIC-001/{service}-api-contract-tests.md` — API contract validation (happy path, 400, 401, 404)
- `docs/test-cases/EPIC-001/integration-scenarios.md` — cross-service end-to-end flows
- `docs/test-cases/EPIC-001/business-rule-tests.md` — domain-specific rule validation
- `docs/test-cases/EPIC-001/EPIC-001-test-cases.csv` — **ALL test cases in one CSV** — open in Excel, import into Zephyr/TestRail/qTest/Azure Test Plans

The CSV includes QA execution columns (Actual Result, Status, Tested-By, Test-Date, Defect-ID) pre-created but empty — QA fills them during execution.

> **Important:** Test cases are for QA review and execution after development completes. Development agents do NOT consume these — devs write their own unit/integration tests independently to maintain QA independence.

```
@sprint-orchestrator EPIC-001
```
→ Reads the execution plan, checks ADO story statuses, checks whether API specs exist (prompts you to run `@api-architect` first if missing), produces `sprintPlan/EPIC-001-sprint-status.md`.
`@sprint-orchestrator` is also an **orchestrator** — it can delegate the full story workflow to sub-agents:
- **Local mode:** delegates `@task-planner` → `@local-rakbank-dev-agent` → `@local-reviewer` and reads review results from `docs/reviews/`
- **Remote mode:** delegates `@story-analyzer` → creates GitHub Issues
- **Plan only mode:** creates task plans for ALL READY stories (delegates `@task-planner` only), then stops — you review each plan and run the dev agent yourself per the execution plan order
- **Status only:** writes the status file, you run agents yourself

Open `sprintPlan/EPIC-001-sprint-status.md` to see:
- Which stories are ✅ DONE, 🟢 READY, 🔴 BLOCKED
- Which can run in parallel (different services)
- Exact commands to run next

### Story Implementation

```
@task-planner STORY-456
```
→ Reads the ADO story, cross-references solution design + `docs/api-specs/{service-name}.yaml`, produces `taskPlan/STORY-456-service-name.md`. If an API spec exists, the task plan references exact `operationId` values and schema refs — the coding agent follows these as the contract.

```
@local-rakbank-dev-agent taskPlan/STORY-456-service-name.md
```
→ Reads the task plan, loads the API spec for contract compliance, builds in order: migration → entity → repository → service → controller → tests. Checkpoint written after each phase — if VS Code crashes or context window exhausts, resume without restarting from scratch.

### After Implementation

```
@local-reviewer
```
→ Structured review against architecture + API contract + instincts. Writes the full report (machine-parseable JSON + human-readable) to `docs/reviews/{branch-name}-review.md` so `@sprint-orchestrator` can read the verdict automatically.

### Publishing to GitHub (after review passes ✅)

```
@git-publisher STORY-456
```
→ Creates a feature branch from the release branch, commits all reviewed code with a structured message (story ID, service, ACs covered), pushes to remote, and raises a PR against the release branch. Refuses to proceed if review verdict is BLOCKED. Detects and excludes sensitive files. Supports multi-repo workspaces.

```
@address-comments
```
→ After human reviewers leave comments on the PR, this agent reads each comment and makes targeted fixes.

```
@instinct-extractor
```
→ Run before or after `@git-publisher` to capture reusable development patterns from this implementation into `.copilot/instincts/`.

```
@local-instinct-learner "the team prefers X pattern over Y because Z"
```
→ Captures manual learnings into `.copilot/instincts/` for future agents to apply

---

## Multi-Service Workspace Setup

If your project has multiple microservices (e.g. orchestrator + notification + BFF):

```bash
mkdir my-project-workspace
cd my-project-workspace
bash ~/sdlc-copilot-template/plugins/install.sh
```

Select **Local** mode + **Workspace** target. When prompted:

```
How are your microservice repos organized?
  1) All repos are subdirectories of this folder
  2) Repos are in separate locations (I'll provide paths)

Services: orchestrator-service,notification-service,bff-service
```

This creates `my-project-workspace.code-workspace`. Open it in VS Code for the multi-root workspace view.

> **Note:** The workspace config has each service as a folder entry once — they will not appear duplicated in the VS Code Explorer.

---

## Checkpoint System

Long-running agents (`@story-refiner`, `@local-rakbank-dev-agent`, `@rakbank-backend-dev-agent`) write checkpoint files after each phase:

```
.checkpoints/story-refiner-EPIC-001.json
.checkpoints/local-dev-STORY-456.json
.checkpoints/remote-dev-STORY-456.json
```

**Checkpoint lifecycle:**
- `"status": "in-progress"` — agent is running (or was interrupted)
- `"status": "complete"` — all phases finished; agent asks before re-running
- `"status": "failed"` — shows failure reason; offers resume from last phase or fresh start

**Checkpoints are never deleted** — completed runs are preserved as history for `@local-instinct-learner`, `@instinct-extractor`, and `@eval-runner` to learn from.

See `.checkpoints/README.md` for the full lifecycle documentation.

---

## Updating the Template

When a new version of the template is released:

```bash
cd /path/to/your-project
bash ~/sdlc-copilot-template/plugins/install.sh --mode local --target single
```

Existing files are **skipped** — your domain knowledge and customisations are preserved.
To update a specific agent: delete the file from `.github/agents/` and re-run.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Agents don't appear in `@` dropdown | Check files are in `.github/agents/*.agent.md` (not `.github/copilot/agents/`) |
| Agent can't create files | Ensure `edit` is in agent frontmatter `tools:` (not `editFiles` or `runCommands`) |
| MCP not connected | Check VS Code settings → MCP servers → verify tokens are correct |
| MCP server name not found | Agent frontmatter must use `microsoft/azure-devops-mcp/*` — must exactly match VS Code MCP key |
| Hooks not logging (Windows) | Hooks use Node.js scripts — ensure `node` is in PATH; check `.github/hooks/session-logger.json` event names are PascalCase (`SessionStart`, `Stop`, `UserPromptSubmit`) |
| `@story-refiner` can't read ADO | Verify ADO PAT has Work Items Read scope + correct org URL |
| `@story-refiner` creates empty tech stories | Story Description and ACs are auto-templated by the agent — ensure the agent version is up to date |
| `@task-planner` stops on empty story | Add Acceptance Criteria to the ADO story first |
| `mvn verify` fails after coding agent | Check `docs/agent-telemetry/current-sprint.md` for error details |
| Agent interrupted mid-run | Check `.checkpoints/` for a checkpoint file — re-invoke the agent and it will resume from the last completed phase |
| `@local-reviewer` not writing review file | Ensure `edit` is in `local-reviewer.agent.md` tools; review is written to `docs/reviews/{branch}-review.md` |
| ADO write operations return 401 (on-prem) | On-prem ADO may require NTLM/BASIC auth instead of PAT for write operations — check your ADO server's authentication configuration |

---

## Repository Structure

```
.github/
├── agents/                    ← 17 agents as *.agent.md (VS Code reads here)
│   ├── story-refiner.agent.md
│   ├── api-architect.agent.md
│   ├── test-architect.agent.md         ← QA test case generator
│   ├── sprint-orchestrator.agent.md
│   ├── task-planner.agent.md
│   ├── local-rakbank-dev-agent.agent.md
│   ├── local-reviewer.agent.md
│   ├── local-instinct-learner.agent.md
│   ├── story-analyzer.agent.md
│   ├── rakbank-backend-dev-agent.agent.md
│   ├── address-comments.agent.md
│   ├── instinct-extractor.agent.md
│   ├── eval-runner.agent.md
│   ├── git-publisher.agent.md
│   ├── telemetry-collector.agent.md
│   ├── tech-debt-planner.agent.md
│   └── context-architect.agent.md
├── instructions/              ← Auto-applied to every Copilot interaction
│   └── examples/              ← Reference implementations
├── skills/                    ← Auto-activated context helpers (4 skills)
├── hooks/
│   ├── session-logger.json    ← Claude Code hooks config (SessionStart/Stop/UserPromptSubmit)
│   └── session-logger/        ← Node.js scripts (cross-platform: Windows + macOS)
│       ├── log-session-start.js
│       ├── log-session-end.js
│       └── log-prompt.js

.copilot/instincts/            ← INDEX.json + learned pattern files
.checkpoints/                  ← Agent phase recovery files (gitignored JSON) + README.md

contexts/                      ← YOUR domain knowledge (you create this)
docs/
├── solution-design/           ← YOUR architecture docs (you create these)
├── api-specs/                 ← @api-architect writes OpenAPI 3.1 specs here
│   ├── common/
│   │   ├── schemas/           ← errors.yaml (RFC 9457), pagination.yaml, audit.yaml
│   │   ├── parameters/        ← shared query/header params
│   │   └── responses/         ← standard 4xx/5xx response refs
│   └── {service-name}.yaml    ← per-service spec
├── epic-plans/                ← @story-refiner execution plans
├── test-cases/                ← @test-architect QA test cases (per epic)
│   └── EPIC-{id}/            ← functional, API contract, integration, business rule tests
├── reviews/                   ← @local-reviewer structured review reports
├── agent-telemetry/           ← Live agent telemetry log
├── ai-usage/                  ← Per-story AI usage audit trail
├── issues/                    ← @story-analyzer local fallback drafts
└── project-changelog.md       ← Requirement drift tracker

evals/
├── scoring-rubric.md          ← @eval-runner quality criteria
├── sprint-tracker.md          ← Sprint quality scores
└── golden-references/         ← Reference outputs for comparison

taskPlan/                      ← @task-planner writes task specs here
sprintPlan/                    ← @sprint-orchestrator writes status here
logs/copilot/                  ← Session logger output (gitignored)

plugins/                       ← Template installer (run once per project)
├── install.sh                 ← Interactive installer (mode + target selection)
├── bootstrap.sh               ← Clone + install in one command
├── workspace-init.sh          ← Quick workspace init
└── lib/
    ├── core.sh                ← Always-installed components (all modes)
    ├── local-extras.sh        ← Local mode additions (taskPlan/, sprintPlan/)
    ├── hybrid-extras.sh       ← Hybrid additions (workflows, MCP configs)
    ├── workspace.sh           ← Workspace setup (.code-workspace, manifest)
    └── utils.sh               ← Shared helper functions
```

---

## Contributing

See `templateFoundation.md` for the template's living spec and pattern promotion status.
