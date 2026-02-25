# Coding Instructions — Mortgage IPA Platform
# Base: everything-copilot coding standards
# Extended: Java/Spring Boot + banking domain rules

## Code Style

### Formatting
- Use the project's formatter. Do not manually format code.
- Follow the dominant style in the file you are editing.
- Keep lines under 100 characters where practical.

### Naming
- Use descriptive names that reveal intent: `submitIpaApplication`, not `doAction`.
- No single-letter variables except `i`, `j`, `k` in loops.
- Boolean variables: prefix with `is`, `has`, `can`, `should`.
- Constants: UPPER_SNAKE_CASE.
- Follow Java conventions: camelCase for methods/variables, PascalCase for classes.

### Functions and Methods
- Each method does one thing. If you need "and" to describe it, split it.
- Keep methods under 30 lines. Extract helpers for complex logic.
- Limit parameters to 3. Use a request object for more.
- Document non-obvious parameters with Javadoc.
- **All public methods must have Javadoc** — this is non-negotiable in a banking codebase.

## Java and Spring Boot Specific Rules

### Dependency Injection
- **Constructor injection always.** Never `@Autowired` on fields.
- Single-constructor classes do not need `@Autowired` on the constructor.
- Use `@RequiredArgsConstructor` (Lombok) only if the team has agreed to use Lombok.

### Financial Calculations — Hard Rule
- **`BigDecimal` for ALL monetary values, ratios (DBR, LTV), and financial calculations.**
- **Never `double` or `float` for money.** This is a regulatory and correctness requirement.
- Use `BigDecimal.ZERO`, `BigDecimal.valueOf()` — never `new BigDecimal(double)`.
- Set scale explicitly for final display values: `.setScale(2, RoundingMode.HALF_UP)`.
- DBR, LTV, EMI utility methods must be in isolated, independently testable classes.

### Configuration
- No hardcoded values for business rule thresholds, URLs, timeouts, or expiry periods.
- All configurable values live in `application.yml` with Spring profiles.
- Access config via `@ConfigurationProperties` classes, not `@Value` scattered everywhere.
- Timer durations (90-day IPA expiry, 75-day warning) must be configurable.

### Error Handling
- Handle errors explicitly. Never use empty catch blocks.
- Use `@ControllerAdvice` for global exception handling — one handler, all exceptions.
- Custom exceptions: `InvalidStateTransitionException`, `AccessDeniedException`, `BusinessRuleViolationException`.
- Log errors with context (operation, input summary, what went wrong).
- **Never log PII** — Emirates ID, passport number, salary, account number must never appear in logs.

## Banking Domain Rules

### State Machine
Always validate IPA application state transitions. Legal transitions only:
- `DRAFT` → `SUBMITTED`
- `SUBMITTED` → `UNDER_REVIEW`
- `UNDER_REVIEW` → `APPROVED` | `REJECTED` | `REFERRED`
- `REFERRED` → `APPROVED` | `REJECTED`
- Any active state → `EXPIRED` (timer-driven only, never manual)

Throw `InvalidStateTransitionException` for any other attempted transition.


### Business Rule Comments
Every line of eligibility or policy logic must have a comment referencing its rule source:
```java
// Rule: UAE CB DBR cap salaried 50% — business-rules.md
if (dbr.compareTo(DBR_CAP_SALARIED) > 0) { ... }
```

## Code Organization
- Group related code together. One responsibility per class.
- Package structure: `controller`, `service`, `repository`, `entity`, `dto`, `exception`, `config`
- Keep files under 300 lines. Split by responsibility if they grow beyond that.
- No circular dependencies between packages.

## Comments
- Comments explain **why**, never **what**. The code explains what.
- Delete commented-out code. Use git to recover old code.
- TODO comments must include the ADO story ID: `// TODO ADO-123: implement when decision engine contract confirmed`
