# RAKBANK Copilot Template — Foundation

> **Status:** Living document. Updated as new patterns are validated in this lab repo.
> **Goal:** Extract into `rakbank-internal/copilot-template` — the standard AI-SDLC starter for all RAKBANK projects.

---

## Strategic Context

This repository is the **lab** where Copilot patterns, skills, agents, and workflows are discovered and validated.
Once stable, each pattern is promoted to the template repository and distributed to new projects via:

| Distribution Method | How it works | Best for |
|---|---|---|
| **GitHub Template Repo** | DevOps creates new repo from `rakbank-internal/copilot-template` — all files copied in | New greenfield projects |
| **Plugin Installer** | `plugins/install-workflow.sh local\|remote\|all` installs agents, hooks, and skills into any existing repo | Existing projects — developer chooses workflow |
| **Both** | Template gives the full repo structure; plugin installer adds workflow to existing repos on top | Ideal long-term end state |

---

## Dual Workflow Architecture

This template supports **two parallel development workflows**. Developers choose one per story.
Both workflows share the same agents, instincts, and skills — they differ only in execution path.

### Remote Workflow (existing — GitHub Actions + Copilot Workspace)
```
@story-analyzer ADO-456
  → GitHub Issue created (structured spec)
    → Agent 2 (GH Actions) → Copilot Workspace → Draft PR
      → Agent 3 (GH Actions) → AI Review on PR
        → Human Gate (review + merge)
          → Agent 5 (GH Actions) → Instinct extraction on merge
            → Agent 6 (GH Actions) → ADO story → Done
```
**Trigger:** `@story-analyzer` in Copilot Chat
**Output:** GitHub Issue → PR → merged code
**Learning:** Automatic after PR merge (Agent 5)
**AI Usage:** Auto-logged to `docs/ai-usage/` on git commit via post-commit hook

### Local Workflow (new — fully in VS Code)
```
@task-planner ADO-456
  → taskPlan/ADO-456-{service}.md created (structured spec)
    → @local-rakbank-dev-agent taskPlan/ADO-456-{service}.md
      → Code scaffolded locally in VS Code
        → @local-reviewer
          → Pitfalls flagged → developer addresses via prompts
            → @local-instinct-learner (optional — explicit pattern capture)
              → git commit
                → post-commit hook → docs/ai-usage/{sprint}/ADO-456.md auto-created
```
**Trigger:** `@task-planner` in Copilot Chat
**Output:** Local task plan file → code in VS Code editor
**Learning:** Explicit (`@local-instinct-learner`) — developer-driven
**AI Usage:** Auto-logged to `docs/ai-usage/` on git commit via post-commit hook

### Shared Infrastructure (used by both)
- `.copilot/instincts/` — instinct library (built by both workflows)
- `.github/skills/` — promoted skills (consumed by both coding agents)
- `docs/ai-usage/` — auto-populated by post-commit git hook (both workflows)
- `logs/copilot/` — session + prompt logs (both workflows)

---

## File Classification

| Label | Meaning |
|---|---|
| `COPY AS-IS` | Template provides it; project teams do not modify |
| `FILL IN` | Template provides the skeleton; team populates with their project specifics |
| `LEAVE EMPTY` | Directory scaffolded; auto-populated at runtime by agents or workflows |
| `CREATE` | Not provided by template; project team creates from scratch for their domain |

---

## Template Repository Structure

```
{project-repo}/
|
+-- .github/                                  <- Single source of truth for all Copilot config
|   +-- copilot-instructions.md               <- FILL IN: stack, domain, personas, coding rules
|   +-- copilot/
|   |   +-- agents/
|   |       +-- context-architect.md          <- COPY AS-IS | @context-architect in Copilot Chat              [SHARED]
|   |       +-- story-analyzer.md             <- COPY AS-IS | @story-analyzer — ADO story → GitHub Issue     [REMOTE WORKFLOW]
|   |       +-- rakbank-backend-dev-agent.md  <- COPY AS-IS | @rakbank-backend-dev-agent — Issue → working code           [REMOTE WORKFLOW]
|   |       +-- instinct-extractor.md         <- COPY AS-IS | @instinct-extractor — PR → patterns            [REMOTE WORKFLOW]
|   |       +-- task-planner.md               <- COPY AS-IS | @task-planner — ADO/desc → local task plan     [LOCAL WORKFLOW]
|   |       +-- local-rakbank-dev-agent.md   <- COPY AS-IS | @local-rakbank-dev-agent — task plan → VS Code      [LOCAL WORKFLOW]
|   |       +-- local-reviewer.md             <- COPY AS-IS | @local-reviewer — structured pre-commit review [LOCAL WORKFLOW]
|   |       +-- local-instinct-learner.md     <- COPY AS-IS | @local-instinct-learner — explicit learning    [LOCAL WORKFLOW]
|   +-- hooks/
|   |   +-- session-logger/                   <- Copilot VS Code hooks (prompt + session tracking)
|   |   |   +-- hooks.json                    <- COPY AS-IS | sessionStart / sessionEnd / userPromptSubmitted
|   |   |   +-- log-session-start.sh          <- COPY AS-IS
|   |   |   +-- log-session-end.sh            <- COPY AS-IS
|   |   |   +-- log-prompt.sh                 <- COPY AS-IS
|   |   +-- git/                              <- Standard git hooks (via core.hooksPath)
|   |       +-- post-commit                   <- COPY AS-IS | auto-writes docs/ai-usage/ on ADO commits
|   +-- skills/                               <- VS Code Agent Skills (chat.useAgentSkills=true)
|   |   +-- context-map/SKILL.md              <- COPY AS-IS | auto: maps files before any change
|   |   +-- what-context-needed/SKILL.md      <- COPY AS-IS | auto: lists files needed to answer
|   |   +-- refactor-plan/SKILL.md            <- COPY AS-IS | auto: phased plan before refactor
|   |   +-- {project-skill}/SKILL.md          <- CREATE: e.g. flowable-bpmn/, aws-s3/
|   +-- instructions/                         <- Auto-applied to every Copilot interaction
|   |   +-- coding-instructions.md            <- COPY base + FILL IN project rules
|   |   +-- security-instructions.md          <- COPY base + FILL IN project rules
|   |   +-- testing-instructions.md           <- COPY base + FILL IN project rules
|   +-- workflows/
|       +-- agent2-rakbank-backend-dev-agent.yml           <- COPY AS-IS
|       +-- agent3-ai-review.yml              <- COPY AS-IS
|       +-- agent5-learning.yml               <- COPY AS-IS
|       +-- agent6-ado-sync.yml               <- COPY AS-IS
|
+-- .vscode/
|   +-- settings.json                         <- COPY AS-IS | enforces chat.useAgentSkills=true
|
+-- contexts/                                 <- Domain knowledge injected into Copilot context
|   +-- domain.md                             <- FILL IN: business terminology, rules, acronyms
|   +-- {tech-context}.md                     <- FILL IN: e.g. flowable-bpmn.md, kafka.md
|
+-- docs/
|   +-- solution-design/
|   |   +-- architecture-overview.md          <- FILL IN: service map, tech decisions, ADRs
|   |   +-- user-personas.md                  <- FILL IN: who uses this, roles, access rules
|   |   +-- business-rules.md                 <- FILL IN: policy rules from business
|   |   +-- data-model.md                     <- FILL IN: entities, relationships, constraints
|   |   +-- integration-map.md                <- FILL IN: external systems, contracts, status
|   +-- ai-usage/                             <- LEAVE EMPTY: auto-populated by post-commit hook
|       +-- {release-branch}/
|           +-- {TICKET-ID}.md               <- Auto-created: metrics, workflow type, files changed
|
+-- taskPlan/                                 <- LEAVE EMPTY: populated by @task-planner [LOCAL WORKFLOW]
|   +-- {TICKET-ID}-{service}.md              <- Auto-created: full spec consumed by @local-rakbank-dev-agent
|
+-- mcp-configs/
|   +-- agent-pipeline.json                   <- COPY AS-IS: ADO + GitHub MCP tool definitions
|   +-- README.md                             <- COPY AS-IS: secrets setup instructions
|
+-- prompts/
|   +-- README.md                             <- COPY AS-IS: guide for adding project prompts
|   +-- examples/                             <- Reference: Mortgage IPA prompt examples
|
+-- plugins/
|   +-- install-workflow.sh                   <- COPY AS-IS: installs local/remote/all into any repo
|   +-- README.md                             <- COPY AS-IS: usage instructions
|
+-- .gitignore                                <- COPY AS-IS
+-- CHANGELOG.md                              <- COPY AS-IS (auto-updated by release agent)
+-- CODE_OF_CONDUCT.md                        <- COPY AS-IS
+-- CONTRIBUTING.md                           <- COPY AS-IS
+-- README.md                                 <- FILL IN: project name, badges, setup guide
+-- SECURITY.md                               <- COPY AS-IS
```

---

## How a New Project Uses This Template

1. **DevOps creates repo** from `rakbank-internal/copilot-template` via the repo creation workflow
2. **Team fills in** the `FILL IN` files:
   - `.github/copilot-instructions.md` — their stack, domain rules, coding standards
   - `contexts/domain.md` — their business glossary and terminology
   - `docs/solution-design/*.md` — their architecture, personas, business rules
3. **Team creates** any `CREATE` items for their domain (e.g. `.github/skills/flowable-bpmn/SKILL.md`)
4. **Skills and agents activate immediately** — `context-map`, `what-context-needed`, `refactor-plan` skills + `@story-analyzer`, `@rakbank-backend-dev-agent`, `@instinct-extractor`, `@context-architect` agents work out of the box
5. **Agents auto-populate** `docs/ai-usage/` over time as the team works with Copilot

---

## Patterns Validated in This Lab

Update this table as each pattern is confirmed working and ready to promote to the template repo.

| Pattern | Status | Location in template | Workflow |
|---|---|---|---|
| Copilot instructions (Java / Spring Boot) | ✅ Ready | `.github/copilot-instructions.md` | Both |
| Context Engineering skills | ✅ Ready | `.github/skills/` | Both |
| Context Architect agent | ✅ Ready | `.github/copilot/agents/context-architect.md` | Both |
| MCP pipeline config | ✅ Ready | `mcp-configs/agent-pipeline.json` | Both |
| Session logging hooks (Copilot VS Code) | ✅ Ready | `.github/hooks/session-logger/` | Both |
| Git post-commit AI usage hook | ✅ Ready | `.github/hooks/git/post-commit` | Both |
| Plugin installer | ✅ Ready | `plugins/install-workflow.sh` | Both |
| .vscode/settings.json enforcement | ✅ Ready | `.vscode/settings.json` | Both |
| Auto-instructions (coding / security / testing / review) | ✅ Ready (skeletons) | `.github/instructions/` | Both |
| SDLC agents — Remote workflow | ✅ Ready | `.github/copilot/agents/story-analyzer.md` etc | Remote |
| SDLC agents — Local workflow | ✅ Ready | `.github/copilot/agents/task-planner.md` etc | Local |
| Task plan folder | ✅ Ready | `taskPlan/` | Local |
| Domain context files | ✅ Ready (skeletons) | `contexts/` | Both |
| Solution design docs | ✅ Ready (skeletons) | `docs/solution-design/` | Both |
| AI-usage auto-docs (post-commit hook) | ✅ Ready | `docs/ai-usage/` | Both |
| Mortgage IPA examples | ✅ Ready (reference) | `*/examples/` folders | Both |
| Template README with quick-start | ✅ Ready | `README.md` | Both |
| CI/CD workflows | ✅ Ready | `.github/workflows/` | Remote |

---


