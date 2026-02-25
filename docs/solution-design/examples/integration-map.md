# Integration Map — Mortgage IPA
> Status: WIP — Update as each integration is confirmed
> Agents must check this file before generating integration code.
> Do not write integration code for systems marked TBD without confirming the contract first.

| System | Type | Direction | Status | Notes |
|--------|------|-----------|--------|-------|
| External Rule Engine | REST API | Outbound | TBD | Eligibility evaluation — contract pending |
| Middleware / ESB | TBD | TBD | WIP | Details being gathered |
| Notification Gateway | TBD | Outbound | TBD | Email/SMS delivery |
| Document Storage | TBD | Outbound | TBD | Document upload and retrieval |
| Core Banking System | TBD | Outbound | TBD | Customer data, existing liabilities |
| Credit Bureau | TBD | Outbound | TBD | Credit history and existing loans |
| ADO (Azure DevOps) | MCP | Inbound | ✅ Configured | Story reading for agents |

## How to Update This File
When an integration is confirmed, update the row with:
- Exact protocol and API style (REST, SOAP, MQ, etc.)
- Authentication method
- Timeout and circuit breaker requirements
- Fallback behaviour if system is unavailable
- Link to the API contract or WSDL
