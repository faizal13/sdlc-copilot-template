# Testing Instructions — Mortgage IPA Platform
# Base: everything-copilot testing standards
# Extended: Spring Boot patterns + AC-to-test mapping + banking domain rules

## Testing Philosophy
- Tests verify behavior, not implementation. Refactoring internals must not break tests.
- TDD preferred: write failing test first, make it pass, then refactor.
- Every bug fix starts with a test that reproduces the bug.
- Tests are production code — apply the same quality standards.

## Test Structure — Arrange-Act-Assert
```
1. Arrange: set up preconditions and inputs
2. Act:     execute the behavior being tested
3. Assert:  verify the expected outcome
```
Separate the three sections with a blank line.

## Naming Convention — Mandatory
```java
// Pattern: should_{expectedBehavior}_when_{condition}
void shouldRejectApplication_whenDBRExceedsCap()
void shouldReturnForbidden_whenCustomerAccessesBrokerApplication()
void shouldTransitionToExpired_whenNinetyDaysElapsed()
```

## Spring Boot Test Types — Use the Right One

| What you're testing | Annotation to use |
|---------------------|------------------|
| Service logic (no Spring) | `@ExtendWith(MockitoExtension.class)` |
| Controller (web layer only) | `@WebMvcTest(MyController.class)` |
| Repository (JPA layer only) | `@DataJpaTest` |
| Full integration with real DB | `@SpringBootTest` + `@Testcontainers` |

Never use `@SpringBootTest` for unit tests — it's slow and loads the full context.

## Acceptance Criteria → Test Cases — Mandatory Mapping
Every acceptance criterion from the ADO story must become a named test method.
Use this naming format directly tied to the AC number:
```java
@Test
void ac1_givenSubmittedApplication_whenEligible_thenAutoApproved() { }

@Test
void ac2_givenSubmittedApplication_whenDBRExceeds50Percent_thenAutoRejected() { }
```
If an AC doesn't have a test, the story is not done.

## Banking Domain Test Rules

### Financial Calculation Tests
- Test DBR calculation with exact BigDecimal values — never approximate.
- Test boundary conditions: exactly at cap (50.00%), just above (50.01%), just below (49.99%).
- Test both employment types (salaried and self-employed) separately.
```java
@Test
void shouldAutoReject_whenDBREqualsCapForSalaried() {
    BigDecimal monthlyIncome = new BigDecimal("10000.00");
    BigDecimal monthlyLiabilities = new BigDecimal("5000.00"); // exactly 50%
    // assert REFERRED (boundary = cap is not exceeding)
}
```

### State Machine Tests
Test every valid transition AND every invalid transition:
```java
@Test
void shouldThrowInvalidStateTransition_whenApprovingDraftApplication() {
    assertThatThrownBy(() -> service.approve(draftApplicationId, userContext))
        .isInstanceOf(InvalidStateTransitionException.class);
}
```

### Persona Data Isolation Tests — Mandatory for Every Endpoint
```java
@Test
void shouldReturnForbidden_whenCustomerAccessesAnotherCustomersApplication() { }

@Test
void shouldReturnForbidden_whenBrokerAccessesApplicationFromAnotherBroker() { }

@Test
void shouldReturnForbidden_whenCustomerAccessesInternalNotes() { }
```

## Mocking Rules
- Mock external system calls (rule engine, notification gateway, core banking).
- Use `Testcontainers` for real PostgreSQL in integration tests — never H2 for IPA flows.
- Flowable process tests: use `@FlowableTest` with in-memory engine — not real DB.
- Reset mocks between tests — shared state causes flaky tests.

## Coverage Targets
- 80%+ line coverage on new code minimum.
- 100% coverage on: state machine transitions, DBR/LTV calculations, persona access control.
- Coverage is a guide — do not write meaningless tests to hit a number.

## Integration Tests with Testcontainers
```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
class ApplicationServiceIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres =
        new PostgreSQLContainer<>("postgres:16-alpine");

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }
}
```

## Test Checklist — Every PR
- [ ] Unit tests for all service methods
- [ ] Controller tests: happy path + all error paths
- [ ] Repository tests for custom queries
- [ ] AC-to-test mapping: every ADO acceptance criterion has a @Test
- [ ] Persona isolation tests for every endpoint
- [ ] State machine: valid transitions + invalid transition rejection
- [ ] BigDecimal boundary tests for all financial calculations
- [ ] `mvn clean verify` passes with zero failures
