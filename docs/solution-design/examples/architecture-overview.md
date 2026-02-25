# Architecture Overview — Mortgage IPA Platform
> Status: DRAFT

## System Context
UAE bank mortgage In-Principle Approval platform supporting three applicant channels: customer self-service, external broker submission, and internal RM initiation.

## Microservices

| Service | Responsibility | Status |
|---------|---------------|--------|
| `api-gateway` | Auth, JWT validation, routing, rate limiting | TODO |
| `application-service` | IPA application CRUD, state machine | TODO |
| `workflow-service` | Flowable BPMN orchestration | TODO |
| `eligibility-service` | Delegates policy evaluation to external rule engine | TODO |
| `document-service` | Document checklist generation and tracking | TODO |
| `notification-service` | Notifications via Kafka | TODO |

## Technology Decisions
- **Process Engine:** Flowable 6.x (open source, embedded in workflow-service)
- **Rule Engine:** External system via REST API. Internal fallback (Drools) — TBD if needed.
- **Auth:** JWT. Roles: CUSTOMER, BROKER, RM, UNDERWRITER, ADMIN
- **Messaging:** Kafka
- **Database:** PostgreSQL — schema per service
- **API Style:** REST + OpenAPI 3.0
- **Build:** Maven multi-module

## IPA State Machine
```
DRAFT → SUBMITTED → UNDER_REVIEW → APPROVED
                               → REJECTED  
                               → REFERRED → APPROVED
                                          → REJECTED
* → EXPIRED (90-day timer on any active state)
```

## Integrations
See `integration-map.md` — details WIP as downstream systems are confirmed.

## Deployment
Containerized — details TBD.
