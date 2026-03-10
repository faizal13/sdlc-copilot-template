# Golden References — @story-analyzer

Use these input/output pairs to evaluate @story-analyzer quality. These are representative examples showing what a **good** output looks like.

---

## Reference 1: Simple Entity CRUD Story

### INPUT
```
ADO_ID: ADO-501
Title: As a customer, I want to view my mortgage application status
Release Branch: release/feat-mortgage-status
Sprint: 2
Acceptance Criteria:
  AC1: Customer can view application status by application ID
  AC2: Only the owning customer can see their application
  AC3: Response includes status, submission date, last updated date
  AC4: Return 404 if application not found
Service: application-service
```

### EXPECTED OUTPUT — Key Quality Markers
The GitHub Issue MUST contain:
- [ ] `[ADO-501]` in title with service name
- [ ] Labels: `ai-generated`, `application-service`, `release/feat-mortgage-status`, `sprint-2`
- [ ] Business Context: 2-3 sentences explaining WHY (not just what)
- [ ] Personas table: CUSTOMER row with "view own applications" / "cannot see other customer data"
- [ ] Execution Context: Phase reference (or "No execution plan" warning)
- [ ] Data Model: ApplicationEntity with exact fields (id, customerId, status, submissionDate, lastUpdatedDate) — NOT just "relevant fields"
- [ ] API: `GET /api/v1/applications/{id}` with exact response JSON schema
- [ ] State Transitions: "No state machine changes" (this is read-only)
- [ ] Reuse Instructions: Check if ApplicationEntity already exists
- [ ] AC table with 4 rows, each having `should{X}When{Y}` test method names
- [ ] Test method: `shouldReturnApplicationWhenCustomerOwnsIt`
- [ ] Test method: `shouldReturn403WhenCustomerDoesNotOwnApplication`
- [ ] Test method: `shouldReturn404WhenApplicationNotFound`
- [ ] Definition of Done with all checkboxes
- [ ] Coding Agent Instructions with build order

### SCORING GUIDE
| Dimension | What to check |
|-----------|---------------|
| Completeness | All 12 sections present and populated |
| Precision | Exact field names, exact API path, exact test method names — no "{fieldName}" placeholders |
| Standards | Persona isolation enforced, no double/float for dates, Liquibase convention if schema changes |
| Actionability | Could a coding agent implement from this issue alone? |

---

## Reference 2: State Machine + Integration Story

### INPUT
```
ADO_ID: ADO-502
Title: As an underwriter, I want to approve or reject a mortgage application
Release Branch: release/feat-mortgage-review
Sprint: 3
Acceptance Criteria:
  AC1: Underwriter can approve application (UNDER_REVIEW → APPROVED)
  AC2: Underwriter can reject with reason (UNDER_REVIEW → REJECTED)
  AC3: Approval triggers notification to customer via Kafka event
  AC4: Rejection triggers notification with reason to customer
  AC5: Only UNDER_REVIEW applications can be approved/rejected
  AC6: Audit log entry created for each decision
Service: application-service
Integration: Notification Service (Kafka — contract CONFIRMED)
```

### EXPECTED OUTPUT — Key Quality Markers
- [ ] State Transitions section with: UNDER_REVIEW → APPROVED (validation: status == UNDER_REVIEW)
- [ ] State Transitions section with: UNDER_REVIEW → REJECTED (validation: status == UNDER_REVIEW, reason not blank)
- [ ] State Transitions: explicit "illegal transition" warning for other states
- [ ] Integration section: Kafka event `ApplicationDecisionEvent` with payload schema
- [ ] Integration status: "Confirmed" (not TBD)
- [ ] Persona: UNDERWRITER can approve/reject / cannot see customer PII beyond what's needed
- [ ] API: `PUT /api/v1/applications/{id}/decision` with request body `{ decision: "APPROVED|REJECTED", reason: "..." }`
- [ ] 6 test methods matching 6 ACs
- [ ] Test: `shouldRejectWhenStatusIsNotUnderReview` (covers AC5 negative case)
- [ ] Audit log entity/table mentioned in data model

---

## Reference 3: Cross-Service Story

### INPUT
```
ADO_ID: ADO-503
Title: As a broker, I want to submit a mortgage application on behalf of customer
Release Branch: release/feat-broker-submit
Sprint: 2
Acceptance Criteria:
  AC1: Broker can submit application with customer details
  AC2: Application created with status DRAFT
  AC3: Customer eligibility checked via external CBS API (TBD)
  AC4: Broker can only see applications they submitted
Service: application-service + customer-service (cross-service)
```

### EXPECTED OUTPUT — Key Quality Markers
- [ ] Cross-Service Impact Detection section present
- [ ] FLAG: "This story has cross-service impact"
- [ ] Recommendation to decompose into per-service GitHub Issues
- [ ] CBS integration marked as TBD → "coding agent must generate stub only"
- [ ] Persona: BROKER row with "submit on behalf of customer" / "cannot see other brokers' applications"
- [ ] Data model: brokerId field on ApplicationEntity
- [ ] Clarifications: How is customer identity verified by broker? (flagged, not guessed)
