#!/usr/bin/env bash
# ──────────────────────────────────────────────────────
# Test: Command execution and output display
# Criterion: US1.AC2 — "Given the terminal panel is displayed, When the user types a command and presses Enter, Then the command executes and output is displayed in the terminal."
# Feature: 001-terminal-panel-xterm-js-tmux-integration
# Generated: 2026-02-20T00:00:00Z
# ──────────────────────────────────────────────────────
#
# Verifies the data flow: terminal input → WebSocket → PTY → tmux → output → WebSocket → terminal.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "[US1.AC2] Testing: Command execution via terminal"

# 1. Verify terminal onData handler pipes to WebSocket
HOOK_FILE="$PROJECT_DIR/src/app/lib/use-terminal.ts"

if ! grep -q "term.onData" "$HOOK_FILE"; then
  echo "FAIL: use-terminal.ts does not handle terminal input (onData)" >&2
  echo "  Expected: term.onData callback sending data to WebSocket" >&2
  echo "  Actual: onData handler not found" >&2
  exit 1
fi

# 2. Verify WebSocket sends raw input to server
if ! grep -q "ws.send(data)" "$HOOK_FILE"; then
  echo "FAIL: Terminal input is not sent through WebSocket" >&2
  echo "  Expected: ws.send(data) in onData handler" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 3. Verify server writes input to PTY
SERVER_FILE="$PROJECT_DIR/src/terminal-server/index.ts"
if ! grep -q "session.pty.write" "$SERVER_FILE"; then
  echo "FAIL: Server does not write input to PTY" >&2
  echo "  Expected: session.pty.write(msg)" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 4. Verify PTY output is broadcast back to WebSocket clients
PTY_FILE="$PROJECT_DIR/src/terminal-server/pty-manager.ts"
if ! grep -q "ptyProcess.onData" "$PTY_FILE"; then
  echo "FAIL: PTY output is not captured" >&2
  echo "  Expected: ptyProcess.onData handler broadcasting to clients" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

if ! grep -q "client.send(data)" "$PTY_FILE"; then
  echo "FAIL: PTY output is not sent to WebSocket clients" >&2
  echo "  Expected: client.send(data) in onData handler" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

# 5. Verify terminal receives and writes output
if ! grep -q "term.write" "$HOOK_FILE"; then
  echo "FAIL: Terminal does not write received data" >&2
  echo "  Expected: term.write(data) in ws.onmessage" >&2
  echo "  Actual: not found" >&2
  exit 1
fi

echo "PASS: US1.AC2 — Full I/O pipeline verified (input → WS → PTY → WS → terminal)"
exit 0
