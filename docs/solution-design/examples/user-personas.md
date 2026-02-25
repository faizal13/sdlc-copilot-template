# User Personas — Mortgage IPA
> Status: DRAFT

## 1. Customer
- Self-service applicant via portal or mobile app
- Can only see their own applications — no access to other customer data
- Cannot see broker submissions, RM notes, or internal comments
- Receives status change notifications
- JWT Role: `CUSTOMER`

## 2. External Broker
- Submits applications on behalf of customers
- Can see only applications they submitted — not other brokers' submissions
- Cannot see RM/Underwriter notes or any internal bank data
- Receives notifications on application status changes
- JWT Role: `BROKER`

## 3. RM (Relationship Manager)
- Internal bank staff
- Receives referred applications in Flowable user task inbox
- Can view full application including document checklist
- Can add internal notes (not visible to customer or broker)
- Can approve, reject, or escalate to Underwriter
- JWT Role: `RM`

## 4. Underwriter
- Internal bank staff — final approval authority
- Receives escalated cases from RM in Flowable user task inbox
- Has access to full application, documents, and RM notes
- Can approve or reject — decision is final
- JWT Role: `UNDERWRITER`

## Data Isolation — Hard Rules
| Data | CUSTOMER | BROKER | RM | UNDERWRITER |
|------|----------|--------|----|-------------|
| Own application data | ✅ | ✅ (submitted by them) | ✅ | ✅ |
| Other customer applications | ❌ | ❌ | ✅ (assigned) | ✅ |
| Internal RM notes | ❌ | ❌ | ✅ | ✅ |
| Broker identity | ❌ | ✅ (own) | ✅ | ✅ |
| Underwriter decision notes | ❌ | ❌ | ✅ | ✅ |

These rules must be enforced at the service layer — not just the API layer.
