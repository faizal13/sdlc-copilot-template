# Solution Design — Mortgage IPA Platform

Single source of truth for all architecture decisions.
All agents and developers reference these documents before generating or modifying code.

## Documents

| File | Purpose | Status |
|------|---------|--------|
| `architecture-overview.md` | Service map, tech choices, deployment | DRAFT |
| `user-personas.md` | Persona definitions with access rules | DRAFT |
| `bpmn-processes.md` | Flowable process definitions and state transitions | DRAFT |
| `business-rules.md` | Policy rules from business — source of truth for eligibility | DRAFT |
| `integration-map.md` | All external systems and downstream integrations | WIP |
| `data-model.md` | Entity definitions and field-level descriptions | TODO |
| `api-contracts.md` | OpenAPI endpoint inventory across all services | TODO |

## Rule
Do not write code that contradicts a document marked FINAL without raising it with the architect first.
Documents marked DRAFT or WIP are still evolving — flag conflicts and update accordingly.
