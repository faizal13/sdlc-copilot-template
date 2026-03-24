---
name: instinct-lookup
description: 'Search and retrieve relevant development instincts/patterns by category (coding, testing, security, integration, domain) or keyword. Use when implementing features, middleware integrations, or fixing bugs to check for established team patterns before writing code. Auto-activates before any implementation.'
argument-hint: '<category or keyword — e.g. integration, testing, BigDecimal, middleware, error handling>'
---

# Instinct Lookup

Search the team's institutional memory for established patterns before implementing.

## When This Activates

This skill activates when:
- Someone asks "what patterns exist for..."
- An agent needs to check existing conventions
- Before implementing a feature that might have an established pattern

## Instructions

1. List all instinct files in `.copilot/instincts/`
2. Filter by category if specified (coding, testing, security, integration, domain)
3. Filter by keyword if specified (search `name` and `description` fields)
4. Return matching instincts with their confidence scores
5. Instincts with `confidence >= 0.85` should be treated as established standards
6. Instincts with `confidence < 0.85` should be treated as suggestions

## Output Format

```markdown
## Matching Instincts

### Established Patterns (confidence >= 0.85)
| Pattern | Category | Confidence | Description |
|---------|----------|------------|-------------|
| {name} | {category} | {score} | {description} |

### Suggested Patterns (confidence < 0.85)
| Pattern | Category | Confidence | Description |
|---------|----------|------------|-------------|
| {name} | {category} | {score} | {description} |

### No Match
If no instincts match: "No established patterns found for this area. Proceed with standard conventions from copilot-instructions.md."
```
