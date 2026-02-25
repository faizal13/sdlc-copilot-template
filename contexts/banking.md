# Domain Context — [Your Project Name]
#
# PURPOSE: Load this file at the start of any Copilot Chat session.
# It gives Copilot the domain vocabulary and hard rules for your project.
#
# HOW TO FILL IN:
# 1. Replace [placeholders] with your project specifics
# 2. Add every domain term your team uses — Copilot will adopt them in its suggestions
# 3. List critical code generation rules so Copilot never generates code that violates them
# 4. See contexts/examples/banking.md for a complete real-world example
# ──────────────────────────────────────────────────────────────────────────────

## Domain
<!-- TODO: One-line description of your domain and any regulatory context -->

## Key Terminology
<!-- TODO: Define every domain term, acronym, and concept your team uses -->
<!-- Format: **TERM** — Definition. One line each. -->
- **TERM_1** — Definition
- **TERM_2** — Definition

## User Personas (summary)
<!-- TODO: List every user role and their data visibility scope -->
<!-- Full definitions in docs/solution-design/user-personas.md -->
- **ROLE_1** — What they can see and do
- **ROLE_2** — What they can see and do

## Critical Rules for Code Generation
<!-- TODO: List hard rules Copilot must always follow when generating code -->
<!-- These are the rules that, if violated, would cause a bug, security issue, or compliance failure -->
- <!-- e.g. Never double or float for financial calculations — always BigDecimal -->
- <!-- e.g. PII fields (list them) must never appear in application logs -->
- <!-- e.g. Every business rule must have a comment: // Rule: [name] - business-rules.md -->
- <!-- e.g. Thresholds must never be hardcoded — always externalized to Spring config -->
