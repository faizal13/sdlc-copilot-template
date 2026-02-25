---
applyTo: 'src/main/java/**/*.java'
---
<!-- TODO: Fill in your project-specific security rules below. -->
<!-- These rules are auto-applied to every Copilot suggestion on Java source files. -->
<!-- See .github/instructions/examples/security-instructions.md for a complete banking domain example. -->

## Secrets and Credentials
- Never hardcode secrets, tokens, API keys, passwords, or connection strings.
- Load secrets from environment variables or a secrets manager.
- Never log, print, or include secrets in error messages.

## PII Protection
<!-- TODO: List the fields in your domain that are PII and must never appear in logs -->
<!-- Example: Emirates ID, passport number, salary, account number, date of birth -->

## Input Validation
- Validate all input server-side.
- Reject invalid input early with meaningful error codes.
- Validate type, length, format, and range for every field.

## Authentication and Authorization
<!-- TODO: List your JWT roles and per-role data access rules -->
<!-- Example: Role A can only see their own records; Role B can see all records in state X -->
- Check authorization on EVERY request at the service layer, not just the controller.
- Throw `AccessDeniedException` (HTTP 403) — never return another user's data silently.

## Transport Security
- HTTPS for all external requests.
- Never disable TLS certificate verification.

## OWASP Top 10 — Apply as Baseline
- Broken Access Control: enforce persona/role isolation rules
- Injection: parameterized queries always (JPA handles this)
- Security Misconfiguration: no stack traces in production API responses
- Cryptographic Failures: never MD5/SHA-1 for passwords; use bcrypt/Argon2
