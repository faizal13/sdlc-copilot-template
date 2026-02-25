# Flowable BPMN Context

Load this file when working on workflow-service or any BPMN-related task.

## Flowable Version
Flowable 6.x open source, embedded in Spring Boot as a Maven dependency.

## Key Concepts for This Project
- **Process Definition** — the BPMN XML file deployed to the Flowable engine on startup
- **Process Instance** — one running IPA application journey (1 instance per IPA application)
- **User Task** — a step requiring human action. Assigned via candidate groups.
- **Service Task** — automated step. Uses Spring bean delegation: `${beanName.method(execution)}`
- **Candidate Group** — maps directly to JWT roles: `rm-group`, `underwriter-group`
- **Boundary Timer Event** — used for 90-day IPA expiry and 75-day expiry warning

## Conventions for This Project
- All process definitions live in `src/main/resources/processes/`
- Process keys follow pattern: `ipa-{name}-process`
- Every process must have an entry in `docs/solution-design/bpmn-processes.md` before coding
- User task candidate groups must exactly match JWT role names
- All timer durations come from Spring config — never hardcoded in BPMN XML
- Timer config key: `flowable.timers.ipa-expiry-days` (default 90)

## Required Boundary Events on Every IPA Process
- Timer boundary on main flow: 90 days → mark EXPIRED → notify → end
- Intermediate catch event at 75 days → send expiry warning notification

## Testing Flowable Processes
- Use `@FlowableTest` annotation for process unit tests
- Always test all gateway branches: auto-approve, auto-reject, refer to RM, escalate to underwriter
- Always test timer expiry path
- Use in-memory H2 for Flowable test DB — never connect to real DB in unit tests
