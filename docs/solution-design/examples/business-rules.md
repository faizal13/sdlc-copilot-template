# Business Rules — Mortgage IPA
> Status: DRAFT — Update TBD items as business confirms values
> This is the source of truth for all eligibility and policy rules.
> Agents reference this file when generating eligibility-related code.
> All thresholds must be externalized to Spring config — never hardcoded.

## Affordability Rules
- DBR cap salaried: **50%** (UAE Central Bank regulation)
- DBR cap self-employed: **35%** (UAE Central Bank regulation)
- Minimum net monthly salary: **TBD** — confirm with business
- Existing liabilities must be included in DBR calculation

## Property Rules
- LTV for ready property: **TBD** — confirm with business
- LTV for off-plan property: **TBD** — confirm with business
- Developer approval status check: **mandatory** before eligibility decision
- Property type drives document checklist selection

## Applicant Rules
- Employer blacklist check: **mandatory** — reject if blacklisted
- Employer whitelist (preferred employers): affects auto-approval threshold
- Nationality eligibility: **TBD** — rules being finalized
- Minimum applicant age: **21 years**
- Maximum age at loan end: **65** (salaried), **70** (self-employed)

## IPA Validity
- Approved IPA valid for: **90 days** from approval date
- Expiry warning notification: day **75**
- Expiry notification: day **90** — status changes to EXPIRED

## Auto-Decision Thresholds
- DBR within cap + employer whitelisted + no adverse flag → **AUTO APPROVE**
- DBR exceeds cap OR employer blacklisted → **AUTO REJECT**
- All other cases → **REFER** to RM

## Rule Engine
- Primary: External rule engine via REST API (contract TBD)
- Fallback: Internal Drools microservice — TBD if required
- Timeout on external rule engine call: configurable, default 5 seconds
