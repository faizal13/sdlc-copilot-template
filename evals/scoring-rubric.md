# Agent Evaluation — Scoring Rubric

Use this rubric when evaluating any agent's output. Score each dimension 0.0–1.0.

---

## Dimension 1: Completeness (0.0–1.0)

*Did the agent produce ALL required sections and cover the full scope?*

| Score | Criteria |
|-------|----------|
| **1.0** | Every section in the output template is present and populated. No required field is empty or skipped. |
| **0.8** | All critical sections present. 1-2 optional sections missing or sparse. |
| **0.6** | Most sections present. 1-2 critical sections missing or marked "TBD" without justification. |
| **0.4** | Multiple critical sections missing. Output feels incomplete. |
| **0.2** | Majority of expected content is absent. |
| **0.0** | Agent produced no meaningful output or stopped prematurely. |

### What counts as "critical" per agent:
- **@story-analyzer:** AC table, data model, API changes, coding agent instructions
- **@task-planner:** AC table, data model, context manifest, reuse instructions
- **@local-reviewer:** Mechanical verification results, AC coverage check, verdict
- **@story-refiner:** Dependency graph, execution phases, gap report

---

## Dimension 2: Precision (0.0–1.0)

*Is the output specific and concrete — not vague or generic?*

| Score | Criteria |
|-------|----------|
| **1.0** | Every field contains specific values: exact class names, exact API paths, exact field types, exact test method names. No placeholders or generic language. |
| **0.8** | Mostly specific. 1-2 fields use phrases like "appropriate type" or "relevant fields" instead of exact values. |
| **0.6** | Mix of specific and vague. Some sections read like templates rather than story-specific analysis. |
| **0.4** | Predominantly generic. Could apply to any story — not clearly tailored to THIS story. |
| **0.2** | Almost entirely generic boilerplate. |
| **0.0** | No story-specific content at all. |

### Red flags for low precision:
- "Add appropriate validation" (instead of listing exact validation rules)
- "Handle errors appropriately" (instead of listing exact error codes)
- "Create necessary entities" (instead of naming entities and fields)
- "{TBD}" appearing without an explanation of what's missing

---

## Dimension 3: Standards Compliance (0.0–1.0)

*Does the output follow RAKBANK banking, coding, security, and testing standards?*

| Score | Criteria |
|-------|----------|
| **1.0** | All banking rules enforced: BigDecimal for money, persona isolation documented, state machine validated, PII masking noted, Liquibase conventions correct. |
| **0.8** | All critical standards followed. 1-2 minor style deviations. |
| **0.6** | Most standards followed. 1 critical standard missed (e.g., no persona isolation check, float used for money). |
| **0.4** | Multiple standard violations. Agent appears unaware of banking-specific rules. |
| **0.2** | Widespread non-compliance. |
| **0.0** | No evidence of standards awareness. |

### Critical standards to check:
- BigDecimal for all monetary fields (never double/float)
- Persona access rules documented per endpoint
- State transitions validated against solution design
- TBD integrations flagged as stub-only
- Liquibase naming convention followed
- Constructor injection (not field injection)
- Test method naming: `should{Expected}When{Condition}`

---

## Dimension 4: Actionability (0.0–1.0)

*Can the downstream agent/developer act on this output without asking questions?*

| Score | Criteria |
|-------|----------|
| **1.0** | A coding agent could implement directly from this output. Zero ambiguity. Build order is clear. All dependencies listed. All contracts defined. |
| **0.8** | Actionable with minor inference. 1-2 items require reasonable assumptions. |
| **0.6** | Partially actionable. Some sections need clarification before implementation can begin. Gaps are noted but not resolved. |
| **0.4** | Significant clarification needed. Developer would need to ask 3+ questions before starting. |
| **0.2** | Not actionable without substantial rework or additional analysis. |
| **0.0** | Cannot be acted upon at all. |

### Actionability checklist:
- [ ] Build order is explicit (not implied)
- [ ] Each entity lists exact fields with Java types
- [ ] Each API lists exact path, method, request/response schemas
- [ ] Each AC maps to a named test method
- [ ] Reuse instructions list exact class names and packages
- [ ] Dependencies and blockers are identified (not just "check first")

---

## Composite Score

```
Overall = (Completeness × 0.25) + (Precision × 0.30) + (Standards × 0.25) + (Actionability × 0.20)
```

**Precision is weighted highest** because vague output is the #1 failure mode in agentic SDLC.

### Score Interpretation
| Range | Meaning | Action |
|-------|---------|--------|
| **0.85–1.0** | Excellent | Agent is production-ready for this type of story |
| **0.70–0.84** | Good | Minor improvements needed — review agent instructions |
| **0.55–0.69** | Fair | Agent needs targeted fixes — check specific low-scoring dimensions |
| **0.40–0.54** | Poor | Agent needs significant rework |
| **< 0.40** | Failing | Agent definition is fundamentally inadequate for this task |
