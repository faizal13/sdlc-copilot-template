# Golden References — @task-planner

Use these input/output pairs to evaluate @task-planner quality.

---

## Reference 1: Standard Single-Service Story

### INPUT
```
@task-planner ADO-601
Story: Create endpoint to retrieve mortgage payment schedule
Service: payment-service
ACs:
  AC1: GET /api/v1/payments/schedule/{applicationId} returns payment schedule
  AC2: Schedule includes monthly amount, due date, principal, interest breakdown
  AC3: Only authenticated users with CUSTOMER or RM role can access
  AC4: Return 404 if no schedule exists for the application
```

### EXPECTED OUTPUT — Key Quality Markers
The task plan file `taskPlan/ADO-601-payment-service.md` MUST contain:
- [ ] Metadata table: Ticket=ADO-601, Service=payment-service, Status=ready-for-coding, Workflow=local
- [ ] Business Context: 2-3 sentences (not just repeating the title)
- [ ] Personas table: CUSTOMER and RM roles with access rules
- [ ] Data Model: PaymentScheduleEntity with exact fields (applicationId, monthlyAmount: BigDecimal, dueDate: LocalDate, principal: BigDecimal, interest: BigDecimal)
- [ ] API section: `GET /api/v1/payments/schedule/{applicationId}` with JSON response schema
- [ ] Execution Context: Phase and dependencies (or "No execution plan" warning)
- [ ] Codebase Inventory from Step 3.5 scan — what exists vs needs creation
- [ ] Reuse Instructions: existing classes to reuse (PaymentEntity, PaymentRepository if they exist)
- [ ] Context Manifest: exactly which solution design sections and source files the dev agent should read
- [ ] "Files NOT to Read" section (saves context budget)
- [ ] AC table with 4 rows + test method names
- [ ] Applicable Instincts section
- [ ] Coding Agent Instructions with build order

### SCORING GUIDE
| Dimension | What to check |
|-----------|---------------|
| Completeness | All sections populated. Context Manifest fully specified. |
| Precision | Exact field types (BigDecimal not "number"), exact API paths, exact package names |
| Standards | BigDecimal for monetary, persona isolation, Liquibase convention |
| Actionability | @local-rakbank-dev-agent could implement without asking questions |

---

## Reference 2: Story with Execution Plan Dependencies

### INPUT
```
@task-planner ADO-602
Story: Add broker commission calculation on application approval
Service: commission-service
Phase 2 story — depends on ADO-601 (payment schedule) and ADO-501 (application entity)
ACs:
  AC1: When application status changes to APPROVED, calculate broker commission
  AC2: Commission = application amount × broker tier rate
  AC3: Store commission record linked to application and broker
  AC4: Broker can view their commission history
```

### EXPECTED OUTPUT — Key Quality Markers
- [ ] Execution Context table: Phase=2, Dependencies=ADO-601+ADO-501, Dependency Status checked against codebase
- [ ] WARN if dependencies not merged: "ADO-601 not yet complete — proceeding may produce incomplete code"
- [ ] Contract handoffs: references payment schedule API from Phase 1
- [ ] Parallel With: any other Phase 2 stories listed
- [ ] Commission calculation: BigDecimal with explicit RoundingMode
- [ ] Data Model: CommissionEntity with applicationId, brokerId, amount (BigDecimal), tierRate (BigDecimal)
- [ ] State Transitions: triggered by APPROVED status (listens, doesn't change state machine)
- [ ] Reuse Instructions: existing BrokerEntity, ApplicationEntity if available

---

## Reference 3: Greenfield Project (No Existing Codebase)

### INPUT
```
@task-planner "Create the initial mortgage application submission endpoint for a new application-service"
Mode B — plain description, no ADO ID
```

### EXPECTED OUTPUT — Key Quality Markers
- [ ] Metadata: Ticket=local-task, Status=ready-for-coding
- [ ] Codebase Inventory: "Codebase is empty — dev agent will run bootstrap"
- [ ] Notes that Phase 1 (bootstrap) will create the project structure
- [ ] Full entity definition for MortgageApplicationEntity from scratch
- [ ] API: POST /api/v1/applications with complete request/response schemas
- [ ] State machine: initial states defined (DRAFT → SUBMITTED)
- [ ] No "Reuse Instructions" — greenfield, nothing to reuse
- [ ] Context Manifest: minimal (only solution design, no existing source files)
