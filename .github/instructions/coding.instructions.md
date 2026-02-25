---
applyTo: 'src/main/java/**/*.java'
---
<!-- TODO: Fill in your project-specific coding rules below. -->
<!-- These rules are auto-applied to every Copilot suggestion on Java source files. -->
<!-- See .github/instructions/examples/coding-instructions.md for a complete banking domain example. -->

## Code Style
<!-- TODO: Add your naming, formatting, and line-length rules -->

## Dependency Injection
- Constructor injection always. Never `@Autowired` on fields.

## Configuration
<!-- TODO: List what must never be hardcoded (thresholds, URLs, timeouts) -->
- No hardcoded values — all config in `application.yml` with Spring profiles

## Error Handling
- Handle errors explicitly. Never use empty catch blocks.
- Use `@ControllerAdvice` for global exception handling.
<!-- TODO: List your custom exception types -->

## Domain-Specific Rules
<!-- TODO: Add your critical code generation rules -->
<!-- Examples: -->
<!-- - Never use double/float for monetary values — always BigDecimal -->
<!-- - Every business rule must have a comment referencing its source document -->
<!-- - PII fields (list them) must never appear in application logs -->
