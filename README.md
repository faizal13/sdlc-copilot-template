# SDLC Copilot Template

> **AI-powered SDLC workflow for Java/Spring Boot backend projects.**
> Structured agents that take you from ADO Epic → execution plan → task plans → production-ready code.

---

## What You Get

| Component | What it does |
|-----------|-------------|
| **14 Agents** | `@story-refiner`, `@sprint-orchestrator`, `@task-planner`, `@local-rakbank-dev-agent`, `@local-reviewer`, `@local-instinct-learner`, `@story-analyzer`, `@rakbank-backend-dev-agent`, `@eval-runner`, `@telemetry-collector`, `@instinct-extractor`, `@address-comments`, `@tech-debt-planner`, `@context-architect` |
| **4 Skills** | Auto-activated in Copilot Chat: context-map, what-context-needed, refactor-plan, instinct-lookup |
| **6 Instructions** | Auto-applied to every Copilot interaction: coding, security, testing, review, cross-service, mcp-tools |
| **Hooks** | Session logger + git post-commit AI usage tracker |
| **Runtime dirs** | `taskPlan/`, `sprintPlan/`, `docs/epic-plans/`, `docs/agent-telemetry/`, `evals/`, `.copilot/instincts/` |

---

## The Development Flow

```
ADO Epic
  └── @story-refiner EPIC-001
        Reads all features + stories from ADO
        Produces: docs/epic-plans/EPIC-001-execution-plan.md
        (dependency graph, phased execution plan, gap report)

@sprint-orchestrator EPIC-001
  Reads the execution plan + checks ADO story status
  Produces: sprintPlan/EPIC-001-sprint-status.md
  (which stories are READY, which are BLOCKED, parallel commands)

@task-planner STORY-456
  Reads the ADO story + cross-references solution design
  Produces: taskPlan/STORY-456-service-name.md
  (data model, API changes, test cases, DoD, exact class names)

@local-rakbank-dev-agent taskPlan/STORY-456-service-name.md
  Reads the task plan
  Produces: working code + Liquibase migrations + unit + integration tests
  Runs: mvn clean verify

@local-reviewer
  Reviews the PR diff against solution design + instincts

@local-instinct-learner
  Captures learnings from the merged PR into .copilot/instincts/
```

---

## Setup Guide

### Prerequisites

- **VS Code** with **GitHub Copilot** extension (Copilot Business or Enterprise)
- **Agent Mode** enabled in VS Code: `chat.agent.enabled: true`
- **bash** — macOS, Linux, or git bash on Windows
- **MCP servers** configured for Azure DevOps and GitHub (see Step 3)

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
- **Local** — You write code in VS Code with Copilot agents. All 14 agents work locally. Start here.
- **Hybrid** — Same as local + GitHub Actions pipeline for automated coding/review/ADO-sync. Add this later when ready.

**Which target to choose:**
- **Single folder** — One microservice project. Most common.
- **Workspace** — Multi-service setup (e.g. orchestrator + notification + BFF). Creates a `.code-workspace` file and links all services.

What gets installed for **Local + Single folder**:
```
.github/agents/              ← 14 agents as *.agent.md
.github/instructions/        ← 6 auto-instructions + examples
.github/skills/              ← 4 skills
.github/hooks/               ← session-logger + git post-commit
.copilot/instincts/          ← INDEX.json (grows as agents learn)
.checkpoints/                ← agent recovery checkpoints
contexts/                    ← README (you add domain knowledge here)
docs/solution-design/        ← README (you add architecture here)
docs/epic-plans/             ← @story-refiner writes here
docs/agent-telemetry/        ← agents append metrics here
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

> **Reference:** See `docs/solution-design/examples/` (Mortgage IPA) for a complete example of every file.

---

### Step 3 — Configure MCP servers

Agents connect to Azure DevOps and GitHub via MCP. Configure them in VS Code:

Open VS Code → `Cmd+Shift+P` → **Preferences: Open User Settings (JSON)** → add:

```json
{
  "mcp": {
    "servers": {
      "azure-devops": {
        "command": "npx",
        "args": ["-y", "@tiberriver256/mcp-server-azure-devops"],
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

**Getting tokens:**
- **ADO PAT**: ADO → User Settings → Personal Access Tokens → New Token (scopes: Work Items Read/Write, Code Read)
- **GitHub PAT**: GitHub → Settings → Developer settings → Personal access tokens → Classic (scopes: `repo`, `issues`)

**Verify MCP is working:** Open Copilot Chat in VS Code → click the tools icon → you should see `azure-devops` and `github` listed.

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

Open Copilot Chat → type `@` → you should see all 14 agents in the dropdown:

```
@address-comments
@context-architect
@eval-runner
@instinct-extractor
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
→ Reads your entire epic tree from ADO, produces `docs/epic-plans/EPIC-001-execution-plan.md`

```
@sprint-orchestrator EPIC-001
```
→ Reads the execution plan, checks ADO story statuses, produces `sprintPlan/EPIC-001-sprint-status.md`

Open `sprintPlan/EPIC-001-sprint-status.md` to see:
- Which stories are ✅ DONE, 🟢 READY, 🔴 BLOCKED
- Which can run in parallel (different services)
- Exact commands to run next

### Story Implementation

```
@task-planner STORY-456
```
→ Reads the ADO story, cross-references solution design, produces `taskPlan/STORY-456-service-name.md`

```
@local-rakbank-dev-agent taskPlan/STORY-456-service-name.md
```
→ Reads the task plan, builds in order: migration → entity → repository → service → controller → tests

### After Implementation

```
@local-reviewer
```
→ Structured review of your diff against architecture + instincts

```
@local-instinct-learner "the team prefers X pattern over Y because Z"
```
→ Captures the learning into `.copilot/instincts/` for future agents to apply

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
| Agent writes to chat instead of creating file | Ensure `edit/editFiles` is in agent frontmatter `tools:` |
| MCP not connected | Check VS Code settings → MCP servers → verify tokens are correct |
| `@story-refiner` can't read ADO | Verify ADO PAT has Work Items Read scope + correct org URL |
| `@task-planner` stops on empty story | Add Acceptance Criteria to the ADO story first |
| `mvn verify` fails after coding agent | Check `docs/agent-telemetry/current-sprint.md` for error details |

---

## Repository Structure

```
.github/
├── agents/                    ← 14 agents as *.agent.md (VS Code reads here)
├── instructions/              ← Auto-applied to every Copilot interaction
│   └── examples/              ← Mortgage IPA reference implementations
├── skills/                    ← Auto-activated context helpers (4 skills)
├── hooks/
│   ├── session-logger/        ← Copilot session + prompt tracking
│   └── git/post-commit        ← AI usage auto-logger on ADO commits

.copilot/instincts/            ← INDEX.json + learned pattern files
.checkpoints/                  ← Agent phase recovery (gitignored)

contexts/                      ← YOUR domain knowledge (you create this)
docs/
├── solution-design/           ← YOUR architecture docs (you create these)
├── epic-plans/                ← @story-refiner execution plans
├── agent-telemetry/           ← Live agent telemetry log
├── ai-usage/                  ← Per-story AI usage audit trail
└── issues/                    ← @story-analyzer local fallback drafts

evals/
├── scoring-rubric.md          ← @eval-runner quality criteria
├── sprint-tracker.md          ← Sprint quality scores
└── golden-references/         ← Reference outputs for comparison

taskPlan/                      ← @task-planner writes task specs here
sprintPlan/                    ← @sprint-orchestrator writes status here
logs/copilot/                  ← Session logger output (gitignored)

plugins/                       ← Template installer (run once per project)
├── install.sh                 ← Interactive installer
├── bootstrap.sh               ← Clone + install in one command
└── workspace-init.sh          ← Quick workspace init
```

---

## Contributing

See `templateFoundation.md` for the template's living spec and pattern promotion status.
