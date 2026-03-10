# Agent Evaluation Framework

This directory contains the evaluation system for measuring and improving agent quality across sprints.

## Why Evaluate?

Anthropic's guidance: *"Good evaluations are essential for building reliable AI applications."*
Without evals, you cannot know if Sprint 4 agents are better than Sprint 1 agents.

## Structure

```
evals/
├── README.md                          ← You are here
├── scoring-rubric.md                  ← Universal scoring dimensions
├── sprint-tracker.md                  ← Sprint-over-sprint comparison
└── golden-references/
    ├── story-analyzer-eval.md         ← Golden input/output pairs
    ├── task-planner-eval.md
    ├── local-reviewer-eval.md
    └── story-refiner-eval.md
```

## How It Works

### 1. Golden References
Each agent has 3 reference pairs: a known INPUT and the EXPECTED output.
These are not exact-match tests — they define what a **good** output looks like.

### 2. Scoring Rubric
The `@eval-runner` agent scores actual output against golden references on 4 dimensions:
- **Completeness** (0.0–1.0): Did the agent cover all required sections?
- **Precision** (0.0–1.0): Is the output specific and actionable (not vague)?
- **Standards Compliance** (0.0–1.0): Does it follow banking/coding/security rules?
- **Actionability** (0.0–1.0): Can the downstream agent act on this without clarification?

### 3. Sprint Tracker
After each sprint, run `@eval-runner` on 3-5 stories from that sprint.
Record scores in `sprint-tracker.md`. Compare sprint-over-sprint.

## How to Run Evals

### Option A — Run @eval-runner on a specific agent output
```
@eval-runner --agent story-analyzer --input "ADO-456" --actual "GitHub Issue #32"
```

### Option B — Run @eval-runner for full sprint evaluation
```
@eval-runner --sprint 3
```

### Option C — Manual evaluation
1. Pick 3 stories from the sprint
2. For each, compare actual agent output against the golden reference
3. Score each dimension 0.0–1.0 using the rubric
4. Record in sprint-tracker.md

## When to Update Golden References

- After a significant agent rewrite
- When new sections are added to agent output templates
- When business domain changes (new entities, new personas)
- At minimum: review every 3 sprints

## Who Maintains This

The tech lead or AI architect reviews eval results at sprint retrospective.
If any agent scores below 0.7 on any dimension for 2 consecutive sprints — the agent definition needs revision.
