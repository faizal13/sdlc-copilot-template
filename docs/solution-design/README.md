# Solution Design — [Your Project Name]

Single source of truth for all architecture decisions.
All agents and developers reference these documents before generating or modifying code.

## Documents

| File | Purpose | Status |
|------|---------|--------|
| `architecture-overview.md` | Service map, tech choices, deployment | TODO |
| `user-personas.md` | Persona definitions with access rules | TODO |
| `business-rules.md` | Policy rules from business — source of truth | TODO |
| `integration-map.md` | All external systems and downstream integrations | TODO |
| `data-model.md` | Entity definitions and field-level descriptions | TODO |
| `api-contracts.md` | OpenAPI endpoint inventory across all services | TODO |
<!-- TODO: Add any additional design documents your project needs -->
<!-- e.g. bpmn-processes.md, event-catalog.md, etc. -->

## Status Labels
- **TODO** — Not started yet
- **DRAFT** — Initial version, still evolving
- **WIP** — Actively being worked on
- **FINAL** — Reviewed and approved — do not contradict without architect approval

## Rule
Do not write code that contradicts a document marked FINAL without raising it with the architect first.
Documents marked DRAFT or WIP are still evolving — flag conflicts and update accordingly.

## Examples
See `docs/solution-design/examples/` for a complete Mortgage IPA reference implementation of all these documents.
