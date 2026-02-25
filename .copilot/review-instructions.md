# AI Code Review Instructions

<!-- TODO: Fill in your project-specific review rules below. -->
<!-- See .github/instructions/examples/review-instructions.md for a complete banking domain example. -->

## Security
<!-- TODO: Define data access rules, JWT role requirements, PII logging rules, timeout requirements -->
- Customer data must never be accessible to other customers
- Authorization must be validated before any data access
- No PII in logs
- All external API calls must have timeout and circuit breaker configured

## Business Logic
<!-- TODO: Define your critical business logic checks -->
- Monetary calculations must use BigDecimal — flag any double/float for money
- State transitions must follow the defined state machine — flag direct status overrides

## Code Quality
- No hardcoded URLs, credentials, or business rule thresholds — these belong in config
- Every new service class must have a corresponding unit test class
- OpenAPI annotations required on all new controller methods
- Javadoc required on all public methods

## Integration
<!-- TODO: Define integration tracking requirements -->
- New integration points must have a corresponding entry in `docs/solution-design/integration-map.md`

## PR Requirements
<!-- TODO: Adjust ticket ID format to match your project (ADO-xxx, JIRA-xxx, etc.) -->
- PR title and description must include the ticket/story ID
- `docs/ai-usage/` must be updated with what was AI-generated for this story
