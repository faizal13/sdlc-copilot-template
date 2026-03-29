# Copilot Watchdog -- Teams Notifications

A VS Code extension that monitors GitHub Copilot agent sessions and sends Microsoft Teams notifications when attention is needed.

## Problems It Solves

1. **Unnoticed completions** -- Copilot agent finishes a task while you are in another window or on a break. Without monitoring, the session sits idle and you lose time.

2. **Silent errors** -- Rate limits (429), server errors (500/503), connection failures (ECONNREFUSED/ETIMEDOUT), and other transient errors stall the agent. You only find out when you check back manually.

3. **Permission prompts left hanging** -- The agent requests permission to run a command or access a resource and waits indefinitely for your approval. Watchdog detects the inactivity and pings you.

## Installation

### Option A: Run from workspace (recommended for development)

1. Copy the `copilot-watchdog` folder into your workspace under `.github/extensions/`.
2. Open VS Code, press `F5` to launch an Extension Development Host.
3. The extension activates automatically on startup.

### Option B: Package and install

```bash
cd .github/extensions/copilot-watchdog
npx @vscode/vsce package
code --install-extension copilot-watchdog-0.1.0.vsix
```

### Option C: Symlink into VS Code extensions directory

```bash
ln -s "$(pwd)/.github/extensions/copilot-watchdog" \
  ~/.vscode/extensions/rakbank-sdlc.copilot-watchdog-0.1.0
```

Restart VS Code after symlinking.

## Configuration

Open **Settings** and search for `copilotWatchdog`.

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `copilotWatchdog.enabled` | boolean | `true` | Enable or disable all monitoring |
| `copilotWatchdog.idleTimeoutMinutes` | number | `2` | Minutes of inactivity before firing a notification |
| `copilotWatchdog.teamsNotifications` | boolean | `true` | Send Teams webhook notifications via `notify-teams.js` |
| `copilotWatchdog.desktopNotifications` | boolean | `true` | Show VS Code desktop warning notifications |

### Teams Webhook Setup

The extension delegates Teams delivery to `.github/hooks/notify-teams.js`. That script reads `TEAMS_WEBHOOK_URL` from a `.env` file in the workspace root. See the hook's own README for details.

If `notify-teams.js` is not present, Teams notifications are silently skipped and only VS Code desktop notifications are shown.

## How It Works

```
+------------------+       +-----------------+       +------------------+
|  Log File Watcher|       | Output Scanner  |       |  Status Bar Item |
|                  |       | (30s interval)  |       |                  |
|  session.log     |       | Scans output:// |       |  $(eye) Watchdog |
|  prompts.log     |       | for error       |       |  click to toggle |
+--------+---------+       | patterns        |       +--------+---------+
         |                 +--------+--------+                |
         |  activity detected       |  error detected         |
         v                          v                         |
   +-----+------+           +------+-------+                  |
   | Reset Idle |           | Immediate    |                  |
   | Timer      |           | Notification |                  |
   +-----+------+           | (debounced)  |                  |
         |                  +------+-------+                  |
         | timer fires             |                          |
         v                         v                          |
   +-----+---------+     +--------+--------+                  |
   | Idle Detected  +---->  Teams Webhook  |                  |
   | Notification   |     | notify-teams.js|                  |
   +----------------+     +--------+--------+                 |
                                   |                          |
                                   v                          v
                          +--------+--------+     +-----------+---+
                          | MS Teams Channel|     | VS Code       |
                          +-----------------+     | Notification  |
                                                  +---------------+
```

### Lifecycle

1. Extension activates on VS Code startup (`onStartupFinished`).
2. Creates file system watchers for Copilot log files.
3. Starts a 30-second interval scanner for output channel errors.
4. On any log file change, resets the idle timer.
5. When the idle timer fires (default 2 minutes), marks session as idle and notifies.
6. When an error pattern is detected in output channels, notifies immediately (debounced to 5-minute window per error).
7. On deactivation, all timers, watchers, and status bar items are disposed.

## Commands

Open the Command Palette (`Cmd+Shift+P` / `Ctrl+Shift+P`) and search for:

- **Copilot Watchdog: Enable** -- Start monitoring
- **Copilot Watchdog: Disable** -- Stop monitoring and clear all timers
- **Copilot Watchdog: Show Status** -- Display current state, session info, and last activity time

## Troubleshooting

### Notifications not appearing

- Verify `copilotWatchdog.enabled` is `true` in settings.
- Verify `copilotWatchdog.desktopNotifications` is `true`.
- Check the **Copilot Watchdog** output channel (View > Output > select "Copilot Watchdog") for diagnostic logs.

### Teams notifications not sending

- Confirm `.github/hooks/notify-teams.js` exists in the workspace.
- Confirm `TEAMS_WEBHOOK_URL` is set in your `.env` file.
- Check that `copilotWatchdog.teamsNotifications` is `true`.
- Look for errors in the **Copilot Watchdog** output channel.

### False idle alerts

- Increase `copilotWatchdog.idleTimeoutMinutes` to a higher value (e.g., 5).
- The timer only resets on log file changes. If Copilot is active but not writing to the monitored log files, the watchdog may fire prematurely.

### Extension does not activate

- Ensure `engines.vscode` in `package.json` matches your VS Code version.
- Check the Extension Host log (Help > Toggle Developer Tools > Console) for activation errors.

### Error scanner not detecting errors

- The scanner only inspects open documents with a `output:` URI scheme.
- Errors are debounced to once per 5 minutes per pattern to avoid notification spam.

## Zero Dependencies

This extension uses only Node.js built-in modules (`fs`, `path`, `child_process`) and the VS Code API. No `node_modules` directory is needed.
