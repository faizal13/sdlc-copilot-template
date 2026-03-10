# Golden References — @story-refiner

Use these input/output pairs to evaluate @story-refiner quality.

---

## Reference 1: Small Epic (1 Feature, 4 Stories, Single Service)

### INPUT
```
@story-refiner EPIC-100
Epic: Mortgage Application Submission
Feature: FEATURE-101 — Basic Application Flow
Stories:
  STORY-201: Customer submits mortgage application (creates entity, initial status DRAFT)
  STORY-202: Customer uploads supporting documents (links documents to application)
  STORY-203: System validates application completeness (checks all required fields)
  STORY-204: Customer views application status dashboard (read-only, queries all data)
All stories target: application-service
```

### EXPECTED OUTPUT — Key Quality Markers
- [ ] Execution plan saved to `docs/epic-plans/EPIC-100-execution-plan.md`
- [ ] Metadata table: Epic=EPIC-100, Features=1, BA Stories=4, Services=1
- [ ] Story-to-Service mapping: all 4 stories → application-service
- [ ] Dependency Graph:
  - STORY-201 → STORY-202 (entity dependency — ApplicationEntity)
  - STORY-201 → STORY-203 (entity dependency — needs ApplicationEntity fields to validate)
  - STORY-201 + STORY-202 + STORY-203 → STORY-204 (read dependency — dashboard reads all)
- [ ] Execution Phases:
  - Phase 1: STORY-201 (foundation — creates the entity)
  - Phase 2: STORY-202, STORY-203 (both depend only on Phase 1, can run in parallel)
  - Phase 3: STORY-204 (depends on everything)
- [ ] Parallel marker: STORY-202 and STORY-203 marked as parallel (same service but different tables/features)
- [ ] Contract Handoff: ApplicationEntity from Phase 1 consumed by Phase 2+3
- [ ] Gaps: "No gaps detected" or minor gaps only
- [ ] Technical stories created if needed (e.g., migration story)

### SCORING GUIDE
| Dimension | What to check |
|-----------|---------------|
| Completeness | All 7 output sections populated. Gap report present even if empty. |
| Precision | Specific dependency types identified (entity/API/state/event). Not just "STORY-201 → STORY-202" without reason. |
| Standards | Service mapping verified against actual codebase. No invented services. |
| Actionability | Can a developer immediately pick Phase 1 stories and start @task-planner? |

---

## Reference 2: Multi-Service Epic with Cross-Service Dependencies

### INPUT
```
@story-refiner EPIC-200
Epic: Mortgage Approval Workflow
Feature: FEATURE-210 — Underwriter Review
  STORY-301: Underwriter reviews application (application-service — state: UNDER_REVIEW → APPROVED/REJECTED)
  STORY-302: System sends decision notification (notification-service — Kafka event)
  STORY-303: System calculates broker commission (commission-service — triggered on APPROVED)
Feature: FEATURE-220 — Document Verification
  STORY-304: System verifies uploaded documents via OCR (document-service — external API)
  STORY-305: Underwriter views verification results (application-service — read-only)
```

### EXPECTED OUTPUT — Key Quality Markers
- [ ] 3 services affected: application-service, notification-service, commission-service, document-service
- [ ] Dependency Graph includes cross-service dependencies:
  - STORY-301 → STORY-302 (event dependency — ApplicationDecisionEvent)
  - STORY-301 → STORY-303 (state dependency — APPROVED triggers commission)
  - STORY-304 → STORY-305 (API dependency — verification results needed)
- [ ] Execution Phases:
  - Phase 1: STORY-301, STORY-304 (parallel — different services, no shared dependency)
  - Phase 2: STORY-302, STORY-303, STORY-305 (all depend on Phase 1)
- [ ] Phase 2 parallel: STORY-302 (notification-service) + STORY-303 (commission-service) can run in parallel
- [ ] Contract Handoffs:
  - STORY-301 publishes `ApplicationDecisionEvent` → consumed by STORY-302, STORY-303
  - STORY-304 produces verification result API → consumed by STORY-305
- [ ] STORY-304 OCR integration marked as "external API — check if contract confirmed or TBD"

---

## Reference 3: Epic with Gaps

### INPUT
```
@story-refiner EPIC-300
Epic: Mortgage Rate Comparison
Feature: FEATURE-310 — Rate Comparison
  STORY-401: Customer compares mortgage rates from multiple providers
  STORY-402: System stores customer's selected rate
  STORY-403: Advisor reviews customer selections (no AC — empty story)
```

### EXPECTED OUTPUT — Key Quality Markers
- [ ] Gap detected: STORY-403 has no acceptance criteria → severity HIGH
- [ ] Gap detected: "Multiple providers" — which providers? Missing integration details → severity MEDIUM
- [ ] Gap detected: Missing persona — "Advisor" not in user-personas.md → severity MEDIUM
- [ ] Recommendation: "Resolve 3 gaps with BA before sprint starts"
- [ ] Despite gaps, still produces dependency graph and execution phases for the stories that CAN be analyzed
- [ ] Does NOT create technical stories for STORY-403 (no ACs = cannot decompose)
