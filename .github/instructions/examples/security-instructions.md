# Security Instructions — Mortgage IPA Platform
# Base: everything-copilot security standards
# Extended: UAE banking, PII, JWT persona rules

## Secrets and Credentials
- Never hardcode secrets, tokens, API keys, passwords, or connection strings.
- Load secrets from environment variables or GitHub Secrets.
- Never log, print, or include secrets in error messages.
- Add secret file patterns to `.gitignore` (`.env`, `*.pem`, `*.key`).

## PII Protection — Banking Hard Rule
The following fields are PII and must **never** appear in any log, trace, or error message:
- Emirates ID / National ID number
- Passport number
- Monthly salary / income
- Account number
- Date of birth (in combination with name)

Mask PII in logs: `salary: [REDACTED]`, `emiratesId: ***-****-*******-*`

## Input Validation
- Validate all input server-side. Client-side validation is UX only.
- Reject invalid input early with meaningful error codes.
- Validate type, length, format, and range for every field.
- Monetary fields: validate positive value, max scale 2 decimal places.

## Authentication and Authorization — Persona Rules
JWT roles in this system: `CUSTOMER`, `BROKER`, `RM`, `UNDERWRITER`, `ADMIN`

**Check authorization on EVERY request at the service layer, not just the controller.**

Persona access rules — enforce strictly:
- `CUSTOMER`: read/write own applications only. Block access to any other customer's data.
- `BROKER`: read/write applications they submitted. Block access to other brokers' data.
- `RM`: read applications in their queue. Can add internal notes. Cannot see Underwriter-only data.
- `UNDERWRITER`: read all applications in review state. Full access including RM notes.

Use `@PreAuthorize` at controller level for coarse role check.
Re-validate ownership at service level — never trust the token alone for data scoping.

Throw `AccessDeniedException` (HTTP 403) — never return another user's data silently.

## Transport Security
- HTTPS for all external requests.
- Validate TLS certificates — never disable certificate verification.
- Set secure cookie flags: `Secure`, `HttpOnly`, `SameSite=Strict`.

## Data Protection
- Encrypt sensitive data at rest (salary, Emirates ID, passport).
- Apply data minimization — do not store more than necessary.
- Use separate database credentials per service.
- Integration calls to external systems (rule engine, core banking) must use service accounts, not user credentials.

## External Integration Security
- All outbound calls to external systems must have:
  - Configurable timeout (never block indefinitely)
  - Circuit breaker (fail fast when downstream is unavailable)
  - Retry with backoff (for transient failures only)
- Never forward JWT tokens to downstream internal services — use service-to-service auth.

## Logging Security Events
Log these events with user ID and timestamp (no PII):
- Login / logout
- Application status changes
- Unauthorized access attempts (403s)
- Rule engine calls (request summary, not full payload)
- RM/Underwriter task completions

## OWASP Top 10 — Apply as Baseline
1. Broken Access Control — persona isolation rules above
2. Cryptographic Failures — encrypt PII at rest
3. Injection — parameterized queries always (JPA handles this)
4. Insecure Design — state machine validation
5. Security Misconfiguration — no defaults, no stack traces in prod responses
6. Vulnerable Components — dependency scanning in CI
7. Auth Failures — JWT validation on every request
8. Data Integrity Failures — Flowable process integrity
9. Logging Failures — structured logging, security event audit trail
10. SSRF — validate all outbound URLs from config, not user input
