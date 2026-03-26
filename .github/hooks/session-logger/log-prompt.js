#!/usr/bin/env node
// log-prompt.js — Fired by VS Code on every userPromptSubmitted event
//
// VS Code sends a JSON payload on stdin. Known fields:
//   { timestamp, sessionId, hookEventName, cwd, transcript_path, prompt,
//     agentId, participantId, agent, participant, references, command }
//
// When the user selects an agent via the Copilot Chat UI picker, the agent
// name is NOT embedded in `prompt` — it arrives in a dedicated field.
// This script checks all known field locations before falling back to
// @mention parsing in the prompt text.
//
// Writes one JSON line to: logs/copilot/prompts.log

'use strict';

const fs   = require('fs');
const path = require('path');

// ── Read stdin payload ────────────────────────────────────────────────────────
let raw = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => { raw += chunk; });
process.stdin.on('end', () => {
  if (process.env.SKIP_LOGGING === 'true') process.exit(0);

  let payload = {};
  try { payload = JSON.parse(raw); } catch (_) { /* ignore malformed payload */ }

  const timestamp  = payload.timestamp  || new Date().toISOString();
  const sessionId  = payload.sessionId  || payload.session_id || payload.id || '';
  const promptText = payload.prompt     || payload.userMessage || '';

  // ── Resolve agent name — check all locations VS Code may send it ─────────────
  //
  // Priority order:
  //  1. Dedicated agent/participant fields (set when user picks from UI dropdown)
  //  2. @mention inside the prompt text (set when user types @agent-name manually)
  //  3. Slash command (e.g. /fix → treat as command)
  //  4. Fallback: '(direct)' — plain prompt with no agent context
  //
  const agentFromPayload =
    payload.agentId        ||   // VS Code internal agent ID
    payload.participantId  ||   // Chat participant ID (used in some VS Code builds)
    payload.agent          ||   // Some Copilot builds use this key
    payload.participant    ||   // Alternate key name
    (payload.references && payload.references.find &&
      payload.references.find(r => r.type === 'agent' || r.type === 'participant')?.name) ||
    null;

  // Normalise: strip leading '@' if present, add it back consistently
  const normalise = s => s ? '@' + s.replace(/^@/, '') : null;

  const agentFromMention = (() => {
    const m = promptText.match(/^@([a-zA-Z][a-zA-Z0-9_-]*)/);
    return m ? m[0] : null;
  })();

  const agentFromCommand = (() => {
    if (payload.command) return '/' + payload.command.replace(/^\//, '');
    const m = promptText.match(/^\/([a-zA-Z][a-zA-Z0-9_-]*)/);
    return m ? m[0] : null;
  })();

  const agent =
    normalise(agentFromPayload) ||
    agentFromMention            ||
    agentFromCommand            ||
    '(direct)';

  // ── Truncate prompt to 500 chars — full text lives in the transcript ─────────
  const prompt = promptText.slice(0, 500);

  // ── Ensure log directory exists ─────────────────────────────────────────────
  const logDir  = path.join(process.cwd(), 'logs', 'copilot');
  const logFile = path.join(logDir, 'prompts.log');
  fs.mkdirSync(logDir, { recursive: true });

  // ── Metrics: prompt size as proxy for input tokens (~4 chars ≈ 1 token) ─────
  const promptChars  = promptText.length;
  const estTokens    = Math.round(promptChars / 4);

  // ── Append one JSON line ─────────────────────────────────────────────────────
  const entry = JSON.stringify({ timestamp, sessionId, agent, prompt, promptChars, estTokens });
  fs.appendFileSync(logFile, entry + '\n', 'utf8');

  // ── Debug dump (one-shot, only if logs/copilot/debug-payload.json absent) ────
  // Uncomment the block below temporarily to capture the raw payload and
  // identify the exact field VS Code uses on your build. Delete after inspecting.
  //
  // const debugFile = path.join(logDir, 'debug-payload.json');
  // if (!fs.existsSync(debugFile)) {
  //   fs.writeFileSync(debugFile, JSON.stringify(payload, null, 2), 'utf8');
  // }

  process.exit(0);
});
