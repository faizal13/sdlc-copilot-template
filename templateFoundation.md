# RAKBANK Copilot Template — Foundation

> **Status:** Living document. Updated as new patterns are validated in this lab repo.
> **Goal:** Extract into `rakbank-internal/copilot-template` — the standard AI-SDLC starter for all RAKBANK projects.

---

## Strategic Context

This repository is the **lab** where Copilot patterns, skills, agents, and workflows are discovered and validated.
Once stable, each pattern is promoted to the template repository and distributed to new projects via:

| Distribution Method | How it works | Best for |
|---|---|---|
| **GitHub Template Repo** | DevOps creates new repo from `rakbank-internal/copilot-template` via repo creation workflow — all files copied in | New greenfield projects |
| **Copilot Plugin** | Plugin installed per developer; skills and agents available in any repo they work in | Cross-project reuse of skills and agents |
| **Both** | Template gives the repo structure; plugin adds org-wide skills on top | Ideal long-term end state |

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
|   |       +-- context-architect.md          <- COPY AS-IS | @context-architect in Copilot Chat
|   |       +-- story-analyzer.md             <- COPY AS-IS | @story-analyzer — ADO story → GitHub Issue
|   |       +-- coding-agent.md               <- COPY AS-IS | @coding-agent — Issue → working code
|   |       +-- instinct-extractor.md         <- COPY AS-IS | @instinct-extractor — PR → patterns
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
|       +-- agent2-coding-agent.yml           <- COPY AS-IS
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
|   +-- ai-usage/                             <- LEAVE EMPTY: auto-populated per story by agents
|
+-- mcp-configs/
|   +-- agent-pipeline.json                   <- COPY AS-IS: ADO + GitHub MCP tool definitions
|   +-- README.md                             <- COPY AS-IS: secrets setup instructions
|
+-- prompts/
|   +-- README.md                             <- COPY AS-IS: guide for adding project prompts
|   +-- examples/                             <- Reference: Mortgage IPA prompt examples
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
4. **Skills and agents activate immediately** — `context-map`, `what-context-needed`, `refactor-plan` skills + `@story-analyzer`, `@coding-agent`, `@instinct-extractor`, `@context-architect` agents work out of the box
5. **Agents auto-populate** `docs/ai-usage/` over time as the team works with Copilot

---

## Patterns Validated in This Lab

Update this table as each pattern is confirmed working and ready to promote to the template repo.

| Pattern | Status | Location in template |
|---|---|---|
| Copilot instructions (Java / Spring Boot) | ✅ Ready | `.github/copilot-instructions.md` |
| Context Engineering skills | ✅ Ready | `.github/skills/` |
| Context Architect agent | ✅ Ready | `.github/copilot/agents/context-architect.md` |
| MCP pipeline config | ✅ Ready | `mcp-configs/agent-pipeline.json` |
| Session logging hooks | ✅ Ready | `.github/hooks/session-logger/` |
| .vscode/settings.json enforcement | ✅ Ready | `.vscode/settings.json` |
| Auto-instructions (coding / security / testing / review) | ✅ Ready (skeletons) | `.github/instructions/` |
| SDLC agents (story-analyzer / coding-agent / instinct-extractor) | ✅ Ready | `.github/copilot/agents/` |
| Domain context files | ✅ Ready (skeletons) | `contexts/` |
| Solution design docs | ✅ Ready (skeletons) | `docs/solution-design/` |
| AI-usage auto-docs | ✅ Ready (skeleton) | `docs/ai-usage/` |
| Mortgage IPA examples | ✅ Ready (reference) | `*/examples/` folders |
| Template README with quick-start | ✅ Ready | `README.md` |
| CI/CD workflows | ✅ Ready | `.github/workflows/` |

---


