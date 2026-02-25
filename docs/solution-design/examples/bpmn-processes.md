# BPMN Process Definitions — Mortgage IPA
> Status: DRAFT

## Main Process: IPA Application Lifecycle
**Process Key:** `ipa-application-process`
**File:** `workflow-service/src/main/resources/processes/ipa-application-process.bpmn20.xml`

### Swimlanes
- **System** — automated service tasks
- **Customer / Broker** — initiator lane (start event only)
- **RM** — review and decision user tasks
- **Underwriter** — final approval user tasks

### Process Flow
```
Start Event: Application Submitted
  → Service Task: Validate Application Data
  → Service Task: Call External Rule Engine
  → Exclusive Gateway: Eligibility Decision
      [AUTO_APPROVE] → Service Task: Generate IPA Letter
                     → Service Task: Send Approval Notification
                     → End Event: APPROVED

      [AUTO_REJECT]  → Service Task: Send Rejection Notification
                     → End Event: REJECTED

      [REFER]        → User Task: RM Review [candidate group: rm-group]
                     → Exclusive Gateway: RM Decision
                         [APPROVE]   → Service Task: Generate IPA Letter → End: APPROVED
                         [REJECT]    → Service Task: Send Rejection Notification → End: REJECTED
                         [ESCALATE]  → User Task: Underwriter Decision [candidate group: underwriter-group]
                                     → Exclusive Gateway: Underwriter Decision
                                         [APPROVE] → Service Task: Generate IPA Letter → End: APPROVED
                                         [REJECT]  → End: REJECTED

Boundary Timer Events:
  - 75 days (non-interrupting): Service Task: Send Expiry Warning Notification
  - 90 days (interrupting): Service Task: Mark Status EXPIRED → End: EXPIRED
```

### Configuration
All timer durations from Spring config:
- `flowable.timers.ipa-expiry-warning-days` = 75
- `flowable.timers.ipa-expiry-days` = 90

## Process Inventory

| Process | Key | File | Status |
|---------|-----|------|--------|
| IPA Lifecycle | `ipa-application-process` | `ipa-application-process.bpmn20.xml` | TODO |
| Document Collection | `ipa-document-process` | `ipa-document-process.bpmn20.xml` | TODO |
