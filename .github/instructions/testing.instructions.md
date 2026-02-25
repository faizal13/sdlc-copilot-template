---
applyTo: 'src/test/java/**/*.java'
---
<!-- TODO: Fill in your project-specific testing rules below. -->
<!-- These rules are auto-applied to every Copilot suggestion on test files. -->
<!-- See .github/instructions/examples/testing-instructions.md for a complete banking domain example. -->

## Test Structure — Arrange-Act-Assert
```
1. Arrange: set up preconditions and inputs
2. Act:     execute the behaviour being tested
3. Assert:  verify the expected outcome
```

## Naming Convention
<!-- TODO: Define your test method naming convention -->
<!-- Example: should_{expectedBehaviour}_when_{condition} -->

## Spring Boot Test Types
| What you're testing | Annotation to use |
|---|---|
| Service logic (no Spring) | `@ExtendWith(MockitoExtension.class)` |
| Controller (web layer only) | `@WebMvcTest(MyController.class)` |
| Repository (JPA layer only) | `@DataJpaTest` |
| Full integration with real DB | `@SpringBootTest` + `@Testcontainers` |

Never use `@SpringBootTest` for unit tests — loads the full context, too slow.

## Acceptance Criteria → Test Cases
<!-- TODO: Define how AC from your ticket system map to test methods -->
<!-- Example: every ADO acceptance criterion must become a named @Test method -->

## Coverage Targets
<!-- TODO: Define minimum coverage percentages for your project -->
- 80%+ line coverage on new code minimum.

## Domain Test Rules
<!-- TODO: Add domain-specific test rules -->
<!-- Examples: -->
<!-- - Test BigDecimal boundary conditions for financial calculations -->
<!-- - Test all valid state transitions AND all invalid transition rejections -->
<!-- - Persona isolation test required for every endpoint -->
