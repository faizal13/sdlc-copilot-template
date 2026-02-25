# AI Code Review Instructions — Mortgage IPA

You are reviewing code for a UAE banking mortgage IPA platform. Apply these checks on every PR.

## Security
- Customer data must never be accessible to other customers
- Broker-submitted applications visible only to that broker and internal bank users
- JWT role must be validated before any data access (CUSTOMER, BROKER, RM, UNDERWRITER)
- No PII (Emirates ID, passport number, salary) in logs
- All external API calls must have timeout and circuit breaker configured

## Business Logic
- Monetary calculations must use BigDecimal — flag any double/float for money
- DBR calculation must consider employment type (salaried vs self-employed)
- State transitions must follow the defined IPA state machine — flag direct status overrides
- Flowable process keys must match definitions in `docs/solution-design/bpmn-processes.md`

## Code Quality
- No hardcoded URLs, credentials, or business rule thresholds — these belong in config
- Every new service class must have a corresponding unit test class
- OpenAPI annotations required on all new controller methods
- Javadoc required on all public methods

## Integration
- New integration points must have a corresponding entry in `docs/solution-design/integration-map.md`
- Kafka topics must come from configuration, not hardcoded strings

## PR Requirements
- PR title and description must include `ADO-{storyId}`
- `docs/ai-usage/` must be updated with what was generated this story
