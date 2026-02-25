---
agent: ask
description: 'Resume building the RAKBANK Copilot template repository. Loads full context of what has been built, what is in progress, and what is planned next.'
---

# Resume: RAKBANK Copilot Template Builder

You are helping build `rakbank-internal/copilot-template` — a GitHub Template Repository that gives every RAKBANK project a standardised AI-powered SDLC from day one.

## What This Lab Repo Is

This repository (`platform-backend-copilot-template`) is the **discovery lab**. Every Copilot feature is explored and validated here first, then promoted to the template repo.

Read `templateFoundation.md` now — it is the live spec for the template structure, file classifications, and pattern promotion status.

## The Goal

When complete, a new RAKBANK project gets everything below on day one, with zero manual setup beyond filling in their domain:

- **Copilot instructions** tuned to their stack and coding standards
- **Skills** that auto-trigger context mapping, dependency tracing, and refactor planning
- **Agents** for context-aware multi-file changes
- **Instructions** auto-applied on every Copilot interaction (coding, security, testing rules)
- **SDLC prompts** for story analysis, coding agent bootstrap, and instinct extraction
- **MCP configs** wired to ADO and GitHub for autonomous agent pipelines
- **Domain context files** ready to be filled in with business terminology and architecture

## Distribution Strategy

| Method | Mechanism | When used |
|---|---|---|
| GitHub Template Repo | DevOps repo creation workflow copies all files | New greenfield projects |
| Copilot Plugin (`copilot plugin install rakbank@rakbank-internal`) | Skills and agents available in any repo per developer | Cross-project / existing projects |
| Both | Template for structure + plugin for org-wide skills | Ideal end state |

## What Has Been Built (Ready to Promote)

| Pattern | File(s) | Notes |
|---|---|---|
| Copilot instructions (Java / Spring Boot) | `.github/copilot-instructions.md` | Naming, Modern Java, Code Quality, Spring Boot, Performance, OWASP |
| Context Engineering skills | `.github/skills/context-map/`, `what-context-needed/`, `refactor-plan/` | Auto-triggered via `chat.useAgentSkills=true` |
| Context Architect agent | `.github/copilot/agents/context-architect.md` | `@context-architect` in chat |
| MCP pipeline config | `mcp-configs/agent-pipeline.json` | ADO + GitHub MCPs |
| VS Code settings enforcement | `.vscode/settings.json` | Enforces `chat.useAgentSkills=true` |

## What Is In Progress

| Pattern | File(s) | What's needed |
|---|---|---|
| Banking domain context | `contexts/banking.md` | Complete with RAKBANK-specific terminology, mortgage domain rules |
| Flowable BPMN context | `contexts/flowable-bpmn.md` | Complete with process patterns, service task conventions |
| SDLC prompts | `prompts/story-analyzer.md`, `coding-agent-bootstrap.md`, `instinct-extractor.md` | Review and generalise for template (currently mortgage-specific) |

## What Is Planned Next

| Pattern | Location | Description |
|---|---|---|
| Auto-instructions | `.github/instructions/coding-instructions.md` | Base coding rules auto-applied to every interaction, with `applyTo: '**/*.java'` |
| Auto-instructions | `.github/instructions/security-instructions.md` | OWASP rules auto-applied to Java files |
| Auto-instructions | `.github/instructions/testing-instructions.md` | Test standards auto-applied to test files |
| Project-specific skills | `.github/skills/{domain}/SKILL.md` | e.g. flowable-bpmn skill for teams using Flowable |
| AI-usage auto-docs | `docs/ai-usage/` | Auto-populated by agents per story |

## Key Design Decisions Made

- **`.github/` is the single source of truth** — no `.copilot/` folder; everything lives in `.github/` which is the GitHub and VS Code Copilot standard
- **Skills live at `.github/skills/<name>/SKILL.md`** — VS Code discovers them when `chat.useAgentSkills=true`; the `description` field in the SKILL.md frontmatter is the auto-trigger
- **Agents live at `.github/copilot/agents/<name>.md`** — invoked via `@agent-name` in Copilot Chat
- **Instructions live at `.github/instructions/*.instructions.md`** — auto-applied based on `applyTo` glob pattern; no user action needed
- **Prompts live at `.github/prompts/*.prompt.md`** — manual `/command` invocation in Copilot Chat
- **`copilot-instructions.md` is global** — always loaded; keep it for org-wide rules, not project specifics

## File Classification Reference

| Label | Meaning |
|---|---|
| `COPY AS-IS` | Template provides it; teams do not modify |
| `FILL IN` | Template provides skeleton; team populates with their specifics |
| `LEAVE EMPTY` | Auto-populated at runtime by agents or workflows |
| `CREATE` | Not in template; team creates for their domain |

## How to Continue in This Session

1. Read `templateFoundation.md` for the current full structure and pattern status
2. Read `.github/copilot-instructions.md` to see what's already in the global instructions
3. Read `.github/skills/` to see which skills exist
4. Ask me what you want to add, improve, or validate next
5. When a pattern is confirmed working, update the **Patterns Validated** table in `templateFoundation.md` and set status to `Ready`

## Useful Commands

- `/template-builder-resume` — run this prompt to reload context in a new session
- `/context-map` — map files before making changes
- `/refactor-plan` — plan a multi-file change before executing
- `@context-architect` — get a full context map and dependency trace for any task
