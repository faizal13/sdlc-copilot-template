---
applyTo: '**'
---

## MCP Tool Usage Guide

### Available MCP Servers

#### Azure DevOps MCP (`microsoft/azure-devops-mcp`)
Use for reading/writing ADO work items.

**Available operations:**
- Read work item by ID — returns title, description, state, acceptance criteria, tags
- Update work item fields — update state, add comments
- Query work items — WIQL queries

**Rules:**
- Read specific fields, not entire work item trees
- Limit comment retrieval to last 10 (avoid context overflow)
- If MCP call fails: retry ONCE, then report error
- If authentication fails: STOP and report "Check ADO PAT token"

#### GitHub MCP (`github`)
Use for managing issues, PRs, and repository content.

**Available operations:**
- Create/read/update issues
- Create/read/update pull requests
- Read repository files and directories
- Post comments on issues and PRs

**Rules:**
- Create ONE issue per invocation (unless cross-service decomposition)
- Always add labels when creating issues: `ai-generated` + service name + release branch
- When reading files, specify exact paths — do not list entire repositories
- If MCP call fails: retry ONCE, then report error

### General MCP Rules
- MAX 3 MCP tool calls of the same type per agent session
- Do NOT invent parameters that aren't documented above
- Do NOT chain MCP calls speculatively ("let me also check..." — only call what's needed)
- If tool returns unexpected format: report it, do NOT parse creatively
- All MCP operations are logged — do not call tools unnecessarily
