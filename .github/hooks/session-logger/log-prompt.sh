#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
#  log-prompt.sh — Fired by VS Code on every userPromptSubmitted event
#
#  VS Code sends a JSON payload on stdin with these fields:
#    {
#      "timestamp":      "2026-03-12T10:30:00.000Z",
#      "sessionId":      "abc-123",
#      "hookEventName":  "UserPromptSubmit",
#      "cwd":            "/path/to/workspace",
#      "transcript_path":"/path/to/transcript.json",
#      "prompt":         "@task-planner STORY-456 implement the login API"
#    }
#
#  Output written to: logs/copilot/prompts.log  (one JSON line per prompt)
#  Format:
#    {"timestamp":"...","sessionId":"...","agent":"@task-planner","prompt":"..."}
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

# Skip if logging disabled
if [[ "${SKIP_LOGGING:-}" == "true" ]]; then
  exit 0
fi

# ── Read payload from VS Code ─────────────────────────────────────────────────
INPUT=$(cat)

# ── Extract fields from the JSON payload ─────────────────────────────────────
TIMESTAMP=$(echo "$INPUT"   | jq -r '.timestamp // empty')
SESSION_ID=$(echo "$INPUT"  | jq -r '.sessionId // empty')
PROMPT_TEXT=$(echo "$INPUT" | jq -r '.prompt // .userMessage // empty')

# Use current time as fallback if payload didn't include timestamp
TIMESTAMP=${TIMESTAMP:-$(date -u +"%Y-%m-%dT%H:%M:%SZ")}

# ── Extract @agent-name from prompt (e.g. "@task-planner STORY-456") ─────────
AGENT=$(echo "$PROMPT_TEXT" | grep -oE '@[a-zA-Z][a-zA-Z0-9_-]*' | head -1 || true)
AGENT=${AGENT:-"(direct)"}

# ── Sanitise prompt for logging ───────────────────────────────────────────────
# Truncate to 500 chars to keep log readable; full text is in the transcript
PROMPT_SHORT=$(echo "$PROMPT_TEXT" | head -c 500)

# ── Ensure log directory exists ───────────────────────────────────────────────
mkdir -p logs/copilot

# ── Append one JSON line to prompts.log ──────────────────────────────────────
# Using jq -cn ensures all fields are correctly JSON-escaped
# (handles quotes, newlines, special chars in prompt text)
jq -cn \
  --arg timestamp  "$TIMESTAMP" \
  --arg sessionId  "$SESSION_ID" \
  --arg agent      "$AGENT" \
  --arg prompt     "$PROMPT_SHORT" \
  '{
    timestamp: $timestamp,
    sessionId: $sessionId,
    agent:     $agent,
    prompt:    $prompt
  }' >> logs/copilot/prompts.log

exit 0
