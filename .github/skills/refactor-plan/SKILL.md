---
name: refactor-plan
description: 'Plan a multi-file Java/Spring Boot refactor with proper sequencing and rollback steps. Use when renaming classes, extracting services, changing exception hierarchy, migrating patterns, or restructuring packages across a microservice.'
argument-hint: '<describe the refactor — e.g. extract middleware base class, rename DownStreamException hierarchy>'
---

# Refactor Plan

Create a detailed plan for this Java/Spring Boot refactoring task.

## Refactor Goal

{{refactor_description}}

## Instructions

1. Search the codebase to understand current state — read affected Java classes, interfaces, and tests
2. Identify all affected files: entities, services, controllers, repositories, DTOs, tests, Liquibase migrations
3. Plan changes in a safe sequence (interfaces/base classes first, then implementations, then tests)
4. Include `mvn clean verify` verification steps between phases
5. Consider rollback if something fails

## Output Format

```markdown
## Refactor Plan: [title]

### Current State
[Brief description of how things work now]

### Target State
[Brief description of how things will work after]

### Affected Files
| File | Change Type | Dependencies |
|------|-------------|--------------|
| src/main/java/.../ServiceImpl.java | modify | blocks controller update |
| src/test/java/.../ServiceImplTest.java | modify | blocked by service change |

### Execution Plan

#### Phase 1: Interfaces and Base Classes
- [ ] Step 1.1: [action] in `src/main/java/.../*.java`
- [ ] Verify: `mvn compile` — zero errors

#### Phase 2: Implementations
- [ ] Step 2.1: [action] in `src/main/java/.../*.java`
- [ ] Verify: `mvn compile` — zero errors

#### Phase 3: Tests
- [ ] Step 3.1: Update tests in `src/test/java/.../*Test.java`
- [ ] Verify: `mvn test` — zero failures

#### Phase 4: Cleanup
- [ ] Remove deprecated classes/imports
- [ ] Update Javadoc
- [ ] Verify: `mvn clean verify` — zero failures

### Rollback Plan
If something fails:
1. `git stash` to revert uncommitted changes
2. [specific rollback step]

### Risks
- [Potential issue and mitigation — e.g. circular dependency, Liquibase migration conflict]
```

Shall I proceed with Phase 1?
