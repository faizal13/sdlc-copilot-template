---
applyTo: '**'
---
<!-- TODO: Fill in your project-specific PR review rules below. -->
<!-- These rules are auto-applied during every Copilot code review interaction. -->
<!-- See .github/instructions/examples/review-instructions.md for a complete banking domain example. -->

## Security
<!-- TODO: Define your data access and authorization review checks -->
- No PII in logs
- Authorization validated before data access
- All external calls have timeout and circuit breaker

## Business Logic
<!-- TODO: Define your critical business logic invariants -->
<!-- Examples: -->
<!-- - Monetary calculations must use BigDecimal -->
<!-- - State transitions must follow the defined state machine -->

## Code Quality
- No hardcoded URLs, credentials, or thresholds
- Every new service class has a corresponding unit test class
- OpenAPI annotations on all new controller methods
- Javadoc on all public methods

## PR Requirements
<!-- TODO: Adjust to your ticketing system and AI usage tracking process -->
- PR title includes the ticket/story ID
- `docs/ai-usage/` updated with what was AI-generated this story
