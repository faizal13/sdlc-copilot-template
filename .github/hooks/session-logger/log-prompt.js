#!/usr/bin/env node
// log-prompt.js — Fired by VS Code on every userPromptSubmitted event
//
// VS Code sends a JSON payload on stdin:
//   { timestamp, sessionId, hookEventName, cwd, transcript_path, prompt }
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
  const sessionId  = payload.sessionId  || '';
  const promptText = payload.prompt     || payload.userMessage || '';

  // ── Extract @agent-name from prompt (e.g. "@task-planner STORY-456") ────────
  const agentMatch = promptText.match(/@([a-zA-Z][a-zA-Z0-9_-]*)/);
  const agent      = agentMatch ? agentMatch[0] : '(direct)';

  // ── Truncate prompt to 500 chars — full text lives in the transcript ─────────
  const prompt = promptText.slice(0, 500);

  // ── Ensure log directory exists ─────────────────────────────────────────────
  const logDir  = path.join(process.cwd(), 'logs', 'copilot');
  const logFile = path.join(logDir, 'prompts.log');
  fs.mkdirSync(logDir, { recursive: true });

  // ── Append one JSON line ────────────────────────────────────────────────────
  const entry = JSON.stringify({ timestamp, sessionId, agent, prompt });
  fs.appendFileSync(logFile, entry + '\n', 'utf8');

  process.exit(0);
});
