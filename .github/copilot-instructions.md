# Code Generation Instructions for Java

**Version:** 1.1.0
**Last Updated:** 2026-02-25

---

**Instructions Repository:**
This file is maintained in a central repository for shared usage across multiple projects and teams. All updates, version history, and feedback should be managed through the repository to ensure consistency and traceability.

**Repository Link:** https://github.com/rakbank-internal/oss-copilot-instructions

Please refer to the repository for the latest version, contribution guidelines, and to submit feedback or change requests.

---

## Change Log
| Version | Date       | Author      | Changes                 |
|---------|------------|-------------|-------------------------|
| 1.0.0   | 2025-05-15 | Vasilii Sushko     | Initial version         |
| 1.0.1   | 2025-05-20 | Vasilii Sushko     | Unnecessary blank lines |
| 1.0.2   | 2025-05-22 | Vasilii Sushko     | Grammar and spelling |
| 1.0.3   | 2025-06-23 | Vasilii Sushko     | Java coding standards update |
| 1.0.4   | 2025-06-26 | Vasilii Sushko     | Custom Directives & Gradle support |
| 1.1.0   | 2026-02-25 | GitHub Copilot     | Naming conventions, Modern Java, Code Quality, Spring Boot, Performance & Security |

## Purpose
These instructions guide the generation of Java code with a focus on best practices, including exception handling, input validation, and comprehensive unit testing.

## Custom Directives
- Always conform to the coding styles and patterns defined in this project's established guidelines when generating code.
- Use @terminal when answering questions about Git commands, build processes, or deployment procedures.
- Answer all questions in the style of a professional but approachable RAKBANK team member, using clear and concise language.
- Keep code explanations under 500 characters when possible, prioritizing clarity and actionable guidance.
- Prioritize security-first approaches in all code suggestions, especially for banking domain requirements.
- Address code smells proactively during development rather than accumulating technical debt; prefer readable and maintainable code over clever code.
- Use IDE/editor warnings and static analysis suggestions to catch common issues early.

## Java Coding Standards
- Follow the [Java Code Conventions](https://www.oracle.com/java/technologies/javase/codeconventions-contents.html).
- If build configuration (pom.xml/build.gradle) doesn't already specify Java version, use Java 21.
- Use meaningful variable and method names that enhance readability.
- Maintain consistent indentation (4 spaces) and avoid tabs.
- Use Javadoc for all public classes.
- Keep line length to a maximum of 160 characters.
- Avoid import statement collapses or wildcards.
- Remove dead code including unused imports, variables, methods, and classes.

### Naming Conventions
- `UpperCamelCase` for class and interface names.
- `lowerCamelCase` for method and variable names.
- `UPPER_SNAKE_CASE` for constants.
- `lowercase` for package names (no underscores).
- Use nouns for classes (e.g., `MortgageService`) and verbs for methods (e.g., `getApplicationById`).
- Avoid abbreviations and Hungarian notation.

## Build Tool Considerations
### Maven Projects
- Use Maven wrapper (`mvnw`) for consistent build environments.
- Follow Maven standard directory layout.
- Configure Surefire plugin for parallel test execution.
- Use Maven profiles for environment-specific configurations.

### Gradle Projects
- Use Gradle wrapper (`gradlew`) for consistent build environments.
- Follow Gradle standard directory layout (same as Maven).
- Configure test task for parallel execution: `test { useJUnitPlatform(); maxParallelForks = Runtime.runtime.availableProcessors() }`.
- Use Gradle build variants or configurations for environment-specific settings.
- Prefer Kotlin DSL (`build.gradle.kts`) over Groovy DSL for better IDE support and type safety.
- Use Gradle's built-in dependency management and version catalogs for better dependency organization.

### Build Verification
- After adding or modifying code, always verify the project builds and all tests pass before committing.
- Maven: `./mvnw clean install`
- Gradle: `./gradlew build`

## Recommended Folder Structure
A well-organized folder structure is crucial for maintaining a Spring Boot application. Below is a recommended structure:
```
src/
├── main/
│   ├── java/
│   │   └── ae/
│   │       └── rakbank/
│   │           └── yourapp/
│   │               ├── config/          # Configuration classes
│   │               ├── constants/       # Constants
│   │               ├── controller/      # REST controllers
│   │               ├── dto/             # Data Transfer Objects
│   │               ├── entity/          # Entity classes
│   │               ├── enums/           # Enumerations
│   │               ├── exception/       # Custom exceptions classes
│   │               ├── jobs/            # Scheduled jobs
│   │               ├── repository/      # Data access layer
│   │               ├── service/         # Business logic layer services
│   │               ├── service/impl     # Business logic layer implementations
│   │               └── utils            # Utility classes
│   └── resources/
│       ├── application.properties       # Application properties
│       ├── db/
│       │   └── changelog/
│       │       └── changes/
│       │           └── dev/
│       │               └── 20240430-001-initial-schema.sql        # Example changelog file
│       │           └── sit/
│       │           └── pt/
│       │           └── replica/
│       │           └── prod/
│       │       └── db.changelog-master.yaml  # Liquibase master changelog file
│       └── static/                      # Static assets (CSS, JS, images)
│       └── templates/                   # Thymeleaf or other template files
└── test/
   └── java/
       └── ae/
           └── rakbank/
               └── yourapp/
                   ├── controller/      # Test classes for controllers
                   ├── service/         # Test classes for services
                   └── repository/      # Test classes for repositories
```
## Best Practices
- Use Lombok for getters and setters on beans and entity classes.
- Use SLF4J for logging.
- Use debug logging statements.
- Use info level logging for key information points.
- Use error level for logging all errors.
- Avoid using String.format() method in logging statements.
- Always log stacktrace in catch block.
- Never swallow any exception.
- Mask all the sensitive information such as customer name, account number, credit card numbers, etc. while logging.
- Use the latest Java features supported by the target version (e.g., Records, Collections, Virtual Threads, try-with-resources, etc.).
- Keep Request/Response DTOs (Records) and Entity classes separate.
- Use mapper libraries such as MapStruct for automatic mapping.
- Adhere to [12 factor app](https://12factor.net/) principles.
- Consider target deployment platform and topology like multiple replicas.
- Maintain consistent spacing and avoid unnecessary blank lines (e.g., no consecutive empty lines between statements, fields, or methods).

## Modern Java Features
This project targets Java 21. Leverage these features to write cleaner, safer, and more expressive code:
- **Records**: Use Records instead of traditional classes for DTOs and immutable data structures. They provide concise, read-only carriers of structured data.
- **Pattern Matching**: Use pattern matching for `instanceof` checks and `switch` expressions to simplify conditional logic and eliminate explicit casts.
- **Type Inference**: Use `var` for local variable declarations when the type is immediately clear from the right-hand side; avoid it when the type would be ambiguous.
- **Immutability**: Prefer immutable objects. Declare classes and fields `final` where possible. Use `List.of()`, `Map.of()` for fixed collections and `Stream.toList()` for immutable stream results.
- **Streams & Lambdas**: Use the Streams API and lambda expressions for collection processing. Prefer method references (e.g., `stream.map(Foo::toBar)`) for clarity.
- **Null Safety**: Avoid returning or accepting `null`. Use `Optional<T>` for possibly-absent values and `Objects.requireNonNull()` for precondition checks.
- **Virtual Threads**: For I/O-bound workloads, prefer virtual threads (Project Loom) over platform threads to maximise throughput without blocking.

## Code Quality

### Common Bug Patterns to Avoid
- **Resource Leaks**: Always close resources (files, streams, connections) using try-with-resources so they are released automatically.
- **Reference Equality**: Compare objects with `.equals()` or `Objects.equals()`, never `==` for non-primitives.
- **Redundant Casts**: Prefer correct generic typing and compiler-inferred types; remove unnecessary casts.
- **Unreachable Conditions**: Avoid conditionals that are always `true` or `false`; they indicate dead code or logic bugs.

### Code Smells
Proactively identify and address these patterns during development and code review:
- **Long Parameter Lists**: If a method requires many parameters, group them into a value object or use the builder pattern.
- **Large Methods**: Keep methods focused and small. Extract helper methods to improve readability and testability.
- **High Cognitive Complexity**: Reduce deep nesting and heavy branching by extracting methods, using polymorphism, or applying the Strategy pattern.
- **Duplicated Literals**: Extract repeated strings and numbers into named constants or enums to ease future changes and reduce error risk.
- **Magic Numbers**: Replace numeric literals with named constants that communicate intent (e.g., `MAX_RETRY_ATTEMPTS`).
- **Dead Code**: Remove unused variables, assignments, and methods; they mislead reviewers and can conceal bugs.

## Exception Handling
- **Always Handle Exceptions**: Ensure that all code generated handles exceptions properly.
- Use specific exception types rather than generic exceptions (e.g., `IOException`, `SQLException`).
- Log exceptions using a logging framework (e.g., SLF4J, Log4j).
- Provide meaningful error messages.
- Use `try-catch` blocks effectively to manage exceptions.
- GlobalExceptionHandler annotated with `@ControllerAdvice` should be used for handling exceptions globally.

## Database
- Use Liquibase based scripts unless mentioned otherwise.
- Optimize SQL queries for execution.
- Recommend appropriate indexes for query optimization.
- Use in-memory database for local testing.
- Create a .local configuration for local testing.
- Use `@Transactional` annotation for methods that modify the database.
- Use `@Query` annotation for custom queries in repository interfaces.
- Use `@Modifying` annotation for update/delete operations in repository interfaces.
- Use `@Lock` annotation for optimistic locking.
- Use `@Version` annotation for optimistic locking in entity classes.
- Prevent N+1 query problems: use `JOIN FETCH`, `@EntityGraph`, or batch loading in Spring Data JPA.
- Avoid `SELECT *`; select only the columns required to reduce I/O and memory pressure.
- Keep transactions as short as possible to minimise lock contention and avoid deadlocks.
- Regularly archive or purge old records to keep tables lean and queries fast.

## Input Validation
- **Generate Input Validation**: When generating code, include validation for all input parameters.
- Validate for null values, empty strings, and invalid formats.
- Include checks to ensure that inputs meet expected criteria before processing.
- Implement validation for special characters based on business logic.
- Use annotation based validation wherever possible.

## Spring Boot Development

### Dependency Injection
- Use constructor injection for all required dependencies; avoid field injection with `@Autowired`.
- Declare injected fields as `private final`.

### Configuration
- Prefer YAML (`application.yml`) over `.properties` files for externalized configuration.
- Use `@ConfigurationProperties` for type-safe, grouped configuration binding.
- Use Spring profiles (`dev`, `sit`, `prod`) for environment-specific configuration.
- Externalize all secrets via environment variables or a secrets management service (e.g., Azure Key Vault, HashiCorp Vault). Never hardcode credentials.

### Code Organization
- Keep controllers thin: delegate all business logic to the service layer.
- Services must be stateless and independently testable; inject repositories via constructor.
- Service method signatures should accept and return DTOs or domain IDs—do not expose JPA entities in the API layer.
- Make utility classes `final` with a private constructor to prevent instantiation.

### Useful Commands
| Gradle Command               | Maven Command                      | Description                                  |
|:-----------------------------|:-----------------------------------|:---------------------------------------------|
| `./gradlew bootRun`          | `./mvnw spring-boot:run`           | Run the application.                         |
| `./gradlew build`            | `./mvnw package`                   | Build the application.                       |
| `./gradlew test`             | `./mvnw test`                      | Run tests.                                   |
| `./gradlew bootJar`          | `./mvnw spring-boot:repackage`     | Package the application as a JAR.            |
| `./gradlew bootBuildImage`   | `./mvnw spring-boot:build-image`   | Build a container image.                     |

## Performance

### General Principles
- **Measure First, Optimize Second**: Profile and benchmark before optimizing. Use VisualVM, JProfiler, async-profiler, or distributed tracing (OpenTelemetry) to find real bottlenecks.
- **Avoid Premature Optimization**: Write clear, maintainable code first; optimize only where profiling identifies a genuine need.
- **Automate Performance Testing**: Integrate load tests (e.g., Gatling, k6) into the CI/CD pipeline to catch regressions early.

### Java & Spring Boot
- Choose the right data structure for the access pattern (`ArrayList` for sequential access, `HashMap` for O(1) lookups).
- Avoid O(n²) or worse complexity; profile nested loops and recursive calls.
- Use `CompletableFuture` or virtual threads for async/I/O-bound operations to avoid blocking threads.
- Use connection pooling (HikariCP is Spring Boot's default) for all database and external service connections.
- Cache expensive or frequently accessed data with Spring Cache (`@Cacheable`) backed by Redis; handle cache invalidation explicitly.
- Tune JVM options for your workload: heap size (`-Xmx`, `-Xms`) and GC algorithm (`-XX:+UseG1GC` or `-XX:+UseZGC`).
- Minimize logging in hot code paths; use guarded log statements (`if (logger.isDebugEnabled())`) where necessary.

### Database Performance
- Avoid N+1 queries: use `JOIN FETCH`, `@EntityGraph`, or batch loading.
- Add indexes on columns that are frequently filtered, sorted, or joined; monitor and drop unused indexes.
- Paginate large result sets; use cursors or keyset pagination for real-time data.
- Use read replicas for read-heavy workloads; monitor replication lag.

## Secure Coding (OWASP)
Security is non-negotiable in a banking context. All generated code must be secure by default.

### Access Control
- Default to least privilege; deny access unless an explicit rule permits it.
- Validate all user-supplied URLs before making server-side requests (SSRF prevention); use an allow-list for permitted hosts and ports.
- Sanitize file paths derived from user input to prevent directory traversal (e.g., `../../etc/passwd`).

### Cryptography
- Never use MD5 or SHA-1 for password hashing; use bcrypt, Argon2, or PBKDF2 with an appropriate work factor.
- Protect data at rest with AES-256 or equivalent. Enforce TLS for all data in transit.
- Never hardcode secrets (API keys, passwords, connection strings). Read them from environment variables or a secrets manager.

### Injection Prevention
- Always use parameterized queries / Spring Data JPA; never construct queries via string concatenation.
- Sanitize OS command arguments using safe APIs that prevent shell injection.
- When displaying user-controlled data, apply context-aware output encoding to prevent XSS.

### Security Configuration
- Disable verbose error messages and stack traces in production API responses.
- Apply security headers: `Content-Security-Policy`, `Strict-Transport-Security`, `X-Content-Type-Options`.
- Keep dependencies up to date; run `./mvnw dependency-check:check` or `./gradlew dependencyCheckAnalyze` regularly to detect known vulnerabilities.

### Authentication & Session Management
- Generate a new session ID upon successful login to prevent session fixation.
- Configure session cookies with `HttpOnly`, `Secure`, and `SameSite=Strict` attributes.
- Implement rate limiting and account lockout after repeated failed authentication attempts.

### Deserialization
- Avoid deserializing data from untrusted sources. Prefer JSON over binary serialization formats.
- Apply strict type validation when deserialization is unavoidable; never deserialize arbitrary class hierarchies.

## Unit Testing Guidelines
- **Generate Comprehensive Unit Tests**: Ensure that unit tests generated cover the following:
- Generate unit tests for each public method in the class.
- Use JUnit 5 for unit testing.
- Name test methods clearly to indicate what they are testing without using under_scores.
- **Edge Cases**: Include tests that handle extreme or unusual input values.
- **Negative Cases**: Create tests for invalid input scenarios to ensure that the code behaves as expected when faced with erroneous input.
- **Boundary Conditions**: Generate tests that validate the behavior of the code at the limits of acceptable input ranges.
- **Testing Exceptions**: Include tests that check if the correct exceptions are thrown for invalid inputs.
- **Code coverage**: Ensure at least 80% code coverage is achieved with generated unit tests.
- Ensure all test compile and run properly.
- Use correct combination of unit, acceptance and integration tests suggested by Test Pyramid.
- Each test should test only one scenario, avoid clubbing many cases in single tests.
- Avoid duplicate tests for same scenarios.
- Watch build time. Build time should not be too high due to tests.
- Tests should be configured to run in parallel. Configure build file (pom.xml/build.gradle) to run tests in parallel.
- Tests should not have side effects.
- Tests shouldn't depend on any test order.
## Summary
By adhering to these guidelines, the generated Java code will be robust, maintainable, and aligned with best practices. Ensure to review the generated code to confirm compliance with these standards.
