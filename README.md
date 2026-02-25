# RAKBANK Copilot Starter Template — Backend SDLC

> **AI-powered SDLC starter for Java/Spring Boot backend projects.**
> Clone this template → fill in your project specifics → Copilot works for your domain from day one.

---

## What This Template Gives You

| Capability | What it does | Works out of the box? |
|---|---|---|
| **Copilot Instructions** | Coding standards Copilot follows in every suggestion | ✅ Yes — Java/Spring Boot defaults |
| **Auto-Instructions** | File-type-specific rules (coding, security, testing, review) | 🔧 Fill in your domain rules |
| **Skills** | Context mapping, refactor planning, context-needed analysis | ✅ Yes |
| **Agents** | `@context-architect`, `@story-analyzer`, `@coding-agent`, `@instinct-extractor` | ✅ Yes |
| **Hooks** | Session logging for AI usage tracking | ✅ Yes |
| **Domain Context** | Business terminology, rules, technology conventions | 🔧 Fill in your domain |
| **Solution Design** | Architecture, personas, business rules, integrations | 🔧 Fill in your project |
| **MCP Config** | ADO + GitHub MCP server definitions | ✅ Yes — just add tokens |
| **AI Usage Tracking** | Audit trail of what AI generated per story | ✅ Yes |

---

## Quick Start

### 1. Create your repo from this template
DevOps creates a new repo from `rakbank-internal/copilot-template` via the repo creation workflow.

### 2. Fill in your project specifics
Every file marked with `<!-- TODO: -->` needs your input:

| File | What to fill in |
|---|---|
| `contexts/banking.md` | Your domain terminology, rules, personas (rename to match your domain) |
| `contexts/flowable-bpmn.md` | Technology-specific conventions (rename or delete if not needed) |
| `docs/solution-design/*.md` | Your architecture, personas, business rules, integrations |
| `.github/instructions/*.instructions.md` | Your domain-specific coding, security, testing, review rules |
| `prompts/*.md` | Your project-specific one-shot prompts (optional) |

### 3. Set up MCP secrets
See `mcp-configs/` — add your ADO and GitHub tokens as environment variables.

### 4. Start using Copilot
Skills and agents work immediately. Open Copilot Chat and try:
- `@context-architect plan the changes for [feature]`
- `@story-analyzer` with an ADO story ID to generate a GitHub Issue
- `@coding-agent` with a GitHub Issue to implement it end-to-end
- `@instinct-extractor` after a PR merge to capture learned patterns
- Use the `context-map` skill to map files before any change

---

## Repository Structure

```
.github/
├── copilot-instructions.md                    ← Java/Spring Boot coding standards (generic)
├── copilot/agents/
│   ├── context-architect.md                   ← Multi-file change planning agent
│   ├── story-analyzer.md                      ← ADO story → GitHub Issue agent
│   ├── coding-agent.md                        ← Issue → working code agent
│   └── instinct-extractor.md                  ← PR → learned patterns agent
├── skills/                                    ← Auto-activated in Copilot Chat
│   ├── context-map/SKILL.md                   ← Maps files before changes
│   ├── refactor-plan/SKILL.md                 ← Plans multi-file refactors
│   └── what-context-needed/SKILL.md           ← Lists files needed to answer a question
├── instructions/                              ← Auto-applied per file type
│   ├── coding.instructions.md                 ← Coding rules (FILL IN your domain)
│   ├── security.instructions.md               ← Security rules (FILL IN your PII/roles)
│   ├── testing.instructions.md                ← Testing rules (FILL IN your coverage targets)
│   ├── review.instructions.md                 ← PR review rules (FILL IN your invariants)
│   └── examples/                              ← Mortgage IPA reference implementation
├── hooks/session-logger/                      ← Copilot session audit logging
├── workflows/                                 ← CI/CD and agent workflows

.vscode/
├── settings.json                              ← Enables Copilot skills

contexts/                                      ← Domain knowledge for Copilot
├── banking.md                                 ← Domain context skeleton (FILL IN)
├── flowable-bpmn.md                           ← Technology context skeleton (FILL IN)
└── examples/                                  ← Mortgage IPA reference

docs/
├── solution-design/                           ← Architecture decisions (FILL IN)
│   ├── architecture-overview.md
│   ├── user-personas.md
│   ├── business-rules.md
│   ├── bpmn-processes.md
│   ├── integration-map.md
│   └── examples/                              ← Mortgage IPA reference
├── ai-usage/                                  ← Auto-populated per story

prompts/                                       ← Project-specific one-shot prompts
├── README.md                                  ← Guide for adding custom prompts
└── examples/                                  ← Mortgage IPA reference

mcp-configs/                                   ← MCP server definitions
├── agent-pipeline.json                        ← ADO + GitHub (uses env vars)
```

---

## Examples

Every `examples/` folder contains a **complete Mortgage IPA reference implementation** — a real banking project that shows how each file should look when filled in. Use these as your guide:

| Folder | What's inside |
|---|---|
| `.github/instructions/examples/` | Coding, security, testing, review instructions for Mortgage IPA |
| `contexts/examples/` | Banking domain context, Flowable BPMN conventions |
| `docs/solution-design/examples/` | Full architecture, personas, business rules, integrations, BPMN |
| `prompts/examples/` | Story analyzer, coding agent, instinct extractor, application-service — all Mortgage IPA specific |

---

## File Classification

| Label | Meaning |
|---|---|
| ✅ **COPY AS-IS** | Template provides it; works immediately, no modification needed |
| 🔧 **FILL IN** | Template provides the skeleton with TODO markers; team fills in their specifics |
| 📁 **LEAVE EMPTY** | Directory scaffolded; auto-populated at runtime by agents or workflows |

---

## Contributing
See `templateFoundation.md` for the template's living spec and promotion status of each pattern.