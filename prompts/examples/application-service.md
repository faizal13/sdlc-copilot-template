# Prompt: application-service — End to End

## Before Running This Prompt
Load in Copilot Chat:
1. `contexts/banking.md`
2. `docs/solution-design/architecture-overview.md`
3. `docs/solution-design/user-personas.md`
4. `docs/solution-design/business-rules.md`

Read the ADO story via MCP. Replace `{ADO_ID}` with the actual story ID.

---

## Instruction to Copilot

You are building the `application-service` Spring Boot microservice for the Mortgage IPA platform.

### Step 1 — Read the Story
Read ADO story `{ADO_ID}` via MCP. Extract:
- Title and description
- All acceptance criteria (each becomes a test case)
- Any linked stories or dependencies

### Step 2 — Data Model
Generate:
- `IpaApplication` JPA entity with fields: id, applicantId, applicantType (CUSTOMER/BROKER), brokerId (nullable), propertyValue, loanAmount, employerName, monthlyIncome, monthlyLiabilities, status, createdAt, updatedAt, submittedAt, expiresAt
- `ApplicationStatus` enum: DRAFT, SUBMITTED, UNDER_REVIEW, APPROVED, REJECTED, REFERRED, EXPIRED
- `ApplicantType` enum: CUSTOMER, BROKER
- Flyway migration V1__create_ipa_application.sql

### Step 3 — Repository
Generate `IpaApplicationRepository` (Spring Data JPA) with queries:
- findByApplicantId
- findByBrokerIdAndStatus
- findByStatus
- findAllByExpiresAtBeforeAndStatusIn (for expiry job)

### Step 4 — Service Layer
Generate `ApplicationService` with:
- `createApplication(request, userContext)` — enforces persona rules, sets initial state DRAFT
- `submitApplication(id, userContext)` — DRAFT → SUBMITTED, starts Flowable process
- `updateStatus(id, newStatus, userContext)` — validates state machine transitions
- `getById(id, userContext)` — enforces data isolation from user-personas.md
- `getApplications(filter, userContext)` — persona-filtered list
- State machine validation: throw `InvalidStateTransitionException` for illegal transitions
- Data isolation: throw `AccessDeniedException` if persona rules violated

### Step 5 — REST Controller
Generate `ApplicationController` with OpenAPI annotations:
- `POST /api/v1/applications` — create
- `POST /api/v1/applications/{id}/submit` — submit
- `GET /api/v1/applications/{id}` — get by id
- `GET /api/v1/applications` — list with filters
- JWT role validation on each endpoint using `@PreAuthorize`

### Step 6 — Tests
Generate:
- `ApplicationServiceTest` — unit tests covering all state transitions, all persona access control rules, each acceptance criteria from ADO-{ADO_ID}
- `ApplicationRepositoryTest` — integration test using Testcontainers PostgreSQL
- `ApplicationControllerTest` — slice test with MockMvc

### Step 7 — Verify Before Finishing
Check:
- No `double` or `float` used for financial fields — only `BigDecimal`
- No hardcoded values — all config in `application.yml`
- All public methods have Javadoc
- OpenAPI annotations present on all endpoints
- `mvn clean verify` would pass

### Step 8 — AI Usage Record
Create `docs/ai-usage/sprint-{N}/ADO-{ADO_ID}.md` with:
- Story title
- This prompt file reference
- Summary of what was generated
- Any changes you made to the generated output

---
## Expected Output
Complete Spring Boot Maven module. `mvn clean verify` passes. PR ready.
PR title format: `feat(application-service): {story title} [ADO-{ADO_ID}]`
