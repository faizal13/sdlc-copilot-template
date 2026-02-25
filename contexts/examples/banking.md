# Banking Domain Context — Mortgage IPA

Load this file at the start of any Copilot Chat session for this project.

## Domain
UAE retail banking — mortgage In-Principle Approval (IPA).
Regulated by UAE Central Bank. All eligibility rules must be traceable to a policy document.

## Key Terminology
- **IPA** — In-Principle Approval. Conditional bank commitment before full mortgage application.
- **DBR** — Debt Burden Ratio. Monthly debt obligations / monthly income. Regulator hard cap.
- **LTV** — Loan to Value. Loan amount / property value.
- **EMI** — Equated Monthly Installment.
- **Off-plan** — Property not yet built. Different LTV rules apply vs ready property.
- **Referred** — Application that cannot be auto-decided and needs human review.
- **RM** — Relationship Manager. First level human reviewer.
- **Underwriter** — Final bank decision authority.

## User Personas (summary)
Full definitions in `docs/solution-design/user-personas.md`
- **CUSTOMER** — self-service, sees own applications only
- **BROKER** — submits on behalf of customers, sees own submissions only
- **RM** — internal bank reviewer, sees cases assigned to them
- **UNDERWRITER** — internal approver, sees all cases in review stage

## Critical Rules for Code Generation
- Never `double` or `float` for financial calculations — always `BigDecimal`
- DBR, LTV, EMI calculations must be in isolated, independently testable utility classes
- Every business rule in code must have a comment: `// Rule: [rule name] - business-rules.md`
- Regulatory thresholds must never be hardcoded — always externalized to Spring config
- PII fields (Emirates ID, passport, salary) must never appear in application logs
