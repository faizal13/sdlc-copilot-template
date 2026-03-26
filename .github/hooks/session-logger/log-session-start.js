#!/usr/bin/env node
// log-session-start.js — Fired by VS Code when a new Copilot session starts
//
// VS Code sends a JSON payload on stdin. Field names vary across builds:
//   { timestamp, sessionId|session_id, hookEventName, cwd, transcript_path, source }
//
// Writes one JSON line to: logs/copilot/session.log

'use strict';

const fs   = require('fs');
const path = require('path');

// ── Resolve a field from multiple possible key names ────────────────────────
function resolve(payload, ...keys) {
  for (const k of keys) {
    if (payload[k] !== undefined && payload[k] !== null && payload[k] !== '') return payload[k];
  }
  return '';
}

// ── Read stdin payload ────────────────────────────────────────────────────────
let raw = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => { raw += chunk; });
process.stdin.on('end', () => {
  if (process.env.SKIP_LOGGING === 'true') process.exit(0);

  let payload = {};
  try { payload = JSON.parse(raw); } catch (_) { /* ignore malformed payload */ }

  const timestamp = payload.timestamp || new Date().toISOString();
  const sessionId = resolve(payload, 'sessionId', 'session_id', 'id');
  const cwd       = payload.cwd || process.cwd();

  // ── Ensure log directory exists ─────────────────────────────────────────────
  const logDir  = path.join(process.cwd(), 'logs', 'copilot');
  const logFile = path.join(logDir, 'session.log');
  fs.mkdirSync(logDir, { recursive: true });

  // ── Append one JSON line ────────────────────────────────────────────────────
  const entry = JSON.stringify({ timestamp, event: 'sessionStart', sessionId, cwd });
  fs.appendFileSync(logFile, entry + '\n', 'utf8');

  process.exit(0);
});
