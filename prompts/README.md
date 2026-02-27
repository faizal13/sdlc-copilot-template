# Prompts

This folder holds **project-specific prompt files** — reusable prompt templates that teams invoke manually via Copilot Chat.

> **Agents vs Prompts:** Autonomous multi-step agents live in `.github/copilot/agents/`.
> This folder is for one-shot or guided prompts that require human-in-the-loop interaction.

## Examples

The `examples/` subfolder contains reference implementations from a banking domain (Mortgage IPA).
Copy and adapt them for your project's domain.

| Example File | Purpose |
|---|---|
| `application-service.md` | Prompt for generating a Spring Boot service layer |
| `story-analyzer.md` | Original story analyzer (now an agent in `.github/copilot/agents/`) |
| `coding-agent-bootstrap.md` | Original rakbank backend dev agent (now an agent in `.github/copilot/agents/`) |
| `instinct-extractor.md` | Original instinct extractor (now an agent in `.github/copilot/agents/`) |

## Adding Your Own Prompts

Create `.md` files in this folder for any reusable prompt your team uses frequently, e.g.:
- `api-design.md` — prompt for designing REST API contracts
- `code-review.md` — prompt for structured code review feedback
- `migration-script.md` — prompt for generating database migration scripts
