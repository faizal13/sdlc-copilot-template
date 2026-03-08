---
applyTo: '**'
---

## Cross-Service Development Rules

### Story Scoping
- Every story/task plan targets ONE microservice
- If a story requires changes across multiple services, decompose into per-service stories
- Each per-service story defines the contract (API spec or event schema) it exposes

### Contract-First Development
When your service will be consumed by another microservice:
1. Define the API contract FIRST (OpenAPI spec or event schema)
2. Implement the contract in your service
3. Add Pact contract test to verify the contract
4. Document the contract in the task plan for the consuming service's story

### Cross-Service Data Rules
- NEVER share JPA entities across services — use DTOs
- NEVER access another service's database directly
- Communication via REST API or event bus ONLY
- All cross-service calls must have: timeout, circuit breaker, retry with backoff, fallback

### Dependency Management
- If your story depends on an API from another service: VERIFY it exists in that service's codebase
- If the dependency doesn't exist yet: use the stub pattern (`@ConditionalOnProperty`)
- Document the dependency in the task plan's "Integration Touchpoints" section
- Flag any missing dependencies as blockers — do NOT proceed with assumptions

### Liquibase Collision Prevention
- Use timestamp-based changeset naming: `{YYYYMMDD}-{HHMM}-{ticket-id}-{description}.sql`
- NEVER use sequential numbers (001, 002, etc.) — they collide when engineers work in parallel
- Each changeset must have a unique ID combining date, time, and ticket
